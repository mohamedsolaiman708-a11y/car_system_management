// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CompanySettings _$CompanySettingsFromJson(Map<String, dynamic> json) {
  return _CompanySettings.fromJson(json);
}

/// @nodoc
mixin _$CompanySettings {
  String get companyName => throw _privateConstructorUsedError;
  String get logoUrl => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  double get defaultProfitRatio => throw _privateConstructorUsedError;
  String get currencyCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'tax_number')
  String get taxNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'cr_number')
  String get crNumber => throw _privateConstructorUsedError; // رقم السجل التجاري
  @JsonKey(name: 'website')
  String get website => throw _privateConstructorUsedError;

  /// Serializes this CompanySettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompanySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompanySettingsCopyWith<CompanySettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanySettingsCopyWith<$Res> {
  factory $CompanySettingsCopyWith(
    CompanySettings value,
    $Res Function(CompanySettings) then,
  ) = _$CompanySettingsCopyWithImpl<$Res, CompanySettings>;
  @useResult
  $Res call({
    String companyName,
    String logoUrl,
    String address,
    String phone,
    String email,
    String currency,
    double defaultProfitRatio,
    String currencyCode,
    @JsonKey(name: 'tax_number') String taxNumber,
    @JsonKey(name: 'cr_number') String crNumber,
    @JsonKey(name: 'website') String website,
  });
}

/// @nodoc
class _$CompanySettingsCopyWithImpl<$Res, $Val extends CompanySettings>
    implements $CompanySettingsCopyWith<$Res> {
  _$CompanySettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompanySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyName = null,
    Object? logoUrl = null,
    Object? address = null,
    Object? phone = null,
    Object? email = null,
    Object? currency = null,
    Object? defaultProfitRatio = null,
    Object? currencyCode = null,
    Object? taxNumber = null,
    Object? crNumber = null,
    Object? website = null,
  }) {
    return _then(
      _value.copyWith(
            companyName: null == companyName
                ? _value.companyName
                : companyName // ignore: cast_nullable_to_non_nullable
                      as String,
            logoUrl: null == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultProfitRatio: null == defaultProfitRatio
                ? _value.defaultProfitRatio
                : defaultProfitRatio // ignore: cast_nullable_to_non_nullable
                      as double,
            currencyCode: null == currencyCode
                ? _value.currencyCode
                : currencyCode // ignore: cast_nullable_to_non_nullable
                      as String,
            taxNumber: null == taxNumber
                ? _value.taxNumber
                : taxNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            crNumber: null == crNumber
                ? _value.crNumber
                : crNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            website: null == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CompanySettingsImplCopyWith<$Res>
    implements $CompanySettingsCopyWith<$Res> {
  factory _$$CompanySettingsImplCopyWith(
    _$CompanySettingsImpl value,
    $Res Function(_$CompanySettingsImpl) then,
  ) = __$$CompanySettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String companyName,
    String logoUrl,
    String address,
    String phone,
    String email,
    String currency,
    double defaultProfitRatio,
    String currencyCode,
    @JsonKey(name: 'tax_number') String taxNumber,
    @JsonKey(name: 'cr_number') String crNumber,
    @JsonKey(name: 'website') String website,
  });
}

/// @nodoc
class __$$CompanySettingsImplCopyWithImpl<$Res>
    extends _$CompanySettingsCopyWithImpl<$Res, _$CompanySettingsImpl>
    implements _$$CompanySettingsImplCopyWith<$Res> {
  __$$CompanySettingsImplCopyWithImpl(
    _$CompanySettingsImpl _value,
    $Res Function(_$CompanySettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompanySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyName = null,
    Object? logoUrl = null,
    Object? address = null,
    Object? phone = null,
    Object? email = null,
    Object? currency = null,
    Object? defaultProfitRatio = null,
    Object? currencyCode = null,
    Object? taxNumber = null,
    Object? crNumber = null,
    Object? website = null,
  }) {
    return _then(
      _$CompanySettingsImpl(
        companyName: null == companyName
            ? _value.companyName
            : companyName // ignore: cast_nullable_to_non_nullable
                  as String,
        logoUrl: null == logoUrl
            ? _value.logoUrl
            : logoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultProfitRatio: null == defaultProfitRatio
            ? _value.defaultProfitRatio
            : defaultProfitRatio // ignore: cast_nullable_to_non_nullable
                  as double,
        currencyCode: null == currencyCode
            ? _value.currencyCode
            : currencyCode // ignore: cast_nullable_to_non_nullable
                  as String,
        taxNumber: null == taxNumber
            ? _value.taxNumber
            : taxNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        crNumber: null == crNumber
            ? _value.crNumber
            : crNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        website: null == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompanySettingsImpl implements _CompanySettings {
  const _$CompanySettingsImpl({
    this.companyName = 'شركة التمويل المتقدمة',
    this.logoUrl = '',
    this.address = 'الرياض، المملكة العربية السعودية',
    this.phone = '',
    this.email = '',
    this.currency = 'ر.س',
    this.defaultProfitRatio = 15.0,
    this.currencyCode = 'SAR',
    @JsonKey(name: 'tax_number') this.taxNumber = '',
    @JsonKey(name: 'cr_number') this.crNumber = '',
    @JsonKey(name: 'website') this.website = '',
  });

  factory _$CompanySettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanySettingsImplFromJson(json);

  @override
  @JsonKey()
  final String companyName;
  @override
  @JsonKey()
  final String logoUrl;
  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  final double defaultProfitRatio;
  @override
  @JsonKey()
  final String currencyCode;
  @override
  @JsonKey(name: 'tax_number')
  final String taxNumber;
  @override
  @JsonKey(name: 'cr_number')
  final String crNumber;
  // رقم السجل التجاري
  @override
  @JsonKey(name: 'website')
  final String website;

  @override
  String toString() {
    return 'CompanySettings(companyName: $companyName, logoUrl: $logoUrl, address: $address, phone: $phone, email: $email, currency: $currency, defaultProfitRatio: $defaultProfitRatio, currencyCode: $currencyCode, taxNumber: $taxNumber, crNumber: $crNumber, website: $website)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanySettingsImpl &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.defaultProfitRatio, defaultProfitRatio) ||
                other.defaultProfitRatio == defaultProfitRatio) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.taxNumber, taxNumber) ||
                other.taxNumber == taxNumber) &&
            (identical(other.crNumber, crNumber) ||
                other.crNumber == crNumber) &&
            (identical(other.website, website) || other.website == website));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    companyName,
    logoUrl,
    address,
    phone,
    email,
    currency,
    defaultProfitRatio,
    currencyCode,
    taxNumber,
    crNumber,
    website,
  );

  /// Create a copy of CompanySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanySettingsImplCopyWith<_$CompanySettingsImpl> get copyWith =>
      __$$CompanySettingsImplCopyWithImpl<_$CompanySettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CompanySettingsImplToJson(this);
  }
}

abstract class _CompanySettings implements CompanySettings {
  const factory _CompanySettings({
    final String companyName,
    final String logoUrl,
    final String address,
    final String phone,
    final String email,
    final String currency,
    final double defaultProfitRatio,
    final String currencyCode,
    @JsonKey(name: 'tax_number') final String taxNumber,
    @JsonKey(name: 'cr_number') final String crNumber,
    @JsonKey(name: 'website') final String website,
  }) = _$CompanySettingsImpl;

  factory _CompanySettings.fromJson(Map<String, dynamic> json) =
      _$CompanySettingsImpl.fromJson;

  @override
  String get companyName;
  @override
  String get logoUrl;
  @override
  String get address;
  @override
  String get phone;
  @override
  String get email;
  @override
  String get currency;
  @override
  double get defaultProfitRatio;
  @override
  String get currencyCode;
  @override
  @JsonKey(name: 'tax_number')
  String get taxNumber;
  @override
  @JsonKey(name: 'cr_number')
  String get crNumber; // رقم السجل التجاري
  @override
  @JsonKey(name: 'website')
  String get website;

  /// Create a copy of CompanySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompanySettingsImplCopyWith<_$CompanySettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
