import 'package:cornerstone/src/failure.dart';
import 'package:cornerstone/src/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:test/test.dart';

class MyUniqueRepo extends LocallyPersistentRepository {
  @override
  Future<Either<Failure, Unit>> clear() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> read() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> write(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}

class MyNotSoUniqueRepo extends LocallyPersistentRepository {
  @override
  Future<Either<Failure, Unit>> clear() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> read() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> write(Map<String, dynamic> json) {
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
