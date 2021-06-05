import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/use_cases/clear_people_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../shared_mocks.dart';

void main() {
  final failureFixture = Failure<Object?>(name: 'TEST_ERROR', details: {});

  late MockRepo repo;
  late ClearPeopleStorage clear;

  setUp(() {
    repo = MockRepo();
    clear = ClearPeopleStorage(repo: repo);
  });

  group('ClearPeopleStorage', () {
    tearDown(() {
      verify(() => repo.clear()).called(1);
    });
    test('should return the Right result of repo.clear', () async {
      when(() => repo.clear()).thenAnswer((_) async => Right(unit));

      final result = await clear();

      expect((result as Right).value, unit);
    });
    test('should return the Left result of repo.clear', () async {
      when(() => repo.clear()).thenAnswer((_) async => Left(failureFixture));

      final result = await clear();

      expect((result as Left).value, failureFixture);
    });
  });
}
