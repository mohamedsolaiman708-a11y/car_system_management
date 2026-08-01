// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContractActivityImpl _$$ContractActivityImplFromJson(
  Map<String, dynamic> json,
) => _$ContractActivityImpl(
  eventType: json['eventType'] as String,
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  details: json['details'] as Map<String, dynamic>? ?? const {},
  profileName: json['profileName'] as String?,
);

Map<String, dynamic> _$$ContractActivityImplToJson(
  _$ContractActivityImpl instance,
) => <String, dynamic>{
  'eventType': instance.eventType,
  'occurredAt': instance.occurredAt.toIso8601String(),
  'details': instance.details,
  'profileName': instance.profileName,
};
