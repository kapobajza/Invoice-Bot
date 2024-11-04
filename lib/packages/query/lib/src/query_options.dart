import 'package:query/src/query.dart';

class DefaultQueryOptions {
  final Duration? staleTime;
  final Duration? gcTime;

  const DefaultQueryOptions({this.staleTime, this.gcTime});

  static Duration gcTimeOrDefault(Duration? gcTime) {
    return gcTime ?? const Duration(minutes: 5);
  }

  static Duration staleTimeOrDefault(Duration? staleTime) {
    return staleTime ?? const Duration(minutes: 1);
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
  final DefaultQueryOptions? optionals;

  QueryOptions({
    required this.queryKey,
    required this.queryFn,
    this.optionals = const DefaultQueryOptions.defaulted(),
  });
}
