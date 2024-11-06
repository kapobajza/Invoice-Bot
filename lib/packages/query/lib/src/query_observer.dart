import 'dart:async';

import 'package:query/query.dart';

class QueryObserverResult<T> {
  final T? data;
  final Object? error;
  final QueryStatus status;
  final FetchStatus fetchStatus;

  bool get isFetching => fetchStatus == FetchStatus.fetching;

  bool get isSuccess => status == QueryStatus.success;

  bool get isError => status == QueryStatus.error;

  bool get isPending => status == QueryStatus.pending;

  bool get isLoading => isFetching && isPending;

  QueryObserverResult({
    required this.data,
    required this.error,
    required this.status,
    required this.fetchStatus,
  });
}

class QueryObserverOptions {
  final bool refetchOnMount;

  const QueryObserverOptions({
    this.refetchOnMount = true,
  });
}

class QueryObserver<T> {
  final QueryClient queryClient;
  final QueryOptions<T> queryOptions;
  final QueryObserverOptions? options;

  late Query<T> _currentQuery;
  late QueryObserverResult<T> _currentResult;
  late final _controller = StreamController<QueryObserverResult<T>>.broadcast(
    sync: true,
    onListen: _onListen,
    onCancel: _onCancel,
  );

  Stream<QueryObserverResult<T>> get stream => _controller.stream;
  QueryObserverResult<T> get currentResult => _currentResult;

  QueryObserver({
    required this.queryClient,
    required this.queryOptions,
    this.options = const QueryObserverOptions(),
  }) {
    final query = queryClient.queryCache.getOrCreate<T>(
      queryOptions.queryKey,
      queryOptions.queryFn,
      queryOptions.optionals,
    );
    _currentQuery = query;
    updateResult();
  }

  void dispose() {
    _currentQuery.removeObserver(this);
    _controller.close();
  }

  void onQueryUpdate(Query<T> updatedQuery) {
    if (!_controller.isClosed && _controller.hasListener) {
      updateResult();
      _controller.add(createResult(updatedQuery));
    }
  }

  QueryObserverResult<T> createResult(Query<T> query) {
    var newQueryState = query.state;

    if (_shouldFetchOnMount(query) ||
        _shouldFetchOptionally(query, _currentQuery)) {
      newQueryState = query.state.copyWith(
        fetchStatus: FetchStatus.fetching,
        status:
            query.state.data == null ? QueryStatus.pending : query.state.status,
        error: null,
      );
    }

    return QueryObserverResult<T>(
      data: newQueryState.data,
      error: newQueryState.error,
      status: newQueryState.status,
      fetchStatus: newQueryState.fetchStatus,
    );
  }

  isStale(Query<T> query) {
    return query.isStaleByTime(
      DefaultQueryOptions.staleTimeOrDefault(
        query.options.optionals?.staleTime,
      ),
    );
  }

  QueryObserverResult<T> getOptimisticResult() {
    final query = queryClient.queryCache.getOrCreate(
      queryOptions.queryKey,
      queryOptions.queryFn,
      queryOptions.optionals,
    );

    return createResult(query);
  }

  void updateResult() {
    _currentResult = createResult(_currentQuery);
  }

  void _onListen() {
    _currentQuery.addObserver(this);

    if (_shouldFetchOnMount(_currentQuery)) {
      _executeFetch();
    } else {
      updateResult();
    }
  }

  void _onCancel() {
    _currentQuery.removeObserver(this);
  }

  Future<T> _executeFetch() {
    _updateQuery();

    return _currentQuery.fetch();
  }

  void _updateQuery() {
    final query = queryClient.queryCache.getOrCreate(
      queryOptions.queryKey,
      queryOptions.queryFn,
      queryOptions.optionals,
    );

    if (_currentQuery == query) {
      return;
    }

    final prevQuery = _currentQuery;
    _currentQuery = query;

    if (_controller.hasListener) {
      prevQuery.removeObserver(this);
      query.addObserver(this);
    }
  }

  bool _shouldFetchOnMount(Query<T> query) {
    return query.state.data == null ||
        (options?.refetchOnMount != false && isStale(query));
  }

  bool _shouldFetchOptionally(Query<T> query, Query<T> prevQuery) {
    return query != prevQuery &&
        query.state.status != QueryStatus.error &&
        isStale(query);
  }
}
