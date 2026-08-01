// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BackupRecordImpl _$$BackupRecordImplFromJson(Map<String, dynamic> json) =>
    _$BackupRecordImpl(
      id: json['id'] as String,
      filename: json['filename'] as String,
      sizeBytes: (json['size_bytes'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'completed',
      backupType: json['backup_type'] as String? ?? 'automatic',
      downloadUrl: json['download_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String?,
    );

Map<String, dynamic> _$$BackupRecordImplToJson(_$BackupRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename': instance.filename,
      'size_bytes': instance.sizeBytes,
      'status': instance.status,
      'backup_type': instance.backupType,
      'download_url': instance.downloadUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'created_by': instance.createdBy,
    };
