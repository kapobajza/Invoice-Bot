import 'package:flutter/material.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:go_router/go_router.dart';
import 'package:query/query.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: QueryBuilder(
          queryOptions: QueryOptions(
            queryKey: ['example'],
            queryFn: () async {
              await Future.delayed(const Duration(seconds: 2));
              return 42;
            },
            optionals: const DefaultQueryOptions(
              staleTime: Duration(seconds: 10),
            ),
          ),
          builder: (context, state) {
            if (state.isFetching) {
              return const CircularProgressIndicator();
            }

            if (state.isError) {
              return Text('Error: ${state.error}');
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('The answer is: ${state.data}'),
                TextButton(
                  child: const Text('Go to query'),
                  onPressed: () => context.go('/query'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
