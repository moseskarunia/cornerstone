import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/hive_persistence_repository_mixin.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'people_repository.g.dart';

abstract class PeopleRepository extends LocallyPersistentRepository
    with HivePersistenceRepositoryMixin {
  Future<Either<Failure, List<Person>>> getPeople();
}

@JsonSerializable(explicitToJson: true)
class PeopleRepositoryImpl extends PeopleRepository {
  @JsonKey(ignore: true)
  final PeopleDataSource dataSource;

  @JsonKey(ignore: true)
  final HiveInterface hive;

  @JsonKey(fromJson: _$dateTimeFromJson, toJson: _$dateTimeToJson)
  DateTime updatedAt;

  @JsonKey(defaultValue: [])
  List<Person> data = [];

  Map<String, dynamic> get asJson => _$PeopleRepositoryImplToJson(this);

  PeopleRepositoryImpl({
    @required this.dataSource,
    @required this.hive,
    this.data,
    this.updatedAt,
  });

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
  Future<Either<Failure, Unit>> load() async {
    try {
      final box = await hive.openBox(storageName);

      /// For some reason, this is the only safe way I can get box data as
      /// Map<String, dynamic> consistently. Using cast throws an error.
      ///
      /// See this [issue](https://github.com/hivedb/hive/issues/522) if you
      /// want to get updated on this.
      final result = box.toMap().map((k, e) => MapEntry(k.toString(), e));
      final val = _$PeopleRepositoryImplFromJson(result);

      data = val.data;
      updatedAt = val.updatedAt;

      return Right(unit);
    } on HiveError catch (e) {
      return Left(Failure(name: e.message));
    } catch (e) {
      return Left(Failure(name: 'UNEXPECTED_ERROR', details: e.toString()));
    }
  }
}

/// Parse string date to DateTime object
DateTime _$dateTimeFromJson(String date) =>
    date != null && date.isNotEmpty ? DateTime.parse(date).toLocal() : null;

/// Parse DateTime object to String
String _$dateTimeToJson(DateTime date) =>
    date != null ? date.toUtc().toIso8601String() : null;
