import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/account.dart';
import '../domain/journal_entry.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_accounting_repository.g.dart';

class SupabaseAccountingRepository {
  final SupabaseClient _client;
  SupabaseAccountingRepository(this._client);

  /// جلب شجرة الحسابات
  Future<List<Account>> getChartOfAccounts() async {
    final response = await _client
        .from('accounts')
        .select()
        .order('code', ascending: true);
    
    return (response as List).map((json) => Account.fromJson(json)).toList();
  }

  /// جلب القيود اليومية مع تفاصيلها
  Future<List<JournalEntry>> getJournalEntries({
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    int limit = 50,
  }) async {
    var query = _client
        .from('journal_entries')
        .select('*, journal_entry_lines(*, accounts(name, code))');

    if (startDate != null) {
      query = query.gte('entry_date', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('entry_date', endDate.toIso8601String());
    }
    
    // ملاحظة: فلترة القيود حسب حساب معين تتطلب استعلاماً متقدماً في Supabase 
    // أو معالجة في الـ SQL. سنقوم بجلب الكل حالياً.

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => JournalEntry.fromJson(json)).toList();
  }

  /// إغلاق فترة مالية
  Future<void> closeFiscalPeriod(String periodId) async {
    await _client.from('fiscal_periods').update({'is_closed': true}).eq('id', periodId);
  }
}

@Riverpod(keepAlive: true)
SupabaseAccountingRepository accountingRepository(AccountingRepositoryRef ref) {
  return SupabaseAccountingRepository(ref.watch(supabaseClientProvider));
}
