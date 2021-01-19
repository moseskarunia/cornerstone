import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/people_multiple_getter_repository.dart';
import 'package:example/repositories/people_repository.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockDataSource extends Mock implements PeopleDataSource {}

class MockHive extends Mock implements HiveInterface {}

class MockBox extends Mock implements Box {}

class MockConvert extends Mock implements ConvertExceptionToFailure {}

void main() {
  group('ConvertPeopleExceptionToFailure', () {
    ConvertPeopleExceptionToFailure convert;

    setUp(() {
      convert = ConvertPeopleExceptionToFailure();
    });
    test('should return Failure FAILED_TO_RETRIEVE_DATA', () {
      expect(
        convert(DioError(error: 'lorem ipsum')),
        Failure<dynamic>(
          name: 'FAILED_TO_RETRIEVE_DATA',
          details: DioError(error: 'lorem ipsum').toString(),
        ),
      );
    });
    test('should return Failure equal to HiveError message', () {
      expect(convert(HiveError('lorem ipsum')), Failure(name: 'lorem ipsum'));
    });
    test('should return Failure UNEXPECTED_ERROR with details', () {
      expect(
        convert(Exception()),
        Failure<dynamic>(
            name: 'UNEXPECTED_ERROR', details: Exception().toString()),
      );
    });
    test('should return Failure UNEXPECTED_ERROR without details', () {
      expect(convert('a'), Failure(name: 'UNEXPECTED_ERROR'));
    });
  });

  group('PeopleMultipleGetterRepositoryImpl', () {
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
    MockConvert convert;
    PeopleMultipleGetterRepositoryImpl repo;
    setUp(() {
      box = MockBox();
      hive = MockHive();
      dataSource = MockDataSource();
      convert = MockConvert();

      repo = PeopleMultipleGetterRepositoryImpl(
        multipleGetterDataSource: dataSource,
        hive: hive,
        convertExceptionToFailure: convert,
        clock: Clock.fixed(DateTime(2020, 10, 10)),
      );
      when(hive.openBox(any)).thenAnswer((_) async => box);
    });

    test('storageName should be PeopleMultipleGetterRepositoryImpl', () {
      expect(repo.storageName, 'PeopleMultipleGetterRepositoryImpl');
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

          final result = await repo.getMultiple();

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

          final result = await repo.getMultiple();

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
        'should return Left with Failure and call convert'
        'when data source throws an exception',
        () async {
          final e = Exception();
          when(dataSource.readMany(param: anyNamed('param'))).thenThrow(e);
          when(convert(any)).thenReturn(Failure<dynamic>(
            name: 'TEST_ERROR',
            details: Exception().toString(),
          ));

          final result = await repo.getMultiple();

          expect(
            (result as Left).value,
            Failure<dynamic>(
              name: 'TEST_ERROR',
              details: Exception().toString(),
            ),
          );

          verifyInOrder([dataSource.readMany(), convert(e)]);
        },
      );
    });

    group('load', () {
      test('should catch exception', () async {
        final e = HiveError('TEST_ERROR');
        when(hive.openBox(any)).thenThrow(e);
        when(convert(any)).thenReturn(Failure<dynamic>(name: 'TEST_ERROR'));

        final result = await repo.load();

        expect(
          (result as Left).value,
          Failure<dynamic>(name: 'TEST_ERROR'),
        );
        verifyInOrder([hive.openBox(repo.storageName), convert(e)]);
      });

      test('should set loaded data to repo and return the data', () async {
        when(box.toMap()).thenReturn({...snapJsonFixture, 'isSaved': true});
        final result = await repo.load();
        expect(
          repo.data,
          PeopleSnapshot(
            data: peopleListFixture,
            updatedAt: dateFixture,
            isSaved: true,
          ),
        );
        expect(
          (result as Right).value,
          PeopleSnapshot(
            data: peopleListFixture,
            updatedAt: dateFixture,
            isSaved: true,
          ),
        );
        verifyInOrder([
          hive.openBox(repo.storageName),
          box.toMap(),
        ]);
      });
    });
  });
}
