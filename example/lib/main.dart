import 'dart:convert';
import 'dart:io';

import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/repositories/people_repository.dart';
import 'package:example/use_cases/clear_people_storage.dart';
import 'package:example/use_cases/get_people.dart';
import 'package:example/use_cases/load_people.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

void main() async {
  initArchitecture();

  DateFormat formatter = DateFormat('EEE, dd MMM yyyy (HH:mm:ss)', 'en_US');

  String selectedOption;

  do {
    print(
      '==================================================\n'
      '## Select one option and press enter ##\n\n'
      '0. Exit\n'
      '1. Get people data from server\n'
      '2. Load locally-stored data\n'
      '3. Clear locally-stored data\n\n'
      'Enter your choice = ',
    );

    selectedOption = stdin.readLineSync(encoding: Encoding.getByName('utf-8'));

    if (selectedOption == '0') {
      print('Bye bye!\n');
    } else if (selectedOption == '1' || selectedOption == '2') {
      print('Please wait...\n');
      Either<Failure, PeopleSnapshot> result;
      switch (selectedOption) {
        case '1':
          result = await GetIt.I<GetPeople>()();
          break;
        case '2':
          result = await GetIt.I<LoadPeople>()();
          break;
      }

      result.fold(
        (f) => print('[FAILED]\n${f.toString()}\n'),
        (d) {
          print(
            '[SUCCESS]\n'
            'Data Fetched At = ${d.updatedAt != null ? formatter.format(d.updatedAt) : 'N/A'}\n'
            'Stored Locally? = ${d.isSaved}\n'
            'Data = ${d.data}\n\n'
            'Current Time = ${formatter.format(DateTime.now())}\n',
          );
        },
      );
    } else if (selectedOption == '3') {
      final result = await GetIt.I<ClearPeopleStorage>()();

      result.fold(
        (f) => print('[FAILED]\n${f.toString()}\n'),
        (d) => print('[SUCCESS]\n${d.toString()}'),
      );
    } else {
      print('Unexpected option. Please see the hint.\n');
    }
  } while (selectedOption != '0');
  print('==================================================\n');
}

void initArchitecture() {
  EquatableConfig.stringify = true;

  Hive.init(Directory.current.path + '/db');

  GetIt.I.registerLazySingleton(() => Dio());
  GetIt.I.registerLazySingleton<PeopleDataSource>(
    () => PeopleDataSourceImpl(client: GetIt.I()),
  );
  GetIt.I.registerLazySingleton<PeopleRepository>(
    () => PeopleRepositoryImpl(dataSource: GetIt.I(), hive: Hive),
  );
  GetIt.I.registerLazySingleton(() => GetPeople(repo: GetIt.I()));
  GetIt.I.registerLazySingleton(() => LoadPeople(repo: GetIt.I()));
  GetIt.I.registerLazySingleton(() => ClearPeopleStorage(repo: GetIt.I()));
}
