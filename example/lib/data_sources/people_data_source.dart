import 'dart:async';

import 'package:example/entities/person.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:dio/dio.dart';

abstract class PeopleDataSource extends MultipleGetterDataSource<Person, Null> {
}

class PeopleDataSourceImpl extends PeopleDataSource {
  /// It'll be better if you interface this client with your own class
  final Dio client;

  PeopleDataSourceImpl({required this.client});

  @override
  FutureOr<List<Person>> readMany({Null param}) async {
    final result = await client.get(
      'https://jsonplaceholder.typicode.com/users',
    );

    return List<dynamic>.from(result.data)
        .map((e) => Person.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
