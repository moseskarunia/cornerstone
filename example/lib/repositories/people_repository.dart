import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/hive_persistence_repository_mixin.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'people_repository.g.dart';

abstract class PeopleRepository
    with
        LocallyPersistentRepository<PeopleSnapshot>,
        HivePersistenceRepositoryMixin<PeopleSnapshot> {
  Future<Either<Failure, PeopleSnapshot>> getPeople();
}

/// Remember to use `anyMap: true` if you use Hive because otherwise will throw:
///
/// ```sh
/// type '_InternalLinkedHashMap<dynamic, dynamic>' is not a subtype of type
/// 'Map<String, dynamic>' in type cast)
/// ```
@JsonSerializable(explicitToJson: true, checked: true, anyMap: true)
class PeopleSnapshot extends Equatable {
  @JsonKey(fromJson: _$dateTimeFromJson, toJson: _$dateTimeToJson)
  final DateTime updatedAt;

  @JsonKey(defaultValue: [])
  final List<Person> data;

  @JsonKey(defaultValue: false)
  final bool isSaved;

  const PeopleSnapshot({
    this.updatedAt,
    this.data = const [],
    this.isSaved = false,
  });

  factory PeopleSnapshot.fromJson(Map json) => _$PeopleSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$PeopleSnapshotToJson(this);

  @override
  List<Object> get props => [updatedAt, isSaved, data];
}

class PeopleRepositoryImpl extends PeopleRepository {
  final PeopleDataSource dataSource;
  final HiveInterface hive;
  final Clock clock;

  PeopleSnapshot data = PeopleSnapshot();

  Map<String, dynamic> get asJson => data.toJson();

  PeopleRepositoryImpl({
    @required this.dataSource,
    @required this.hive,
    this.clock = const Clock(),
  });

  @override
  Future<Either<Failure, PeopleSnapshot>> getPeople() async {
    try {
      final results = await dataSource.readMany();

      data = PeopleSnapshot(
        data: results,
        updatedAt: clock.now(),
        isSaved: true,
      );

      final saveResult = await save();

      if (saveResult.isLeft()) {
        data = PeopleSnapshot(data: data.data, updatedAt: data.updatedAt);
      }

      return Right(data);
    } catch (e) {
      return Left(Failure(
        name: 'FAILED_TO_RETRIEVE_DATA',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, PeopleSnapshot>> load() async {
    try {
      final box = await hive.openBox(storageName);

      /// For some reason, this is the only safe way I can get box data as
      /// Map<String, dynamic> consistently. Using cast throws an error.
      ///
      /// See this [issue](https://github.com/hivedb/hive/issues/522) if you
      /// want to get updated on this.
      final result = box.toMap().map((k, e) => MapEntry(k.toString(), e));
      data = PeopleSnapshot.fromJson(result);

      return Right(data);
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
