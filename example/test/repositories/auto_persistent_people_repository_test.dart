import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/auto_persistent_people_repository.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'auto_persistent_people_repository_test.mocks.dart';

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

class MockConvertToFailure extends Mock implements ConvertToFailure {
  @override
  Failure call(dynamic e) => super.noSuchMethod(Invocation.method(#call, [e]),
      returnValue: Failure<dynamic>(name: 'err.app.TEST_ERROR', details: e));
}

class MockConvertToSnapshot extends Mock
    implements ConvertToSnapshot<NewPeopleSnapshot> {
  @override
  NewPeopleSnapshot call(Map data) =>
      super.noSuchMethod(Invocation.method(#call, [data]),
          returnValue: NewPeopleSnapshot(timestamp: DateTime(2020, 10, 10)));
}

@GenerateMocks([HiveInterface])
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

    late MockBox box;
    late MockHiveInterface hive;
    late MockConvertToFailure convert;
    late MockConvertToSnapshot convertToSnapshot;
    late AutoPersistentPeopleRepositoryImpl repo;

    setUp(() {
      box = MockBox();
      hive = MockHiveInterface();
      convert = MockConvertToFailure();
      convertToSnapshot = MockConvertToSnapshot();

      repo = AutoPersistentPeopleRepositoryImpl(
        hive: hive,
        convertToFailure: convert,
        convertToSnapshot: convertToSnapshot,
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

    test('storageName should be AutoPersistentPeopleRepositoryImpl', () {
      expect(repo.storageName, 'AutoPersistentPeopleRepositoryImpl');
    });
    test('asJson', () {
      repo.snapshot = snapFixture;
      expect(repo.asJson, snapJsonFixture);
    });

    test('getPeople should throw UnimplementedError', () {
      expectLater(() => repo.getPeople(), throwsA(isA<UnimplementedError>()));
    });
  });
}
