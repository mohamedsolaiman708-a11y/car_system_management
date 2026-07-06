import 'package:freezed_annotation/freezed_annotation.dart';

part 'security_log.freezed.dart';
part 'security_log.g.dart';

@freezed
class SecurityLog with _$SecurityLog {
  const factory SecurityLog({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'event_type') required String eventType,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'user_agent') String? userAgent,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SecurityLog;

  factory SecurityLog.fromJson(Map<String, dynamic> json) => _$SecurityLogFromJson(json);
}
