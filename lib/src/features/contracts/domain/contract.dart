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
    @JsonKey(name: 'guarantor_1_address') String? guarantor1Address,
    
    @JsonKey(name: 'guarantor_2_name') String? guarantor2Name,
    @JsonKey(name: 'guarantor_2_id') String? guarantor2Id,
    @JsonKey(name: 'guarantor_2_phone') String? guarantor2Phone,
    @JsonKey(name: 'guarantor_2_work') String? guarantor2Work,
    @JsonKey(name: 'guarantor_2_address') String? guarantor2Address,

    @JsonKey(name: 'witness_1') String? witness1,
    @JsonKey(name: 'witness_2') String? witness2,
    
    @JsonKey(name: 'down_payment') @Default(0.0) double downPayment,
    @JsonKey(name: 'moroor_fees') @Default(0.0) double moroorFees,
    @JsonKey(name: 'tamm_fees') @Default(0.0) double tammFees,
    @JsonKey(name: 'insurance_fees') @Default(0.0) double insuranceFees,
    @JsonKey(name: 'inspection_fees') @Default(0.0) double inspectionFees,
    @JsonKey(name: 'plate_fees') @Default(0.0) double plateFees,
    @JsonKey(name: 'traffic_violations_fees') @Default(0.0) double trafficViolationsFees,
    @JsonKey(name: 'other_fees') @Default(0.0) double otherFees,
    @JsonKey(name: 'vat_amount') @Default(0.0) double vatAmount,
    
    @JsonKey(name: 'notes') String? notes,
    @JsonKey(name: 'vehicles_list') List<Map<String, dynamic>>? vehiclesList,

    @JsonKey(name: 'customers') Map<String, dynamic>? customer,
    @JsonKey(name: 'inventory_items') Map<String, dynamic>? vehicle,
  }) = _Contract;

  factory Contract.fromJson(Map<String, dynamic> json) => _$ContractFromJson(json);
}
