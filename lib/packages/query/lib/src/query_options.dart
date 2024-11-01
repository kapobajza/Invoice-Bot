class QueryOptions<T> {
  final Duration? staleTime;
  final Duration? gcTime;
  final List<dynamic> queryKey;
  final Future<T> Function() queryFn;

  QueryOptions({
    this.staleTime,
    this.gcTime,
    required this.queryKey,
    required this.queryFn,
  });
}
