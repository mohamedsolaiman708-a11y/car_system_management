// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'security_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SecurityLog _$SecurityLogFromJson(Map<String, dynamic> json) {
  return _SecurityLog.fromJson(json);
}

/// @nodoc
mixin _$SecurityLog {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_type')
  String get eventType => throw _privateConstructorUsedError;
  @JsonKey(name: 'ip_address')
  String? get ipAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_agent')
  String? get userAgent => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SecurityLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecurityLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecurityLogCopyWith<SecurityLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityLogCopyWith<$Res> {
  factory $SecurityLogCopyWith(
    SecurityLog value,
    $Res Function(SecurityLog) then,
  ) = _$SecurityLogCopyWithImpl<$Res, SecurityLog>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'event_type') String eventType,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'user_agent') String? userAgent,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$SecurityLogCopyWithImpl<$Res, $Val extends SecurityLog>
    implements $SecurityLogCopyWith<$Res> {
  _$SecurityLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? eventType = null,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            eventType: null == eventType
                ? _value.eventType
                : eventType // ignore: cast_nullable_to_non_nullable
                      as String,
            ipAddress: freezed == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            userAgent: freezed == userAgent
                ? _value.userAgent
                : userAgent // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$SecurityLogImplCopyWith<$Res>
    implements $SecurityLogCopyWith<$Res> {
  factory _$$SecurityLogImplCopyWith(
    _$SecurityLogImpl value,
    $Res Function(_$SecurityLogImpl) then,
  ) = __$$SecurityLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'event_type') String eventType,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'user_agent') String? userAgent,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$SecurityLogImplCopyWithImpl<$Res>
    extends _$SecurityLogCopyWithImpl<$Res, _$SecurityLogImpl>
    implements _$$SecurityLogImplCopyWith<$Res> {
  __$$SecurityLogImplCopyWithImpl(
    _$SecurityLogImpl _value,
    $Res Function(_$SecurityLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SecurityLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? eventType = null,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$SecurityLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        eventType: null == eventType
            ? _value.eventType
            : eventType // ignore: cast_nullable_to_non_nullable
                  as String,
        ipAddress: freezed == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        userAgent: freezed == userAgent
            ? _value.userAgent
            : userAgent // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$SecurityLogImpl implements _SecurityLog {
  const _$SecurityLogImpl({
    required this.id,
    @JsonKey(name: 'user_id') this.userId,
    @JsonKey(name: 'event_type') required this.eventType,
    @JsonKey(name: 'ip_address') this.ipAddress,
    @JsonKey(name: 'user_agent') this.userAgent,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$SecurityLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityLogImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'event_type')
  final String eventType;
  @override
  @JsonKey(name: 'ip_address')
  final String? ipAddress;
  @override
  @JsonKey(name: 'user_agent')
  final String? userAgent;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'SecurityLog(id: $id, userId: $userId, eventType: $eventType, ipAddress: $ipAddress, userAgent: $userAgent, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    eventType,
    ipAddress,
    userAgent,
    createdAt,
  );

  /// Create a copy of SecurityLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityLogImplCopyWith<_$SecurityLogImpl> get copyWith =>
      __$$SecurityLogImplCopyWithImpl<_$SecurityLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityLogImplToJson(this);
  }
}

abstract class _SecurityLog implements SecurityLog {
  const factory _SecurityLog({
    required final String id,
    @JsonKey(name: 'user_id') final String? userId,
    @JsonKey(name: 'event_type') required final String eventType,
    @JsonKey(name: 'ip_address') final String? ipAddress,
    @JsonKey(name: 'user_agent') final String? userAgent,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$SecurityLogImpl;

  factory _SecurityLog.fromJson(Map<String, dynamic> json) =
      _$SecurityLogImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override
  @JsonKey(name: 'event_type')
  String get eventType;
  @override
  @JsonKey(name: 'ip_address')
  String? get ipAddress;
  @override
  @JsonKey(name: 'user_agent')
  String? get userAgent;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of SecurityLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityLogImplCopyWith<_$SecurityLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
