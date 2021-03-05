import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/data_sources/people_data_source.dart';
import 'package:example/entities/person.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'people_repository.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class PeopleSnapshot extends CornerstoneSnapshot {
  @JsonKey(defaultValue: [])
  final List<Person> data;

  PeopleSnapshot({this.data = const [], required DateTime timestamp})
      : super(clock: const Clock(), timestamp: timestamp);

  @override
  List<Object?> get props => [timestamp, data];

  factory PeopleSnapshot.fromJson(Map json) => _$PeopleSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$PeopleSnapshotToJson(this);
}

/// Equivalent to [PeopleRepository] but this time, the Hive functionality is
/// built-in.
abstract class PeopleRepository
    with
        LocallyPersistentRepository<PeopleSnapshot>,
        CornerstonePersistentRepositoryMixin<PeopleSnapshot> {
  Future<Either<Failure, PeopleSnapshot>> getPeople();
}

class PeopleRepositoryImpl extends PeopleRepository {
  final PeopleDataSource dataSource;
  final Clock clock;
  final HiveInterface hive;
  final ConvertToFailure convertToFailure;
  final ConvertToSnapshot<PeopleSnapshot> convertToSnapshot;

  @override
  PeopleSnapshot snapshot;

  Map<String, dynamic> get asJson => snapshot.toJson();

  PeopleRepositoryImpl({
    required this.dataSource,
    required this.hive,
    required this.convertToFailure,
    required this.convertToSnapshot,
    this.clock = const Clock(),
  }) : snapshot = PeopleSnapshot(timestamp: clock.now());

  @override
  Future<Either<Failure, PeopleSnapshot>> getPeople() async {
    try {
      final results = await dataSource.readMany();

      snapshot = PeopleSnapshot(data: results, timestamp: clock.now());

      final saveResult = await save();

      if (saveResult.isLeft()) {
        snapshot = PeopleSnapshot(data: snapshot.data, timestamp: clock.now());
      }

      return Right(snapshot);
    } catch (e) {
      return Left(convertToFailure(e));
    }
  }
}

class ConvertPeopleExceptionToFailure extends ConvertToFailure {
  @override
  Failure call(dynamic e) {
    if (e is CornerstoneException) {
      return Failure(name: e.name, details: e);
    }
    return Failure(name: 'err.app.UNEXPECTED_ERROR', details: e);
  }
}

class ConvertToPeopleSnapshot extends ConvertToSnapshot<PeopleSnapshot> {
  @override
  PeopleSnapshot call(Map<String, dynamic> data) =>
      PeopleSnapshot.fromJson(data);
}
