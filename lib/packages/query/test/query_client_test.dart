import 'package:mockito/mockito.dart';
import 'package:query/query.dart';
import 'package:test/test.dart';

import 'query_mock.mocks.dart';

void main() {
  final queryClient = QueryClient();

  test(
    'should prefetch query successfully',
    () async {
      QueryKey queryKey = ['key', 'of', 'mine'];
      queryFn() async => 1;
      await queryClient.prefetchQuery(
        options: QueryOptions(queryKey: queryKey, queryFn: queryFn),
      );

      expect(queryClient.queryCache.get(queryKey), isNotNull);
    },
  );

  test(
    'should refetch queries successfully',
    () async {
      QueryKey qk1 = ['key', 'of', 'mine'];
      QueryKey qk2 = ['key', 'of', 'mine', 'second'];
      final qfn1 = MockQueryFunction();
      final qfn2 = MockQueryFunction();

      when(qfn1()).thenAnswer((_) async => 1);
      when(qfn2()).thenAnswer((_) async => 2);

      await queryClient.prefetchQuery(
        options: QueryOptions(queryKey: qk1, queryFn: qfn1.call),
      );
      await queryClient.prefetchQuery(
        options: QueryOptions(queryKey: qk2, queryFn: qfn2.call),
      );

      await queryClient.refetchQueries(
        filters: QueryFilters(queryKey: qk1),
      );
      await queryClient.refetchQueries(
        filters: QueryFilters(queryKey: qk2),
      );

      verify(qfn1()).called(2);
      verify(qfn2()).called(2);
    },
  );

  test(
    'should invalidate queries successfully',
    () async {
      QueryKey queryKey = ['key', 'of', 'mine'];
      final queryFn = MockQueryFunction();

      when(queryFn()).thenAnswer((_) async => 1);

      await queryClient.prefetchQuery(
        options: QueryOptions(queryKey: queryKey, queryFn: queryFn.call),
      );

      await queryClient.invalidateQueries(
        filters: QueryFilters(queryKey: queryKey),
      );

      verify(queryFn()).called(2);
    },
  );
}
