import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/people_repository.dart';
import 'package:example/use_cases/get_people.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockRepo extends Mock implements PeopleRepository {}

void main() {
  final snapFixture = PeopleSnapshot(
    data: [
      Person(id: 123, name: 'John Doe', email: 'johndoe@test.com'),
      Person(id: 456, name: 'Tony Stark', email: 'tony@starkindustries.com'),
    ],
    updatedAt: DateTime(2020, 10, 10),
    isSaved: true,
  );

  final failureFixture = Failure(name: 'TEST_ERROR');

  MockRepo repo;
  GetPeople getPeople;

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
