import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/people_repository.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockDataSource extends Mock implements PeopleDataSource {}

class MockHive extends Mock implements HiveInterface {}

class MockBox extends Mock implements Box {}

void main() {
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
    'updatedAt': dateFixture.toUtc().toIso8601String(),
    'data': jsonListFixture,
    'isSaved': false,
  };

  final snapFixture = PeopleSnapshot(
    data: peopleListFixture,
    updatedAt: dateFixture,
  );

  MockBox box;
  MockHive hive;
  MockDataSource dataSource;
  PeopleRepositoryImpl repo;

  setUp(() {
    box = MockBox();
    hive = MockHive();
    dataSource = MockDataSource();
    repo = PeopleRepositoryImpl(
      dataSource: dataSource,
      hive: hive,
      clock: Clock.fixed(DateTime(2020, 10, 10)),
    );
    when(hive.openBox(any)).thenAnswer((_) async => box);
  });

  group('PeopleSnapshot', () {
    test('props', () {
      expect(snapFixture.props, [dateFixture, false, peopleListFixture]);
    });
    test('fromJson', () {
      expect(PeopleSnapshot.fromJson(snapJsonFixture), snapFixture);
    });
    test('toJson', () {
      expect(snapFixture.toJson(), snapJsonFixture);
    });
  });
  group('PeopleRepositoryImpl', () {
    test('storageName should be PeopleRepositoryImpl', () {
      expect(repo.storageName, 'PeopleRepositoryImpl');
    });
    test('asJson', () {
      repo.data = snapFixture;
      expect(repo.asJson, snapJsonFixture);
    });
    group('getPeople', () {
      test(
        'should return Right with PeopleSnapshot and isSaved',
        () async {
          when(dataSource.readMany(param: anyNamed('param'))).thenAnswer(
            (_) async => peopleListFixture,
          );

          final result = await repo.getPeople();

          expect(
            (result as Right).value,
            PeopleSnapshot(
              data: peopleListFixture,
              updatedAt: dateFixture,
              isSaved: true,
            ),
          );
          verifyInOrder([
            dataSource.readMany(),
            hive.openBox(repo.storageName),
            box.putAll(<String, dynamic>{...snapJsonFixture, 'isSaved': true}),
          ]);
        },
      );

      test(
        'should return Right with PeopleSnapshot and !isSaved',
        () async {
          when(dataSource.readMany(param: anyNamed('param'))).thenAnswer(
            (_) async => peopleListFixture,
          );
          when(box.putAll(any)).thenThrow(HiveError('TEST_ERROR'));

          final result = await repo.getPeople();

          expect(
            (result as Right).value,
            PeopleSnapshot(
              data: peopleListFixture,
              updatedAt: dateFixture,
              isSaved: false,
            ),
          );
          verifyInOrder([
            dataSource.readMany(),
            hive.openBox(repo.storageName),
            box.putAll(<String, dynamic>{...snapJsonFixture, 'isSaved': true}),
          ]);
        },
      );

      test(
        'should return Left with Failure '
        'when data source throws an exception',
        () async {
          when(dataSource.readMany(param: anyNamed('param')))
              .thenThrow(Exception());

          final result = await repo.getPeople();

          expect(
            (result as Left).value,
            Failure<dynamic>(
              name: 'FAILED_TO_RETRIEVE_DATA',
              details: Exception().toString(),
            ),
          );

          verify(dataSource.readMany()).called(1);
        },
      );
    });

    group('load', () {
      tearDown(() {
        verifyInOrder([
          hive.openBox(repo.storageName),
          box.toMap(),
        ]);
      });
      group('should catch', () {
        test('HiveError and converts it into Failure', () async {
          when(box.toMap()).thenThrow(HiveError('TEST_ERROR'));

          final result = await repo.load();

          expect((result as Left).value, Failure(name: 'TEST_ERROR'));
        });
        test('other Exception and converts it into Failure', () async {
          when(box.toMap()).thenThrow(Exception());

          final result = await repo.load();

          expect(
            (result as Left).value,
            Failure<dynamic>(
              name: 'UNEXPECTED_ERROR',
              details: Exception().toString(),
            ),
          );
        });
      });

      test(
        'should set loaded data to repo and return unit',
        () async {
          when(box.toMap()).thenReturn(snapJsonFixture);
          final result = await repo.load();
          expect((result as Right).value, unit);
          expect(repo.data, snapFixture);
        },
      );
    });
  });
}
