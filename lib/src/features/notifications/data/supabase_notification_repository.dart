import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/app_notification.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/utils/error_handler.dart';

part 'supabase_notification_repository.g.dart';

class SupabaseNotificationRepository {
  final SupabaseClient _client;
  final Map<String, dynamic> _memCache = {};

  SupabaseNotificationRepository(this._client);

  Future<List<AppNotification>> getNotifications() async {
    const key = 'notifications_list';
    try {
      final response = await _client
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      
      final list = (response as List).map((json) => AppNotification.fromJson(json)).toList();
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<AppNotification>;
      }
      throw Failure.fromException(e);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _client.from('notifications').update({'is_read': true}).eq('id', id);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId != null) {
        await _client.from('notifications').update({'is_read': true}).eq('profile_id', userId);
        _memCache.clear();
      }
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Stream<List<AppNotification>> watchNotifications() {
    final userId = _client.auth.currentUser?.id;
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('profile_id', userId ?? '')
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => AppNotification.fromJson(json)).toList());
  }
}

@Riverpod(keepAlive: true)
SupabaseNotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  return SupabaseNotificationRepository(ref.watch(supabaseClientProvider));
}
