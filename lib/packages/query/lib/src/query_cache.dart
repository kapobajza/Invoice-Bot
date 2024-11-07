import 'package:query/src/query_options.dart';
import 'package:query/src/util.dart';

import 'query.dart';

class QueryCache {
  final Map<String, Query> _cache = {};

  Query<T>? get<T>(QueryKey key) {
    final hashedKey = hashKey(key);
    return _cache[hashedKey] as Query<T>?;
  }

  Query<T> getOrCreate<T>(
    QueryKey key,
    QueryFunction<T> queryFn, [
    DefaultQueryOptions<T>? options = const DefaultQueryOptions.defaulted(),
  ]) {
    final hashedKey = hashKey(key);
    return _cache.putIfAbsent(
      hashedKey,
      () => Query<T>(
        cache: this,
        options: QueryOptions(
          queryKey: key,
          queryFn: queryFn,
          optionals: options,
        ),
      ),
    ) as Query<T>;
  }

  void set<T>(QueryKey key, Query<T> query) {
    final hashedKey = hashKey(key);
    _cache[hashedKey] = query;
  }

  void remove(QueryKey key) {
    final hashedKey = hashKey(key);
    final query = _cache[hashedKey];

    if (query != null) {
      query.destroy();
      _cache.remove(hashedKey);
    }
  }

  void clear() {
    _cache.forEach((key, query) {
      query.destroy();
    });
    _cache.clear();
  }

  List<Query<T>> findAll<T>(QueryFilters filters) {
    return _cache.values.whereType<Query<T>>().where(
      (query) {
        return hashKey(query.options.queryKey) == hashKey(filters.queryKey);
      },
    ).toList();
  }
}
