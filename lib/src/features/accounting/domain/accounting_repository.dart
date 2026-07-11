import 'account.dart';
import 'journal_entry.dart';

abstract class AccountingRepository {
  Future<List<Account>> getChartOfAccounts();
  Future<List<JournalEntry>> getJournalEntries({
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    int limit = 50,
  });
  Future<List<Map<String, dynamic>>> getFiscalPeriods();
  Future<void> closeFiscalPeriod(String periodId);
  Future<void> openNewFiscalPeriod(String name, DateTime start, DateTime end);
}
