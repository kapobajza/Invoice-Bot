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

void main() {
  final queryClient = QueryClient();

  group(
    'QeuryBuilder',
    () {
      testWidgets(
        'should display loading and success states',
        (WidgetTester tester) async {
          const fnData = 1;

          final widget = TestApp(
            queryClient: queryClient,
            child: QueryBuilder(
              builder: (context, result) {
                if (result.isError) {
                  return Text("Error: ${result.error}");
                }

                if (result.isLoading) {
                  return const Text("Loading...");
                }

                return Text("Data: ${result.data}");
              },
              queryOptions: QueryOptions(
                queryKey: ['key', 'of', 'mine'],
                queryFn: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  return Future.value(fnData);
                },
              ),
            ),
          );

          await tester.pumpWidget(widget);

          expect(find.text("Loading..."), findsOneWidget);

          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.text("Data: $fnData"), findsOneWidget);
        },
      );

      testWidgets(
        'should display error state',
        (WidgetTester tester) async {
          const errorMessage = 'error_message';

          final widget = TestApp(
            queryClient: queryClient,
            child: QueryBuilder(
              builder: (context, result) {
                if (result.isError) {
                  return Text(result.error?.toString() ?? 'Error');
                }

                if (result.isLoading) {
                  return const Text("Loading...");
                }

                return Text("Data: ${result.data}");
              },
              queryOptions: QueryOptions(
                queryKey: ['key', 'of', 'mine'],
                queryFn: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  throw Exception(errorMessage);
                },
                optionals: const DefaultQueryOptions(
                  retry: 0,
                ),
              ),
            ),
          );

          await tester.pumpWidget(widget);

          expect(find.text("Loading..."), findsOneWidget);

          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.text("Exception: $errorMessage"), findsOneWidget);
        },
      );
    },
  );
}
