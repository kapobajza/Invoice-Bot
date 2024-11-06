import 'package:query/src/query.dart';

class QueryFunctionContext {
  final QueryKey queryKey;
  final dynamic meta;

  QueryFunctionContext({required this.queryKey, this.meta});
}

class FetchContext<T> {
  final QueryOptions<T> options;
  final QueryKey queryKey;
  final QueryState<T> state;
  final Future<T> Function() fetchFn;

  FetchContext({
    required this.options,
    required this.queryKey,
    required this.state,
    required this.fetchFn,
  });
}

typedef QueryPersister<T> = Future<T> Function(
  QueryFunction<T>,
  QueryFunctionContext,
  Query<T>,
);

class QueryBehavior<T> {
  final void Function(FetchContext<T>, Query<T>)? onFetch;

  QueryBehavior({this.onFetch});
}

class DefaultQueryOptions<T> {
  final Duration? staleTime;
  final Duration? gcTime;
  final dynamic meta;
  final int? retry;
  final QueryBehavior<T>? behavior;
  final QueryPersister<T>? persister;
  final int? retryDelay;

  const DefaultQueryOptions({
    this.staleTime,
    this.gcTime,
    this.behavior,
    this.persister,
    this.meta,
    this.retry,
    this.retryDelay,
  });

  static Duration gcTimeOrDefault(Duration? gcTime) {
    return gcTime ?? const Duration(minutes: 5);
  }

  static Duration staleTimeOrDefault(Duration? staleTime) {
    return staleTime ?? const Duration(minutes: 1);
  }

  static int retryOrDefault(int? retry) {
    return retry ?? 3;
  }

  static int retryDelayOrDefault({int? retryDelay}) {
    return retryDelay ?? 30 * 1000;
  }

  const DefaultQueryOptions.defaulted()
      : this(
          staleTime: const Duration(minutes: 1),
          gcTime: const Duration(minutes: 5),
        );
}

typedef QueryFunction<T> = Future<T> Function();

class QueryOptions<T> {
  final QueryKey queryKey;
  final QueryFunction<T> queryFn;
  final DefaultQueryOptions<T>? optionals;

  QueryOptions({
    required this.queryKey,
    required this.queryFn,
    this.optionals = const DefaultQueryOptions.defaulted(),
  });
}

class QueryFilters {
  QueryKey queryKey;

  QueryFilters({required this.queryKey});
}
