// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'background_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BackgroundJob _$BackgroundJobFromJson(Map<String, dynamic> json) {
  return _BackgroundJob.fromJson(json);
}

/// @nodoc
mixin _$BackgroundJob {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'job_type')
  String get jobType => throw _privateConstructorUsedError;
  Map<String, dynamic>? get payload => throw _privateConstructorUsedError;
  JobStatus get status => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_attempts')
  int get maxAttempts => throw _privateConstructorUsedError;
  @JsonKey(name: 'error_message')
  String? get errorMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'scheduled_at')
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'started_at')
  DateTime? get startedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BackgroundJob to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackgroundJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackgroundJobCopyWith<BackgroundJob> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackgroundJobCopyWith<$Res> {
  factory $BackgroundJobCopyWith(
    BackgroundJob value,
    $Res Function(BackgroundJob) then,
  ) = _$BackgroundJobCopyWithImpl<$Res, BackgroundJob>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'job_type') String jobType,
    Map<String, dynamic>? payload,
    JobStatus status,
    int attempts,
    @JsonKey(name: 'max_attempts') int maxAttempts,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'scheduled_at') DateTime scheduledAt,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$BackgroundJobCopyWithImpl<$Res, $Val extends BackgroundJob>
    implements $BackgroundJobCopyWith<$Res> {
  _$BackgroundJobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackgroundJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobType = null,
    Object? payload = freezed,
    Object? status = null,
    Object? attempts = null,
    Object? maxAttempts = null,
    Object? errorMessage = freezed,
    Object? scheduledAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            jobType: null == jobType
                ? _value.jobType
                : jobType // ignore: cast_nullable_to_non_nullable
                      as String,
            payload: freezed == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as JobStatus,
            attempts: null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
                      as int,
            maxAttempts: null == maxAttempts
                ? _value.maxAttempts
                : maxAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            scheduledAt: null == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BackgroundJobImplCopyWith<$Res>
    implements $BackgroundJobCopyWith<$Res> {
  factory _$$BackgroundJobImplCopyWith(
    _$BackgroundJobImpl value,
    $Res Function(_$BackgroundJobImpl) then,
  ) = __$$BackgroundJobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'job_type') String jobType,
    Map<String, dynamic>? payload,
    JobStatus status,
    int attempts,
    @JsonKey(name: 'max_attempts') int maxAttempts,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'scheduled_at') DateTime scheduledAt,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$BackgroundJobImplCopyWithImpl<$Res>
    extends _$BackgroundJobCopyWithImpl<$Res, _$BackgroundJobImpl>
    implements _$$BackgroundJobImplCopyWith<$Res> {
  __$$BackgroundJobImplCopyWithImpl(
    _$BackgroundJobImpl _value,
    $Res Function(_$BackgroundJobImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackgroundJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobType = null,
    Object? payload = freezed,
    Object? status = null,
    Object? attempts = null,
    Object? maxAttempts = null,
    Object? errorMessage = freezed,
    Object? scheduledAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$BackgroundJobImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        jobType: null == jobType
            ? _value.jobType
            : jobType // ignore: cast_nullable_to_non_nullable
                  as String,
        payload: freezed == payload
            ? _value._payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as JobStatus,
        attempts: null == attempts
            ? _value.attempts
            : attempts // ignore: cast_nullable_to_non_nullable
                  as int,
        maxAttempts: null == maxAttempts
            ? _value.maxAttempts
            : maxAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        scheduledAt: null == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BackgroundJobImpl implements _BackgroundJob {
  const _$BackgroundJobImpl({
    required this.id,
    @JsonKey(name: 'job_type') required this.jobType,
    final Map<String, dynamic>? payload,
    required this.status,
    required this.attempts,
    @JsonKey(name: 'max_attempts') required this.maxAttempts,
    @JsonKey(name: 'error_message') this.errorMessage,
    @JsonKey(name: 'scheduled_at') required this.scheduledAt,
    @JsonKey(name: 'started_at') this.startedAt,
    @JsonKey(name: 'completed_at') this.completedAt,
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : _payload = payload;

  factory _$BackgroundJobImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackgroundJobImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'job_type')
  final String jobType;
  final Map<String, dynamic>? _payload;
  @override
  Map<String, dynamic>? get payload {
    final value = _payload;
    if (value == null) return null;
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final JobStatus status;
  @override
  final int attempts;
  @override
  @JsonKey(name: 'max_attempts')
  final int maxAttempts;
  @override
  @JsonKey(name: 'error_message')
  final String? errorMessage;
  @override
  @JsonKey(name: 'scheduled_at')
  final DateTime scheduledAt;
  @override
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  @override
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'BackgroundJob(id: $id, jobType: $jobType, payload: $payload, status: $status, attempts: $attempts, maxAttempts: $maxAttempts, errorMessage: $errorMessage, scheduledAt: $scheduledAt, startedAt: $startedAt, completedAt: $completedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackgroundJobImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.jobType, jobType) || other.jobType == jobType) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.maxAttempts, maxAttempts) ||
                other.maxAttempts == maxAttempts) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    jobType,
    const DeepCollectionEquality().hash(_payload),
    status,
    attempts,
    maxAttempts,
    errorMessage,
    scheduledAt,
    startedAt,
    completedAt,
    createdAt,
  );

  /// Create a copy of BackgroundJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackgroundJobImplCopyWith<_$BackgroundJobImpl> get copyWith =>
      __$$BackgroundJobImplCopyWithImpl<_$BackgroundJobImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackgroundJobImplToJson(this);
  }
}

abstract class _BackgroundJob implements BackgroundJob {
  const factory _BackgroundJob({
    required final String id,
    @JsonKey(name: 'job_type') required final String jobType,
    final Map<String, dynamic>? payload,
    required final JobStatus status,
    required final int attempts,
    @JsonKey(name: 'max_attempts') required final int maxAttempts,
    @JsonKey(name: 'error_message') final String? errorMessage,
    @JsonKey(name: 'scheduled_at') required final DateTime scheduledAt,
    @JsonKey(name: 'started_at') final DateTime? startedAt,
    @JsonKey(name: 'completed_at') final DateTime? completedAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$BackgroundJobImpl;

  factory _BackgroundJob.fromJson(Map<String, dynamic> json) =
      _$BackgroundJobImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'job_type')
  String get jobType;
  @override
  Map<String, dynamic>? get payload;
  @override
  JobStatus get status;
  @override
  int get attempts;
  @override
  @JsonKey(name: 'max_attempts')
  int get maxAttempts;
  @override
  @JsonKey(name: 'error_message')
  String? get errorMessage;
  @override
  @JsonKey(name: 'scheduled_at')
  DateTime get scheduledAt;
  @override
  @JsonKey(name: 'started_at')
  DateTime? get startedAt;
  @override
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of BackgroundJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackgroundJobImplCopyWith<_$BackgroundJobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
