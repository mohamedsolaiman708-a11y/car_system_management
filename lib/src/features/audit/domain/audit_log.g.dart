// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuditLogImpl _$$AuditLogImplFromJson(Map<String, dynamic> json) =>
    _$AuditLogImpl(
      id: json['id'] as String,
      profileId: json['profile_id'] as String?,
      eventType: json['event_type'] as String,
      tableName: json['table_name'] as String,
      recordId: json['record_id'] as String,
      oldValues: json['old_values'] as Map<String, dynamic>?,
      newValues: json['new_values'] as Map<String, dynamic>?,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      profile: json['profiles'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AuditLogImplToJson(_$AuditLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profile_id': instance.profileId,
      'event_type': instance.eventType,
      'table_name': instance.tableName,
      'record_id': instance.recordId,
      'old_values': instance.oldValues,
      'new_values': instance.newValues,
      'ip_address': instance.ipAddress,
      'user_agent': instance.userAgent,
      'created_at': instance.createdAt.toIso8601String(),
      'profiles': instance.profile,
    };
