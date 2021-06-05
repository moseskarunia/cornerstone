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
/// class ConvertMyExceptionToFailure<Object>{
///   Failure<Object?> call(Object e) {
///     if(e is MyException) {
///       return Failure<Object?>(name: e.name, details: e.details);
///     } else {
///       return Failure<Object?>(name: 'UNEXPECTED_ERROR', details: e);
///     }
///   }
/// }
/// ```
///
/// To get stackTrace data, add stackTrace in your catch block
///
/// ```dart
/// try {
///   // Your code
/// } catch (e, stackTrace) {
///   return ConvertToFailure(e, stackTrace);
/// }
/// ```
abstract class ConvertToFailure<T extends Object?> {
  Failure<T> call(Object e, [StackTrace? stackTrace]);
}

/// Convert to snapshot is a mockable function which used to generate
/// Snapshot from data. Used in utility repos such as
/// [CornerstonePersistentRepositoryMixin].
abstract class ConvertToSnapshot<T extends Object> {
  T call(Map<String, dynamic> data);
}
