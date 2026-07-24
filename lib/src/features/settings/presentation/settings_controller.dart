import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_settings_repository.dart';
import '../domain/system_setting.dart';
import '../domain/company_settings.dart';

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

  Future<void> toggleMaintenance(bool isActive, String message) async {
    await ref.read(settingsRepositoryProvider).toggleMaintenanceMode(isActive, message);
    ref.invalidate(isMaintenanceModeProvider);
  }
}

@riverpod
Future<bool> isMaintenanceMode(IsMaintenanceModeRef ref) {
  return ref.watch(settingsRepositoryProvider).isMaintenanceMode();
}

/// Provider مخصص لجلب إعدادات المنشأة فقط لاستخدامها في التقارير والـ UI
@riverpod
Future<CompanySettings> companySettings(CompanySettingsRef ref) async {
  final settings = await ref.watch(settingsRepositoryProvider).getSettings();
  final companyItem = settings.firstWhere(
    (s) => s.key == 'company_profile',
    orElse: () => throw Exception('Company settings not found'),
  );
  return CompanySettings.fromJson(companyItem.value);
}

