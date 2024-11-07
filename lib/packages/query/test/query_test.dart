import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:query/query.dart';

import 'query_mock.mocks.dart';

void main() {
  final QueryClient queryClient = QueryClient();
  final List<Future<void> Function()> subscribers = [];

  tearDown(() async {
    queryClient.clear();

    for (final subscriber in subscribers) {
      await subscriber();
    }
  });

  QueryObserver<T> createObserver<T>(QueryOptions<T> queryOptions) {
    final observer = QueryObserver<T>(
      queryClient: queryClient,
      queryOptions: queryOptions,
    );
    subscribers.add(observer.stream.listen((_) {}).cancel);

    return observer;
  }

  test('should update and save the query to cache', () async {
    const fnData = 1;
    QueryKey key = ['key', 1, 2];
    queryFn() async => fnData;

    expect(queryClient.queryCache.get(key), equals(null));

    createObserver(
      QueryOptions(queryKey: key, queryFn: queryFn),
    );
    final query = queryClient.queryCache.get(key);

    expect(query?.state.status, equals(QueryStatus.pending));

    await Future.microtask(() {});

    expect(query?.state.status, equals(QueryStatus.success));
    expect(query?.state.data, equals(fnData));
    expect(queryClient.queryCache.get(key), equals(query));
  });

  test('should not fetch query if it isn\'t stale', () async {
    const fnData = 1;
    QueryKey key = ['key', 1, 2];
    final queryFn = MockQueryFunction();
    when(queryFn()).thenAnswer((_) async => fnData);

    expect(queryClient.queryCache.get(key), equals(null));

    createObserver(
      QueryOptions(queryKey: key, queryFn: queryFn.call),
    );
    await Future.microtask(() {});

    createObserver(
      QueryOptions(queryKey: key, queryFn: queryFn.call),
    );
    await Future.microtask(() {});

    verify(queryFn()).called(1);
  });

  test(
    'should fetch query only once, if multiple observers are called in quick succession',
    () async {
      const fnData = 1;
      QueryKey key = ['key', 1, 2];
      final queryFn = MockQueryFunction();
      when(queryFn()).thenAnswer((_) async => fnData);

      createObserver(
        QueryOptions(queryKey: key, queryFn: queryFn.call),
      );
      createObserver(
        QueryOptions(queryKey: key, queryFn: queryFn.call),
      );
      await Future.microtask(() {});

      verify(queryFn()).called(1);
    },
  );

  test(
    'should fetch query again when stale time runs out',
    () async {
      const fnData = 1;
      QueryKey key = ['key', 1, 2];
      final queryFn = MockQueryFunction();
      when(queryFn()).thenAnswer((_) async => fnData);

      createObserver(
        QueryOptions(
          queryKey: key,
          queryFn: queryFn.call,
          optionals: const DefaultQueryOptions<int>(
            staleTime: Duration(milliseconds: 50),
          ),
        ),
      );
      await Future.microtask(() {});

      await Future.delayed(const Duration(milliseconds: 51));

      final observer = createObserver(
        QueryOptions(queryKey: key, queryFn: queryFn.call),
      );
      expect(observer.currentResult.isFetching, true);
      expect(observer.currentResult.isLoading, false);
      await Future.microtask(() {});

      verify(queryFn()).called(2);
      expect(observer.currentResult.isFetching, false);
      expect(observer.currentResult.isLoading, false);
    },
  );

  test('should retry fetching query on error', () async {
    QueryKey key = ['key', 1, 2];
    String error = 'error_message';
    const int retryCount = 3;
    int callCount = 0;
    const int fnData = 1;

    final queryFn = MockQueryFunction();
    when(queryFn()).thenAnswer((_) async {
      callCount++;

      if (callCount <= retryCount) {
        throw Exception(error);
      }

      return fnData;
    });

    int? returnedData;

    try {
      returnedData = await queryClient.fetchQuery(
        options: QueryOptions(
          queryKey: key,
          queryFn: queryFn.call,
          optionals: const DefaultQueryOptions<int>(
            retry: retryCount,
            retryDelay: 10,
          ),
        ),
      );
    } catch (err) {
      expect(err, isA<Exception>());
      expect(err.toString(), 'Exception: $error');
    }

    verify(queryFn()).called(retryCount + 1);
    expect(returnedData, fnData);
  });

  test(
    'should show error when query fails',
    () async {
      QueryKey key = ['key', 1, 2];
      const errorMessage = 'error_message';
      final queryFn = MockQueryFunction();

      when(queryFn()).thenThrow(Exception(errorMessage));

      final observer = createObserver(
        QueryOptions(
          queryKey: key,
          queryFn: () async {
            throw Exception(errorMessage);
          },
          optionals: const DefaultQueryOptions(
            retry: 0,
          ),
        ),
      );

      await expectLater(
        observer.stream,
        emits(predicate<QueryObserverResult>((result) {
          expect(result.isError, true);
          expect(result.error.toString(), 'Exception: $errorMessage');
          return true;
        })),
      );
    },
  );
}
