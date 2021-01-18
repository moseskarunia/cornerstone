import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// Base snapshot abstract with several convenience properties.
/// Don't forget to add [timestamp] in your implementation's props.
/// On the other hand, don't add [clock].
abstract class CornerstoneSnapshot extends Equatable {
  /// Already annotated with
  /// `@JsonKey(ignore: true, defaultValue: const Clock())` so won't mess with
  /// your `@JsonSerializable`
  ///
  ///
  /// To make this testable, we need clock, because `DateTime.now()`
  /// is impossible to test without sacrificing some coverage.
  ///
  /// By default will use `const Clock()`.
  @JsonKey(ignore: true, defaultValue: const Clock())
  final Clock clock;

  /// Should only be changed after calling from the server. With this,
  /// you can set up a timer to periodically fetches the data from the server
  /// if it's already too old.
  ///
  /// Shouldn't null
  final DateTime timestamp;

  /// Difference of current datetime compared to [timestamp].
  Duration get age => timestamp.difference(clock.now());

  CornerstoneSnapshot({
    @required this.timestamp,
    this.clock = const Clock(),
  }) : assert(clock != null && timestamp != null);
}
