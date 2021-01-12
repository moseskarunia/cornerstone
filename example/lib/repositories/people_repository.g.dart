// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeopleSnapshot _$PeopleSnapshotFromJson(Map json) {
  return $checkedNew('PeopleSnapshot', json, () {
    final val = PeopleSnapshot(
      updatedAt: $checkedConvert(
          json, 'updatedAt', (v) => _$dateTimeFromJson(v as String)),
      data: $checkedConvert(
              json,
              'data',
              (v) => (v as List)
                  ?.map((e) => e == null
                      ? null
                      : Person.fromJson((e as Map)?.map(
                          (k, e) => MapEntry(k as String, e),
                        )))
                  ?.toList()) ??
          [],
      isSaved: $checkedConvert(json, 'isSaved', (v) => v as bool) ?? false,
    );
    return val;
  });
}

Map<String, dynamic> _$PeopleSnapshotToJson(PeopleSnapshot instance) =>
    <String, dynamic>{
      'updatedAt': _$dateTimeToJson(instance.updatedAt),
      'data': instance.data?.map((e) => e?.toJson())?.toList(),
      'isSaved': instance.isSaved,
    };
