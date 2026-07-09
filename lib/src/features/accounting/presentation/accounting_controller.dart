import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_accounting_repository.dart';
import '../domain/account.dart';
import '../domain/journal_entry.dart';

part 'accounting_controller.g.dart';

@riverpod
class ChartOfAccountsController extends _$ChartOfAccountsController {
  @override
  FutureOr<List<Account>> build() {
    return ref.watch(accountingRepositoryProvider).getChartOfAccounts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(accountingRepositoryProvider).getChartOfAccounts());
  }
}

@riverpod
class JournalEntriesController extends _$JournalEntriesController {
  @override
  FutureOr<List<JournalEntry>> build() {
    return ref.watch(accountingRepositoryProvider).getJournalEntries();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(accountingRepositoryProvider).getJournalEntries());
  }

  Future<void> filterEntries({DateTime? startDate, DateTime? endDate}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(accountingRepositoryProvider).getJournalEntries(
      startDate: startDate,
      endDate: endDate,
    ));
  }
}
