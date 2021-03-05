import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/repositories/auto_persistent_people_repository.dart';
import 'package:mockito/mockito.dart';

class MockSnapshotResult extends Mock
    implements Either<Failure, NewPeopleSnapshot> {}

class MockClearResult extends Mock implements Either<Failure, Unit> {}

class MockRepo extends Mock implements AutoPersistentPeopleRepository {
  @override
  Future<Either<Failure, NewPeopleSnapshot>> getPeople() async =>
      await super.noSuchMethod(
        Invocation.method(#getPeople, []),
        returnValue: MockSnapshotResult(),
      );

  @override
  Future<Either<Failure, NewPeopleSnapshot>> load() async =>
      await super.noSuchMethod(
        Invocation.method(#load, []),
        returnValue: MockSnapshotResult(),
      );

  @override
  Future<Either<Failure, Unit>> clear() async => await super.noSuchMethod(
        Invocation.method(#clear, []),
        returnValue: MockClearResult(),
      );
}
