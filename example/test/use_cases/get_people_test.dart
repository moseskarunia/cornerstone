import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/auto_persistent_people_repository.dart';
import 'package:example/use_cases/get_people.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockResult extends Mock implements Either<Failure, NewPeopleSnapshot> {}

class MockRepo extends Mock implements AutoPersistentPeopleRepository {
  @override
  Future<Either<Failure, NewPeopleSnapshot>> getPeople() async =>
      await super.noSuchMethod(
        Invocation.method(#getPeople, []),
        returnValue: MockResult(),
      );
}

void main() {
  final snapFixture = NewPeopleSnapshot(
    data: [
      Person(id: 123, name: 'John Doe', email: 'johndoe@test.com'),
      Person(id: 456, name: 'Tony Stark', email: 'tony@starkindustries.com'),
    ],
    timestamp: DateTime(2020, 10, 10),
  );

  final failureFixture = Failure(name: 'TEST_ERROR');

  late MockRepo repo;
  late GetPeople getPeople;

  setUp(() {
    repo = MockRepo();
    getPeople = GetPeople(repo: repo);
  });

  group('GetPeople', () {
    tearDown(() {
      verify(repo.getPeople()).called(1);
    });
    test('should return the Right result of repo.getPeople', () async {
      when(repo.getPeople()).thenAnswer((_) async => Right(snapFixture));

      final result = await getPeople();

      expect((result as Right).value, snapFixture);
    });
    test('should return the Left result of repo.getPeople', () async {
      when(repo.getPeople()).thenAnswer((_) async => Left(failureFixture));

      final result = await getPeople();

      expect((result as Left).value, failureFixture);
    });
  });
}
