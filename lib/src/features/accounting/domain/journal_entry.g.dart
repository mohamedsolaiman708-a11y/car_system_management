// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JournalEntryImpl _$$JournalEntryImplFromJson(Map<String, dynamic> json) =>
    _$JournalEntryImpl(
      id: json['id'] as String,
      fiscalPeriodId: json['fiscal_period_id'] as String?,
      entryDate: DateTime.parse(json['entry_date'] as String),
      description: json['description'] as String,
      referenceNo: json['reference_no'] as String?,
      sourceType: json['source_type'] as String?,
      sourceId: json['source_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map((e) => JournalEntryLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$JournalEntryImplToJson(_$JournalEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fiscal_period_id': instance.fiscalPeriodId,
      'entry_date': instance.entryDate.toIso8601String(),
      'description': instance.description,
      'reference_no': instance.referenceNo,
      'source_type': instance.sourceType,
      'source_id': instance.sourceId,
      'created_at': instance.createdAt.toIso8601String(),
      'lines': instance.lines,
    };

_$JournalEntryLineImpl _$$JournalEntryLineImplFromJson(
  Map<String, dynamic> json,
) => _$JournalEntryLineImpl(
  id: json['id'] as String,
  journalEntryId: json['journal_entry_id'] as String,
  accountId: json['account_id'] as String,
  debit: (json['debit'] as num).toDouble(),
  credit: (json['credit'] as num).toDouble(),
  accounts: json['accounts'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$JournalEntryLineImplToJson(
  _$JournalEntryLineImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'journal_entry_id': instance.journalEntryId,
  'account_id': instance.accountId,
  'debit': instance.debit,
  'credit': instance.credit,
  'accounts': instance.accounts,
};
