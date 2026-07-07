import 'package:freezed_annotation/freezed_annotation.dart';

part 'contract.freezed.dart';
part 'contract.g.dart';

@freezed
class Contract with _$Contract {
  const factory Contract({
    required String id,
    @JsonKey(name: 'contract_no') required String contractNo,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'inventory_item_id') required String inventoryItemId,
    @JsonKey(name: 'principal_amount') required double principalAmount,
    @JsonKey(name: 'finance_profit_rate') required double financeProfitRate,
    @JsonKey(name: 'total_contract_value') required double totalContractValue,
    @JsonKey(name: 'duration_months') required int durationMonths,
    @JsonKey(name: 'start_date') DateTime? startDate,
    required String status, // draft, pending_funding, active, closed, defaulted
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Optional relations (for UI display)
    @Default(null) Map<String, dynamic>? customer,
    @Default(null) Map<String, dynamic>? vehicle,
  }) = _Contract;

  factory Contract.fromJson(Map<String, dynamic> json) => _$ContractFromJson(json);
}
