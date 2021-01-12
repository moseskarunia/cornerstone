import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'person.g.dart';

/// Remember to use `anyMap: true` if you use Hive because otherwise will throw:
///
/// ```sh
/// type '_InternalLinkedHashMap<dynamic, dynamic>' is not a subtype of type
/// 'Map<String, dynamic>' in type cast)
/// ```
@JsonSerializable(checked: true, anyMap: true)
class Person extends Equatable {
  final int id;
  final String name, email;

  const Person({this.id, this.name, this.email});

  @override
  List<Object> get props => [id, name, email];

  factory Person.fromJson(Map json) => _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}
