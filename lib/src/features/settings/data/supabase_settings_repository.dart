import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/system_setting.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_settings_repository.g.dart';

class SupabaseSettingsRepository {
  final SupabaseClient _client;
  SupabaseSettingsRepository(this._client);

  Future<List<SystemSetting>> getSettings() async {
    final response = await _client
        .from('system_settings')
        .select()
        .order('key', ascending: true);
    
    return (response as List).map((json) => SystemSetting.fromJson(json)).toList();
  }

  Future<void> updateSetting(String key, Map<String, dynamic> value) async {
    await _client
        .from('system_settings')
        .upsert({
          'key': key,
          'value': value,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'key');
    
    // Audit Log
    try {
      await _client.from('audit_logs').insert({
        'profile_id': _client.auth.currentUser?.id,
        'event_type': 'SETTING_UPDATED',
        'table_name': 'system_settings',
        'record_id': _client.auth.currentUser?.id ?? '00000000-0000-0000-0000-000000000000',
        'new_values': {'key': key, 'value': value},
      });
    } catch (_) {}
  }

  /// التحقق من وضع الصيانة
  Future<bool> isMaintenanceMode() async {
    final response = await _client.rpc('is_maintenance_mode');
    return response as bool;
  }

  /// تبديل وضع الصيانة
  Future<void> toggleMaintenanceMode(bool isActive, String message) async {
    await _client.rpc('toggle_maintenance_mode', params: {
      'p_is_active': isActive,
      'p_message': message,
    });
  }
}

@Riverpod(keepAlive: true)
SupabaseSettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  return SupabaseSettingsRepository(ref.watch(supabaseClientProvider));
}
