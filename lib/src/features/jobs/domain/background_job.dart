import 'package:freezed_annotation/freezed_annotation.dart';

part 'background_job.freezed.dart';
part 'background_job.g.dart';

enum JobStatus {
  @JsonValue('pending') pending,
  @JsonValue('running') running,
  @JsonValue('failed') failed,
  @JsonValue('completed') completed,
  @JsonValue('retrying') retrying
}

@freezed
class BackgroundJob with _$BackgroundJob {
  const factory BackgroundJob({
    required String id,
    @JsonKey(name: 'job_type') required String jobType,
    Map<String, dynamic>? payload,
    required JobStatus status,
    required int attempts,
    @JsonKey(name: 'max_attempts') required int maxAttempts,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'scheduled_at') required DateTime scheduledAt,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _BackgroundJob;

  factory BackgroundJob.fromJson(Map<String, dynamic> json) => _$BackgroundJobFromJson(json);
}
