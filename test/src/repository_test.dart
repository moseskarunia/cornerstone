import 'package:cornerstone/src/repository.dart';
import 'package:test/test.dart';

class MyUniqueRepo extends LocallyPersistentRepository {
  @override
  Future<void> clear() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> load() {
    throw UnimplementedError();
  }

  @override
  Future<void> write(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}

class MyNotSoUniqueRepo extends LocallyPersistentRepository {
  @override
  Future<void> clear() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> load() {
    throw UnimplementedError();
  }

  @override
  Future<void> write(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  @override
  String get id => 'loremipsum';
}

void main() {
  group('LocallyPersistedRepository', () {
    test(
      'storageName should returns a string of runtimeType '
      'when not overrided',
      () {
        expect(MyUniqueRepo().storageName, 'MyUniqueRepo');
      },
    );

    test('id should returns empty string when not overrided', () {
      expect(MyUniqueRepo().id, '');
    });

    test(
      'storageName should returns a string of runtimeType '
      'appended with overrided id value',
      () {
        expect(MyNotSoUniqueRepo().storageName, 'MyNotSoUniqueRepoloremipsum');
      },
    );
  });
}
