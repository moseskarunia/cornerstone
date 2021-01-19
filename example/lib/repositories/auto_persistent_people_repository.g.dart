// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_persistent_people_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewPeopleSnapshot _$NewPeopleSnapshotFromJson(Map<String, dynamic> json) {
  return NewPeopleSnapshot(
    data: (json['data'] as List)
            ?.map((e) =>
                e == null ? null : Person.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
    timestamp: dateTimeFromString(json['timestamp'] as String),
  );
}

Map<String, dynamic> _$NewPeopleSnapshotToJson(NewPeopleSnapshot instance) =>
    <String, dynamic>{
      'timestamp': dateTimeToString(instance.timestamp),
      'data': instance.data?.map((e) => e?.toJson())?.toList(),
    };
