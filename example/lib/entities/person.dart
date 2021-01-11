import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'person.g.dart';

@JsonSerializable()
class Person extends Equatable {
  final String id, name, email;

  const Person({this.id, this.name, this.email});

  @override
  List<Object> get props => [id, name, email];

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}
