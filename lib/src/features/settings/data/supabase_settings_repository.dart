import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/system_setting.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/utils/error_handler.dart';

part 'supabase_settings_repository.g.dart';

class SupabaseSettingsRepository {
  final SupabaseClient _client;
  final Map<String, dynamic> _memCache = {};

  SupabaseSettingsRepository(this._client);

  Future<List<SystemSetting>> getSettings() async {
    const key = 'system_settings_list';
    try {
      final response = await _client
          .from('system_settings')
          .select()
          .order('key', ascending: true);
      
      final list = (response as List).map((json) => SystemSetting.fromJson(json)).toList();
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<SystemSetting>;
      }
      throw Failure.fromException(e);
    }
  }

  Future<void> updateSetting(String key, Map<String, dynamic> value) async {
    try {
      await _client
          .from('system_settings')
          .upsert({
            'key': key,
            'value': value,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'key');
      
      _memCache.clear();

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
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// التحقق من وضع الصيانة
  Future<bool> isMaintenanceMode() async {
    const key = 'maintenance_mode';
    try {
      final response = await _client.rpc('is_maintenance_mode');
      final val = response as bool;
      _memCache[key] = val;
      return val;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as bool;
      }
      throw Failure.fromException(e);
    }
  }

  /// تبديل وضع الصيانة
  Future<void> toggleMaintenanceMode(bool isActive, String message) async {
    try {
      await _client.rpc('toggle_maintenance_mode', params: {
        'p_is_active': isActive,
        'p_message': message,
      });
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}

@Riverpod(keepAlive: true)
SupabaseSettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  return SupabaseSettingsRepository(ref.watch(supabaseClientProvider));
}
