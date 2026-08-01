// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'domain_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DomainEvent _$DomainEventFromJson(Map<String, dynamic> json) {
  return _DomainEvent.fromJson(json);
}

/// @nodoc
mixin _$DomainEvent {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_name')
  String get eventName => throw _privateConstructorUsedError;
  @JsonKey(name: 'aggregate_id')
  String get aggregateId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get payload => throw _privateConstructorUsedError;
  @JsonKey(name: 'occurred_at')
  DateTime get occurredAt => throw _privateConstructorUsedError;

  /// Serializes this DomainEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DomainEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DomainEventCopyWith<DomainEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DomainEventCopyWith<$Res> {
  factory $DomainEventCopyWith(
    DomainEvent value,
    $Res Function(DomainEvent) then,
  ) = _$DomainEventCopyWithImpl<$Res, DomainEvent>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'event_name') String eventName,
    @JsonKey(name: 'aggregate_id') String aggregateId,
    Map<String, dynamic>? payload,
    @JsonKey(name: 'occurred_at') DateTime occurredAt,
  });
}

/// @nodoc
class _$DomainEventCopyWithImpl<$Res, $Val extends DomainEvent>
    implements $DomainEventCopyWith<$Res> {
  _$DomainEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DomainEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventName = null,
    Object? aggregateId = null,
    Object? payload = freezed,
    Object? occurredAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            eventName: null == eventName
                ? _value.eventName
                : eventName // ignore: cast_nullable_to_non_nullable
                      as String,
            aggregateId: null == aggregateId
                ? _value.aggregateId
                : aggregateId // ignore: cast_nullable_to_non_nullable
                      as String,
            payload: freezed == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            occurredAt: null == occurredAt
                ? _value.occurredAt
                : occurredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DomainEventImplCopyWith<$Res>
    implements $DomainEventCopyWith<$Res> {
  factory _$$DomainEventImplCopyWith(
    _$DomainEventImpl value,
    $Res Function(_$DomainEventImpl) then,
  ) = __$$DomainEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'event_name') String eventName,
    @JsonKey(name: 'aggregate_id') String aggregateId,
    Map<String, dynamic>? payload,
    @JsonKey(name: 'occurred_at') DateTime occurredAt,
  });
}

/// @nodoc
class __$$DomainEventImplCopyWithImpl<$Res>
    extends _$DomainEventCopyWithImpl<$Res, _$DomainEventImpl>
    implements _$$DomainEventImplCopyWith<$Res> {
  __$$DomainEventImplCopyWithImpl(
    _$DomainEventImpl _value,
    $Res Function(_$DomainEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DomainEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventName = null,
    Object? aggregateId = null,
    Object? payload = freezed,
    Object? occurredAt = null,
  }) {
    return _then(
      _$DomainEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        eventName: null == eventName
            ? _value.eventName
            : eventName // ignore: cast_nullable_to_non_nullable
                  as String,
        aggregateId: null == aggregateId
            ? _value.aggregateId
            : aggregateId // ignore: cast_nullable_to_non_nullable
                  as String,
        payload: freezed == payload
            ? _value._payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        occurredAt: null == occurredAt
            ? _value.occurredAt
            : occurredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DomainEventImpl implements _DomainEvent {
  const _$DomainEventImpl({
    required this.id,
    @JsonKey(name: 'event_name') required this.eventName,
    @JsonKey(name: 'aggregate_id') required this.aggregateId,
    final Map<String, dynamic>? payload,
    @JsonKey(name: 'occurred_at') required this.occurredAt,
  }) : _payload = payload;

  factory _$DomainEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$DomainEventImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'event_name')
  final String eventName;
  @override
  @JsonKey(name: 'aggregate_id')
  final String aggregateId;
  final Map<String, dynamic>? _payload;
  @override
  Map<String, dynamic>? get payload {
    final value = _payload;
    if (value == null) return null;
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'occurred_at')
  final DateTime occurredAt;

  @override
  String toString() {
    return 'DomainEvent(id: $id, eventName: $eventName, aggregateId: $aggregateId, payload: $payload, occurredAt: $occurredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DomainEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventName, eventName) ||
                other.eventName == eventName) &&
            (identical(other.aggregateId, aggregateId) ||
                other.aggregateId == aggregateId) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.occurredAt, occurredAt) ||
                other.occurredAt == occurredAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    eventName,
    aggregateId,
    const DeepCollectionEquality().hash(_payload),
    occurredAt,
  );

  /// Create a copy of DomainEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DomainEventImplCopyWith<_$DomainEventImpl> get copyWith =>
      __$$DomainEventImplCopyWithImpl<_$DomainEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DomainEventImplToJson(this);
  }
}

abstract class _DomainEvent implements DomainEvent {
  const factory _DomainEvent({
    required final String id,
    @JsonKey(name: 'event_name') required final String eventName,
    @JsonKey(name: 'aggregate_id') required final String aggregateId,
    final Map<String, dynamic>? payload,
    @JsonKey(name: 'occurred_at') required final DateTime occurredAt,
  }) = _$DomainEventImpl;

  factory _DomainEvent.fromJson(Map<String, dynamic> json) =
      _$DomainEventImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'event_name')
  String get eventName;
  @override
  @JsonKey(name: 'aggregate_id')
  String get aggregateId;
  @override
  Map<String, dynamic>? get payload;
  @override
  @JsonKey(name: 'occurred_at')
  DateTime get occurredAt;

  /// Create a copy of DomainEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DomainEventImplCopyWith<_$DomainEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
