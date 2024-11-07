import 'package:flutter/widgets.dart';
import 'package:flutter_query/src/query_provider.dart';
import 'package:query/query.dart';

class QueryBuilder<T> extends StatefulWidget {
  final QueryOptions<T> queryOptions;
  final Widget Function(BuildContext context, QueryObserverResult<T>) builder;

  const QueryBuilder({
    super.key,
    required this.queryOptions,
    required this.builder,
  });

  @override
  State<StatefulWidget> createState() => _QueryBuilderState<T>();
}

class _QueryBuilderState<T> extends State<QueryBuilder<T>> {
  late QueryObserver<T> _observer;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final queryClient = QueryProvider.of(context).client;
      _observer = QueryObserver(
        queryClient: queryClient,
        queryOptions: widget.queryOptions,
      );
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _observer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container();
    }

    return StreamBuilder<QueryObserverResult<T>>(
      stream: _observer.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final errorResult = QueryObserverResult<T>(
            data: null,
            error: snapshot.error,
            status: QueryStatus.error,
            fetchStatus: _observer.currentResult.fetchStatus,
          );
          return widget.builder(context, errorResult);
        }

        final result = snapshot.data;

        if (!snapshot.hasData || result == null) {
          final loadingResult = QueryObserverResult<T>(
            data: null,
            error: null,
            status: QueryStatus.pending,
            fetchStatus: _observer.currentResult.fetchStatus,
          );
          return widget.builder(context, loadingResult);
        }

        return widget.builder(context, result);
      },
    );
  }
}
