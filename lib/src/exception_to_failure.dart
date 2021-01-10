import 'dart:async';

import 'package:cornerstone/src/cornerstone_exception.dart';
import 'package:cornerstone/src/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// Wrap a function so that if it throws an exception, it will return Left
/// instead.
///
/// If a [CornerstoneException] is thrown, it will be automatically converted
/// into a [Failure].
///
/// Other exceptions will be converted into UNEXPECTED_ERROR Failure.
/// ```dart
/// try {
/// } catch (e) {
///   Failure(
///     name: 'UNEXPECTED_ERROR',
///     details: {
///      'message': e.toString(),
///     }
///   );
/// }
/// ```
class ExceptionToFailure {
  FutureOr<Either<Failure, T>> call<T, P>({
    @required T Function(P) f,
    P params,
  }) async {
    try {
      return Right(await f(params));
    } on CornerstoneException catch (e) {
      return Left(Failure(name: e.name, details: e.details));
    } catch (e) {
      return Left(Failure(
        name: 'UNEXPECTED_ERROR',
        details: <String, dynamic>{'message': e.toString()},
      ));
    }
  }
}
