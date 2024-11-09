import 'package:flutter/material.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:query/query.dart';

class TestApp extends StatelessWidget {
  final QueryClient queryClient;
  final Widget child;

  const TestApp({
    super.key,
    required this.queryClient,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QueryProvider(
        client: queryClient,
        child: child,
      ),
    );
  }
}

const QueryKey defaultQueryKey = ['key', 'of', 'mine'];

class TestQueryBuilder extends StatelessWidget {
  final DefaultQueryOptions? options;
  final QueryKey? queryKey;
  final QueryClient queryClient;
  final QueryFunction? queryFn;

  const TestQueryBuilder({
    super.key,
    this.options,
    required this.queryClient,
    this.queryKey = defaultQueryKey,
    this.queryFn,
  });

  @override
  Widget build(BuildContext context) {
    return TestApp(
      queryClient: queryClient,
      child: QueryBuilder(
        builder: (context, result) {
          if (result.isError) {
            return Text(result.error?.toString() ?? 'Error');
          }

          if (result.isLoading) {
            return const Text("Loading...");
          }

          if (result.isFetching) {
            return const Text("Fetching...");
          }

          return Text("Data: ${result.data}");
        },
        queryOptions: QueryOptions(
          queryKey: queryKey ?? defaultQueryKey,
          queryFn: queryFn ??
              () async {
                await Future.delayed(const Duration(seconds: 1));
                return 1;
              },
          optionals: options,
        ),
      ),
    );
  }
}

void main() {
  final queryClient = QueryClient();

  group(
    'QeuryBuilder',
    () {
      testWidgets(
        'should display loading and success states',
        (WidgetTester tester) async {
          const fnData = 1;

          await tester.pumpWidget(TestQueryBuilder(queryClient: queryClient));

          expect(find.text("Loading..."), findsOneWidget);

          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.text("Data: $fnData"), findsOneWidget);
        },
      );

      testWidgets(
        'should display error state',
        (WidgetTester tester) async {
          const errorMessage = 'error_message';

          await tester.pumpWidget(
            TestQueryBuilder(
              queryClient: queryClient,
              queryFn: () async {
                await Future.delayed(const Duration(seconds: 1));
                throw Exception(errorMessage);
              },
              options: const DefaultQueryOptions(
                retry: 0,
              ),
            ),
          );

          expect(find.text("Loading..."), findsOneWidget);

          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.text("Exception: $errorMessage"), findsOneWidget);
        },
      );

      testWidgets(
        'should refetch when query is stale',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            TestQueryBuilder(
              queryClient: queryClient,
            ),
          );

          expect(find.text("Loading..."), findsOneWidget);

          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.text("Data: 1"), findsOneWidget);

          await tester.pumpWidget(
            TestQueryBuilder(
              queryClient: queryClient,
              options: const DefaultQueryOptions(
                staleTime: Duration(seconds: 0),
              ),
            ),
          );

          expect(find.text("Fetching..."), findsOneWidget);

          await tester.pumpAndSettle(const Duration(seconds: 1));
        },
      );

      testWidgets(
        'should hard load when query is garbage collected',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            TestQueryBuilder(
              queryClient: queryClient,
              options: const DefaultQueryOptions(
                gcTime: Duration(minutes: 5),
              ),
            ),
          );

          expect(find.text("Loading..."), findsOneWidget);

          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.text("Data: 1"), findsOneWidget);

          await tester.pump(const Duration(minutes: 5));

          await tester.pumpWidget(
            TestQueryBuilder(
              queryClient: queryClient,
            ),
          );

          expect(find.text("Loading..."), findsOneWidget);

          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.text("Data: 1"), findsOneWidget);
        },
      );
    },
  );
}
