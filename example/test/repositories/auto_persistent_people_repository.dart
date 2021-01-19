import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/auto_persistent_people_repository.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockDataSource extends Mock implements PeopleDataSource {}

class MockHive extends Mock implements HiveInterface {}

class MockBox extends Mock implements Box {}

class MockConvert extends Mock implements ConvertToFailure {}

void main() {
  group('AutoPersistentPeopleRepositoryImpl', () {
    final jsonListFixture = [
      <String, dynamic>{
        'id': 123,
        'name': 'John Doe',
        'email': 'johndoe@test.com',
      },
      <String, dynamic>{
        'id': 456,
        'name': 'Tony Stark',
        'email': 'tony@starkindustries.com',
      },
    ];
    final peopleListFixture = [
      Person(id: 123, name: 'John Doe', email: 'johndoe@test.com'),
      Person(id: 456, name: 'Tony Stark', email: 'tony@starkindustries.com'),
    ];
    final dateFixture = DateTime(2020, 10, 10);

    final snapJsonFixture = {
      'timestamp': dateFixture.toUtc().toIso8601String(),
      'data': jsonListFixture,
    };

    final snapFixture = NewPeopleSnapshot(
      data: peopleListFixture,
      timestamp: dateFixture,
    );

    MockBox box;
    MockHive hive;
    MockConvert convert;
    AutoPersistentPeopleRepositoryImpl repo;

    setUp(() {
      box = MockBox();
      hive = MockHive();
      convert = MockConvert();

      repo = AutoPersistentPeopleRepositoryImpl(
        hive: hive,
        convertToFailure: convert,
        clock: Clock.fixed(DateTime(2020, 10, 10)),
      );
      when(hive.openBox(any)).thenAnswer((_) async => box);
    });

    group('NewPeopleSnapshot', () {
      test('props', () {
        expect(snapFixture.props, [dateFixture, peopleListFixture]);
      });
      test('fromJson', () {
        expect(NewPeopleSnapshot.fromJson(snapJsonFixture), snapFixture);
      });
      test('toJson', () {
        expect(snapFixture.toJson(), snapJsonFixture);
      });
    });

    test('storageName should be PeopleRepoWithBuiltInHiveImpl', () {
      expect(repo.storageName, 'PeopleRepoWithBuiltInHiveImpl');
    });
    test('asJson', () {
      repo.data = snapFixture;
      expect(repo.asJson, snapJsonFixture);
    });

    test('getPeople should throw UnimplementedError', () {
      expectLater(() => repo.getPeople(), throwsA(isA<UnimplementedError>()));
    });

    group('load', () {
      test(
        'should catch exception and return result of convertToFailure in Left',
        () async {
          final e = HiveError('TEST_ERROR');
          when(hive.openBox(any)).thenThrow(e);
          when(convert(any)).thenReturn(Failure<dynamic>(name: 'TEST_ERROR'));

          final result = await repo.load();

          expect(
            (result as Left).value,
            Failure<dynamic>(name: 'TEST_ERROR'),
          );
          verifyInOrder([hive.openBox(repo.storageName), convert(e)]);
        },
      );

      test('should call loadData in mixin and return Right', () async {
        EquatableConfig.stringify = true;
        when(box.toMap()).thenReturn(snapJsonFixture);
        final result = await repo.load();
        expect(
          repo.data,
          NewPeopleSnapshot(data: peopleListFixture, timestamp: dateFixture),
        );
        expect(
          (result as Right).value,
          NewPeopleSnapshot(data: peopleListFixture, timestamp: dateFixture),
        );
        verifyInOrder([
          hive.openBox(repo.storageName),
          box.toMap(),
        ]);
      });
    });
  });
}
