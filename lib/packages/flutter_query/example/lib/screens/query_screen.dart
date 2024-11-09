import 'package:flutter/material.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:go_router/go_router.dart';
import 'package:query/query.dart';

class QueryScreen extends StatelessWidget {
  const QueryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final queryClient = QueryProvider.of(context).client;

    return Scaffold(
      appBar: AppBar(title: const Text('Query Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: const Text('Invalidate and go back'),
              onPressed: () {
                queryClient.invalidateQueries(
                  filters: QueryFilters(queryKey: ['example']),
                );
                context.pop();
              },
            ),
            TextButton(
              child: const Text('Go back'),
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
