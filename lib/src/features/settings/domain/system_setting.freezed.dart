// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_setting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SystemSetting _$SystemSettingFromJson(Map<String, dynamic> json) {
  return _SystemSetting.fromJson(json);
}

/// @nodoc
mixin _$SystemSetting {
  String get id => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;
  Map<String, dynamic> get value => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SystemSetting to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SystemSetting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SystemSettingCopyWith<SystemSetting> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemSettingCopyWith<$Res> {
  factory $SystemSettingCopyWith(
    SystemSetting value,
    $Res Function(SystemSetting) then,
  ) = _$SystemSettingCopyWithImpl<$Res, SystemSetting>;
  @useResult
  $Res call({
    String id,
    String key,
    Map<String, dynamic> value,
    String? description,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$SystemSettingCopyWithImpl<$Res, $Val extends SystemSetting>
    implements $SystemSettingCopyWith<$Res> {
  _$SystemSettingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SystemSetting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? key = null,
    Object? value = null,
    Object? description = freezed,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SystemSettingImplCopyWith<$Res>
    implements $SystemSettingCopyWith<$Res> {
  factory _$$SystemSettingImplCopyWith(
    _$SystemSettingImpl value,
    $Res Function(_$SystemSettingImpl) then,
  ) = __$$SystemSettingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String key,
    Map<String, dynamic> value,
    String? description,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$SystemSettingImplCopyWithImpl<$Res>
    extends _$SystemSettingCopyWithImpl<$Res, _$SystemSettingImpl>
    implements _$$SystemSettingImplCopyWith<$Res> {
  __$$SystemSettingImplCopyWithImpl(
    _$SystemSettingImpl _value,
    $Res Function(_$SystemSettingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SystemSetting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? key = null,
    Object? value = null,
    Object? description = freezed,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SystemSettingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        value: null == value
            ? _value._value
            : value // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SystemSettingImpl implements _SystemSetting {
  const _$SystemSettingImpl({
    required this.id,
    required this.key,
    required final Map<String, dynamic> value,
    this.description,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : _value = value;

  factory _$SystemSettingImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemSettingImplFromJson(json);

  @override
  final String id;
  @override
  final String key;
  final Map<String, dynamic> _value;
  @override
  Map<String, dynamic> get value {
    if (_value is EqualUnmodifiableMapView) return _value;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_value);
  }

  @override
  final String? description;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SystemSetting(id: $id, key: $key, value: $value, description: $description, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemSettingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.key, key) || other.key == key) &&
            const DeepCollectionEquality().equals(other._value, _value) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    key,
    const DeepCollectionEquality().hash(_value),
    description,
    updatedAt,
  );

  /// Create a copy of SystemSetting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemSettingImplCopyWith<_$SystemSettingImpl> get copyWith =>
      __$$SystemSettingImplCopyWithImpl<_$SystemSettingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemSettingImplToJson(this);
  }
}

abstract class _SystemSetting implements SystemSetting {
  const factory _SystemSetting({
    required final String id,
    required final String key,
    required final Map<String, dynamic> value,
    final String? description,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$SystemSettingImpl;

  factory _SystemSetting.fromJson(Map<String, dynamic> json) =
      _$SystemSettingImpl.fromJson;

  @override
  String get id;
  @override
  String get key;
  @override
  Map<String, dynamic> get value;
  @override
  String? get description;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of SystemSetting
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemSettingImplCopyWith<_$SystemSettingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
