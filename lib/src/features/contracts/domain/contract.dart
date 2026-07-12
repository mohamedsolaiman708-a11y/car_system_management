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
    @Default('draft') String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    
    // إضافات بناءً على متطلبات النظام
    String? type,
    @JsonKey(name: 'guarantor_1_name') String? guarantor1Name,
    @JsonKey(name: 'guarantor_1_id') String? guarantor1Id,
    @JsonKey(name: 'guarantor_1_phone') String? guarantor1Phone,
    @JsonKey(name: 'guarantor_1_work') String? guarantor1Work,
    
    @JsonKey(name: 'witness_1') String? witness1,
    @JsonKey(name: 'witness_2') String? witness2,
    
    @JsonKey(name: 'moroor_fees') @Default(0.0) double moroorFees,
    @JsonKey(name: 'tamm_fees') @Default(0.0) double tammFees,
    @JsonKey(name: 'insurance_fees') @Default(0.0) double insuranceFees,
    @JsonKey(name: 'vat_amount') @Default(0.0) double vatAmount,
    
    // Joined data (Matching Supabase keys)
    @JsonKey(name: 'customers') Map<String, dynamic>? customer,
    @JsonKey(name: 'inventory_items') Map<String, dynamic>? vehicle,
  }) = _Contract;

  factory Contract.fromJson(Map<String, dynamic> json) => _$ContractFromJson(json);
}
