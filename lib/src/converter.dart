import 'package:cornerstone/src/failure.dart';

/// Accepts an exeption and return equivalent failure.
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
///   Failure<dynamic> call(Exception e) {
///     if(e is MyException) {
///       return Failure(name: e.name, details: e.details);
///     } else {
///       return Failure(name: 'UNEXPECTED_ERROR', details: e.toString());
///     }
///   }
/// }
/// ```
abstract class ConvertExceptionToFailure<T> {
  Failure<T> call(Exception e);
}
