import 'package:freezed_annotation/freezed_annotation.dart';
import 'investor_transaction_type.dart';

part 'investor_transaction.freezed.dart';
part 'investor_transaction.g.dart';

@freezed
class InvestorTransaction with _$InvestorTransaction {
  const factory InvestorTransaction({
    required String id,
    @JsonKey(name: 'investor_id') required String investorId,
    required double amount,
    required InvestorTransactionType type,
    @JsonKey(name: 'reference_id') String? referenceId,
    String? description,
    @JsonKey(name: 'recorded_by_name') String? recordedByName,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _InvestorTransaction;

  factory InvestorTransaction.fromJson(Map<String, dynamic> json) => _$InvestorTransactionFromJson(json);
}
