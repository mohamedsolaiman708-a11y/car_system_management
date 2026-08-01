// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FinancialSummary _$FinancialSummaryFromJson(Map<String, dynamic> json) {
  return _FinancialSummary.fromJson(json);
}

/// @nodoc
mixin _$FinancialSummary {
  @JsonKey(name: 'total_revenue')
  double get totalRevenue => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_profit')
  double get totalProfit => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_contracts_count')
  int get activeContractsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_deployed_capital')
  double get totalDeployedCapital => throw _privateConstructorUsedError;
  @JsonKey(name: 'collected_amount')
  double get collectedAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'overdue_amount')
  double get overdueAmount => throw _privateConstructorUsedError;

  /// Serializes this FinancialSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FinancialSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinancialSummaryCopyWith<FinancialSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialSummaryCopyWith<$Res> {
  factory $FinancialSummaryCopyWith(
    FinancialSummary value,
    $Res Function(FinancialSummary) then,
  ) = _$FinancialSummaryCopyWithImpl<$Res, FinancialSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'total_revenue') double totalRevenue,
    @JsonKey(name: 'total_profit') double totalProfit,
    @JsonKey(name: 'active_contracts_count') int activeContractsCount,
    @JsonKey(name: 'total_deployed_capital') double totalDeployedCapital,
    @JsonKey(name: 'collected_amount') double collectedAmount,
    @JsonKey(name: 'overdue_amount') double overdueAmount,
  });
}

/// @nodoc
class _$FinancialSummaryCopyWithImpl<$Res, $Val extends FinancialSummary>
    implements $FinancialSummaryCopyWith<$Res> {
  _$FinancialSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinancialSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRevenue = null,
    Object? totalProfit = null,
    Object? activeContractsCount = null,
    Object? totalDeployedCapital = null,
    Object? collectedAmount = null,
    Object? overdueAmount = null,
  }) {
    return _then(
      _value.copyWith(
            totalRevenue: null == totalRevenue
                ? _value.totalRevenue
                : totalRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            totalProfit: null == totalProfit
                ? _value.totalProfit
                : totalProfit // ignore: cast_nullable_to_non_nullable
                      as double,
            activeContractsCount: null == activeContractsCount
                ? _value.activeContractsCount
                : activeContractsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDeployedCapital: null == totalDeployedCapital
                ? _value.totalDeployedCapital
                : totalDeployedCapital // ignore: cast_nullable_to_non_nullable
                      as double,
            collectedAmount: null == collectedAmount
                ? _value.collectedAmount
                : collectedAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            overdueAmount: null == overdueAmount
                ? _value.overdueAmount
                : overdueAmount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FinancialSummaryImplCopyWith<$Res>
    implements $FinancialSummaryCopyWith<$Res> {
  factory _$$FinancialSummaryImplCopyWith(
    _$FinancialSummaryImpl value,
    $Res Function(_$FinancialSummaryImpl) then,
  ) = __$$FinancialSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'total_revenue') double totalRevenue,
    @JsonKey(name: 'total_profit') double totalProfit,
    @JsonKey(name: 'active_contracts_count') int activeContractsCount,
    @JsonKey(name: 'total_deployed_capital') double totalDeployedCapital,
    @JsonKey(name: 'collected_amount') double collectedAmount,
    @JsonKey(name: 'overdue_amount') double overdueAmount,
  });
}

/// @nodoc
class __$$FinancialSummaryImplCopyWithImpl<$Res>
    extends _$FinancialSummaryCopyWithImpl<$Res, _$FinancialSummaryImpl>
    implements _$$FinancialSummaryImplCopyWith<$Res> {
  __$$FinancialSummaryImplCopyWithImpl(
    _$FinancialSummaryImpl _value,
    $Res Function(_$FinancialSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FinancialSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRevenue = null,
    Object? totalProfit = null,
    Object? activeContractsCount = null,
    Object? totalDeployedCapital = null,
    Object? collectedAmount = null,
    Object? overdueAmount = null,
  }) {
    return _then(
      _$FinancialSummaryImpl(
        totalRevenue: null == totalRevenue
            ? _value.totalRevenue
            : totalRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        totalProfit: null == totalProfit
            ? _value.totalProfit
            : totalProfit // ignore: cast_nullable_to_non_nullable
                  as double,
        activeContractsCount: null == activeContractsCount
            ? _value.activeContractsCount
            : activeContractsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDeployedCapital: null == totalDeployedCapital
            ? _value.totalDeployedCapital
            : totalDeployedCapital // ignore: cast_nullable_to_non_nullable
                  as double,
        collectedAmount: null == collectedAmount
            ? _value.collectedAmount
            : collectedAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        overdueAmount: null == overdueAmount
            ? _value.overdueAmount
            : overdueAmount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialSummaryImpl implements _FinancialSummary {
  const _$FinancialSummaryImpl({
    @JsonKey(name: 'total_revenue') required this.totalRevenue,
    @JsonKey(name: 'total_profit') required this.totalProfit,
    @JsonKey(name: 'active_contracts_count') required this.activeContractsCount,
    @JsonKey(name: 'total_deployed_capital') required this.totalDeployedCapital,
    @JsonKey(name: 'collected_amount') required this.collectedAmount,
    @JsonKey(name: 'overdue_amount') required this.overdueAmount,
  });

  factory _$FinancialSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'total_revenue')
  final double totalRevenue;
  @override
  @JsonKey(name: 'total_profit')
  final double totalProfit;
  @override
  @JsonKey(name: 'active_contracts_count')
  final int activeContractsCount;
  @override
  @JsonKey(name: 'total_deployed_capital')
  final double totalDeployedCapital;
  @override
  @JsonKey(name: 'collected_amount')
  final double collectedAmount;
  @override
  @JsonKey(name: 'overdue_amount')
  final double overdueAmount;

  @override
  String toString() {
    return 'FinancialSummary(totalRevenue: $totalRevenue, totalProfit: $totalProfit, activeContractsCount: $activeContractsCount, totalDeployedCapital: $totalDeployedCapital, collectedAmount: $collectedAmount, overdueAmount: $overdueAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialSummaryImpl &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.totalProfit, totalProfit) ||
                other.totalProfit == totalProfit) &&
            (identical(other.activeContractsCount, activeContractsCount) ||
                other.activeContractsCount == activeContractsCount) &&
            (identical(other.totalDeployedCapital, totalDeployedCapital) ||
                other.totalDeployedCapital == totalDeployedCapital) &&
            (identical(other.collectedAmount, collectedAmount) ||
                other.collectedAmount == collectedAmount) &&
            (identical(other.overdueAmount, overdueAmount) ||
                other.overdueAmount == overdueAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalRevenue,
    totalProfit,
    activeContractsCount,
    totalDeployedCapital,
    collectedAmount,
    overdueAmount,
  );

  /// Create a copy of FinancialSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialSummaryImplCopyWith<_$FinancialSummaryImpl> get copyWith =>
      __$$FinancialSummaryImplCopyWithImpl<_$FinancialSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialSummaryImplToJson(this);
  }
}

abstract class _FinancialSummary implements FinancialSummary {
  const factory _FinancialSummary({
    @JsonKey(name: 'total_revenue') required final double totalRevenue,
    @JsonKey(name: 'total_profit') required final double totalProfit,
    @JsonKey(name: 'active_contracts_count')
    required final int activeContractsCount,
    @JsonKey(name: 'total_deployed_capital')
    required final double totalDeployedCapital,
    @JsonKey(name: 'collected_amount') required final double collectedAmount,
    @JsonKey(name: 'overdue_amount') required final double overdueAmount,
  }) = _$FinancialSummaryImpl;

  factory _FinancialSummary.fromJson(Map<String, dynamic> json) =
      _$FinancialSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'total_revenue')
  double get totalRevenue;
  @override
  @JsonKey(name: 'total_profit')
  double get totalProfit;
  @override
  @JsonKey(name: 'active_contracts_count')
  int get activeContractsCount;
  @override
  @JsonKey(name: 'total_deployed_capital')
  double get totalDeployedCapital;
  @override
  @JsonKey(name: 'collected_amount')
  double get collectedAmount;
  @override
  @JsonKey(name: 'overdue_amount')
  double get overdueAmount;

  /// Create a copy of FinancialSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinancialSummaryImplCopyWith<_$FinancialSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
