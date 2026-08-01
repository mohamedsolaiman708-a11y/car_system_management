// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journal_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) {
  return _JournalEntry.fromJson(json);
}

/// @nodoc
mixin _$JournalEntry {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'fiscal_period_id')
  String? get fiscalPeriodId => throw _privateConstructorUsedError;
  @JsonKey(name: 'entry_date')
  DateTime get entryDate => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_no')
  String? get referenceNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_type')
  String? get sourceType => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_id')
  String? get sourceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<JournalEntryLine> get lines => throw _privateConstructorUsedError;

  /// Serializes this JournalEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JournalEntryCopyWith<JournalEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JournalEntryCopyWith<$Res> {
  factory $JournalEntryCopyWith(
    JournalEntry value,
    $Res Function(JournalEntry) then,
  ) = _$JournalEntryCopyWithImpl<$Res, JournalEntry>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'fiscal_period_id') String? fiscalPeriodId,
    @JsonKey(name: 'entry_date') DateTime entryDate,
    String description,
    @JsonKey(name: 'reference_no') String? referenceNo,
    @JsonKey(name: 'source_type') String? sourceType,
    @JsonKey(name: 'source_id') String? sourceId,
    @JsonKey(name: 'created_at') DateTime createdAt,
    List<JournalEntryLine> lines,
  });
}

/// @nodoc
class _$JournalEntryCopyWithImpl<$Res, $Val extends JournalEntry>
    implements $JournalEntryCopyWith<$Res> {
  _$JournalEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fiscalPeriodId = freezed,
    Object? entryDate = null,
    Object? description = null,
    Object? referenceNo = freezed,
    Object? sourceType = freezed,
    Object? sourceId = freezed,
    Object? createdAt = null,
    Object? lines = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            fiscalPeriodId: freezed == fiscalPeriodId
                ? _value.fiscalPeriodId
                : fiscalPeriodId // ignore: cast_nullable_to_non_nullable
                      as String?,
            entryDate: null == entryDate
                ? _value.entryDate
                : entryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            referenceNo: freezed == referenceNo
                ? _value.referenceNo
                : referenceNo // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceType: freezed == sourceType
                ? _value.sourceType
                : sourceType // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceId: freezed == sourceId
                ? _value.sourceId
                : sourceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lines: null == lines
                ? _value.lines
                : lines // ignore: cast_nullable_to_non_nullable
                      as List<JournalEntryLine>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JournalEntryImplCopyWith<$Res>
    implements $JournalEntryCopyWith<$Res> {
  factory _$$JournalEntryImplCopyWith(
    _$JournalEntryImpl value,
    $Res Function(_$JournalEntryImpl) then,
  ) = __$$JournalEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'fiscal_period_id') String? fiscalPeriodId,
    @JsonKey(name: 'entry_date') DateTime entryDate,
    String description,
    @JsonKey(name: 'reference_no') String? referenceNo,
    @JsonKey(name: 'source_type') String? sourceType,
    @JsonKey(name: 'source_id') String? sourceId,
    @JsonKey(name: 'created_at') DateTime createdAt,
    List<JournalEntryLine> lines,
  });
}

/// @nodoc
class __$$JournalEntryImplCopyWithImpl<$Res>
    extends _$JournalEntryCopyWithImpl<$Res, _$JournalEntryImpl>
    implements _$$JournalEntryImplCopyWith<$Res> {
  __$$JournalEntryImplCopyWithImpl(
    _$JournalEntryImpl _value,
    $Res Function(_$JournalEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fiscalPeriodId = freezed,
    Object? entryDate = null,
    Object? description = null,
    Object? referenceNo = freezed,
    Object? sourceType = freezed,
    Object? sourceId = freezed,
    Object? createdAt = null,
    Object? lines = null,
  }) {
    return _then(
      _$JournalEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        fiscalPeriodId: freezed == fiscalPeriodId
            ? _value.fiscalPeriodId
            : fiscalPeriodId // ignore: cast_nullable_to_non_nullable
                  as String?,
        entryDate: null == entryDate
            ? _value.entryDate
            : entryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        referenceNo: freezed == referenceNo
            ? _value.referenceNo
            : referenceNo // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceType: freezed == sourceType
            ? _value.sourceType
            : sourceType // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceId: freezed == sourceId
            ? _value.sourceId
            : sourceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lines: null == lines
            ? _value._lines
            : lines // ignore: cast_nullable_to_non_nullable
                  as List<JournalEntryLine>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JournalEntryImpl implements _JournalEntry {
  const _$JournalEntryImpl({
    required this.id,
    @JsonKey(name: 'fiscal_period_id') this.fiscalPeriodId,
    @JsonKey(name: 'entry_date') required this.entryDate,
    required this.description,
    @JsonKey(name: 'reference_no') this.referenceNo,
    @JsonKey(name: 'source_type') this.sourceType,
    @JsonKey(name: 'source_id') this.sourceId,
    @JsonKey(name: 'created_at') required this.createdAt,
    final List<JournalEntryLine> lines = const [],
  }) : _lines = lines;

  factory _$JournalEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$JournalEntryImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'fiscal_period_id')
  final String? fiscalPeriodId;
  @override
  @JsonKey(name: 'entry_date')
  final DateTime entryDate;
  @override
  final String description;
  @override
  @JsonKey(name: 'reference_no')
  final String? referenceNo;
  @override
  @JsonKey(name: 'source_type')
  final String? sourceType;
  @override
  @JsonKey(name: 'source_id')
  final String? sourceId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final List<JournalEntryLine> _lines;
  @override
  @JsonKey()
  List<JournalEntryLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  String toString() {
    return 'JournalEntry(id: $id, fiscalPeriodId: $fiscalPeriodId, entryDate: $entryDate, description: $description, referenceNo: $referenceNo, sourceType: $sourceType, sourceId: $sourceId, createdAt: $createdAt, lines: $lines)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JournalEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fiscalPeriodId, fiscalPeriodId) ||
                other.fiscalPeriodId == fiscalPeriodId) &&
            (identical(other.entryDate, entryDate) ||
                other.entryDate == entryDate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.referenceNo, referenceNo) ||
                other.referenceNo == referenceNo) &&
            (identical(other.sourceType, sourceType) ||
                other.sourceType == sourceType) &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._lines, _lines));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fiscalPeriodId,
    entryDate,
    description,
    referenceNo,
    sourceType,
    sourceId,
    createdAt,
    const DeepCollectionEquality().hash(_lines),
  );

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JournalEntryImplCopyWith<_$JournalEntryImpl> get copyWith =>
      __$$JournalEntryImplCopyWithImpl<_$JournalEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JournalEntryImplToJson(this);
  }
}

abstract class _JournalEntry implements JournalEntry {
  const factory _JournalEntry({
    required final String id,
    @JsonKey(name: 'fiscal_period_id') final String? fiscalPeriodId,
    @JsonKey(name: 'entry_date') required final DateTime entryDate,
    required final String description,
    @JsonKey(name: 'reference_no') final String? referenceNo,
    @JsonKey(name: 'source_type') final String? sourceType,
    @JsonKey(name: 'source_id') final String? sourceId,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    final List<JournalEntryLine> lines,
  }) = _$JournalEntryImpl;

  factory _JournalEntry.fromJson(Map<String, dynamic> json) =
      _$JournalEntryImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'fiscal_period_id')
  String? get fiscalPeriodId;
  @override
  @JsonKey(name: 'entry_date')
  DateTime get entryDate;
  @override
  String get description;
  @override
  @JsonKey(name: 'reference_no')
  String? get referenceNo;
  @override
  @JsonKey(name: 'source_type')
  String? get sourceType;
  @override
  @JsonKey(name: 'source_id')
  String? get sourceId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  List<JournalEntryLine> get lines;

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JournalEntryImplCopyWith<_$JournalEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JournalEntryLine _$JournalEntryLineFromJson(Map<String, dynamic> json) {
  return _JournalEntryLine.fromJson(json);
}

/// @nodoc
mixin _$JournalEntryLine {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'journal_entry_id')
  String get journalEntryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_id')
  String get accountId => throw _privateConstructorUsedError;
  double get debit => throw _privateConstructorUsedError;
  double get credit => throw _privateConstructorUsedError; // Joined field
  Map<String, dynamic>? get accounts => throw _privateConstructorUsedError;

  /// Serializes this JournalEntryLine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JournalEntryLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JournalEntryLineCopyWith<JournalEntryLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JournalEntryLineCopyWith<$Res> {
  factory $JournalEntryLineCopyWith(
    JournalEntryLine value,
    $Res Function(JournalEntryLine) then,
  ) = _$JournalEntryLineCopyWithImpl<$Res, JournalEntryLine>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'journal_entry_id') String journalEntryId,
    @JsonKey(name: 'account_id') String accountId,
    double debit,
    double credit,
    Map<String, dynamic>? accounts,
  });
}

/// @nodoc
class _$JournalEntryLineCopyWithImpl<$Res, $Val extends JournalEntryLine>
    implements $JournalEntryLineCopyWith<$Res> {
  _$JournalEntryLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JournalEntryLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? journalEntryId = null,
    Object? accountId = null,
    Object? debit = null,
    Object? credit = null,
    Object? accounts = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            journalEntryId: null == journalEntryId
                ? _value.journalEntryId
                : journalEntryId // ignore: cast_nullable_to_non_nullable
                      as String,
            accountId: null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                      as String,
            debit: null == debit
                ? _value.debit
                : debit // ignore: cast_nullable_to_non_nullable
                      as double,
            credit: null == credit
                ? _value.credit
                : credit // ignore: cast_nullable_to_non_nullable
                      as double,
            accounts: freezed == accounts
                ? _value.accounts
                : accounts // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JournalEntryLineImplCopyWith<$Res>
    implements $JournalEntryLineCopyWith<$Res> {
  factory _$$JournalEntryLineImplCopyWith(
    _$JournalEntryLineImpl value,
    $Res Function(_$JournalEntryLineImpl) then,
  ) = __$$JournalEntryLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'journal_entry_id') String journalEntryId,
    @JsonKey(name: 'account_id') String accountId,
    double debit,
    double credit,
    Map<String, dynamic>? accounts,
  });
}

/// @nodoc
class __$$JournalEntryLineImplCopyWithImpl<$Res>
    extends _$JournalEntryLineCopyWithImpl<$Res, _$JournalEntryLineImpl>
    implements _$$JournalEntryLineImplCopyWith<$Res> {
  __$$JournalEntryLineImplCopyWithImpl(
    _$JournalEntryLineImpl _value,
    $Res Function(_$JournalEntryLineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JournalEntryLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? journalEntryId = null,
    Object? accountId = null,
    Object? debit = null,
    Object? credit = null,
    Object? accounts = freezed,
  }) {
    return _then(
      _$JournalEntryLineImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        journalEntryId: null == journalEntryId
            ? _value.journalEntryId
            : journalEntryId // ignore: cast_nullable_to_non_nullable
                  as String,
        accountId: null == accountId
            ? _value.accountId
            : accountId // ignore: cast_nullable_to_non_nullable
                  as String,
        debit: null == debit
            ? _value.debit
            : debit // ignore: cast_nullable_to_non_nullable
                  as double,
        credit: null == credit
            ? _value.credit
            : credit // ignore: cast_nullable_to_non_nullable
                  as double,
        accounts: freezed == accounts
            ? _value._accounts
            : accounts // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JournalEntryLineImpl implements _JournalEntryLine {
  const _$JournalEntryLineImpl({
    required this.id,
    @JsonKey(name: 'journal_entry_id') required this.journalEntryId,
    @JsonKey(name: 'account_id') required this.accountId,
    required this.debit,
    required this.credit,
    final Map<String, dynamic>? accounts,
  }) : _accounts = accounts;

  factory _$JournalEntryLineImpl.fromJson(Map<String, dynamic> json) =>
      _$$JournalEntryLineImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'journal_entry_id')
  final String journalEntryId;
  @override
  @JsonKey(name: 'account_id')
  final String accountId;
  @override
  final double debit;
  @override
  final double credit;
  // Joined field
  final Map<String, dynamic>? _accounts;
  // Joined field
  @override
  Map<String, dynamic>? get accounts {
    final value = _accounts;
    if (value == null) return null;
    if (_accounts is EqualUnmodifiableMapView) return _accounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'JournalEntryLine(id: $id, journalEntryId: $journalEntryId, accountId: $accountId, debit: $debit, credit: $credit, accounts: $accounts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JournalEntryLineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.journalEntryId, journalEntryId) ||
                other.journalEntryId == journalEntryId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.debit, debit) || other.debit == debit) &&
            (identical(other.credit, credit) || other.credit == credit) &&
            const DeepCollectionEquality().equals(other._accounts, _accounts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    journalEntryId,
    accountId,
    debit,
    credit,
    const DeepCollectionEquality().hash(_accounts),
  );

  /// Create a copy of JournalEntryLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JournalEntryLineImplCopyWith<_$JournalEntryLineImpl> get copyWith =>
      __$$JournalEntryLineImplCopyWithImpl<_$JournalEntryLineImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JournalEntryLineImplToJson(this);
  }
}

abstract class _JournalEntryLine implements JournalEntryLine {
  const factory _JournalEntryLine({
    required final String id,
    @JsonKey(name: 'journal_entry_id') required final String journalEntryId,
    @JsonKey(name: 'account_id') required final String accountId,
    required final double debit,
    required final double credit,
    final Map<String, dynamic>? accounts,
  }) = _$JournalEntryLineImpl;

  factory _JournalEntryLine.fromJson(Map<String, dynamic> json) =
      _$JournalEntryLineImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'journal_entry_id')
  String get journalEntryId;
  @override
  @JsonKey(name: 'account_id')
  String get accountId;
  @override
  double get debit;
  @override
  double get credit; // Joined field
  @override
  Map<String, dynamic>? get accounts;

  /// Create a copy of JournalEntryLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JournalEntryLineImplCopyWith<_$JournalEntryLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
