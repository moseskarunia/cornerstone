import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/entities/person.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'people_repository_with_built_in_hive.g.dart';

@JsonSerializable(explicitToJson: true)
class PeopleSnapshot extends CornerstoneSnapshot {
  @JsonKey(defaultValue: [])
  final List<Person> data;

  PeopleSnapshot({this.data = const [], DateTime timestamp})
      : super(clock: const Clock(), timestamp: timestamp);

  @override
  List<Object> get props => [timestamp, data];

  factory PeopleSnapshot.fromJson(Map json) => _$PeopleSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$PeopleSnapshotToJson(this);
}

/// Equivalent to [PeopleRepository] but this time, the Hive functionality is
/// built-in.
abstract class PeopleRepoWithBuiltInHive
    with
        LocallyPersistentRepository<PeopleSnapshot>,
        HivePersistentRepositoryMixin<PeopleSnapshot> {
  Future<Either<Failure, PeopleSnapshot>> getPeople();
}

class PeopleRepoWithBuiltInHiveImpl extends PeopleRepoWithBuiltInHive {
  final Clock clock;
  final HiveInterface hive;
  @override
  final ConvertToFailure convertToFailure;

  PeopleSnapshot data = PeopleSnapshot(timestamp: (const Clock()).now());

  Map<String, dynamic> get asJson => data.toJson();

  PeopleRepoWithBuiltInHiveImpl({
    @required this.hive,
    @required this.convertToFailure,
    this.clock = const Clock(),
  });

  @override
  Future<Either<Failure, PeopleSnapshot>> load() async {
    try {
      final result = await loadData();

      if (result.isLeft()) {
        return Left((result as Left).value);
      }

      data = PeopleSnapshot.fromJson((result as Right).value);

      return Right(data);
    } catch (e) {
      return Left(convertToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PeopleSnapshot>> getPeople() {
    /// The implementation is identical to the one in [PeopleRepository],
    /// so I won't rewrite it again for brevity.
    throw UnimplementedError();
  }
}

/// You can reuse this across many repositories and many repo's functions.
/// The efficiency gain will be more impactful in a large project.
///
/// Since [PeopleMultipleGetterRepositoryImpl] is not actually used besides
/// in test, then this implementation is commented out. Mocked object will be
/// used in test.
///
// class ConvertPeopleExceptionToFailure extends ConvertToFailure {
//   @override
//   Failure call(dynamic e) {
//     if (e is HiveError) {
//       return Failure(name: e.message);
//     } else if (e is DioError) {
//       return Failure(name: 'FAILED_TO_RETRIEVE_DATA', details: e.toString());
//     } else if (e is Exception) {
//       return Failure(name: 'UNEXPECTED_ERROR', details: e.toString());
//     } else {
//       return Failure(name: 'UNEXPECTED_ERROR');
//     }
//   }
// }
