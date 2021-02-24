import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// An exception to encapsulate other exceptions from data source layer or below
/// to make repository layer even more decoupled. The fields of this class is
/// identical to Failure for easier conversion in the repository.
class CornerstoneException<T> extends Equatable implements Exception {
  /// Name of the error. You can put anything here, but make sure to be as
  /// consistent as possible to make it easier to maintain.
  final String name;

  /// You can put anything here
  final T details;

  const CornerstoneException({@required this.name, this.details});

  @override
  List<Object> get props => [name, details];
}
