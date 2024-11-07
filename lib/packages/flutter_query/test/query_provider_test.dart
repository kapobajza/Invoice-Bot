import 'package:flutter/widgets.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:query/query.dart';

void main() {
  group('QueryProvider', () {
    testWidgets(
      'should provide QueryClient to child widgets',
      (WidgetTester tester) async {
        final queryClient = QueryClient();
        late QueryClient retrievedClient;

        final widget = QueryProvider(
          client: queryClient,
          child: Builder(builder: (BuildContext context) {
            retrievedClient = QueryProvider.of(context).client;
            return Container();
          }),
        );

        await tester.pumpWidget(widget);

        expect(retrievedClient, equals(queryClient));
      },
    );

    testWidgets(
      'should return correct QueryProvider using of',
      (WidgetTester tester) async {
        final queryClient = QueryClient();
        late QueryProvider provider;

        await tester.pumpWidget(QueryProvider(
          client: queryClient,
          child: Builder(
            builder: (BuildContext context) {
              provider = QueryProvider.of(context);
              return Container();
            },
          ),
        ));

        expect(provider.client, equals(queryClient));
      },
    );

    testWidgets(
      'should have the same client instance across multiple QueryProviders',
      (WidgetTester tester) async {
        final queryClient1 = QueryClient();
        final queryClient2 = QueryClient();

        final widget1 = QueryProvider(
          client: queryClient1,
          child: Builder(builder: (BuildContext context) {
            return Container();
          }),
        );

        await tester.pumpWidget(widget1);

        final widget2 = QueryProvider(
          client: queryClient2,
          child: Builder(builder: (BuildContext context) {
            return Container();
          }),
        );

        await tester.pumpWidget(widget2);

        expect(widget1.client, equals(widget2.client));
      },
    );
  });
}
