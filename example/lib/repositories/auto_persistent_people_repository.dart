import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/entities/person.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'auto_persistent_people_repository.g.dart';

@JsonSerializable(explicitToJson: true)
class NewPeopleSnapshot extends CornerstoneSnapshot {
  @JsonKey(defaultValue: [])
  final List<Person> data;

  NewPeopleSnapshot({this.data = const [], DateTime timestamp})
      : super(clock: const Clock(), timestamp: timestamp);

  @override
  List<Object> get props => [timestamp, data];

  factory NewPeopleSnapshot.fromJson(Map json) =>
      _$NewPeopleSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$NewPeopleSnapshotToJson(this);
}

/// Equivalent to [PeopleRepository] but this time, the Hive functionality is
/// built-in.
abstract class AutoPersistentPeopleRepository
    with
        LocallyPersistentRepository<NewPeopleSnapshot>,
        CornerstonePersistentRepositoryMixin<NewPeopleSnapshot> {
  Future<Either<Failure, NewPeopleSnapshot>> getPeople();
}

class AutoPersistentPeopleRepositoryImpl
    extends AutoPersistentPeopleRepository {
  final Clock clock;
  final HiveInterface hive;
  final ConvertToFailure convertToFailure;
  final ConvertToSnapshot<Map<String, dynamic>, NewPeopleSnapshot>
      convertToSnapshot;

  @override
  NewPeopleSnapshot snapshot;

  Map<String, dynamic> get asJson => snapshot.toJson();

  AutoPersistentPeopleRepositoryImpl({
    @required this.hive,
    @required this.convertToFailure,
    @required this.convertToSnapshot,
    this.clock = const Clock(),
  }) : snapshot = NewPeopleSnapshot(timestamp: (const Clock()).now());

  @override
  Future<Either<Failure, NewPeopleSnapshot>> getPeople() {
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
