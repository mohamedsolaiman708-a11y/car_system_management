import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/account.dart';
import '../domain/journal_entry.dart';
import '../domain/accounting_repository.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/utils/error_handler.dart';

part 'supabase_accounting_repository.g.dart';

class SupabaseAccountingRepository implements AccountingRepository {
  final SupabaseClient _client;
  final Map<String, dynamic> _memCache = {};

  SupabaseAccountingRepository(this._client);

  @override
  Future<List<Account>> getChartOfAccounts() async {
    const key = 'chart_of_accounts';
    try {
      final response = await _client
          .from('accounts')
          .select()
          .order('code', ascending: true);

      final list = (response as List).map((json) => Account.fromJson(json)).toList();
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<Account>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<JournalEntry>> getJournalEntries({
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    int limit = 50,
  }) async {
    final key = 'journal_entries_${startDate?.millisecondsSinceEpoch}_${endDate?.millisecondsSinceEpoch}_${accountId}_$limit';
    try {
      var query = _client
          .from('journal_entries')
          .select('*, lines:journal_entry_lines(*, accounts(name, code))');

      if (startDate != null) {
        query = query.gte('entry_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('entry_date', endDate.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final list = (response as List).map((json) => JournalEntry.fromJson(json)).toList();
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<JournalEntry>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFiscalPeriods() async {
    const key = 'fiscal_periods';
    try {
      final response = await _client
          .from('fiscal_periods')
          .select()
          .order('start_date', ascending: false);
      final list = List<Map<String, dynamic>>.from(response);
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<Map<String, dynamic>>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> closeFiscalPeriod(String periodId) async {
    try {
      await _client.from('fiscal_periods').update({
        'is_closed': true,
        'closed_at': DateTime.now().toIso8601String(),
        'closed_by': _client.auth.currentUser?.id,
      }).eq('id', periodId);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> openNewFiscalPeriod(String name, DateTime start, DateTime end) async {
    try {
      await _client.from('fiscal_periods').insert({
        'name': name,
        'start_date': start.toIso8601String(),
        'end_date': end.toIso8601String(),
        'is_closed': false,
      });
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}

@Riverpod(keepAlive: true)
AccountingRepository accountingRepository(AccountingRepositoryRef ref) {
  return SupabaseAccountingRepository(ref.watch(supabaseClientProvider));
}
