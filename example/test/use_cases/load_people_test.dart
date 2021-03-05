import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/people_repository.dart';
import 'package:example/use_cases/load_people.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'shared_mock_repo.dart';

void main() {
  final snapFixture = PeopleSnapshot(
    data: [
      Person(id: 123, name: 'John Doe', email: 'johndoe@test.com'),
      Person(id: 456, name: 'Tony Stark', email: 'tony@starkindustries.com'),
    ],
    timestamp: DateTime(2020, 10, 10),
  );

  final failureFixture = Failure(name: 'TEST_ERROR');

  late MockRepo repo;
  late LoadPeople loadPeople;

  setUp(() {
    repo = MockRepo();
    loadPeople = LoadPeople(repo: repo);
  });

  group('LoadPeople', () {
    tearDown(() {
      verify(repo.load()).called(1);
    });
    test('should return the Right result of repo.load', () async {
      when(repo.load()).thenAnswer((_) async => Right(snapFixture));

      final result = await loadPeople();

      expect((result as Right).value, snapFixture);
    });
    test('should return the Left result of repo.load', () async {
      when(repo.load()).thenAnswer((_) async => Left(failureFixture));

      final result = await loadPeople();

      expect((result as Left).value, failureFixture);
    });
  });
}
