// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuditLog _$AuditLogFromJson(Map<String, dynamic> json) {
  return _AuditLog.fromJson(json);
}

/// @nodoc
mixin _$AuditLog {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_id')
  String? get profileId => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_type')
  String get eventType => throw _privateConstructorUsedError;
  @JsonKey(name: 'table_name')
  String get tableName => throw _privateConstructorUsedError;
  @JsonKey(name: 'record_id')
  String get recordId => throw _privateConstructorUsedError;
  @JsonKey(name: 'old_values')
  Map<String, dynamic>? get oldValues => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_values')
  Map<String, dynamic>? get newValues => throw _privateConstructorUsedError;
  @JsonKey(name: 'ip_address')
  String? get ipAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_agent')
  String? get userAgent => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError; // Joined field
  @JsonKey(name: 'profiles')
  Map<String, dynamic>? get profile => throw _privateConstructorUsedError;

  /// Serializes this AuditLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditLogCopyWith<AuditLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditLogCopyWith<$Res> {
  factory $AuditLogCopyWith(AuditLog value, $Res Function(AuditLog) then) =
      _$AuditLogCopyWithImpl<$Res, AuditLog>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'profile_id') String? profileId,
    @JsonKey(name: 'event_type') String eventType,
    @JsonKey(name: 'table_name') String tableName,
    @JsonKey(name: 'record_id') String recordId,
    @JsonKey(name: 'old_values') Map<String, dynamic>? oldValues,
    @JsonKey(name: 'new_values') Map<String, dynamic>? newValues,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'user_agent') String? userAgent,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'profiles') Map<String, dynamic>? profile,
  });
}

/// @nodoc
class _$AuditLogCopyWithImpl<$Res, $Val extends AuditLog>
    implements $AuditLogCopyWith<$Res> {
  _$AuditLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profileId = freezed,
    Object? eventType = null,
    Object? tableName = null,
    Object? recordId = null,
    Object? oldValues = freezed,
    Object? newValues = freezed,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? createdAt = null,
    Object? profile = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            profileId: freezed == profileId
                ? _value.profileId
                : profileId // ignore: cast_nullable_to_non_nullable
                      as String?,
            eventType: null == eventType
                ? _value.eventType
                : eventType // ignore: cast_nullable_to_non_nullable
                      as String,
            tableName: null == tableName
                ? _value.tableName
                : tableName // ignore: cast_nullable_to_non_nullable
                      as String,
            recordId: null == recordId
                ? _value.recordId
                : recordId // ignore: cast_nullable_to_non_nullable
                      as String,
            oldValues: freezed == oldValues
                ? _value.oldValues
                : oldValues // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            newValues: freezed == newValues
                ? _value.newValues
                : newValues // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
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
            profile: freezed == profile
                ? _value.profile
                : profile // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuditLogImplCopyWith<$Res>
    implements $AuditLogCopyWith<$Res> {
  factory _$$AuditLogImplCopyWith(
    _$AuditLogImpl value,
    $Res Function(_$AuditLogImpl) then,
  ) = __$$AuditLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'profile_id') String? profileId,
    @JsonKey(name: 'event_type') String eventType,
    @JsonKey(name: 'table_name') String tableName,
    @JsonKey(name: 'record_id') String recordId,
    @JsonKey(name: 'old_values') Map<String, dynamic>? oldValues,
    @JsonKey(name: 'new_values') Map<String, dynamic>? newValues,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'user_agent') String? userAgent,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'profiles') Map<String, dynamic>? profile,
  });
}

/// @nodoc
class __$$AuditLogImplCopyWithImpl<$Res>
    extends _$AuditLogCopyWithImpl<$Res, _$AuditLogImpl>
    implements _$$AuditLogImplCopyWith<$Res> {
  __$$AuditLogImplCopyWithImpl(
    _$AuditLogImpl _value,
    $Res Function(_$AuditLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profileId = freezed,
    Object? eventType = null,
    Object? tableName = null,
    Object? recordId = null,
    Object? oldValues = freezed,
    Object? newValues = freezed,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? createdAt = null,
    Object? profile = freezed,
  }) {
    return _then(
      _$AuditLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        profileId: freezed == profileId
            ? _value.profileId
            : profileId // ignore: cast_nullable_to_non_nullable
                  as String?,
        eventType: null == eventType
            ? _value.eventType
            : eventType // ignore: cast_nullable_to_non_nullable
                  as String,
        tableName: null == tableName
            ? _value.tableName
            : tableName // ignore: cast_nullable_to_non_nullable
                  as String,
        recordId: null == recordId
            ? _value.recordId
            : recordId // ignore: cast_nullable_to_non_nullable
                  as String,
        oldValues: freezed == oldValues
            ? _value._oldValues
            : oldValues // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        newValues: freezed == newValues
            ? _value._newValues
            : newValues // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
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
        profile: freezed == profile
            ? _value._profile
            : profile // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuditLogImpl implements _AuditLog {
  const _$AuditLogImpl({
    required this.id,
    @JsonKey(name: 'profile_id') this.profileId,
    @JsonKey(name: 'event_type') required this.eventType,
    @JsonKey(name: 'table_name') required this.tableName,
    @JsonKey(name: 'record_id') required this.recordId,
    @JsonKey(name: 'old_values') final Map<String, dynamic>? oldValues,
    @JsonKey(name: 'new_values') final Map<String, dynamic>? newValues,
    @JsonKey(name: 'ip_address') this.ipAddress,
    @JsonKey(name: 'user_agent') this.userAgent,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'profiles') final Map<String, dynamic>? profile,
  }) : _oldValues = oldValues,
       _newValues = newValues,
       _profile = profile;

  factory _$AuditLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuditLogImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'profile_id')
  final String? profileId;
  @override
  @JsonKey(name: 'event_type')
  final String eventType;
  @override
  @JsonKey(name: 'table_name')
  final String tableName;
  @override
  @JsonKey(name: 'record_id')
  final String recordId;
  final Map<String, dynamic>? _oldValues;
  @override
  @JsonKey(name: 'old_values')
  Map<String, dynamic>? get oldValues {
    final value = _oldValues;
    if (value == null) return null;
    if (_oldValues is EqualUnmodifiableMapView) return _oldValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _newValues;
  @override
  @JsonKey(name: 'new_values')
  Map<String, dynamic>? get newValues {
    final value = _newValues;
    if (value == null) return null;
    if (_newValues is EqualUnmodifiableMapView) return _newValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'ip_address')
  final String? ipAddress;
  @override
  @JsonKey(name: 'user_agent')
  final String? userAgent;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  // Joined field
  final Map<String, dynamic>? _profile;
  // Joined field
  @override
  @JsonKey(name: 'profiles')
  Map<String, dynamic>? get profile {
    final value = _profile;
    if (value == null) return null;
    if (_profile is EqualUnmodifiableMapView) return _profile;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AuditLog(id: $id, profileId: $profileId, eventType: $eventType, tableName: $tableName, recordId: $recordId, oldValues: $oldValues, newValues: $newValues, ipAddress: $ipAddress, userAgent: $userAgent, createdAt: $createdAt, profile: $profile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profileId, profileId) ||
                other.profileId == profileId) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.tableName, tableName) ||
                other.tableName == tableName) &&
            (identical(other.recordId, recordId) ||
                other.recordId == recordId) &&
            const DeepCollectionEquality().equals(
              other._oldValues,
              _oldValues,
            ) &&
            const DeepCollectionEquality().equals(
              other._newValues,
              _newValues,
            ) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._profile, _profile));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    profileId,
    eventType,
    tableName,
    recordId,
    const DeepCollectionEquality().hash(_oldValues),
    const DeepCollectionEquality().hash(_newValues),
    ipAddress,
    userAgent,
    createdAt,
    const DeepCollectionEquality().hash(_profile),
  );

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditLogImplCopyWith<_$AuditLogImpl> get copyWith =>
      __$$AuditLogImplCopyWithImpl<_$AuditLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuditLogImplToJson(this);
  }
}

abstract class _AuditLog implements AuditLog {
  const factory _AuditLog({
    required final String id,
    @JsonKey(name: 'profile_id') final String? profileId,
    @JsonKey(name: 'event_type') required final String eventType,
    @JsonKey(name: 'table_name') required final String tableName,
    @JsonKey(name: 'record_id') required final String recordId,
    @JsonKey(name: 'old_values') final Map<String, dynamic>? oldValues,
    @JsonKey(name: 'new_values') final Map<String, dynamic>? newValues,
    @JsonKey(name: 'ip_address') final String? ipAddress,
    @JsonKey(name: 'user_agent') final String? userAgent,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'profiles') final Map<String, dynamic>? profile,
  }) = _$AuditLogImpl;

  factory _AuditLog.fromJson(Map<String, dynamic> json) =
      _$AuditLogImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'profile_id')
  String? get profileId;
  @override
  @JsonKey(name: 'event_type')
  String get eventType;
  @override
  @JsonKey(name: 'table_name')
  String get tableName;
  @override
  @JsonKey(name: 'record_id')
  String get recordId;
  @override
  @JsonKey(name: 'old_values')
  Map<String, dynamic>? get oldValues;
  @override
  @JsonKey(name: 'new_values')
  Map<String, dynamic>? get newValues;
  @override
  @JsonKey(name: 'ip_address')
  String? get ipAddress;
  @override
  @JsonKey(name: 'user_agent')
  String? get userAgent;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt; // Joined field
  @override
  @JsonKey(name: 'profiles')
  Map<String, dynamic>? get profile;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditLogImplCopyWith<_$AuditLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
