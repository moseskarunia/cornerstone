import 'package:cornerstone/src/core/failure.dart';

/// Accepts an exeption and return equivalent failure. A reusable model to make
/// your repository functions doesn't need to keep testing exception handling.
/// Just mock it and off you go.
///
/// Example usage:
///
/// ```dart
/// class Exception extends Equatable implements Exception {
///   final String name;
///   final Map<String,dynamic> details;
///
///   /// Other codes
/// }
///
/// class ConvertMyExceptionToFailure<dynamic>{
///   Failure<dynamic> call(dynamic e) {
///     if(e is MyException) {
///       return Failure(name: e.name, details: e.details);
///     } else {
///       return Failure(name: 'UNEXPECTED_ERROR', details: e);
///     }
///   }
/// }
/// ```
abstract class ConvertExceptionToFailure<T> {
  Failure<T> call(dynamic e);
}
