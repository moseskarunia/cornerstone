import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

/// If you use this. You have to call `Hive.init()` first. For example:
///
/// ```dart
/// Hive.init(Directory.current.path + '/db');
/// ```
///
/// If you use Flutter, you should install hive_flutter package and use
/// `Hive.initFlutter()`.
mixin CornerstonePersistentRepositoryMixin<Snap>
    on LocallyPersistentRepository<Snap> {
  HiveInterface get hive;
  ConvertToFailure get convertToFailure;

  @override
  @visibleForOverriding
  Future<Either<Failure, Unit>> save() async {
    try {
      final box = await hive.openBox(storageName);
      await box.putAll(asJson);
      return Right(unit);
    } catch (e) {
      return Left(convertToFailure(e));
      // return Left(Failure(name: 'UNEXPECTED_ERROR', details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clear() async {
    try {
      final box = await hive.openBox(storageName);
      await box.clear();
      return Right(unit);
    } catch (e) {
      return Left(convertToFailure(e));
      // return Left(Failure(name: 'UNEXPECTED_ERROR', details: e.toString()));
    }
  }

  /// Loads data from hive and returns the `Map<String,dynamic>` data of
  /// your snapshot. Call it from your load() which overrided from
  /// [LocallyPersistentRepository].
  @protected
  @visibleForTesting
  Future<Either<Failure, Map<String, dynamic>>> loadData() async {
    try {
      final box = await hive.openBox(storageName);

      /// For some reason, this is the only safe way I can get box data as
      /// `Map<String, dynamic>` consistently. Using cast throws an error.
      ///
      /// See this [issue](https://github.com/hivedb/hive/issues/522) if you
      /// want to get updated on this.
      final result = box.toMap().map((k, e) => MapEntry(k.toString(), e));

      return Right(result);
    } catch (e) {
      return Left(convertToFailure(e));
    }
  }
}
