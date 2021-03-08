import 'dart:async';

import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/people_repository.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'people_repository_test.mocks.dart';

class MockBox extends Mock implements Box {
  @override
  Future<void> putAll(Map entries) async =>
      await super.noSuchMethod(Invocation.method(#putAll, [entries]));

  @override
  Future<int> clear() async =>
      await super.noSuchMethod(Invocation.method(#clear, []), returnValue: 0);

  @override
  Map toMap() => super.noSuchMethod(Invocation.method(#toMap, []),
      returnValue: <String, dynamic>{});
}

class MockConvertToFailure extends Mock implements ConvertToFailure<Object> {
  @override
  Failure<Object> call(dynamic e) =>
      super.noSuchMethod(Invocation.method(#call, [e]),
          returnValue: Failure<Object>(name: 'err.app.TEST_ERROR', details: e));
}

class MockConvertToSnapshot extends Mock
    implements ConvertToSnapshot<PeopleSnapshot> {
  @override
  PeopleSnapshot call(Map data) =>
      super.noSuchMethod(Invocation.method(#call, [data]),
          returnValue: PeopleSnapshot(timestamp: DateTime(2020, 10, 10)));
}

class MockDataSource extends Mock implements PeopleDataSource {
  @override
  FutureOr<List<Person>> readMany({Unit param = unit}) async =>
      await super.noSuchMethod(Invocation.method(#readMany, [unit]),
          returnValue: <Person>[]);
}

@GenerateMocks([HiveInterface])
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
    'timestamp': dateFixture.toUtc().toIso8601String(),
    'data': jsonListFixture,
  };

  final snapFixture = PeopleSnapshot(
    data: peopleListFixture,
    timestamp: dateFixture,
  );

  final clockFixture = Clock.fixed(DateTime(2020, 10, 10));
  group('PeopleRepository', () {
    late MockBox box;
    late MockHiveInterface hive;
    late MockConvertToFailure convertToFailure;
    late MockConvertToSnapshot convertToSnapshot;
    late PeopleRepositoryImpl repo;
    late PeopleDataSource dataSource;

    setUp(() {
      box = MockBox();
      hive = MockHiveInterface();
      convertToFailure = MockConvertToFailure();
      convertToSnapshot = MockConvertToSnapshot();
      dataSource = MockDataSource();

      repo = PeopleRepositoryImpl(
        hive: hive,
        convertToFailure: convertToFailure,
        convertToSnapshot: convertToSnapshot,
        clock: clockFixture,
        dataSource: dataSource,
      );
      when(hive.openBox(any)).thenAnswer((_) async => box);
    });

    group('PeopleSnapshot', () {
      test('props', () {
        expect(snapFixture.props, [dateFixture, peopleListFixture]);
      });
      test('fromJson', () {
        expect(PeopleSnapshot.fromJson(snapJsonFixture), snapFixture);
      });
      test('toJson', () {
        expect(snapFixture.toJson(), snapJsonFixture);
      });
    });

    test('storageName', () {
      expect(repo.storageName, 'PeopleRepositoryImpl');
    });
    test('asJson', () {
      repo.snapshot = snapFixture;
      expect(repo.asJson, snapJsonFixture);
    });
    test('initial snapshot', () {
      expect(repo.snapshot, PeopleSnapshot(timestamp: clockFixture.now()));
    });

    group('getPeople', () {
      test(
        'should return Right with PeopleSnapshot',
        () async {
          when(dataSource.readMany()).thenAnswer(
            (_) async => peopleListFixture,
          );

          final result = await repo.getPeople();

          expect(
            (result as Right).value,
            PeopleSnapshot(data: peopleListFixture, timestamp: dateFixture),
          );
          verifyInOrder([
            dataSource.readMany(),
            hive.openBox(repo.storageName),
            box.putAll(snapJsonFixture),
          ]);
        },
      );

      test(
        'should return Left with result of convertToFailure',
        () async {
          final e = Exception();
          when(dataSource.readMany()).thenThrow(e);
          when(convertToFailure(e)).thenReturn(
            Failure<Object>(name: 'err.app.TEST_ERROR', details: e),
          );

          final result = await repo.getPeople();

          expect(
            (result as Left).value,
            Failure<Object>(name: 'err.app.TEST_ERROR', details: e),
          );

          verify(dataSource.readMany()).called(1);
        },
      );
    });
  });
  group('ConvertToPeopleSnapshot', () {
    final converter = const ConvertToPeopleSnapshot();
    test('should convert from Map', () {
      expect(converter(snapJsonFixture), snapFixture);
    });
  });
}
