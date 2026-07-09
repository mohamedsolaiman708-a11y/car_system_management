import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_record.freezed.dart';
part 'backup_record.g.dart';

@freezed
class BackupRecord with _$BackupRecord {
  const factory BackupRecord({
    required String id,
    required String filename,
    @JsonKey(name: 'size_bytes') int? sizeBytes,
    @Default('completed') String status,
    @JsonKey(name: 'backup_type') @Default('automatic') String backupType,
    @JsonKey(name: 'download_url') String? downloadUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'created_by') String? createdBy,
  }) = _BackupRecord;

  factory BackupRecord.fromJson(Map<String, dynamic> json) => _$BackupRecordFromJson(json);
}
