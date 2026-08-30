import 'package:diu/data/asset_routine_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled CSE JSON loads and is a persisted fallback', () async {
    final file = await AssetRoutineRepository.loadBundledFile();
    expect(file.slots, isNotEmpty);
    expect(file.meta.department, 'CSE');
    expect(file.isPersistedRoutine, isTrue);
    expect(AssetRoutineRepository.fromFile(file).hasRoutine, isTrue);
  });
}
