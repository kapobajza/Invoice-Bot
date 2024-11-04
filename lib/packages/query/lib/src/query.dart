import 'dart:async';

import 'package:query/src/query_observer.dart';

import 'query_options.dart';
import 'query_cache.dart';

enum QueryStatus {
  idle,
  loading,
  success,
  error,
}

typedef QueryKey = List<dynamic>;

class QueryState<T> {
  final T? data;
  final Object? error;
  final QueryStatus status;
  final DateTime? dataUpdatedAt;
  final bool isInvalidated;
  final bool isFetching;
  final bool isLoading;

  QueryState({
    this.data,
    this.error,
    this.status = QueryStatus.idle,
    this.isInvalidated = false,
    this.isFetching = false,
    this.isLoading = false,
    this.dataUpdatedAt,
  });

  QueryState<T> copyWith({
    T? data,
    Object? error,
    QueryStatus? status,
    DateTime? dataUpdatedAt,
    bool? isInvalidated,
    bool? isFetching,
    bool? isLoading,
  }) {
    return QueryState<T>(
      data: data ?? this.data,
      error: error ?? this.error,
      status: status ?? this.status,
      dataUpdatedAt: dataUpdatedAt ?? this.dataUpdatedAt,
      isInvalidated: isInvalidated ?? this.isInvalidated,
      isFetching: isFetching ?? this.isFetching,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class Query<T> {
  final QueryOptions<T> options;
  final QueryCache cache;

  QueryState<T> _state = QueryState<T>();
  final List<QueryObserver<T>> _observers = [];
  Future<void>? _currentFetch;
  Timer? _gcTimer;

  Query({
    required this.options,
    required this.cache,
  });

  QueryState<T> get state => _state;

  Future<void> fetch() async {
    if (_currentFetch != null) {
      return _currentFetch;
    }

    _setState(_state.copyWith(status: QueryStatus.loading, isFetching: true));

    _currentFetch = _fetchIfNeeded();

    try {
      await _currentFetch;
    } finally {
      _setState(_state.copyWith(isFetching: false, isLoading: false));
      _currentFetch = null;
      _scheduleGC();
    }
  }

  Future<void> _fetchIfNeeded() async {
    try {
      Query<T>? cachedQuery = cache.get(options.queryKey);

      if (cachedQuery != null && !isStale()) {
        return _setState(_state.copyWith(
          data: cachedQuery._state.data,
          status: QueryStatus.success,
          dataUpdatedAt: DateTime.now(),
        ));
      }

      _setState(_state.copyWith(isLoading: cachedQuery?.state.data == null));

      final data = await options.queryFn();

      _setState(_state.copyWith(
        data: data,
        status: QueryStatus.success,
        dataUpdatedAt: DateTime.now(),
        isInvalidated: false,
      ));
      cache.set(options.queryKey, this);
    } catch (error) {
      _setState(_state.copyWith(
        error: error,
        status: QueryStatus.error,
      ));
    }
  }

  void addObserver(QueryObserver<T> observer) {
    _observers.add(observer);
  }

  void removeObserver(QueryObserver<T> observer) {
    _observers.remove(observer);
  }

  bool isStale() {
    if (_state.isInvalidated) {
      return true;
    }

    if (_observers.isNotEmpty) {
      return _observers.any((observer) => observer.isStale());
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

  void _notifyObservers() {
    for (final observer in _observers) {
      observer.onQueryUpdated(this);
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

    if (gcTime > Duration.zero) {
      _gcTimer = Timer(gcTime, () {
        if (_observers.isEmpty && _state.status == QueryStatus.idle) {
          cache.remove(options.queryKey);
        }
      });
    }
  }

  void _clearGCTimer() {
    _gcTimer?.cancel();
    _gcTimer = null;
  }
}
