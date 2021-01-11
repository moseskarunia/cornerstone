import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/people_repositories.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockDataSource extends Mock implements PeopleDataSource {}

void main() {
  final peopleListFixture = [
    Person(id: '123', name: 'John Doe', email: 'johndoe@test.com'),
    Person(id: '456', name: 'Tony Stark', email: 'tony@starkindustries.com'),
  ];
  MockDataSource dataSource;
  PeopleRepositoryImpl repo;

  setUp(() {
    dataSource = MockDataSource();
    repo = PeopleRepositoryImpl(dataSource: dataSource);
  });

  group('PeopleRepositoryImpl', () {
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
            Failure(name: 'FAILED_TO_RETRIEVE_DATA'),
          );
        },
      );
    });
  });
}
