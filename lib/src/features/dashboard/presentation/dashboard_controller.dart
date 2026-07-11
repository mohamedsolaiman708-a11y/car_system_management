import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_dashboard_repository.dart';
import '../../audit/data/supabase_disaster_recovery_repository.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  @override
  FutureOr<void> build() {
    // Initial build
  }

  /// وظيفة البحث الشامل من خلال الكنترولر
  Future<Map<String, List<dynamic>>> search(String query) async {
    return ref.read(dashboardRepositoryProvider).globalSearch(query);
  }
}

@riverpod
Future<Map<String, dynamic>> staffStats(StaffStatsRef ref) async {
  return ref.watch(dashboardRepositoryProvider).getStaffStats();
}

@riverpod
Future<List<Map<String, dynamic>>> monthlyGrowthData(MonthlyGrowthDataRef ref) async {
  return ref.watch(dashboardRepositoryProvider).getMonthlyGrowthData();
}

@riverpod
Future<Map<String, dynamic>> systemIntegrityStatus(SystemIntegrityStatusRef ref) async {
  final history = await ref.watch(disasterRecoveryRepositoryProvider).getIntegrityHistory();
  if (history.isEmpty) {
    return {'is_healthy': true, 'message': 'لا توجد سجلات فحص'};
  }
  final lastCheck = history.first;
  return {
    'is_healthy': lastCheck['is_healthy'] == true,
    'accounting_gap': lastCheck['accounting_imbalance'] ?? 0,
    'investor_gap': lastCheck['investor_imbalance'] ?? 0,
  };
}
