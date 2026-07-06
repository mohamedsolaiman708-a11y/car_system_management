// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investor_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvestorTransactionImpl _$$InvestorTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$InvestorTransactionImpl(
  id: json['id'] as String,
  investorId: json['investor_id'] as String,
  amount: (json['amount'] as num).toDouble(),
  type: $enumDecode(_$InvestorTransactionTypeEnumMap, json['type']),
  referenceId: json['reference_id'] as String?,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$InvestorTransactionImplToJson(
  _$InvestorTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'investor_id': instance.investorId,
  'amount': instance.amount,
  'type': _$InvestorTransactionTypeEnumMap[instance.type]!,
  'reference_id': instance.referenceId,
  'description': instance.description,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$InvestorTransactionTypeEnumMap = {
  InvestorTransactionType.deposit: 'deposit',
  InvestorTransactionType.withdrawal: 'withdrawal',
  InvestorTransactionType.contractAllocation: 'contract_allocation',
  InvestorTransactionType.contractReturn: 'contract_return',
  InvestorTransactionType.financeProfitDistribution:
      'finance_profit_distribution',
};
