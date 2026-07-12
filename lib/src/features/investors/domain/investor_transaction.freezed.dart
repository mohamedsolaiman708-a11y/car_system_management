// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'investor_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InvestorTransaction _$InvestorTransactionFromJson(Map<String, dynamic> json) {
  return _InvestorTransaction.fromJson(json);
}

/// @nodoc
mixin _$InvestorTransaction {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'investor_id')
  String get investorId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  InvestorTransactionType get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_id')
  String? get referenceId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'recorded_by_name')
  String? get recordedByName => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this InvestorTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvestorTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvestorTransactionCopyWith<InvestorTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvestorTransactionCopyWith<$Res> {
  factory $InvestorTransactionCopyWith(
    InvestorTransaction value,
    $Res Function(InvestorTransaction) then,
  ) = _$InvestorTransactionCopyWithImpl<$Res, InvestorTransaction>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'investor_id') String investorId,
    double amount,
    InvestorTransactionType type,
    @JsonKey(name: 'reference_id') String? referenceId,
    String? description,
    @JsonKey(name: 'recorded_by_name') String? recordedByName,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$InvestorTransactionCopyWithImpl<$Res, $Val extends InvestorTransaction>
    implements $InvestorTransactionCopyWith<$Res> {
  _$InvestorTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvestorTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? investorId = null,
    Object? amount = null,
    Object? type = null,
    Object? referenceId = freezed,
    Object? description = freezed,
    Object? recordedByName = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            investorId: null == investorId
                ? _value.investorId
                : investorId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as InvestorTransactionType,
            referenceId: freezed == referenceId
                ? _value.referenceId
                : referenceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            recordedByName: freezed == recordedByName
                ? _value.recordedByName
                : recordedByName // ignore: cast_nullable_to_non_nullable
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
abstract class _$$InvestorTransactionImplCopyWith<$Res>
    implements $InvestorTransactionCopyWith<$Res> {
  factory _$$InvestorTransactionImplCopyWith(
    _$InvestorTransactionImpl value,
    $Res Function(_$InvestorTransactionImpl) then,
  ) = __$$InvestorTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'investor_id') String investorId,
    double amount,
    InvestorTransactionType type,
    @JsonKey(name: 'reference_id') String? referenceId,
    String? description,
    @JsonKey(name: 'recorded_by_name') String? recordedByName,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$InvestorTransactionImplCopyWithImpl<$Res>
    extends _$InvestorTransactionCopyWithImpl<$Res, _$InvestorTransactionImpl>
    implements _$$InvestorTransactionImplCopyWith<$Res> {
  __$$InvestorTransactionImplCopyWithImpl(
    _$InvestorTransactionImpl _value,
    $Res Function(_$InvestorTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InvestorTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? investorId = null,
    Object? amount = null,
    Object? type = null,
    Object? referenceId = freezed,
    Object? description = freezed,
    Object? recordedByName = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$InvestorTransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        investorId: null == investorId
            ? _value.investorId
            : investorId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as InvestorTransactionType,
        referenceId: freezed == referenceId
            ? _value.referenceId
            : referenceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        recordedByName: freezed == recordedByName
            ? _value.recordedByName
            : recordedByName // ignore: cast_nullable_to_non_nullable
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
class _$InvestorTransactionImpl implements _InvestorTransaction {
  const _$InvestorTransactionImpl({
    required this.id,
    @JsonKey(name: 'investor_id') required this.investorId,
    required this.amount,
    required this.type,
    @JsonKey(name: 'reference_id') this.referenceId,
    this.description,
    @JsonKey(name: 'recorded_by_name') this.recordedByName,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$InvestorTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvestorTransactionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'investor_id')
  final String investorId;
  @override
  final double amount;
  @override
  final InvestorTransactionType type;
  @override
  @JsonKey(name: 'reference_id')
  final String? referenceId;
  @override
  final String? description;
  @override
  @JsonKey(name: 'recorded_by_name')
  final String? recordedByName;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'InvestorTransaction(id: $id, investorId: $investorId, amount: $amount, type: $type, referenceId: $referenceId, description: $description, recordedByName: $recordedByName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvestorTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.investorId, investorId) ||
                other.investorId == investorId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.recordedByName, recordedByName) ||
                other.recordedByName == recordedByName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    investorId,
    amount,
    type,
    referenceId,
    description,
    recordedByName,
    createdAt,
  );

  /// Create a copy of InvestorTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvestorTransactionImplCopyWith<_$InvestorTransactionImpl> get copyWith =>
      __$$InvestorTransactionImplCopyWithImpl<_$InvestorTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InvestorTransactionImplToJson(this);
  }
}

abstract class _InvestorTransaction implements InvestorTransaction {
  const factory _InvestorTransaction({
    required final String id,
    @JsonKey(name: 'investor_id') required final String investorId,
    required final double amount,
    required final InvestorTransactionType type,
    @JsonKey(name: 'reference_id') final String? referenceId,
    final String? description,
    @JsonKey(name: 'recorded_by_name') final String? recordedByName,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$InvestorTransactionImpl;

  factory _InvestorTransaction.fromJson(Map<String, dynamic> json) =
      _$InvestorTransactionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'investor_id')
  String get investorId;
  @override
  double get amount;
  @override
  InvestorTransactionType get type;
  @override
  @JsonKey(name: 'reference_id')
  String? get referenceId;
  @override
  String? get description;
  @override
  @JsonKey(name: 'recorded_by_name')
  String? get recordedByName;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of InvestorTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvestorTransactionImplCopyWith<_$InvestorTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
