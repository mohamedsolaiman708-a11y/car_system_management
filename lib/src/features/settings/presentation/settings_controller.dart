import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_settings_repository.dart';
import '../domain/system_setting.dart';

part 'settings_controller.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  @override
  FutureOr<List<SystemSetting>> build() {
    return ref.watch(settingsRepositoryProvider).getSettings();
  }

  Future<void> updateSetting(String key, Map<String, dynamic> value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(settingsRepositoryProvider).updateSetting(key, value);
      return ref.read(settingsRepositoryProvider).getSettings();
    });
  }

  /// تبديل وضع الصيانة
  Future<void> toggleMaintenance(bool isActive, String message) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(settingsRepositoryProvider).toggleMaintenanceMode(isActive, message);
      ref.invalidate(isMaintenanceModeProvider); // تحديث الحالة عالمياً
      return ref.read(settingsRepositoryProvider).getSettings();
    });
  }
}

/// موفر حالة الصيانة الحالية (للمراقبة في الـ Router)
@riverpod
Future<bool> isMaintenanceMode(IsMaintenanceModeRef ref) {
  return ref.watch(settingsRepositoryProvider).isMaintenanceMode();
}
