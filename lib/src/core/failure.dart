import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Failure is a "nice" way to represent errors instead of throwing
/// an exception.
class Failure<T> extends Equatable {
  /// Name of the error. You can put anything here, but make sure to be as
  /// consistent as possible to make it easier to maintain.
  final String name;

  /// You can put anything here
  final T details;

  const Failure({@required this.name, this.details});

  @override
  List<Object> get props => [name, details];
}
