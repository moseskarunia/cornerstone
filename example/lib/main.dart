import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/repositories/people_repositories.dart';
import 'package:example/use_cases/get_people.dart';
import 'package:get_it/get_it.dart';

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
    () => PeopleRepositoryImpl(dataSource: GetIt.I()),
  );
  GetIt.I.registerLazySingleton(() => GetPeople(repo: GetIt.I()));
}
