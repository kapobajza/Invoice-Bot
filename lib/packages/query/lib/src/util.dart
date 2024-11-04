import 'package:query/main.dart';

String hashKey(QueryKey key) {
  return key.map((key) => key.toString()).join(':');
}
