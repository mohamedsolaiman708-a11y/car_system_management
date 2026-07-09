import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_settings.freezed.dart';
part 'company_settings.g.dart';

@freezed
class CompanySettings with _$CompanySettings {
  const factory CompanySettings({
    @Default('شركة التمويل المتقدمة') String companyName,
    @Default('') String logoUrl,
    @Default('الرياض، المملكة العربية السعودية') String address,
    @Default('') String phone,
    @Default('') String email,
    @Default('ر.س') String currency,
    @Default(15.0) double defaultProfitRatio,
    @Default('SAR') String currencyCode,
    @JsonKey(name: 'tax_number') @Default('') String taxNumber,
    @JsonKey(name: 'cr_number') @Default('') String crNumber, // رقم السجل التجاري
    @JsonKey(name: 'website') @Default('') String website,
  }) = _CompanySettings;

  factory CompanySettings.fromJson(Map<String, dynamic> json) => _$CompanySettingsFromJson(json);
}
