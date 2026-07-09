import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log.freezed.dart';
part 'audit_log.g.dart';

@freezed
class AuditLog with _$AuditLog {
  const factory AuditLog({
    required String id,
    @JsonKey(name: 'profile_id') String? profileId,
    @JsonKey(name: 'event_type') required String eventType,
    @JsonKey(name: 'table_name') required String tableName,
    @JsonKey(name: 'record_id') required String recordId,
    @JsonKey(name: 'old_values') Map<String, dynamic>? oldValues,
    @JsonKey(name: 'new_values') Map<String, dynamic>? newValues,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'user_agent') String? userAgent,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // Joined field
    @JsonKey(name: 'profiles') Map<String, dynamic>? profile,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);
}
