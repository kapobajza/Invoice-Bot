import 'query_options.dart';
import 'query_cache.dart';

enum QueryStatus {
  idle,
  loading,
  success,
  error,
}

class QueryState<T> {
  final T? data;
  final Object? error;
  final QueryStatus status;
  final DateTime? dataUpdatedAt;

  QueryState({
    this.data,
    this.error,
    this.status = QueryStatus.idle,
    this.dataUpdatedAt,
  });

  QueryState<T> copyWith({
    T? data,
    Object? error,
    QueryStatus? status,
    DateTime? dataUpdatedAt,
  }) {
    return QueryState<T>(
      data: data ?? this.data,
      error: error ?? this.error,
      status: status ?? this.status,
      dataUpdatedAt: dataUpdatedAt ?? this.dataUpdatedAt,
    );
  }
}

class Query<T> {
  final QueryOptions<T> options;
  final QueryCache cache;

  QueryState<T> _state;
  final List<QueryObserver<T>> _observers = [];

  Query({
    required this.options,
    required this.cache,
  }) : _state = QueryState<T>();

  QueryState<T> get state => _state;

  void _notifyObservers() {}
}
