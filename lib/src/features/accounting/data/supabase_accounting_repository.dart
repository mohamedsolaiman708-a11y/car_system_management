import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/account.dart';
import '../domain/journal_entry.dart';
import '../domain/accounting_repository.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_accounting_repository.g.dart';

class SupabaseAccountingRepository implements AccountingRepository {
  final SupabaseClient _client;
  SupabaseAccountingRepository(this._client);

  @override
  Future<List<Account>> getChartOfAccounts() async {
    final response = await _client
        .from('accounts')
        .select()
        .order('code', ascending: true);

    return (response as List).map((json) => Account.fromJson(json)).toList();
  }

  @override
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

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => JournalEntry.fromJson(json)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getFiscalPeriods() async {
    final response = await _client
        .from('fiscal_periods')
        .select()
        .order('start_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> closeFiscalPeriod(String periodId) async {
    await _client.from('fiscal_periods').update({
      'is_closed': true,
      'closed_at': DateTime.now().toIso8601String(),
      'closed_by': _client.auth.currentUser?.id,
    }).eq('id', periodId);
  }

  @override
  Future<void> openNewFiscalPeriod(String name, DateTime start, DateTime end) async {
    await _client.from('fiscal_periods').insert({
      'name': name,
      'start_date': start.toIso8601String(),
      'end_date': end.toIso8601String(),
      'is_closed': false,
    });
  }
}

@Riverpod(keepAlive: true)
AccountingRepository accountingRepository(AccountingRepositoryRef ref) {
  return SupabaseAccountingRepository(ref.watch(supabaseClientProvider));
}
