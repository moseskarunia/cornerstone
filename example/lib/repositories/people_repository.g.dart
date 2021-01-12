// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeopleSnapshot _$PeopleSnapshotFromJson(Map<String, dynamic> json) {
  return PeopleSnapshot(
    updatedAt: _$dateTimeFromJson(json['updatedAt'] as String),
    data: (json['data'] as List)
            ?.map((e) =>
                e == null ? null : Person.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  );
}

Map<String, dynamic> _$PeopleSnapshotToJson(PeopleSnapshot instance) =>
    <String, dynamic>{
      'updatedAt': _$dateTimeToJson(instance.updatedAt),
      'data': instance.data?.map((e) => e?.toJson())?.toList(),
    };
