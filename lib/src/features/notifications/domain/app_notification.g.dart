// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$AppNotificationImpl(
  id: json['id'] as String,
  profileId: json['profile_id'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  type: json['type'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  isRead: json['is_read'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$AppNotificationImplToJson(
  _$AppNotificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'profile_id': instance.profileId,
  'title': instance.title,
  'content': instance.content,
  'type': instance.type,
  'metadata': instance.metadata,
  'is_read': instance.isRead,
  'created_at': instance.createdAt.toIso8601String(),
};
