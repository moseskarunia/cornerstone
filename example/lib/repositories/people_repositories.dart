import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/entities/person.dart';
import 'package:meta/meta.dart';

abstract class PeopleRepository {
  Future<Either<Failure, List<Person>>> getPeople();
}

class PeopleRepositoryImpl extends PeopleRepository {
  final PeopleDataSource dataSource;

  PeopleRepositoryImpl({@required this.dataSource});

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
}
