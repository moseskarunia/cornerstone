// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map json) {
  return $checkedNew('Person', json, () {
    final val = Person(
      id: $checkedConvert(json, 'id', (v) => v as int),
      name: $checkedConvert(json, 'name', (v) => v as String),
      email: $checkedConvert(json, 'email', (v) => v as String),
    );
    return val;
  });
}

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };
