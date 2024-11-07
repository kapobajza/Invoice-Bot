import 'dart:async';
import 'dart:math' as math;

import 'package:query/src/query_observer.dart';

import 'query_options.dart';
import 'query_cache.dart';

enum QueryStatus {
  idle,
  pending,
  success,
  error,
}

enum FetchStatus { idle, fetching, paused }

class FetchOptions {
  final dynamic meta;
  final bool cancelRefetch;

  FetchOptions({this.meta, this.cancelRefetch = false});
}

typedef QueryKey = List<dynamic>;

class QueryState<T> {
  final T? data;
  final Object? error;
  final QueryStatus status;
  final DateTime? dataUpdatedAt;
  final bool isInvalidated;
  final FetchStatus fetchStatus;
  final dynamic fetchMeta;

  QueryState({
    this.data,
    this.error,
    this.status = QueryStatus.idle,
    this.isInvalidated = false,
    this.fetchStatus = FetchStatus.idle,
    this.dataUpdatedAt,
    this.fetchMeta,
  });

  QueryState<T> copyWith({
    T? data,
    Object? error,
    QueryStatus? status,
    DateTime? dataUpdatedAt,
    bool? isInvalidated,
    bool? isFetching,
    bool? isLoading,
    FetchStatus? fetchStatus,
    dynamic fetchMeta,
    int? fetchFailureCount,
  }) {
    return QueryState<T>(
      data: data ?? this.data,
      error: error ?? this.error,
      status: status ?? this.status,
      dataUpdatedAt: dataUpdatedAt ?? this.dataUpdatedAt,
      isInvalidated: isInvalidated ?? this.isInvalidated,
      fetchMeta: fetchMeta ?? this.fetchMeta,
      fetchStatus: fetchStatus ?? this.fetchStatus,
    );
  }
}

class Query<T> {
  final QueryOptions<T> options;
  final QueryCache cache;

  QueryState<T> _state = QueryState<T>();
  final List<QueryObserver<T>> _observers = [];
  Completer<T>? _currentFetch;
  Timer? _retryTimer;
  Timer? _gcTimer;

  Query({
    required this.options,
    required this.cache,
  });

  QueryState<T> get state => _state;

  Future<T> fetch({FetchOptions? fetchOptions}) async {
    if (state.fetchStatus != FetchStatus.idle) {
      if (state.data != null && fetchOptions?.cancelRefetch == true) {
        cancel(silent: true);
      } else if (_currentFetch != null) {
        return _currentFetch!.future;
      }
    }

    _currentFetch = Completer<T>();

    Future<T> fetchFn() async {
      final queryFnContext = QueryFunctionContext(
        queryKey: options.queryKey,
        meta: options.optionals?.meta,
      );

      try {
        if (options.optionals?.persister != null) {
          return await options.optionals!.persister!(
            options.queryFn,
            queryFnContext,
            this,
          );
        } else {
          return await options.queryFn();
        }
      } catch (error) {
        if (error is Exception) rethrow;
        throw Exception(error.toString());
      }
    }

    final context = FetchContext<T>(
      options: options,
      queryKey: options.queryKey,
      state: state,
      fetchFn: fetchFn,
    );

    if (options.optionals?.behavior?.onFetch != null) {
      options.optionals?.behavior?.onFetch!(context, this);
    }

    if (state.fetchStatus == FetchStatus.idle ||
        state.fetchMeta != fetchOptions?.meta) {
      _setState(_state.copyWith(
        fetchStatus: FetchStatus.fetching,
        fetchMeta: fetchOptions?.meta,
        status: _state.data == null ? QueryStatus.pending : _state.status,
        error: _state.data == null ? null : _state.error,
      ));
    }

    try {
      final data = await _retry(fetchFn);

      _setState(_state.copyWith(
        data: data,
        dataUpdatedAt: DateTime.now(),
        error: null,
        isInvalidated: false,
        status: QueryStatus.success,
        fetchStatus: FetchStatus.idle,
      ));
      _scheduleGC();

      _currentFetch?.complete(data);
      return data;
    } catch (error) {
      _setState(_state.copyWith(
        status: QueryStatus.error,
        error: error,
      ));
      _scheduleGC();
      rethrow;
    } finally {
      _currentFetch = null;
    }
  }

  Future<T> _retry(Future<T> Function() fn) async {
    final retry = DefaultQueryOptions.retryOrDefault(options.optionals?.retry);

    for (int attempt = 0; attempt <= retry; attempt++) {
      try {
        return await fn();
      } catch (error) {
        if (attempt == retry) rethrow;
        _setState(_state.copyWith(
          fetchStatus: FetchStatus.fetching,
          error: error,
        ));
        await Future.delayed(
          Duration(
            milliseconds: math
                .min(
                  1 * 1000 * math.pow(2, attempt),
                  DefaultQueryOptions.retryDelayOrDefault(
                    retryDelay: options.optionals?.retryDelay,
                  ),
                )
                .toInt(),
          ),
        );
      }
    }
    throw Exception('Retry failed');
  }

  void cancel({bool silent = false}) {
    _retryTimer?.cancel();

    if (!silent) {
      _setState(_state.copyWith(fetchStatus: FetchStatus.idle));
    }
  }

  void addObserver(QueryObserver<T> observer) {
    if (_observers.contains(observer)) {
      return;
    }

    _observers.add(observer);
    _clearGCTimer();
  }

  void removeObserver(QueryObserver<T> observer) {
    if (!_observers.contains(observer)) {
      return;
    }

    _observers.remove(observer);

    if (_observers.isNotEmpty) {
      cancel(silent: true);
      _scheduleGC();
    }
  }

  bool isStale() {
    if (_state.isInvalidated) {
      return true;
    }

    if (_observers.isNotEmpty) {
      return _observers.any((observer) => observer.isStale(this));
    }

    return _state.data == null;
  }

  bool isStaleByTime([Duration staleTime = Duration.zero]) {
    if (_state.isInvalidated || _state.data == null) {
      return true;
    }

    if (_state.dataUpdatedAt == null) {
      return false;
    }

    final now = DateTime.now();
    final expiresAt = _state.dataUpdatedAt!.add(staleTime);

    return expiresAt.isBefore(now);
  }

  void invalidate() {
    _setState(_state.copyWith(isInvalidated: true));
  }

  void destroy() {
    _clearGCTimer();
    cancel(silent: true);
  }

  void _notifyObservers() {
    for (final observer in _observers) {
      observer.onQueryUpdate(this);
    }
  }

  void _setState(QueryState<T> newState) {
    _state = newState;
    _notifyObservers();
  }

  void _scheduleGC() {
    _clearGCTimer();
    final gcTime =
        DefaultQueryOptions.gcTimeOrDefault(options.optionals?.gcTime);

    _gcTimer = Timer(gcTime, () {
      if (_observers.isEmpty && _state.fetchStatus == FetchStatus.idle) {
        cache.remove(options.queryKey);
      }
    });
  }

  void _clearGCTimer() {
    _gcTimer?.cancel();
    _gcTimer = null;
  }
}
