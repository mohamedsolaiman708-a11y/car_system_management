// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BackgroundJobImpl _$$BackgroundJobImplFromJson(Map<String, dynamic> json) =>
    _$BackgroundJobImpl(
      id: json['id'] as String,
      jobType: json['job_type'] as String,
      payload: json['payload'] as Map<String, dynamic>?,
      status: $enumDecode(_$JobStatusEnumMap, json['status']),
      attempts: (json['attempts'] as num).toInt(),
      maxAttempts: (json['max_attempts'] as num).toInt(),
      errorMessage: json['error_message'] as String?,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$BackgroundJobImplToJson(_$BackgroundJobImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'job_type': instance.jobType,
      'payload': instance.payload,
      'status': _$JobStatusEnumMap[instance.status]!,
      'attempts': instance.attempts,
      'max_attempts': instance.maxAttempts,
      'error_message': instance.errorMessage,
      'scheduled_at': instance.scheduledAt.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$JobStatusEnumMap = {
  JobStatus.pending: 'pending',
  JobStatus.running: 'running',
  JobStatus.failed: 'failed',
  JobStatus.completed: 'completed',
  JobStatus.retrying: 'retrying',
};
