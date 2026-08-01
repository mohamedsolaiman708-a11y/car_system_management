// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FinancialSummaryImpl _$$FinancialSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$FinancialSummaryImpl(
  totalRevenue: (json['total_revenue'] as num).toDouble(),
  totalProfit: (json['total_profit'] as num).toDouble(),
  activeContractsCount: (json['active_contracts_count'] as num).toInt(),
  totalDeployedCapital: (json['total_deployed_capital'] as num).toDouble(),
  collectedAmount: (json['collected_amount'] as num).toDouble(),
  overdueAmount: (json['overdue_amount'] as num).toDouble(),
);

Map<String, dynamic> _$$FinancialSummaryImplToJson(
  _$FinancialSummaryImpl instance,
) => <String, dynamic>{
  'total_revenue': instance.totalRevenue,
  'total_profit': instance.totalProfit,
  'active_contracts_count': instance.activeContractsCount,
  'total_deployed_capital': instance.totalDeployedCapital,
  'collected_amount': instance.collectedAmount,
  'overdue_amount': instance.overdueAmount,
};
