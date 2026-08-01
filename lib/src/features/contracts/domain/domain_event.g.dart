// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DomainEventImpl _$$DomainEventImplFromJson(Map<String, dynamic> json) =>
    _$DomainEventImpl(
      id: json['id'] as String,
      eventName: json['event_name'] as String,
      aggregateId: json['aggregate_id'] as String,
      payload: json['payload'] as Map<String, dynamic>?,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
    );

Map<String, dynamic> _$$DomainEventImplToJson(_$DomainEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_name': instance.eventName,
      'aggregate_id': instance.aggregateId,
      'payload': instance.payload,
      'occurred_at': instance.occurredAt.toIso8601String(),
    };
