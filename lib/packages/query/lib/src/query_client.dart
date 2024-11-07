import 'package:query/query.dart';

class QueryClient {
  final _queryCache = QueryCache();

  QueryClient._internal();

  static final _instance = QueryClient._internal();

  factory QueryClient() {
    return _instance;
  }

  QueryCache get queryCache => _queryCache;

  Future<T?> fetchQuery<T>({required QueryOptions<T> options}) {
    final query = _queryCache.getOrCreate(
      options.queryKey,
      options.queryFn,
      options.optionals,
    );

    return query.isStaleByTime(
      DefaultQueryOptions.staleTimeOrDefault(
        options.optionals?.staleTime,
      ),
    )
        ? query.fetch()
        : Future.value(query.state.data);
  }

  Future<void> prefetchQuery<T>({required QueryOptions<T> options}) {
    return fetchQuery(options: options).then((data) {}).catchError((err) {});
  }

  Future<void> refetchQueries({required QueryFilters filters}) async {
    final futures = _queryCache.findAll(filters).map((query) {
      return query.state.fetchStatus == FetchStatus.paused
          ? Future.value()
          : query.fetch();
    }).toList();

    await Future.wait(futures);
  }

  Future<void> invalidateQueries({required QueryFilters filters}) async {
    _queryCache.findAll(filters).forEach((query) {
      query.invalidate();
    });

    await refetchQueries(filters: filters);
  }

  clear() {
    _queryCache.clear();
  }
}
