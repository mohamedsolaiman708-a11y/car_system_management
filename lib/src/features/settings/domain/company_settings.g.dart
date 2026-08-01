// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompanySettingsImpl _$$CompanySettingsImplFromJson(
  Map<String, dynamic> json,
) => _$CompanySettingsImpl(
  companyName: json['companyName'] as String? ?? 'شركة التمويل المتقدمة',
  logoUrl: json['logoUrl'] as String? ?? '',
  address: json['address'] as String? ?? 'الرياض، المملكة العربية السعودية',
  phone: json['phone'] as String? ?? '',
  email: json['email'] as String? ?? '',
  currency: json['currency'] as String? ?? 'ر.س',
  defaultProfitRatio: (json['defaultProfitRatio'] as num?)?.toDouble() ?? 15.0,
  currencyCode: json['currencyCode'] as String? ?? 'SAR',
  taxNumber: json['tax_number'] as String? ?? '',
  crNumber: json['cr_number'] as String? ?? '',
  website: json['website'] as String? ?? '',
);

Map<String, dynamic> _$$CompanySettingsImplToJson(
  _$CompanySettingsImpl instance,
) => <String, dynamic>{
  'companyName': instance.companyName,
  'logoUrl': instance.logoUrl,
  'address': instance.address,
  'phone': instance.phone,
  'email': instance.email,
  'currency': instance.currency,
  'defaultProfitRatio': instance.defaultProfitRatio,
  'currencyCode': instance.currencyCode,
  'tax_number': instance.taxNumber,
  'cr_number': instance.crNumber,
  'website': instance.website,
};
