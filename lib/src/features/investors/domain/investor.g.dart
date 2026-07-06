// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvestorImpl _$$InvestorImplFromJson(Map<String, dynamic> json) =>
    _$InvestorImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      availableBalance: (json['available_balance'] as num).toDouble(),
      deployedCapital: (json['deployed_capital'] as num).toDouble(),
      totalProfitEarned: (json['total_profit_earned'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$InvestorImplToJson(_$InvestorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'email': instance.email,
      'available_balance': instance.availableBalance,
      'deployed_capital': instance.deployedCapital,
      'total_profit_earned': instance.totalProfitEarned,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
