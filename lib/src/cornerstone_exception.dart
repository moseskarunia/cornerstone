import 'package:cornerstone/src/exception_to_failure.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A regular exception which implements equatable and works well with
/// [ExceptionToFailure].
///
/// If you throw this from your data source instead of regular exception and
/// your repository uses [ExceptionToFailure], then it will automatically
/// converted to Failure
class CornerstoneException extends Equatable implements Exception {
  /// Name of the error. You can put anything here, but make sure to be as
  /// consistent as possible to make it easier to maintain.
  final String name;

  /// You can put anything here
  final Map<String, dynamic> details;

  const CornerstoneException({@required this.name, this.details});

  @override
  List<Object> get props => [name, details];
}
