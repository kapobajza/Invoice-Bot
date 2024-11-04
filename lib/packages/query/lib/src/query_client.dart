import 'package:query/query.dart';

class QueryClient {
  final _queryCache = QueryCache();

  QueryClient._internal();

  static final _instance = QueryClient._internal();

  factory QueryClient() {
    return _instance;
  }

  fetchQuery<T>(QueryOptions<T> options) {
    final query = _queryCache.getOrCreate(
      options.queryKey,
      options.queryFn,
      options.optionals,
    );
    return query.fetch();
  }
}
