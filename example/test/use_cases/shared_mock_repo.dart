import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/repositories/people_repository.dart';
import 'package:mockito/mockito.dart';

class MockSnapshotResult extends Mock
    implements Either<Failure<Object>, PeopleSnapshot> {}

class MockClearResult extends Mock implements Either<Failure<Object>, Unit> {}

class MockRepo extends Mock implements PeopleRepository {
  @override
  Future<Either<Failure<Object>, PeopleSnapshot>> getPeople() async =>
      await super.noSuchMethod(
        Invocation.method(#getPeople, []),
        returnValue: MockSnapshotResult(),
      );

  @override
  Future<Either<Failure<Object>, PeopleSnapshot>> load({Object? param}) async =>
      await super.noSuchMethod(
        Invocation.method(#load, []),
        returnValue: MockSnapshotResult(),
      );

  @override
  Future<Either<Failure<Object>, Unit>> clear() async =>
      await super.noSuchMethod(
        Invocation.method(#clear, []),
        returnValue: MockClearResult(),
      );
}
