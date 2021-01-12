import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/repositories/people_repository.dart';
import 'package:example/use_cases/clear_people_storage.dart';
import 'package:example/use_cases/get_people.dart';
import 'package:example/use_cases/load_people.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

void main() async {
  initArchitecture();

  final result = await GetIt.I<GetPeople>()();

  result.fold(
    (f) => print('[Failed] ${f.toString()}'),
    (d) => print('[Success] ${d.toString()}'),
  );
}

void initArchitecture() {
  EquatableConfig.stringify = true;

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
