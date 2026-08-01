// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SystemSettingImpl _$$SystemSettingImplFromJson(Map<String, dynamic> json) =>
    _$SystemSettingImpl(
      id: json['id'] as String,
      key: json['key'] as String,
      value: json['value'] as Map<String, dynamic>,
      description: json['description'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$SystemSettingImplToJson(_$SystemSettingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
      'description': instance.description,
      'updated_at': instance.updatedAt.toIso8601String(),
    };
