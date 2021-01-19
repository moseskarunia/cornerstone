import 'package:cornerstone/cornerstone.dart';
import 'package:cornerstone/src/converter.dart';
import 'package:cornerstone/src/cornerstone_snapshot.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// Repository with built-in getter to multiple `GetterDataSource`s.
///
/// For Snapshot, you can use [CornerstoneSnapshot] for some built-in
/// conveniences (not mandatory).
///
/// You just need to override [safelyGetMultiple] and call [getMultiple] to use.
/// When called, [getMultiple] will call your [safelyGetMultiple] wrapped
/// in a try-catch block. If it turns out [safelyGetMultiple] throws
/// an Exeption, it will returns Left with [Failure] produced by
/// [convertExceptionToFailure].
mixin MultipleGetterRepository<Type, Snapshot, Param> {
  MultipleGetterDataSource<Type, Param> get multipleGetterDataSource;
  ConvertExceptionToFailure get convertExceptionToFailure;

  /// Calls [safelyGetMultiple] wrapped in a try catch block.
  ///
  /// In most cases, you just need to override [convertExceptionToFailure]
  /// and [safelyGet].
  Future<Either<Failure, Snapshot>> getMultiple({Param param}) async {
    try {
      return Right(await safelyGetMultiple(param: param));
    } catch (e) {
      return Left(convertExceptionToFailure(e));
    }
  }

  /// In most cases, you just need to override this & leave [getMultiple] as-is.
  /// No need to handle exception here.
  @visibleForOverriding
  @visibleForTesting
  Future<Snapshot> safelyGetMultiple({Param param});
}
