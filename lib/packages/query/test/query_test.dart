import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:query/query.dart';

import 'query_mock.mocks.dart';

void main() {
  test('query should be updated and saved to cache', () async {
    const fnData = 1;
    final cache = QueryCache();
    QueryKey key = ['key', 1, 2];
    queryFn() async => fnData;

    final query = Query(
      cache: cache,
      options: QueryOptions(
        queryKey: key,
        queryFn: queryFn,
      ),
    );

    expect(query.state.status, equals(QueryStatus.idle));
    expect(cache.get(key), equals(null));

    final observer = QueryObserver(query: query);

    expect(observer.query.state.status, equals(QueryStatus.loading));

    await Future.microtask(() {});

    expect(observer.query.state.status, equals(QueryStatus.success));
    expect(observer.query.state.data, equals(fnData));
    expect(cache.get(key), equals(query));
  });

  test('if cache data exists, query should not be fetched', () async {
    const fnData = 1;
    final cache = QueryCache();
    QueryKey key = ['key', 1, 2];
    final queryFn = MockQueryFunction();
    when(queryFn()).thenAnswer((_) async => fnData);

    final query = Query(
      cache: cache,
      options: QueryOptions(
        queryKey: key,
        queryFn: queryFn.call,
      ),
    );

    expect(query.state.status, equals(QueryStatus.idle));
    expect(cache.get(key), equals(null));

    QueryObserver(query: query);
    await Future.microtask(() {});

    verify(queryFn()).called(1);

    QueryObserver(query: query);
    await Future.microtask(() {});

    verifyNever(queryFn());
  });

  test(
    'if multiple observers are called in quick succession, only one query should be fetched',
    () async {
      const fnData = 1;
      final cache = QueryCache();
      QueryKey key = ['key', 1, 2];
      final queryFn = MockQueryFunction();
      when(queryFn()).thenAnswer((_) async => fnData);

      final query = Query(
        cache: cache,
        options: QueryOptions(
          queryKey: key,
          queryFn: queryFn.call,
        ),
      );

      QueryObserver(query: query);
      QueryObserver(query: query);

      verify(queryFn()).called(1);
    },
  );

  test(
    'if query is stale, only background fetching should be present',
    () async {
      const fnData = 1;
      final cache = QueryCache();
      QueryKey key = ['key', 1, 2];
      queryFn() async => await Future.value(fnData);

      final query = Query(
        cache: cache,
        options: QueryOptions(
          queryKey: key,
          queryFn: queryFn,
        ),
      );

      QueryObserver(query: query);

      expect(query.state.isLoading, true);
      expect(query.state.isFetching, true);
      await Future.microtask(() {});

      QueryObserver(query: query);

      expect(query.state.isLoading, false);
      expect(query.state.isFetching, true);
    },
  );

  test(
    'when stale time runs out, query should be fetched again',
    () async {
      const fnData = 1;
      final cache = QueryCache();
      QueryKey key = ['key', 1, 2];
      final queryFn = MockQueryFunction();
      when(queryFn()).thenAnswer((_) async => fnData);

      final query = Query(
        cache: cache,
        options: QueryOptions(
          queryKey: key,
          queryFn: queryFn.call,
          optionals: const DefaultQueryOptions(
            staleTime: Duration(milliseconds: 50),
          ),
        ),
      );

      QueryObserver(query: query);
      await Future.microtask(() {});

      await Future.delayed(const Duration(milliseconds: 51));

      QueryObserver(query: query);
      await Future.microtask(() {});

      verify(queryFn()).called(2);
    },
  );
}
