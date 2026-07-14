import 'package:freezed_annotation/freezed_annotation.dart';

part 'investor.freezed.dart';
part 'investor.g.dart';

@freezed
class Investor with _$Investor {
  const factory Investor({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    // تطابق تام مع أسماء الأعمدة في صورتك
    @JsonKey(name: 'available_bal') required double availableBalance,
    @JsonKey(name: 'deployed_capi') required double deployedCapital,
    @JsonKey(name: 'total_profit_') required double totalProfitEarned,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Investor;

  factory Investor.fromJson(Map<String, dynamic> json) => _$InvestorFromJson(json);
}
