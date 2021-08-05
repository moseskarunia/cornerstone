import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:test/test.dart';

class MyUniqueRepo with LocallyPersistentRepository<Map<String, dynamic>> {
  Map<String, dynamic> get asJson => <String, dynamic>{};

  @override
  Future<Either<Failure<Object?>, Unit>> clear() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure<Object?>, Map<String, dynamic>>> load({Object? param}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure<Object?>, Unit>> save() {
    throw UnimplementedError();
  }
}

class MyNotSoUniqueRepo with LocallyPersistentRepository {
  Map<String, dynamic> get asJson => <String, dynamic>{};

  @override
  Future<Either<Failure<Object?>, Unit>> clear() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure<Object?>, Map<String, dynamic>>> load({Object? param}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure<Object?>, Unit>> save() {
    throw UnimplementedError();
  }

  @override
  String get id => 'loremipsum';
}

class NulledIdRepo with LocallyPersistentRepository<Map<String, dynamic>> {
  Map<String, dynamic> get asJson => <String, dynamic>{};

  @override
  Future<Either<Failure<Object?>, Unit>> clear() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure<Object?>, Map<String, dynamic>>> load({Object? param}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure<Object?>, Unit>> save() {
    throw UnimplementedError();
  }
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
