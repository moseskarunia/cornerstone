import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

mixin HivePersistenceRepositoryMixin<T> on LocallyPersistentRepository<T> {
  HiveInterface get hive;

  @override
  @visibleForOverriding
  Future<Either<Failure, Unit>> save() async {
    try {
      final box = await hive.openBox(storageName);
      await box.putAll(asJson);
      return Right(unit);
    } on HiveError catch (e) {
      return Left(Failure(name: e.message));
    } catch (e) {
      return Left(Failure(name: 'UNEXPECTED_ERROR', details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clear() async {
    try {
      final box = await hive.openBox(storageName);
      await box.clear();
      return Right(unit);
    } on HiveError catch (e) {
      return Left(Failure(name: e.message));
    } catch (e) {
      return Left(Failure(name: 'UNEXPECTED_ERROR', details: e.toString()));
    }
  }
}
