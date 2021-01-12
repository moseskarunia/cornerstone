import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/hive_persistence_repository_mixin.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

abstract class PeopleRepository extends LocallyPersistentRepository
    with HivePersistenceRepositoryMixin {
  Future<Either<Failure, List<Person>>> getPeople();
}

class PeopleRepositoryImpl extends PeopleRepository {
  final PeopleDataSource dataSource;
  final HiveInterface hive;

  Map<String, dynamic> get asJson => <String, dynamic>{};

  PeopleRepositoryImpl({@required this.dataSource, @required this.hive});

  @override
  Future<Either<Failure, List<Person>>> getPeople() async {
    try {
      final results = await dataSource.readMany();
      return Right(results);
    } catch (e) {
      return Left(Failure(
        name: 'FAILED_TO_RETRIEVE_DATA',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> load() {
    throw UnimplementedError();
  }
}
