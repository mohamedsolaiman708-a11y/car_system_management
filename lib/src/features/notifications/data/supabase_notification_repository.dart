import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/app_notification.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_notification_repository.g.dart';

class SupabaseNotificationRepository {
  final SupabaseClient _client;
  SupabaseNotificationRepository(this._client);

  Future<List<AppNotification>> getNotifications() async {
    final response = await _client
        .from('notifications')
        .select()
        .order('created_at', ascending: false)
        .limit(50);
    
    return (response as List).map((json) => AppNotification.fromJson(json)).toList();
  }

  Future<void> markAsRead(String id) async {
    await _client.from('notifications').update({'is_read': true}).eq('id', id);
  }

  Future<void> markAllAsRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      await _client.from('notifications').update({'is_read': true}).eq('profile_id', userId);
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
