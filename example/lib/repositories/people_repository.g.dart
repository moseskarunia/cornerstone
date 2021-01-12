// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeopleRepositoryImpl _$PeopleRepositoryImplFromJson(Map<String, dynamic> json) {
  return PeopleRepositoryImpl()
    ..updatedAt = _$dateTimeFromJson(json['updatedAt'] as String)
    ..data = (json['data'] as List)
            ?.map((e) =>
                e == null ? null : Person.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [];
}

Map<String, dynamic> _$PeopleRepositoryImplToJson(
        PeopleRepositoryImpl instance) =>
    <String, dynamic>{
      'updatedAt': _$dateTimeToJson(instance.updatedAt),
      'data': instance.data?.map((e) => e?.toJson())?.toList(),
    };
