// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Vehicle _$VehicleFromJson(Map<String, dynamic> json) {
  return _Vehicle.fromJson(json);
}

/// @nodoc
mixin _$Vehicle {
  String get id => throw _privateConstructorUsedError;
  String get vin => throw _privateConstructorUsedError;
  String get make => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  @JsonKey(name: 'license_plate')
  String? get licensePlate => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // available, on_contract, maintenance
  @JsonKey(name: 'purchase_price')
  double get purchasePrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_market_value')
  double? get estimatedMarketValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'technical_specs')
  Map<String, dynamic> get technicalSpecs => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Vehicle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VehicleCopyWith<Vehicle> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehicleCopyWith<$Res> {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) then) =
      _$VehicleCopyWithImpl<$Res, Vehicle>;
  @useResult
  $Res call({
    String id,
    String vin,
    String make,
    String model,
    int year,
    String? color,
    @JsonKey(name: 'license_plate') String? licensePlate,
    String status,
    @JsonKey(name: 'purchase_price') double purchasePrice,
    @JsonKey(name: 'estimated_market_value') double? estimatedMarketValue,
    @JsonKey(name: 'technical_specs') Map<String, dynamic> technicalSpecs,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$VehicleCopyWithImpl<$Res, $Val extends Vehicle>
    implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vin = null,
    Object? make = null,
    Object? model = null,
    Object? year = null,
    Object? color = freezed,
    Object? licensePlate = freezed,
    Object? status = null,
    Object? purchasePrice = null,
    Object? estimatedMarketValue = freezed,
    Object? technicalSpecs = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            vin: null == vin
                ? _value.vin
                : vin // ignore: cast_nullable_to_non_nullable
                      as String,
            make: null == make
                ? _value.make
                : make // ignore: cast_nullable_to_non_nullable
                      as String,
            model: null == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String,
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            licensePlate: freezed == licensePlate
                ? _value.licensePlate
                : licensePlate // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            purchasePrice: null == purchasePrice
                ? _value.purchasePrice
                : purchasePrice // ignore: cast_nullable_to_non_nullable
                      as double,
            estimatedMarketValue: freezed == estimatedMarketValue
                ? _value.estimatedMarketValue
                : estimatedMarketValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            technicalSpecs: null == technicalSpecs
                ? _value.technicalSpecs
                : technicalSpecs // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$VehicleImplCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$$VehicleImplCopyWith(
    _$VehicleImpl value,
    $Res Function(_$VehicleImpl) then,
  ) = __$$VehicleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String vin,
    String make,
    String model,
    int year,
    String? color,
    @JsonKey(name: 'license_plate') String? licensePlate,
    String status,
    @JsonKey(name: 'purchase_price') double purchasePrice,
    @JsonKey(name: 'estimated_market_value') double? estimatedMarketValue,
    @JsonKey(name: 'technical_specs') Map<String, dynamic> technicalSpecs,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$VehicleImplCopyWithImpl<$Res>
    extends _$VehicleCopyWithImpl<$Res, _$VehicleImpl>
    implements _$$VehicleImplCopyWith<$Res> {
  __$$VehicleImplCopyWithImpl(
    _$VehicleImpl _value,
    $Res Function(_$VehicleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vin = null,
    Object? make = null,
    Object? model = null,
    Object? year = null,
    Object? color = freezed,
    Object? licensePlate = freezed,
    Object? status = null,
    Object? purchasePrice = null,
    Object? estimatedMarketValue = freezed,
    Object? technicalSpecs = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$VehicleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        vin: null == vin
            ? _value.vin
            : vin // ignore: cast_nullable_to_non_nullable
                  as String,
        make: null == make
            ? _value.make
            : make // ignore: cast_nullable_to_non_nullable
                  as String,
        model: null == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        licensePlate: freezed == licensePlate
            ? _value.licensePlate
            : licensePlate // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        purchasePrice: null == purchasePrice
            ? _value.purchasePrice
            : purchasePrice // ignore: cast_nullable_to_non_nullable
                  as double,
        estimatedMarketValue: freezed == estimatedMarketValue
            ? _value.estimatedMarketValue
            : estimatedMarketValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        technicalSpecs: null == technicalSpecs
            ? _value._technicalSpecs
            : technicalSpecs // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$VehicleImpl implements _Vehicle {
  const _$VehicleImpl({
    required this.id,
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    this.color,
    @JsonKey(name: 'license_plate') this.licensePlate,
    required this.status,
    @JsonKey(name: 'purchase_price') required this.purchasePrice,
    @JsonKey(name: 'estimated_market_value') this.estimatedMarketValue,
    @JsonKey(name: 'technical_specs')
    final Map<String, dynamic> technicalSpecs = const {},
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : _technicalSpecs = technicalSpecs;

  factory _$VehicleImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehicleImplFromJson(json);

  @override
  final String id;
  @override
  final String vin;
  @override
  final String make;
  @override
  final String model;
  @override
  final int year;
  @override
  final String? color;
  @override
  @JsonKey(name: 'license_plate')
  final String? licensePlate;
  @override
  final String status;
  // available, on_contract, maintenance
  @override
  @JsonKey(name: 'purchase_price')
  final double purchasePrice;
  @override
  @JsonKey(name: 'estimated_market_value')
  final double? estimatedMarketValue;
  final Map<String, dynamic> _technicalSpecs;
  @override
  @JsonKey(name: 'technical_specs')
  Map<String, dynamic> get technicalSpecs {
    if (_technicalSpecs is EqualUnmodifiableMapView) return _technicalSpecs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_technicalSpecs);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Vehicle(id: $id, vin: $vin, make: $make, model: $model, year: $year, color: $color, licensePlate: $licensePlate, status: $status, purchasePrice: $purchasePrice, estimatedMarketValue: $estimatedMarketValue, technicalSpecs: $technicalSpecs, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vin, vin) || other.vin == vin) &&
            (identical(other.make, make) || other.make == make) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.licensePlate, licensePlate) ||
                other.licensePlate == licensePlate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.purchasePrice, purchasePrice) ||
                other.purchasePrice == purchasePrice) &&
            (identical(other.estimatedMarketValue, estimatedMarketValue) ||
                other.estimatedMarketValue == estimatedMarketValue) &&
            const DeepCollectionEquality().equals(
              other._technicalSpecs,
              _technicalSpecs,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    vin,
    make,
    model,
    year,
    color,
    licensePlate,
    status,
    purchasePrice,
    estimatedMarketValue,
    const DeepCollectionEquality().hash(_technicalSpecs),
    createdAt,
    updatedAt,
  );

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VehicleImplCopyWith<_$VehicleImpl> get copyWith =>
      __$$VehicleImplCopyWithImpl<_$VehicleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VehicleImplToJson(this);
  }
}

abstract class _Vehicle implements Vehicle {
  const factory _Vehicle({
    required final String id,
    required final String vin,
    required final String make,
    required final String model,
    required final int year,
    final String? color,
    @JsonKey(name: 'license_plate') final String? licensePlate,
    required final String status,
    @JsonKey(name: 'purchase_price') required final double purchasePrice,
    @JsonKey(name: 'estimated_market_value') final double? estimatedMarketValue,
    @JsonKey(name: 'technical_specs') final Map<String, dynamic> technicalSpecs,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$VehicleImpl;

  factory _Vehicle.fromJson(Map<String, dynamic> json) = _$VehicleImpl.fromJson;

  @override
  String get id;
  @override
  String get vin;
  @override
  String get make;
  @override
  String get model;
  @override
  int get year;
  @override
  String? get color;
  @override
  @JsonKey(name: 'license_plate')
  String? get licensePlate;
  @override
  String get status; // available, on_contract, maintenance
  @override
  @JsonKey(name: 'purchase_price')
  double get purchasePrice;
  @override
  @JsonKey(name: 'estimated_market_value')
  double? get estimatedMarketValue;
  @override
  @JsonKey(name: 'technical_specs')
  Map<String, dynamic> get technicalSpecs;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VehicleImplCopyWith<_$VehicleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
