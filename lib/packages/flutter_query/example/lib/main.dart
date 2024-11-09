import 'package:example/screens/home_screen.dart';
import 'package:example/screens/query_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:go_router/go_router.dart';
import 'package:query/query.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: '/query',
          builder: (context, state) => const QueryScreen(),
        )
      ],
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return QueryProvider(
      client: QueryClient(),
      child: MaterialApp.router(
        routerConfig: _router,
      ),
    );
  }
}
