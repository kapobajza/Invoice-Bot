import 'package:query/query.dart';

String hashKey(QueryKey key) {
  return key.map((key) => key.toString()).join(':');
}
