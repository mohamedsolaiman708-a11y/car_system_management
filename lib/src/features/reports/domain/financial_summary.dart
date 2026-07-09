import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_summary.freezed.dart';
part 'financial_summary.g.dart';

@freezed
class FinancialSummary with _$FinancialSummary {
  const factory FinancialSummary({
    @JsonKey(name: 'total_revenue') required double totalRevenue,
    @JsonKey(name: 'total_profit') required double totalProfit,
    @JsonKey(name: 'active_contracts_count') required int activeContractsCount,
    @JsonKey(name: 'total_deployed_capital') required double totalDeployedCapital,
    @JsonKey(name: 'collected_amount') required double collectedAmount,
    @JsonKey(name: 'overdue_amount') required double overdueAmount,
  }) = _FinancialSummary;

  factory FinancialSummary.fromJson(Map<String, dynamic> json) => _$FinancialSummaryFromJson(json);
}
