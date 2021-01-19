import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:cornerstone/src/converter.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/hive_persistence_repository_mixin.dart';
import 'package:example/repositories/people_repository.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

/// Equivalent to [PeopleRepository] but this time, I use
/// [MultipleGetterRepository]. This class won't actually be used.
/// Use it just for usage comparison.
abstract class PeopleMultipleGetterRepository
    extends LocallyPersistentRepository<PeopleSnapshot>
    with
        HivePersistenceRepositoryMixin<PeopleSnapshot>,
        MultipleGetterRepository<Person, PeopleSnapshot, Null> {}

class PeopleMultipleGetterRepositoryImpl
    extends PeopleMultipleGetterRepository {
  final Clock clock;

  final HiveInterface hive;

  @override
  final MultipleGetterDataSource<Person, Null> multipleGetterDataSource;

  @override
  final ConvertExceptionToFailure convertExceptionToFailure;

  PeopleSnapshot data = PeopleSnapshot();

  Map<String, dynamic> get asJson => data.toJson();

  PeopleMultipleGetterRepositoryImpl({
    @required this.hive,
    @required this.multipleGetterDataSource,
    @required this.convertExceptionToFailure,
    this.clock = const Clock(),
  });

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
    } catch (e) {
      return Left(convertExceptionToFailure(e));
    }
  }

  @override
  Future<PeopleSnapshot> safelyGetMultiple({Null param}) async {
    final results = await multipleGetterDataSource.readMany();

    data = PeopleSnapshot(
      data: results,
      updatedAt: clock.now(),
      isSaved: true,
    );

    final saveResult = await save();

    if (saveResult.isLeft()) {
      data = PeopleSnapshot(data: data.data, updatedAt: data.updatedAt);
    }

    return data;
  }
}

class ConvertPeopleExceptionToFailure extends ConvertExceptionToFailure {
  @override
  Failure call(dynamic e) {
    if (e is HiveError) {
      return Failure(name: e.message);
    } else if (e is DioError) {
      return Failure(name: 'FAILED_TO_RETRIEVE_DATA', details: e.toString());
    } else if (e is Exception) {
      return Failure(name: 'UNEXPECTED_ERROR', details: e.toString());
    } else {
      return Failure(name: 'UNEXPECTED_ERROR');
    }
  }
}
