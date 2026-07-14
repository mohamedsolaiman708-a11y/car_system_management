import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

@freezed
class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required String id,
    @JsonKey(name: 'fiscal_period_id') String? fiscalPeriodId,
    @JsonKey(name: 'entry_date') required DateTime entryDate,
    required String description,
    @JsonKey(name: 'reference_no') String? referenceNo,
    @JsonKey(name: 'source_type') String? sourceType,
    @JsonKey(name: 'source_id') String? sourceId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // الربط الصحيح مع مسمى الجدول في قاعدة البيانات
    @JsonKey(name: 'journal_entry_lines') @Default([]) List<JournalEntryLine> lines,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);
}

@freezed
class JournalEntryLine with _$JournalEntryLine {
  const factory JournalEntryLine({
    required String id,
    @JsonKey(name: 'journal_entry_id') required String journalEntryId,
    @JsonKey(name: 'account_id') required String accountId,
    required double debit,
    required double credit,
    // Joined field
    Map<String, dynamic>? accounts,
  }) = _JournalEntryLine;

  factory JournalEntryLine.fromJson(Map<String, dynamic> json) => _$JournalEntryLineFromJson(json);
}
