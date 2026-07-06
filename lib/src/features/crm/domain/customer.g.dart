// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerImpl _$$CustomerImplFromJson(Map<String, dynamic> json) =>
    _$CustomerImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      nationalId: json['national_id'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      kycData: json['kyc_data'] as Map<String, dynamic>? ?? const {},
      riskRating: json['risk_rating'] as String? ?? 'medium',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$CustomerImplToJson(_$CustomerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'national_id': instance.nationalId,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'kyc_data': instance.kycData,
      'risk_rating': instance.riskRating,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
