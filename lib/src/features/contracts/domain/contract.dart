import 'package:freezed_annotation/freezed_annotation.dart';

part 'contract.freezed.dart';
part 'contract.g.dart';

@freezed
class Contract with _$Contract {
  const factory Contract({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'contract_no') required String contractNo,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'inventory_item_id') String? inventoryItemId,
    @JsonKey(name: 'principal_amount') @Default(0.0) double principalAmount,
    @JsonKey(name: 'finance_profit_rate') @Default(0.0) double financeProfitRate,
    @JsonKey(name: 'total_contract_value') @Default(0.0) double totalContractValue,
    @JsonKey(name: 'duration_months') @Default(0) int durationMonths,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'status') @Default('draft') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt, // جعلته اختيارياً لضمان عدم تعطل العقد
    
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
    
    @JsonKey(name: 'customers') Map<String, dynamic>? customer,
    @JsonKey(name: 'inventory_items') Map<String, dynamic>? vehicle,
  }) = _Contract;

  factory Contract.fromJson(Map<String, dynamic> json) => _$ContractFromJson(json);
}
