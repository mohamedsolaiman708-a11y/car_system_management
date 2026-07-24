import 'package:freezed_annotation/freezed_annotation.dart';

part 'investor.freezed.dart';
part 'investor.g.dart';

@freezed
class Investor with _$Investor {
  const factory Investor({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    @JsonKey(name: 'available_balance') required double availableBalance,
    @JsonKey(name: 'deployed_capital') required double deployedCapital,
    @JsonKey(name: 'total_profit_earned') required double totalProfitEarned,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Investor;

  factory Investor.fromJson(Map<String, dynamic> json) {
    return Investor(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      availableBalance: (json['available_balance'] as num?)?.toDouble() ?? 0.0,
      deployedCapital: (json['deployed_capital'] as num?)?.toDouble() ?? 0.0,
      totalProfitEarned: (json['total_profit_earned'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? (DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()) : DateTime.now(),
    );
  }
}
