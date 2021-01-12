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

void main() {
  final peopleListFixture = [
    Person(id: 123, name: 'John Doe', email: 'johndoe@test.com'),
    Person(id: 456, name: 'Tony Stark', email: 'tony@starkindustries.com'),
  ];
  MockHive hive;
  MockDataSource dataSource;
  PeopleRepositoryImpl repo;

  setUp(() {
    hive = MockHive();
    dataSource = MockDataSource();
    repo = PeopleRepositoryImpl(
      dataSource: dataSource,
      hive: hive,
    );
  });

  group('PeopleRepositoryImpl', () {
    test('asJson', () {});
    group('getPeople', () {
      tearDown(() {
        verify(dataSource.readMany()).called(1);
      });
      test(
        'should return Right with list of people',
        () async {
          when(dataSource.readMany(param: anyNamed('param'))).thenAnswer(
            (_) async => peopleListFixture,
          );

          final result = await repo.getPeople();

          expect((result as Right).value, peopleListFixture);
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
        },
      );
    });
  });
}
