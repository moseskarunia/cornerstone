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
/// If you use this form a Flutter project, you should also install
/// [hive_flutter](https://pub.dev/packages/hive_flutter) package and use
/// `Hive.initFlutter()` instead of `Hive.init()`
mixin CornerstonePersistentRepositoryMixin<Snap>
    on LocallyPersistentRepository<Snap> {
  HiveInterface get hive;
  ConvertToFailure<Object> get convertToFailure;
  ConvertToSnapshot<Snap> get convertToSnapshot;

  /// Snapshot of this repo. Need to be named [snapshot] to make it accessible
  /// accessible from mixin. This is late-typed, so it MUST have a default value
  /// at the start of this class initialization to make it always non-nullable
  /// afterward.
  late Snap snapshot;

  @override
  @visibleForOverriding
  Future<Either<Failure, Unit>> save() async {
    try {
      final box = await hive.openBox(storageName);
      await box.putAll(asJson);
      return Right(unit);
    } catch (e) {
      return Left(convertToFailure(e));
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
    }
  }

  /// Load data from local storage. If empty, will return:
  ///
  /// ```dart
  /// Left(Failure(
  ///    name: 'err.cornerstone.EMPTY_LOCAL_STORAGE',
  ///    details: <String, dynamic>{'storageName': storageName},
  /// ));
  /// ```
  ///
  /// If you need to return empty snapshot instead, you can make a conditional
  /// block in your use case that checks err.cornerstone.EMPTY_LOCAL_STORAGE
  /// as failure name.
  @override
  Future<Either<Failure, Snap>> load() async {
    try {
      final box = await hive.openBox(storageName);

      if (box.toMap().isEmpty) {
        return Left(Failure<Object>(
          name: 'err.cornerstone.EMPTY_LOCAL_STORAGE',
          details: <String, dynamic>{'storageName': storageName},
        ));
      }

      /// For some reason, this is the only safe way I can get box data as
      /// `Map<String, dynamic>` (Using cast throws an error).
      ///
      /// Don't forget to add `anyMap: true` to your snapshot's
      /// `@JsonSerializable` annotation.
      ///
      /// See this [issue](https://github.com/hivedb/hive/issues/522) if you
      /// want to get updated on this.
      final result = box.toMap().map((k, e) => MapEntry(k.toString(), e));

      snapshot = convertToSnapshot(result);

      return Right(snapshot);
    } catch (e) {
      return Left(convertToFailure(e));
    }
  }
}
