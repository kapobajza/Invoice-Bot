import 'dart:async';

import 'package:query/query.dart';

class QueryObserver<T> {
  final Query<T> query;
  late final _controller = StreamController<QueryState<T>>.broadcast(
    sync: true,
    onListen: _onListen,
    onCancel: _onCancel,
  );

  QueryObserver({
    required this.query,
  }) {
    query.addObserver(this);
    _controller.add(query.state);
    query.fetch();
  }

  Stream<QueryState<T>> get stream => _controller.stream;

  void dispose() {
    query.removeObserver(this);
    _controller.close();
  }

  void onQueryUpdated(Query<T> updatedQuery) {
    if (!_controller.isClosed && _controller.hasListener) {
      _controller.add(updatedQuery.state);
    }
  }

  isStale() {
    return query.isStaleByTime(
      DefaultQueryOptions.staleTimeOrDefault(
          query.options.optionals?.staleTime),
    );
  }

  void _onListen() {
    _controller.add(query.state);
  }

  void _onCancel() {
    // If there are no more listeners, we could potentially do some cleanup here
    // For now, we'll just leave it empty
  }
}
