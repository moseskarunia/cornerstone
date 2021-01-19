// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_repository_with_built_in_hive.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewPeopleSnapshot _$PeopleSnapshotFromJson(Map<String, dynamic> json) {
  return NewPeopleSnapshot(
    data: (json['data'] as List)
            ?.map((e) =>
                e == null ? null : Person.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
    timestamp: dateTimeFromString(json['timestamp'] as String),
  );
}

Map<String, dynamic> _$PeopleSnapshotToJson(NewPeopleSnapshot instance) =>
    <String, dynamic>{
      'timestamp': dateTimeToString(instance.timestamp),
      'data': instance.data?.map((e) => e?.toJson())?.toList(),
    };
