// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchResultImpl _$$SearchResultImplFromJson(Map<String, dynamic> json) =>
    _$SearchResultImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      entityType: $enumDecode(_$SearchEntityTypeEnumMap, json['entityType']),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$SearchResultImplToJson(_$SearchResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'entityType': _$SearchEntityTypeEnumMap[instance.entityType]!,
      'metadata': instance.metadata,
    };

const _$SearchEntityTypeEnumMap = {
  SearchEntityType.customer: 'customer',
  SearchEntityType.investor: 'investor',
  SearchEntityType.contract: 'contract',
  SearchEntityType.payment: 'payment',
  SearchEntityType.staff: 'staff',
};
