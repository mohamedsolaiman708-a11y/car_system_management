// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'investor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Investor _$InvestorFromJson(Map<String, dynamic> json) {
  return _Investor.fromJson(json);
}

/// @nodoc
mixin _$Investor {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_balance')
  double get availableBalance => throw _privateConstructorUsedError;
  @JsonKey(name: 'deployed_capital')
  double get deployedCapital => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_profit_earned')
  double get totalProfitEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Investor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Investor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvestorCopyWith<Investor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvestorCopyWith<$Res> {
  factory $InvestorCopyWith(Investor value, $Res Function(Investor) then) =
      _$InvestorCopyWithImpl<$Res, Investor>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'full_name') String fullName,
    String email,
    @JsonKey(name: 'available_balance') double availableBalance,
    @JsonKey(name: 'deployed_capital') double deployedCapital,
    @JsonKey(name: 'total_profit_earned') double totalProfitEarned,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$InvestorCopyWithImpl<$Res, $Val extends Investor>
    implements $InvestorCopyWith<$Res> {
  _$InvestorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Investor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? email = null,
    Object? availableBalance = null,
    Object? deployedCapital = null,
    Object? totalProfitEarned = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            availableBalance: null == availableBalance
                ? _value.availableBalance
                : availableBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            deployedCapital: null == deployedCapital
                ? _value.deployedCapital
                : deployedCapital // ignore: cast_nullable_to_non_nullable
                      as double,
            totalProfitEarned: null == totalProfitEarned
                ? _value.totalProfitEarned
                : totalProfitEarned // ignore: cast_nullable_to_non_nullable
                      as double,
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
abstract class _$$InvestorImplCopyWith<$Res>
    implements $InvestorCopyWith<$Res> {
  factory _$$InvestorImplCopyWith(
    _$InvestorImpl value,
    $Res Function(_$InvestorImpl) then,
  ) = __$$InvestorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'full_name') String fullName,
    String email,
    @JsonKey(name: 'available_balance') double availableBalance,
    @JsonKey(name: 'deployed_capital') double deployedCapital,
    @JsonKey(name: 'total_profit_earned') double totalProfitEarned,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$InvestorImplCopyWithImpl<$Res>
    extends _$InvestorCopyWithImpl<$Res, _$InvestorImpl>
    implements _$$InvestorImplCopyWith<$Res> {
  __$$InvestorImplCopyWithImpl(
    _$InvestorImpl _value,
    $Res Function(_$InvestorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Investor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? email = null,
    Object? availableBalance = null,
    Object? deployedCapital = null,
    Object? totalProfitEarned = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$InvestorImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        availableBalance: null == availableBalance
            ? _value.availableBalance
            : availableBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        deployedCapital: null == deployedCapital
            ? _value.deployedCapital
            : deployedCapital // ignore: cast_nullable_to_non_nullable
                  as double,
        totalProfitEarned: null == totalProfitEarned
            ? _value.totalProfitEarned
            : totalProfitEarned // ignore: cast_nullable_to_non_nullable
                  as double,
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
class _$InvestorImpl implements _Investor {
  const _$InvestorImpl({
    required this.id,
    @JsonKey(name: 'full_name') required this.fullName,
    required this.email,
    @JsonKey(name: 'available_balance') required this.availableBalance,
    @JsonKey(name: 'deployed_capital') required this.deployedCapital,
    @JsonKey(name: 'total_profit_earned') required this.totalProfitEarned,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$InvestorImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvestorImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  final String email;
  @override
  @JsonKey(name: 'available_balance')
  final double availableBalance;
  @override
  @JsonKey(name: 'deployed_capital')
  final double deployedCapital;
  @override
  @JsonKey(name: 'total_profit_earned')
  final double totalProfitEarned;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Investor(id: $id, fullName: $fullName, email: $email, availableBalance: $availableBalance, deployedCapital: $deployedCapital, totalProfitEarned: $totalProfitEarned, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvestorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.availableBalance, availableBalance) ||
                other.availableBalance == availableBalance) &&
            (identical(other.deployedCapital, deployedCapital) ||
                other.deployedCapital == deployedCapital) &&
            (identical(other.totalProfitEarned, totalProfitEarned) ||
                other.totalProfitEarned == totalProfitEarned) &&
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
    fullName,
    email,
    availableBalance,
    deployedCapital,
    totalProfitEarned,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Investor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvestorImplCopyWith<_$InvestorImpl> get copyWith =>
      __$$InvestorImplCopyWithImpl<_$InvestorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvestorImplToJson(this);
  }
}

abstract class _Investor implements Investor {
  const factory _Investor({
    required final String id,
    @JsonKey(name: 'full_name') required final String fullName,
    required final String email,
    @JsonKey(name: 'available_balance') required final double availableBalance,
    @JsonKey(name: 'deployed_capital') required final double deployedCapital,
    @JsonKey(name: 'total_profit_earned')
    required final double totalProfitEarned,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$InvestorImpl;

  factory _Investor.fromJson(Map<String, dynamic> json) =
      _$InvestorImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  String get email;
  @override
  @JsonKey(name: 'available_balance')
  double get availableBalance;
  @override
  @JsonKey(name: 'deployed_capital')
  double get deployedCapital;
  @override
  @JsonKey(name: 'total_profit_earned')
  double get totalProfitEarned;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of Investor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvestorImplCopyWith<_$InvestorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
