import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_dashboard_repository.dart';

part 'dashboard_controller.g.dart';

@riverpod
class StaffDashboardController extends _$StaffDashboardController {
  @override
  FutureOr<Map<String, dynamic>> build() {
    return ref.watch(dashboardRepositoryProvider).getStaffStats();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(dashboardRepositoryProvider).getStaffStats());
  }
}

@riverpod
Future<Map<String, dynamic>> staffStats(StaffStatsRef ref) {
  return ref.watch(dashboardRepositoryProvider).getStaffStats();
}
