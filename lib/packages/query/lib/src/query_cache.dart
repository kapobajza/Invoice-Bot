import 'package:query/src/query_options.dart';

import 'query.dart';

class QueryCache {
  final Map<String, Query> _cache = {};

  Query<T> get<T>(String key) {
    return _cache.putIfAbsent(
      key,
      () => Query<T>(cache: this, options: QueryOptions()),
    ) as Query<T>;
  }

  void set<T>(String key, Query<T> query) {
    _cache[key] = query;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
}
