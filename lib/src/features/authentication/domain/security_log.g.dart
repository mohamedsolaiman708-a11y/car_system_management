// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SecurityLogImpl _$$SecurityLogImplFromJson(Map<String, dynamic> json) =>
    _$SecurityLogImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      eventType: json['event_type'] as String,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$SecurityLogImplToJson(_$SecurityLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'event_type': instance.eventType,
      'ip_address': instance.ipAddress,
      'user_agent': instance.userAgent,
      'created_at': instance.createdAt.toIso8601String(),
    };
