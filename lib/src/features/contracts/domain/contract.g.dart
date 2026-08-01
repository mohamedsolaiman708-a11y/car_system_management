// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContractImpl _$$ContractImplFromJson(
  Map<String, dynamic> json,
) => _$ContractImpl(
  id: json['id'] as String,
  contractNo: json['contract_no'] as String,
  customerId: json['customer_id'] as String?,
  inventoryItemId: json['inventory_item_id'] as String?,
  principalAmount: (json['principal_amount'] as num?)?.toDouble() ?? 0.0,
  financeProfitRate: (json['finance_profit_rate'] as num?)?.toDouble() ?? 0.0,
  totalContractValue: (json['total_contract_value'] as num?)?.toDouble() ?? 0.0,
  durationMonths: (json['duration_months'] as num?)?.toInt() ?? 0,
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  status: json['status'] as String? ?? 'draft',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  type: json['type'] as String?,
  guarantor1Name: json['guarantor_1_name'] as String?,
  guarantor1Id: json['guarantor_1_id'] as String?,
  guarantor1Phone: json['guarantor_1_phone'] as String?,
  guarantor1Work: json['guarantor_1_work'] as String?,
  guarantor1Address: json['guarantor_1_address'] as String?,
  guarantor2Name: json['guarantor_2_name'] as String?,
  guarantor2Id: json['guarantor_2_id'] as String?,
  guarantor2Phone: json['guarantor_2_phone'] as String?,
  guarantor2Work: json['guarantor_2_work'] as String?,
  guarantor2Address: json['guarantor_2_address'] as String?,
  witness1: json['witness_1'] as String?,
  witness2: json['witness_2'] as String?,
  downPayment: (json['down_payment'] as num?)?.toDouble() ?? 0.0,
  moroorFees: (json['moroor_fees'] as num?)?.toDouble() ?? 0.0,
  tammFees: (json['tamm_fees'] as num?)?.toDouble() ?? 0.0,
  insuranceFees: (json['insurance_fees'] as num?)?.toDouble() ?? 0.0,
  inspectionFees: (json['inspection_fees'] as num?)?.toDouble() ?? 0.0,
  plateFees: (json['plate_fees'] as num?)?.toDouble() ?? 0.0,
  trafficViolationsFees:
      (json['traffic_violations_fees'] as num?)?.toDouble() ?? 0.0,
  otherFees: (json['other_fees'] as num?)?.toDouble() ?? 0.0,
  vatAmount: (json['vat_amount'] as num?)?.toDouble() ?? 0.0,
  notes: json['notes'] as String?,
  vehiclesList: (json['vehicles_list'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  customer: json['customers'] as Map<String, dynamic>?,
  vehicle: json['inventory_items'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ContractImplToJson(_$ContractImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contract_no': instance.contractNo,
      'customer_id': instance.customerId,
      'inventory_item_id': instance.inventoryItemId,
      'principal_amount': instance.principalAmount,
      'finance_profit_rate': instance.financeProfitRate,
      'total_contract_value': instance.totalContractValue,
      'duration_months': instance.durationMonths,
      'start_date': instance.startDate?.toIso8601String(),
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'type': instance.type,
      'guarantor_1_name': instance.guarantor1Name,
      'guarantor_1_id': instance.guarantor1Id,
      'guarantor_1_phone': instance.guarantor1Phone,
      'guarantor_1_work': instance.guarantor1Work,
      'guarantor_1_address': instance.guarantor1Address,
      'guarantor_2_name': instance.guarantor2Name,
      'guarantor_2_id': instance.guarantor2Id,
      'guarantor_2_phone': instance.guarantor2Phone,
      'guarantor_2_work': instance.guarantor2Work,
      'guarantor_2_address': instance.guarantor2Address,
      'witness_1': instance.witness1,
      'witness_2': instance.witness2,
      'down_payment': instance.downPayment,
      'moroor_fees': instance.moroorFees,
      'tamm_fees': instance.tammFees,
      'insurance_fees': instance.insuranceFees,
      'inspection_fees': instance.inspectionFees,
      'plate_fees': instance.plateFees,
      'traffic_violations_fees': instance.trafficViolationsFees,
      'other_fees': instance.otherFees,
      'vat_amount': instance.vatAmount,
      'notes': instance.notes,
      'vehicles_list': instance.vehiclesList,
      'customers': instance.customer,
      'inventory_items': instance.vehicle,
    };
