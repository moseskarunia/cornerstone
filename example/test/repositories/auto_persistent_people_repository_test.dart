import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
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

class MockConvertToSnapshot extends Mock
    implements ConvertToSnapshot<Map<String, dynamic>, NewPeopleSnapshot> {}

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
    MockConvertToSnapshot convertToSnapshot;
    AutoPersistentPeopleRepositoryImpl repo;

    setUp(() {
      box = MockBox();
      hive = MockHive();
      convert = MockConvert();
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
