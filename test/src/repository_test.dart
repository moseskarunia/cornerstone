import 'package:cornerstone/src/failure.dart';
import 'package:cornerstone/src/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:test/test.dart';

class MyUniqueRepo extends LocallyPersistentRepository<Map<String, dynamic>> {
  Map<String, dynamic> get asJson => <String, dynamic>{};

  @override
  Future<Either<Failure, Unit>> clear() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> load() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> save() {
    throw UnimplementedError();
  }
}

class MyNotSoUniqueRepo extends LocallyPersistentRepository {
  Map<String, dynamic> get asJson => <String, dynamic>{};

  @override
  Future<Either<Failure, Unit>> clear() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> load() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> save() {
    throw UnimplementedError();
  }

  @override
  String get id => 'loremipsum';
}

class NulledIdRepo extends LocallyPersistentRepository<Map<String, dynamic>> {
  Map<String, dynamic> get asJson => <String, dynamic>{};

  @override
  Future<Either<Failure, Unit>> clear() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> load() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> save() {
    throw UnimplementedError();
  }

  @override
  String get id => null;
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

    test(
      'if id is null, should treat it as empty string in storageName',
      () {
        expect(NulledIdRepo().storageName, 'NulledIdRepo');
      },
    );
  });
}
