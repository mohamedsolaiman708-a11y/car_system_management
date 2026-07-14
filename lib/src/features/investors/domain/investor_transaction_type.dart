import 'package:json_annotation/json_annotation.dart';

enum InvestorTransactionType {
  @JsonValue('deposit')
  deposit,
  @JsonValue('withdrawal')
  withdrawal,
  @JsonValue('contract_allocation')
  contractAllocation,
  @JsonValue('contract_return')
  contractReturn,
  @JsonValue('finance_profit_distribution')
  financeProfitDistribution;

  String get label {
    switch (this) {
      case InvestorTransactionType.deposit:
        return 'إيداع رأس مال';
      case InvestorTransactionType.withdrawal:
        return 'سحب نقدي';
      case InvestorTransactionType.contractAllocation:
        return 'تمويل عقد';
      case InvestorTransactionType.contractReturn:
        return 'استرداد رأس مال من قسط';
      case InvestorTransactionType.financeProfitDistribution:
        return 'توزيع أرباح تمويل';
    }
  }
}
