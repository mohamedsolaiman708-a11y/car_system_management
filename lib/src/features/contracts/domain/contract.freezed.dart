// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Contract _$ContractFromJson(Map<String, dynamic> json) {
  return _Contract.fromJson(json);
}

/// @nodoc
mixin _$Contract {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'contract_no')
  String get contractNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  String? get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'inventory_item_id')
  String? get inventoryItemId => throw _privateConstructorUsedError;
  @JsonKey(name: 'principal_amount')
  double get principalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'finance_profit_rate')
  double get financeProfitRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_contract_value')
  double get totalContractValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_months')
  int get durationMonths => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError; // جعلته اختيارياً لضمان عدم تعطل العقد
  String? get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'guarantor_1_name')
  String? get guarantor1Name => throw _privateConstructorUsedError;
  @JsonKey(name: 'guarantor_1_id')
  String? get guarantor1Id => throw _privateConstructorUsedError;
  @JsonKey(name: 'guarantor_1_phone')
  String? get guarantor1Phone => throw _privateConstructorUsedError;
  @JsonKey(name: 'guarantor_1_work')
  String? get guarantor1Work => throw _privateConstructorUsedError;
  @JsonKey(name: 'guarantor_1_address')
  String? get guarantor1Address => throw _privateConstructorUsedError;
  @JsonKey(name: 'guarantor_2_name')
  String? get guarantor2Name => throw _privateConstructorUsedError;
  @JsonKey(name: 'guarantor_2_id')
  String? get guarantor2Id => throw _privateConstructorUsedError;
  @JsonKey(name: 'guarantor_2_phone')
  String? get guarantor2Phone => throw _privateConstructorUsedError;
  @JsonKey(name: 'guarantor_2_work')
  String? get guarantor2Work => throw _privateConstructorUsedError;
  @JsonKey(name: 'guarantor_2_address')
  String? get guarantor2Address => throw _privateConstructorUsedError;
  @JsonKey(name: 'witness_1')
  String? get witness1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'witness_2')
  String? get witness2 => throw _privateConstructorUsedError;
  @JsonKey(name: 'down_payment')
  double get downPayment => throw _privateConstructorUsedError;
  @JsonKey(name: 'moroor_fees')
  double get moroorFees => throw _privateConstructorUsedError;
  @JsonKey(name: 'tamm_fees')
  double get tammFees => throw _privateConstructorUsedError;
  @JsonKey(name: 'insurance_fees')
  double get insuranceFees => throw _privateConstructorUsedError;
  @JsonKey(name: 'inspection_fees')
  double get inspectionFees => throw _privateConstructorUsedError;
  @JsonKey(name: 'plate_fees')
  double get plateFees => throw _privateConstructorUsedError;
  @JsonKey(name: 'traffic_violations_fees')
  double get trafficViolationsFees => throw _privateConstructorUsedError;
  @JsonKey(name: 'other_fees')
  double get otherFees => throw _privateConstructorUsedError;
  @JsonKey(name: 'vat_amount')
  double get vatAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'notes')
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicles_list')
  List<Map<String, dynamic>>? get vehiclesList =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'investor_id')
  String? get investorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'investors')
  Map<String, dynamic>? get investor => throw _privateConstructorUsedError;
  @JsonKey(name: 'customers')
  Map<String, dynamic>? get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'inventory_items')
  Map<String, dynamic>? get vehicle => throw _privateConstructorUsedError;

  /// Serializes this Contract to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Contract
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContractCopyWith<Contract> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContractCopyWith<$Res> {
  factory $ContractCopyWith(Contract value, $Res Function(Contract) then) =
      _$ContractCopyWithImpl<$Res, Contract>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String id,
    @JsonKey(name: 'contract_no') String contractNo,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'inventory_item_id') String? inventoryItemId,
    @JsonKey(name: 'principal_amount') double principalAmount,
    @JsonKey(name: 'finance_profit_rate') double financeProfitRate,
    @JsonKey(name: 'total_contract_value') double totalContractValue,
    @JsonKey(name: 'duration_months') int durationMonths,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'status') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
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
    @JsonKey(name: 'down_payment') double downPayment,
    @JsonKey(name: 'moroor_fees') double moroorFees,
    @JsonKey(name: 'tamm_fees') double tammFees,
    @JsonKey(name: 'insurance_fees') double insuranceFees,
    @JsonKey(name: 'inspection_fees') double inspectionFees,
    @JsonKey(name: 'plate_fees') double plateFees,
    @JsonKey(name: 'traffic_violations_fees') double trafficViolationsFees,
    @JsonKey(name: 'other_fees') double otherFees,
    @JsonKey(name: 'vat_amount') double vatAmount,
    @JsonKey(name: 'notes') String? notes,
    @JsonKey(name: 'vehicles_list') List<Map<String, dynamic>>? vehiclesList,
    @JsonKey(name: 'investor_id') String? investorId,
    @JsonKey(name: 'investors') Map<String, dynamic>? investor,
    @JsonKey(name: 'customers') Map<String, dynamic>? customer,
    @JsonKey(name: 'inventory_items') Map<String, dynamic>? vehicle,
  });
}

/// @nodoc
class _$ContractCopyWithImpl<$Res, $Val extends Contract>
    implements $ContractCopyWith<$Res> {
  _$ContractCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Contract
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contractNo = null,
    Object? customerId = freezed,
    Object? inventoryItemId = freezed,
    Object? principalAmount = null,
    Object? financeProfitRate = null,
    Object? totalContractValue = null,
    Object? durationMonths = null,
    Object? startDate = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? type = freezed,
    Object? guarantor1Name = freezed,
    Object? guarantor1Id = freezed,
    Object? guarantor1Phone = freezed,
    Object? guarantor1Work = freezed,
    Object? guarantor1Address = freezed,
    Object? guarantor2Name = freezed,
    Object? guarantor2Id = freezed,
    Object? guarantor2Phone = freezed,
    Object? guarantor2Work = freezed,
    Object? guarantor2Address = freezed,
    Object? witness1 = freezed,
    Object? witness2 = freezed,
    Object? downPayment = null,
    Object? moroorFees = null,
    Object? tammFees = null,
    Object? insuranceFees = null,
    Object? inspectionFees = null,
    Object? plateFees = null,
    Object? trafficViolationsFees = null,
    Object? otherFees = null,
    Object? vatAmount = null,
    Object? notes = freezed,
    Object? vehiclesList = freezed,
    Object? investorId = freezed,
    Object? investor = freezed,
    Object? customer = freezed,
    Object? vehicle = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            contractNo: null == contractNo
                ? _value.contractNo
                : contractNo // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            inventoryItemId: freezed == inventoryItemId
                ? _value.inventoryItemId
                : inventoryItemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            principalAmount: null == principalAmount
                ? _value.principalAmount
                : principalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            financeProfitRate: null == financeProfitRate
                ? _value.financeProfitRate
                : financeProfitRate // ignore: cast_nullable_to_non_nullable
                      as double,
            totalContractValue: null == totalContractValue
                ? _value.totalContractValue
                : totalContractValue // ignore: cast_nullable_to_non_nullable
                      as double,
            durationMonths: null == durationMonths
                ? _value.durationMonths
                : durationMonths // ignore: cast_nullable_to_non_nullable
                      as int,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            guarantor1Name: freezed == guarantor1Name
                ? _value.guarantor1Name
                : guarantor1Name // ignore: cast_nullable_to_non_nullable
                      as String?,
            guarantor1Id: freezed == guarantor1Id
                ? _value.guarantor1Id
                : guarantor1Id // ignore: cast_nullable_to_non_nullable
                      as String?,
            guarantor1Phone: freezed == guarantor1Phone
                ? _value.guarantor1Phone
                : guarantor1Phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            guarantor1Work: freezed == guarantor1Work
                ? _value.guarantor1Work
                : guarantor1Work // ignore: cast_nullable_to_non_nullable
                      as String?,
            guarantor1Address: freezed == guarantor1Address
                ? _value.guarantor1Address
                : guarantor1Address // ignore: cast_nullable_to_non_nullable
                      as String?,
            guarantor2Name: freezed == guarantor2Name
                ? _value.guarantor2Name
                : guarantor2Name // ignore: cast_nullable_to_non_nullable
                      as String?,
            guarantor2Id: freezed == guarantor2Id
                ? _value.guarantor2Id
                : guarantor2Id // ignore: cast_nullable_to_non_nullable
                      as String?,
            guarantor2Phone: freezed == guarantor2Phone
                ? _value.guarantor2Phone
                : guarantor2Phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            guarantor2Work: freezed == guarantor2Work
                ? _value.guarantor2Work
                : guarantor2Work // ignore: cast_nullable_to_non_nullable
                      as String?,
            guarantor2Address: freezed == guarantor2Address
                ? _value.guarantor2Address
                : guarantor2Address // ignore: cast_nullable_to_non_nullable
                      as String?,
            witness1: freezed == witness1
                ? _value.witness1
                : witness1 // ignore: cast_nullable_to_non_nullable
                      as String?,
            witness2: freezed == witness2
                ? _value.witness2
                : witness2 // ignore: cast_nullable_to_non_nullable
                      as String?,
            downPayment: null == downPayment
                ? _value.downPayment
                : downPayment // ignore: cast_nullable_to_non_nullable
                      as double,
            moroorFees: null == moroorFees
                ? _value.moroorFees
                : moroorFees // ignore: cast_nullable_to_non_nullable
                      as double,
            tammFees: null == tammFees
                ? _value.tammFees
                : tammFees // ignore: cast_nullable_to_non_nullable
                      as double,
            insuranceFees: null == insuranceFees
                ? _value.insuranceFees
                : insuranceFees // ignore: cast_nullable_to_non_nullable
                      as double,
            inspectionFees: null == inspectionFees
                ? _value.inspectionFees
                : inspectionFees // ignore: cast_nullable_to_non_nullable
                      as double,
            plateFees: null == plateFees
                ? _value.plateFees
                : plateFees // ignore: cast_nullable_to_non_nullable
                      as double,
            trafficViolationsFees: null == trafficViolationsFees
                ? _value.trafficViolationsFees
                : trafficViolationsFees // ignore: cast_nullable_to_non_nullable
                      as double,
            otherFees: null == otherFees
                ? _value.otherFees
                : otherFees // ignore: cast_nullable_to_non_nullable
                      as double,
            vatAmount: null == vatAmount
                ? _value.vatAmount
                : vatAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            vehiclesList: freezed == vehiclesList
                ? _value.vehiclesList
                : vehiclesList // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>?,
            investorId: freezed == investorId
                ? _value.investorId
                : investorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            investor: freezed == investor
                ? _value.investor
                : investor // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            customer: freezed == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            vehicle: freezed == vehicle
                ? _value.vehicle
                : vehicle // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ContractImplCopyWith<$Res>
    implements $ContractCopyWith<$Res> {
  factory _$$ContractImplCopyWith(
    _$ContractImpl value,
    $Res Function(_$ContractImpl) then,
  ) = __$$ContractImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String id,
    @JsonKey(name: 'contract_no') String contractNo,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'inventory_item_id') String? inventoryItemId,
    @JsonKey(name: 'principal_amount') double principalAmount,
    @JsonKey(name: 'finance_profit_rate') double financeProfitRate,
    @JsonKey(name: 'total_contract_value') double totalContractValue,
    @JsonKey(name: 'duration_months') int durationMonths,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'status') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
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
    @JsonKey(name: 'down_payment') double downPayment,
    @JsonKey(name: 'moroor_fees') double moroorFees,
    @JsonKey(name: 'tamm_fees') double tammFees,
    @JsonKey(name: 'insurance_fees') double insuranceFees,
    @JsonKey(name: 'inspection_fees') double inspectionFees,
    @JsonKey(name: 'plate_fees') double plateFees,
    @JsonKey(name: 'traffic_violations_fees') double trafficViolationsFees,
    @JsonKey(name: 'other_fees') double otherFees,
    @JsonKey(name: 'vat_amount') double vatAmount,
    @JsonKey(name: 'notes') String? notes,
    @JsonKey(name: 'vehicles_list') List<Map<String, dynamic>>? vehiclesList,
    @JsonKey(name: 'investor_id') String? investorId,
    @JsonKey(name: 'investors') Map<String, dynamic>? investor,
    @JsonKey(name: 'customers') Map<String, dynamic>? customer,
    @JsonKey(name: 'inventory_items') Map<String, dynamic>? vehicle,
  });
}

/// @nodoc
class __$$ContractImplCopyWithImpl<$Res>
    extends _$ContractCopyWithImpl<$Res, _$ContractImpl>
    implements _$$ContractImplCopyWith<$Res> {
  __$$ContractImplCopyWithImpl(
    _$ContractImpl _value,
    $Res Function(_$ContractImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Contract
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contractNo = null,
    Object? customerId = freezed,
    Object? inventoryItemId = freezed,
    Object? principalAmount = null,
    Object? financeProfitRate = null,
    Object? totalContractValue = null,
    Object? durationMonths = null,
    Object? startDate = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? type = freezed,
    Object? guarantor1Name = freezed,
    Object? guarantor1Id = freezed,
    Object? guarantor1Phone = freezed,
    Object? guarantor1Work = freezed,
    Object? guarantor1Address = freezed,
    Object? guarantor2Name = freezed,
    Object? guarantor2Id = freezed,
    Object? guarantor2Phone = freezed,
    Object? guarantor2Work = freezed,
    Object? guarantor2Address = freezed,
    Object? witness1 = freezed,
    Object? witness2 = freezed,
    Object? downPayment = null,
    Object? moroorFees = null,
    Object? tammFees = null,
    Object? insuranceFees = null,
    Object? inspectionFees = null,
    Object? plateFees = null,
    Object? trafficViolationsFees = null,
    Object? otherFees = null,
    Object? vatAmount = null,
    Object? notes = freezed,
    Object? vehiclesList = freezed,
    Object? investorId = freezed,
    Object? investor = freezed,
    Object? customer = freezed,
    Object? vehicle = freezed,
  }) {
    return _then(
      _$ContractImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        contractNo: null == contractNo
            ? _value.contractNo
            : contractNo // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        inventoryItemId: freezed == inventoryItemId
            ? _value.inventoryItemId
            : inventoryItemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        principalAmount: null == principalAmount
            ? _value.principalAmount
            : principalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        financeProfitRate: null == financeProfitRate
            ? _value.financeProfitRate
            : financeProfitRate // ignore: cast_nullable_to_non_nullable
                  as double,
        totalContractValue: null == totalContractValue
            ? _value.totalContractValue
            : totalContractValue // ignore: cast_nullable_to_non_nullable
                  as double,
        durationMonths: null == durationMonths
            ? _value.durationMonths
            : durationMonths // ignore: cast_nullable_to_non_nullable
                  as int,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        guarantor1Name: freezed == guarantor1Name
            ? _value.guarantor1Name
            : guarantor1Name // ignore: cast_nullable_to_non_nullable
                  as String?,
        guarantor1Id: freezed == guarantor1Id
            ? _value.guarantor1Id
            : guarantor1Id // ignore: cast_nullable_to_non_nullable
                  as String?,
        guarantor1Phone: freezed == guarantor1Phone
            ? _value.guarantor1Phone
            : guarantor1Phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        guarantor1Work: freezed == guarantor1Work
            ? _value.guarantor1Work
            : guarantor1Work // ignore: cast_nullable_to_non_nullable
                  as String?,
        guarantor1Address: freezed == guarantor1Address
            ? _value.guarantor1Address
            : guarantor1Address // ignore: cast_nullable_to_non_nullable
                  as String?,
        guarantor2Name: freezed == guarantor2Name
            ? _value.guarantor2Name
            : guarantor2Name // ignore: cast_nullable_to_non_nullable
                  as String?,
        guarantor2Id: freezed == guarantor2Id
            ? _value.guarantor2Id
            : guarantor2Id // ignore: cast_nullable_to_non_nullable
                  as String?,
        guarantor2Phone: freezed == guarantor2Phone
            ? _value.guarantor2Phone
            : guarantor2Phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        guarantor2Work: freezed == guarantor2Work
            ? _value.guarantor2Work
            : guarantor2Work // ignore: cast_nullable_to_non_nullable
                  as String?,
        guarantor2Address: freezed == guarantor2Address
            ? _value.guarantor2Address
            : guarantor2Address // ignore: cast_nullable_to_non_nullable
                  as String?,
        witness1: freezed == witness1
            ? _value.witness1
            : witness1 // ignore: cast_nullable_to_non_nullable
                  as String?,
        witness2: freezed == witness2
            ? _value.witness2
            : witness2 // ignore: cast_nullable_to_non_nullable
                  as String?,
        downPayment: null == downPayment
            ? _value.downPayment
            : downPayment // ignore: cast_nullable_to_non_nullable
                  as double,
        moroorFees: null == moroorFees
            ? _value.moroorFees
            : moroorFees // ignore: cast_nullable_to_non_nullable
                  as double,
        tammFees: null == tammFees
            ? _value.tammFees
            : tammFees // ignore: cast_nullable_to_non_nullable
                  as double,
        insuranceFees: null == insuranceFees
            ? _value.insuranceFees
            : insuranceFees // ignore: cast_nullable_to_non_nullable
                  as double,
        inspectionFees: null == inspectionFees
            ? _value.inspectionFees
            : inspectionFees // ignore: cast_nullable_to_non_nullable
                  as double,
        plateFees: null == plateFees
            ? _value.plateFees
            : plateFees // ignore: cast_nullable_to_non_nullable
                  as double,
        trafficViolationsFees: null == trafficViolationsFees
            ? _value.trafficViolationsFees
            : trafficViolationsFees // ignore: cast_nullable_to_non_nullable
                  as double,
        otherFees: null == otherFees
            ? _value.otherFees
            : otherFees // ignore: cast_nullable_to_non_nullable
                  as double,
        vatAmount: null == vatAmount
            ? _value.vatAmount
            : vatAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        vehiclesList: freezed == vehiclesList
            ? _value._vehiclesList
            : vehiclesList // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>?,
        investorId: freezed == investorId
            ? _value.investorId
            : investorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        investor: freezed == investor
            ? _value._investor
            : investor // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        customer: freezed == customer
            ? _value._customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        vehicle: freezed == vehicle
            ? _value._vehicle
            : vehicle // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContractImpl implements _Contract {
  const _$ContractImpl({
    @JsonKey(name: 'id') required this.id,
    @JsonKey(name: 'contract_no') required this.contractNo,
    @JsonKey(name: 'customer_id') this.customerId,
    @JsonKey(name: 'inventory_item_id') this.inventoryItemId,
    @JsonKey(name: 'principal_amount') this.principalAmount = 0.0,
    @JsonKey(name: 'finance_profit_rate') this.financeProfitRate = 0.0,
    @JsonKey(name: 'total_contract_value') this.totalContractValue = 0.0,
    @JsonKey(name: 'duration_months') this.durationMonths = 0,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'status') this.status = 'draft',
    @JsonKey(name: 'created_at') this.createdAt,
    this.type,
    @JsonKey(name: 'guarantor_1_name') this.guarantor1Name,
    @JsonKey(name: 'guarantor_1_id') this.guarantor1Id,
    @JsonKey(name: 'guarantor_1_phone') this.guarantor1Phone,
    @JsonKey(name: 'guarantor_1_work') this.guarantor1Work,
    @JsonKey(name: 'guarantor_1_address') this.guarantor1Address,
    @JsonKey(name: 'guarantor_2_name') this.guarantor2Name,
    @JsonKey(name: 'guarantor_2_id') this.guarantor2Id,
    @JsonKey(name: 'guarantor_2_phone') this.guarantor2Phone,
    @JsonKey(name: 'guarantor_2_work') this.guarantor2Work,
    @JsonKey(name: 'guarantor_2_address') this.guarantor2Address,
    @JsonKey(name: 'witness_1') this.witness1,
    @JsonKey(name: 'witness_2') this.witness2,
    @JsonKey(name: 'down_payment') this.downPayment = 0.0,
    @JsonKey(name: 'moroor_fees') this.moroorFees = 0.0,
    @JsonKey(name: 'tamm_fees') this.tammFees = 0.0,
    @JsonKey(name: 'insurance_fees') this.insuranceFees = 0.0,
    @JsonKey(name: 'inspection_fees') this.inspectionFees = 0.0,
    @JsonKey(name: 'plate_fees') this.plateFees = 0.0,
    @JsonKey(name: 'traffic_violations_fees') this.trafficViolationsFees = 0.0,
    @JsonKey(name: 'other_fees') this.otherFees = 0.0,
    @JsonKey(name: 'vat_amount') this.vatAmount = 0.0,
    @JsonKey(name: 'notes') this.notes,
    @JsonKey(name: 'vehicles_list')
    final List<Map<String, dynamic>>? vehiclesList,
    @JsonKey(name: 'investor_id') this.investorId,
    @JsonKey(name: 'investors') final Map<String, dynamic>? investor,
    @JsonKey(name: 'customers') final Map<String, dynamic>? customer,
    @JsonKey(name: 'inventory_items') final Map<String, dynamic>? vehicle,
  }) : _vehiclesList = vehiclesList,
       _investor = investor,
       _customer = customer,
       _vehicle = vehicle;

  factory _$ContractImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContractImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'contract_no')
  final String contractNo;
  @override
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @override
  @JsonKey(name: 'inventory_item_id')
  final String? inventoryItemId;
  @override
  @JsonKey(name: 'principal_amount')
  final double principalAmount;
  @override
  @JsonKey(name: 'finance_profit_rate')
  final double financeProfitRate;
  @override
  @JsonKey(name: 'total_contract_value')
  final double totalContractValue;
  @override
  @JsonKey(name: 'duration_months')
  final int durationMonths;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'status')
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  // جعلته اختيارياً لضمان عدم تعطل العقد
  @override
  final String? type;
  @override
  @JsonKey(name: 'guarantor_1_name')
  final String? guarantor1Name;
  @override
  @JsonKey(name: 'guarantor_1_id')
  final String? guarantor1Id;
  @override
  @JsonKey(name: 'guarantor_1_phone')
  final String? guarantor1Phone;
  @override
  @JsonKey(name: 'guarantor_1_work')
  final String? guarantor1Work;
  @override
  @JsonKey(name: 'guarantor_1_address')
  final String? guarantor1Address;
  @override
  @JsonKey(name: 'guarantor_2_name')
  final String? guarantor2Name;
  @override
  @JsonKey(name: 'guarantor_2_id')
  final String? guarantor2Id;
  @override
  @JsonKey(name: 'guarantor_2_phone')
  final String? guarantor2Phone;
  @override
  @JsonKey(name: 'guarantor_2_work')
  final String? guarantor2Work;
  @override
  @JsonKey(name: 'guarantor_2_address')
  final String? guarantor2Address;
  @override
  @JsonKey(name: 'witness_1')
  final String? witness1;
  @override
  @JsonKey(name: 'witness_2')
  final String? witness2;
  @override
  @JsonKey(name: 'down_payment')
  final double downPayment;
  @override
  @JsonKey(name: 'moroor_fees')
  final double moroorFees;
  @override
  @JsonKey(name: 'tamm_fees')
  final double tammFees;
  @override
  @JsonKey(name: 'insurance_fees')
  final double insuranceFees;
  @override
  @JsonKey(name: 'inspection_fees')
  final double inspectionFees;
  @override
  @JsonKey(name: 'plate_fees')
  final double plateFees;
  @override
  @JsonKey(name: 'traffic_violations_fees')
  final double trafficViolationsFees;
  @override
  @JsonKey(name: 'other_fees')
  final double otherFees;
  @override
  @JsonKey(name: 'vat_amount')
  final double vatAmount;
  @override
  @JsonKey(name: 'notes')
  final String? notes;
  final List<Map<String, dynamic>>? _vehiclesList;
  @override
  @JsonKey(name: 'vehicles_list')
  List<Map<String, dynamic>>? get vehiclesList {
    final value = _vehiclesList;
    if (value == null) return null;
    if (_vehiclesList is EqualUnmodifiableListView) return _vehiclesList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'investor_id')
  final String? investorId;
  final Map<String, dynamic>? _investor;
  @override
  @JsonKey(name: 'investors')
  Map<String, dynamic>? get investor {
    final value = _investor;
    if (value == null) return null;
    if (_investor is EqualUnmodifiableMapView) return _investor;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _customer;
  @override
  @JsonKey(name: 'customers')
  Map<String, dynamic>? get customer {
    final value = _customer;
    if (value == null) return null;
    if (_customer is EqualUnmodifiableMapView) return _customer;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _vehicle;
  @override
  @JsonKey(name: 'inventory_items')
  Map<String, dynamic>? get vehicle {
    final value = _vehicle;
    if (value == null) return null;
    if (_vehicle is EqualUnmodifiableMapView) return _vehicle;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Contract(id: $id, contractNo: $contractNo, customerId: $customerId, inventoryItemId: $inventoryItemId, principalAmount: $principalAmount, financeProfitRate: $financeProfitRate, totalContractValue: $totalContractValue, durationMonths: $durationMonths, startDate: $startDate, status: $status, createdAt: $createdAt, type: $type, guarantor1Name: $guarantor1Name, guarantor1Id: $guarantor1Id, guarantor1Phone: $guarantor1Phone, guarantor1Work: $guarantor1Work, guarantor1Address: $guarantor1Address, guarantor2Name: $guarantor2Name, guarantor2Id: $guarantor2Id, guarantor2Phone: $guarantor2Phone, guarantor2Work: $guarantor2Work, guarantor2Address: $guarantor2Address, witness1: $witness1, witness2: $witness2, downPayment: $downPayment, moroorFees: $moroorFees, tammFees: $tammFees, insuranceFees: $insuranceFees, inspectionFees: $inspectionFees, plateFees: $plateFees, trafficViolationsFees: $trafficViolationsFees, otherFees: $otherFees, vatAmount: $vatAmount, notes: $notes, vehiclesList: $vehiclesList, investorId: $investorId, investor: $investor, customer: $customer, vehicle: $vehicle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContractImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.contractNo, contractNo) ||
                other.contractNo == contractNo) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.inventoryItemId, inventoryItemId) ||
                other.inventoryItemId == inventoryItemId) &&
            (identical(other.principalAmount, principalAmount) ||
                other.principalAmount == principalAmount) &&
            (identical(other.financeProfitRate, financeProfitRate) ||
                other.financeProfitRate == financeProfitRate) &&
            (identical(other.totalContractValue, totalContractValue) ||
                other.totalContractValue == totalContractValue) &&
            (identical(other.durationMonths, durationMonths) ||
                other.durationMonths == durationMonths) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.guarantor1Name, guarantor1Name) ||
                other.guarantor1Name == guarantor1Name) &&
            (identical(other.guarantor1Id, guarantor1Id) ||
                other.guarantor1Id == guarantor1Id) &&
            (identical(other.guarantor1Phone, guarantor1Phone) ||
                other.guarantor1Phone == guarantor1Phone) &&
            (identical(other.guarantor1Work, guarantor1Work) ||
                other.guarantor1Work == guarantor1Work) &&
            (identical(other.guarantor1Address, guarantor1Address) ||
                other.guarantor1Address == guarantor1Address) &&
            (identical(other.guarantor2Name, guarantor2Name) ||
                other.guarantor2Name == guarantor2Name) &&
            (identical(other.guarantor2Id, guarantor2Id) ||
                other.guarantor2Id == guarantor2Id) &&
            (identical(other.guarantor2Phone, guarantor2Phone) ||
                other.guarantor2Phone == guarantor2Phone) &&
            (identical(other.guarantor2Work, guarantor2Work) ||
                other.guarantor2Work == guarantor2Work) &&
            (identical(other.guarantor2Address, guarantor2Address) ||
                other.guarantor2Address == guarantor2Address) &&
            (identical(other.witness1, witness1) ||
                other.witness1 == witness1) &&
            (identical(other.witness2, witness2) ||
                other.witness2 == witness2) &&
            (identical(other.downPayment, downPayment) ||
                other.downPayment == downPayment) &&
            (identical(other.moroorFees, moroorFees) ||
                other.moroorFees == moroorFees) &&
            (identical(other.tammFees, tammFees) ||
                other.tammFees == tammFees) &&
            (identical(other.insuranceFees, insuranceFees) ||
                other.insuranceFees == insuranceFees) &&
            (identical(other.inspectionFees, inspectionFees) ||
                other.inspectionFees == inspectionFees) &&
            (identical(other.plateFees, plateFees) ||
                other.plateFees == plateFees) &&
            (identical(other.trafficViolationsFees, trafficViolationsFees) ||
                other.trafficViolationsFees == trafficViolationsFees) &&
            (identical(other.otherFees, otherFees) ||
                other.otherFees == otherFees) &&
            (identical(other.vatAmount, vatAmount) ||
                other.vatAmount == vatAmount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(
              other._vehiclesList,
              _vehiclesList,
            ) &&
            (identical(other.investorId, investorId) ||
                other.investorId == investorId) &&
            const DeepCollectionEquality().equals(other._investor, _investor) &&
            const DeepCollectionEquality().equals(other._customer, _customer) &&
            const DeepCollectionEquality().equals(other._vehicle, _vehicle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    contractNo,
    customerId,
    inventoryItemId,
    principalAmount,
    financeProfitRate,
    totalContractValue,
    durationMonths,
    startDate,
    status,
    createdAt,
    type,
    guarantor1Name,
    guarantor1Id,
    guarantor1Phone,
    guarantor1Work,
    guarantor1Address,
    guarantor2Name,
    guarantor2Id,
    guarantor2Phone,
    guarantor2Work,
    guarantor2Address,
    witness1,
    witness2,
    downPayment,
    moroorFees,
    tammFees,
    insuranceFees,
    inspectionFees,
    plateFees,
    trafficViolationsFees,
    otherFees,
    vatAmount,
    notes,
    const DeepCollectionEquality().hash(_vehiclesList),
    investorId,
    const DeepCollectionEquality().hash(_investor),
    const DeepCollectionEquality().hash(_customer),
    const DeepCollectionEquality().hash(_vehicle),
  ]);

  /// Create a copy of Contract
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContractImplCopyWith<_$ContractImpl> get copyWith =>
      __$$ContractImplCopyWithImpl<_$ContractImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContractImplToJson(this);
  }
}

abstract class _Contract implements Contract {
  const factory _Contract({
    @JsonKey(name: 'id') required final String id,
    @JsonKey(name: 'contract_no') required final String contractNo,
    @JsonKey(name: 'customer_id') final String? customerId,
    @JsonKey(name: 'inventory_item_id') final String? inventoryItemId,
    @JsonKey(name: 'principal_amount') final double principalAmount,
    @JsonKey(name: 'finance_profit_rate') final double financeProfitRate,
    @JsonKey(name: 'total_contract_value') final double totalContractValue,
    @JsonKey(name: 'duration_months') final int durationMonths,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'status') final String status,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    final String? type,
    @JsonKey(name: 'guarantor_1_name') final String? guarantor1Name,
    @JsonKey(name: 'guarantor_1_id') final String? guarantor1Id,
    @JsonKey(name: 'guarantor_1_phone') final String? guarantor1Phone,
    @JsonKey(name: 'guarantor_1_work') final String? guarantor1Work,
    @JsonKey(name: 'guarantor_1_address') final String? guarantor1Address,
    @JsonKey(name: 'guarantor_2_name') final String? guarantor2Name,
    @JsonKey(name: 'guarantor_2_id') final String? guarantor2Id,
    @JsonKey(name: 'guarantor_2_phone') final String? guarantor2Phone,
    @JsonKey(name: 'guarantor_2_work') final String? guarantor2Work,
    @JsonKey(name: 'guarantor_2_address') final String? guarantor2Address,
    @JsonKey(name: 'witness_1') final String? witness1,
    @JsonKey(name: 'witness_2') final String? witness2,
    @JsonKey(name: 'down_payment') final double downPayment,
    @JsonKey(name: 'moroor_fees') final double moroorFees,
    @JsonKey(name: 'tamm_fees') final double tammFees,
    @JsonKey(name: 'insurance_fees') final double insuranceFees,
    @JsonKey(name: 'inspection_fees') final double inspectionFees,
    @JsonKey(name: 'plate_fees') final double plateFees,
    @JsonKey(name: 'traffic_violations_fees')
    final double trafficViolationsFees,
    @JsonKey(name: 'other_fees') final double otherFees,
    @JsonKey(name: 'vat_amount') final double vatAmount,
    @JsonKey(name: 'notes') final String? notes,
    @JsonKey(name: 'vehicles_list')
    final List<Map<String, dynamic>>? vehiclesList,
    @JsonKey(name: 'investor_id') final String? investorId,
    @JsonKey(name: 'investors') final Map<String, dynamic>? investor,
    @JsonKey(name: 'customers') final Map<String, dynamic>? customer,
    @JsonKey(name: 'inventory_items') final Map<String, dynamic>? vehicle,
  }) = _$ContractImpl;

  factory _Contract.fromJson(Map<String, dynamic> json) =
      _$ContractImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'contract_no')
  String get contractNo;
  @override
  @JsonKey(name: 'customer_id')
  String? get customerId;
  @override
  @JsonKey(name: 'inventory_item_id')
  String? get inventoryItemId;
  @override
  @JsonKey(name: 'principal_amount')
  double get principalAmount;
  @override
  @JsonKey(name: 'finance_profit_rate')
  double get financeProfitRate;
  @override
  @JsonKey(name: 'total_contract_value')
  double get totalContractValue;
  @override
  @JsonKey(name: 'duration_months')
  int get durationMonths;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'status')
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt; // جعلته اختيارياً لضمان عدم تعطل العقد
  @override
  String? get type;
  @override
  @JsonKey(name: 'guarantor_1_name')
  String? get guarantor1Name;
  @override
  @JsonKey(name: 'guarantor_1_id')
  String? get guarantor1Id;
  @override
  @JsonKey(name: 'guarantor_1_phone')
  String? get guarantor1Phone;
  @override
  @JsonKey(name: 'guarantor_1_work')
  String? get guarantor1Work;
  @override
  @JsonKey(name: 'guarantor_1_address')
  String? get guarantor1Address;
  @override
  @JsonKey(name: 'guarantor_2_name')
  String? get guarantor2Name;
  @override
  @JsonKey(name: 'guarantor_2_id')
  String? get guarantor2Id;
  @override
  @JsonKey(name: 'guarantor_2_phone')
  String? get guarantor2Phone;
  @override
  @JsonKey(name: 'guarantor_2_work')
  String? get guarantor2Work;
  @override
  @JsonKey(name: 'guarantor_2_address')
  String? get guarantor2Address;
  @override
  @JsonKey(name: 'witness_1')
  String? get witness1;
  @override
  @JsonKey(name: 'witness_2')
  String? get witness2;
  @override
  @JsonKey(name: 'down_payment')
  double get downPayment;
  @override
  @JsonKey(name: 'moroor_fees')
  double get moroorFees;
  @override
  @JsonKey(name: 'tamm_fees')
  double get tammFees;
  @override
  @JsonKey(name: 'insurance_fees')
  double get insuranceFees;
  @override
  @JsonKey(name: 'inspection_fees')
  double get inspectionFees;
  @override
  @JsonKey(name: 'plate_fees')
  double get plateFees;
  @override
  @JsonKey(name: 'traffic_violations_fees')
  double get trafficViolationsFees;
  @override
  @JsonKey(name: 'other_fees')
  double get otherFees;
  @override
  @JsonKey(name: 'vat_amount')
  double get vatAmount;
  @override
  @JsonKey(name: 'notes')
  String? get notes;
  @override
  @JsonKey(name: 'vehicles_list')
  List<Map<String, dynamic>>? get vehiclesList;
  @override
  @JsonKey(name: 'investor_id')
  String? get investorId;
  @override
  @JsonKey(name: 'investors')
  Map<String, dynamic>? get investor;
  @override
  @JsonKey(name: 'customers')
  Map<String, dynamic>? get customer;
  @override
  @JsonKey(name: 'inventory_items')
  Map<String, dynamic>? get vehicle;

  /// Create a copy of Contract
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContractImplCopyWith<_$ContractImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
