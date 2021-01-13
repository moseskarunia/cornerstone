import 'package:dio/dio.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/entities/person.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockClient extends Mock implements Dio {}

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
  MockClient client;
  PeopleDataSource dataSource;

  setUp(() {
    client = MockClient();
    dataSource = PeopleDataSourceImpl(client: client);
  });

  test(
    'PeopleDataSource read should call jsonplaceholder.typicode.com/users '
    'and return a list of people',
    () async {
      final response = MockResponse();
      when(response.data).thenReturn(jsonListFixture);
      when(client.get(any)).thenAnswer((_) async => response);

      final results = await dataSource.readMany();

      expect(results, peopleListFixture);

      verify(client.get('https://jsonplaceholder.typicode.com/users'));
    },
  );
}
