import 'package:flutter/widgets.dart';
import 'package:query/query.dart';

class QueryProvider extends StatefulWidget {
  final QueryClient client;
  final Widget child;

  const QueryProvider({
    super.key,
    required this.client,
    required this.child,
  });

  static QueryProvider of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_InheritedQueryProvider>();
    assert(provider != null, 'No QueryProvider found in context');
    return provider!.queryProvider;
  }

  @override
  State<QueryProvider> createState() => _QueryProviderState();
}

class _QueryProviderState extends State<QueryProvider> {
  @override
  void dispose() {
    widget.client.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedQueryProvider(
      queryProvider: widget,
      child: widget.child,
    );
  }
}

class _InheritedQueryProvider extends InheritedWidget {
  final QueryProvider queryProvider;

  const _InheritedQueryProvider({
    required this.queryProvider,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedQueryProvider oldWidget) {
    return queryProvider.client != oldWidget.queryProvider.client;
  }
}
