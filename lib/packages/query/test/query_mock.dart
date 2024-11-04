import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([QueryFunction])
class QueryFunction extends Mock {
  Future<int> call();
}
