import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'national_id') required String nationalId,
    required String phone,
    String? email,
    String? address,
    @JsonKey(name: 'kyc_data') @Default({}) Map<String, dynamic> kycData,
    @JsonKey(name: 'risk_rating') @Default('medium') String riskRating,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
}
