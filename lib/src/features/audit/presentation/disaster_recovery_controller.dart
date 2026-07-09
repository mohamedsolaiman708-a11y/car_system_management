import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_disaster_recovery_repository.dart';

part 'disaster_recovery_controller.g.dart';

@riverpod
class DisasterRecoveryController extends _$DisasterRecoveryController {
  @override
  FutureOr<List<Map<String, dynamic>>> build() {
    return ref.watch(disasterRecoveryRepositoryProvider).getIntegrityHistory();
  }

  Future<void> runIntegrityCheck() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(disasterRecoveryRepositoryProvider).performIntegrityCheck();
      return ref.read(disasterRecoveryRepositoryProvider).getIntegrityHistory();
    });
  }

  Future<bool> repairBalances() async {
    final repository = ref.read(disasterRecoveryRepositoryProvider);
    final result = await AsyncValue.guard(() => repository.repairInvestorBalances());
    if (!result.hasError) {
      await refresh();
      return true;
    }
    return false;
  }

  Future<void> toggleFreeze(bool isFrozen) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(disasterRecoveryRepositoryProvider).toggleFinancialFreeze(isFrozen);
      ref.invalidate(systemFreezeStatusProvider); // تحديث حالة التجميد عالمياً
      return ref.read(disasterRecoveryRepositoryProvider).getIntegrityHistory();
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(disasterRecoveryRepositoryProvider).getIntegrityHistory());
  }
}

@riverpod
Future<bool> systemFreezeStatus(SystemFreezeStatusRef ref) {
  return ref.watch(disasterRecoveryRepositoryProvider).isSystemFrozen();
}
