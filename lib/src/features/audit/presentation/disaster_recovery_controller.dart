import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:car_system_management/src/features/audit/data/supabase_disaster_recovery_repository.dart';
import 'package:car_system_management/src/features/accounting/data/supabase_accounting_repository.dart';

part 'disaster_recovery_controller.g.dart';

@riverpod
class DisasterRecoveryController extends _$DisasterRecoveryController {
  @override
  FutureOr<void> build() => null;

  /// تشغيل فحص النزاهة الشامل
  Future<void> runIntegrityCheck() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(disasterRecoveryRepositoryProvider).performIntegrityCheck(),
    );
  }

  /// تجميد أو إلغاء تجميد العمليات المالية
  Future<void> toggleFreeze(bool freeze) async {
    await ref.read(disasterRecoveryRepositoryProvider).toggleFinancialFreeze(freeze);
    ref.invalidate(systemFreezeStatusProvider);
  }

  /// إغلاق فترة مالية بشكل نهائي
  Future<bool> closePeriod(String periodId) async {
    state = const AsyncLoading();
    final repo = ref.read(accountingRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repo.closeFiscalPeriod(periodId),
    );
    ref.invalidate(fiscalPeriodsProvider);
    return !result.hasError;
  }

  /// فتح فترة مالية جديدة
  Future<bool> openPeriod(String name, DateTime start, DateTime end) async {
    state = const AsyncLoading();
    final repo = ref.read(accountingRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repo.openNewFiscalPeriod(name, start, end),
    );
    ref.invalidate(fiscalPeriodsProvider);
    return !result.hasError;
  }
}

@riverpod
Future<List<Map<String, dynamic>>> fiscalPeriods(FiscalPeriodsRef ref) {
  final repo = ref.watch(accountingRepositoryProvider);
  return repo.getFiscalPeriods();
}

@riverpod
Future<bool> systemFreezeStatus(SystemFreezeStatusRef ref) {
  return ref.watch(disasterRecoveryRepositoryProvider).isSystemFrozen();
}
