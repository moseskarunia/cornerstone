import 'package:cornerstone/cornerstone.dart';
import 'package:dio/dio.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/entities/person.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

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

  late MockDio client;
  late PeopleDataSource dataSource;

  setUp(() {
    client = MockDio();
    dataSource = PeopleDataSourceImpl(client: client);
  });

  test(
    'PeopleDataSource read should call jsonplaceholder.typicode.com/users '
    'and return a list of people',
    () async {
      final response = MockResponse();
      when(() => response.data).thenReturn(jsonListFixture);
      when(() => client.get('https://jsonplaceholder.typicode.com/users'))
          .thenAnswer((_) async => response);

      final results = await dataSource.readMany();

      expect(results, peopleListFixture);
    },
  );

  test(
    'PeopleDataSource should encapsulate thrown exceptions '
    'with CornerstoneException',
    () async {
      final dioErrorFixture = DioError(
        type: DioErrorType.response,
        error: <String, dynamic>{'status': 400},
      );
      when(() => client.get('https://jsonplaceholder.typicode.com/users'))
          .thenThrow(dioErrorFixture);

      await expectLater(
        () async => await dataSource.readMany(),
        throwsA(CornerstoneException<dynamic>(
          name: 'err.app.UNEXPECTED_ERROR',
          details: dioErrorFixture,
        )),
      );
    },
  );
}
