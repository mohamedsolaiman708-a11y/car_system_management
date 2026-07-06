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
        return 'Deposit';
      case InvestorTransactionType.withdrawal:
        return 'Withdrawal';
      case InvestorTransactionType.contractAllocation:
        return 'Contract Allocation';
      case InvestorTransactionType.contractReturn:
        return 'Contract Return';
      case InvestorTransactionType.financeProfitDistribution:
        return 'Finance Profit Distribution';
    }
  }
}
