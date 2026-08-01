// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ContractActivity _$ContractActivityFromJson(Map<String, dynamic> json) {
  return _ContractActivity.fromJson(json);
}

/// @nodoc
mixin _$ContractActivity {
  String get eventType => throw _privateConstructorUsedError;
  DateTime get occurredAt => throw _privateConstructorUsedError;
  Map<String, dynamic> get details => throw _privateConstructorUsedError;
  String? get profileName => throw _privateConstructorUsedError;

  /// Serializes this ContractActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContractActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContractActivityCopyWith<ContractActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContractActivityCopyWith<$Res> {
  factory $ContractActivityCopyWith(
    ContractActivity value,
    $Res Function(ContractActivity) then,
  ) = _$ContractActivityCopyWithImpl<$Res, ContractActivity>;
  @useResult
  $Res call({
    String eventType,
    DateTime occurredAt,
    Map<String, dynamic> details,
    String? profileName,
  });
}

/// @nodoc
class _$ContractActivityCopyWithImpl<$Res, $Val extends ContractActivity>
    implements $ContractActivityCopyWith<$Res> {
  _$ContractActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContractActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventType = null,
    Object? occurredAt = null,
    Object? details = null,
    Object? profileName = freezed,
  }) {
    return _then(
      _value.copyWith(
            eventType: null == eventType
                ? _value.eventType
                : eventType // ignore: cast_nullable_to_non_nullable
                      as String,
            occurredAt: null == occurredAt
                ? _value.occurredAt
                : occurredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            details: null == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            profileName: freezed == profileName
                ? _value.profileName
                : profileName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ContractActivityImplCopyWith<$Res>
    implements $ContractActivityCopyWith<$Res> {
  factory _$$ContractActivityImplCopyWith(
    _$ContractActivityImpl value,
    $Res Function(_$ContractActivityImpl) then,
  ) = __$$ContractActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String eventType,
    DateTime occurredAt,
    Map<String, dynamic> details,
    String? profileName,
  });
}

/// @nodoc
class __$$ContractActivityImplCopyWithImpl<$Res>
    extends _$ContractActivityCopyWithImpl<$Res, _$ContractActivityImpl>
    implements _$$ContractActivityImplCopyWith<$Res> {
  __$$ContractActivityImplCopyWithImpl(
    _$ContractActivityImpl _value,
    $Res Function(_$ContractActivityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ContractActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventType = null,
    Object? occurredAt = null,
    Object? details = null,
    Object? profileName = freezed,
  }) {
    return _then(
      _$ContractActivityImpl(
        eventType: null == eventType
            ? _value.eventType
            : eventType // ignore: cast_nullable_to_non_nullable
                  as String,
        occurredAt: null == occurredAt
            ? _value.occurredAt
            : occurredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        details: null == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        profileName: freezed == profileName
            ? _value.profileName
            : profileName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContractActivityImpl implements _ContractActivity {
  const _$ContractActivityImpl({
    required this.eventType,
    required this.occurredAt,
    final Map<String, dynamic> details = const {},
    this.profileName,
  }) : _details = details;

  factory _$ContractActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContractActivityImplFromJson(json);

  @override
  final String eventType;
  @override
  final DateTime occurredAt;
  final Map<String, dynamic> _details;
  @override
  @JsonKey()
  Map<String, dynamic> get details {
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_details);
  }

  @override
  final String? profileName;

  @override
  String toString() {
    return 'ContractActivity(eventType: $eventType, occurredAt: $occurredAt, details: $details, profileName: $profileName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContractActivityImpl &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.occurredAt, occurredAt) ||
                other.occurredAt == occurredAt) &&
            const DeepCollectionEquality().equals(other._details, _details) &&
            (identical(other.profileName, profileName) ||
                other.profileName == profileName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    eventType,
    occurredAt,
    const DeepCollectionEquality().hash(_details),
    profileName,
  );

  /// Create a copy of ContractActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContractActivityImplCopyWith<_$ContractActivityImpl> get copyWith =>
      __$$ContractActivityImplCopyWithImpl<_$ContractActivityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ContractActivityImplToJson(this);
  }
}

abstract class _ContractActivity implements ContractActivity {
  const factory _ContractActivity({
    required final String eventType,
    required final DateTime occurredAt,
    final Map<String, dynamic> details,
    final String? profileName,
  }) = _$ContractActivityImpl;

  factory _ContractActivity.fromJson(Map<String, dynamic> json) =
      _$ContractActivityImpl.fromJson;

  @override
  String get eventType;
  @override
  DateTime get occurredAt;
  @override
  Map<String, dynamic> get details;
  @override
  String? get profileName;

  /// Create a copy of ContractActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContractActivityImplCopyWith<_$ContractActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
