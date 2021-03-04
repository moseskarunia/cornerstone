// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_persistent_people_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewPeopleSnapshot _$NewPeopleSnapshotFromJson(Map json) {
  return NewPeopleSnapshot(
    data: (json['data'] as List<dynamic>?)
            ?.map((e) => Person.fromJson(e as Map))
            .toList() ??
        [],
    timestamp: dateTimeFromString(json['timestamp'] as String),
  );
}

Map<String, dynamic> _$NewPeopleSnapshotToJson(NewPeopleSnapshot instance) =>
    <String, dynamic>{
      'timestamp': dateTimeToString(instance.timestamp),
      'data': instance.data.map((e) => e.toJson()).toList(),
    };
