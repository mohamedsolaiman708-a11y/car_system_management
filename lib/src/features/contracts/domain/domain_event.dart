import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain_event.freezed.dart';
part 'domain_event.g.dart';

@freezed
class DomainEvent with _$DomainEvent {
  const factory DomainEvent({
    required String id,
    @JsonKey(name: 'event_name') required String eventName,
    @JsonKey(name: 'aggregate_id') required String aggregateId,
    Map<String, dynamic>? payload,
    @JsonKey(name: 'occurred_at') required DateTime occurredAt,
  }) = _DomainEvent;

  factory DomainEvent.fromJson(Map<String, dynamic> json) => _$DomainEventFromJson(json);
}
