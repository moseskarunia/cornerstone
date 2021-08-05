// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeopleSnapshot _$PeopleSnapshotFromJson(Map json) {
  return PeopleSnapshot(
    data: (json['data'] as List<dynamic>?)
            ?.map((e) => Person.fromJson(e as Map))
            .toList() ??
        [],
    timestamp: dateTimeFromString(json['timestamp'] as String),
  );
}

Map<String, dynamic> _$PeopleSnapshotToJson(PeopleSnapshot instance) =>
    <String, dynamic>{
      'timestamp': dateTimeToString(instance.timestamp),
      'data': instance.data.map((e) => e.toJson()).toList(),
    };
