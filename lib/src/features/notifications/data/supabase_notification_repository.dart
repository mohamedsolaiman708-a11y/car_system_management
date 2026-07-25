import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final userId = _client.auth.currentUser?.id;
      var query = _client.from('notifications').select();
      if (userId != null) {
        query = query.eq('profile_id', userId);
      }
      final response = await query
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

  Stream<List<AppNotification>> watchNotifications() async* {
    List<AppNotification> currentData = [];

    // 1. جلب البيانات أولاً عبر REST API وتمريرها مباشرة
    try {
      currentData = await getNotifications();
      yield currentData;
    } catch (_) {
      // إكمال المحاولة بدون التعطل
    }

    // 2. محاولة فتح Realtime Stream، وعند حدوث أي خطأ في Realtime نعتمد البيانات المجلوية أو نلجأ إلى REST API
    try {
      final userId = _client.auth.currentUser?.id;
      final stream = _client
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('profile_id', userId ?? '')
          .order('created_at', ascending: false)
          .map((data) => data.map((json) => AppNotification.fromJson(json)).toList());

      await for (final list in stream) {
        currentData = list;
        yield list;
      }
    } catch (e) {
      // في حالة فشل Realtime (مثل RealtimeSubscribeException)، نقوم بإعادة الجلب من API بدلاً من إظهار الخطأ
      try {
        final fallbackList = await getNotifications();
        yield fallbackList;
      } catch (_) {
        if (currentData.isNotEmpty) {
          yield currentData;
        } else {
          throw Failure.fromException(e);
        }
      }
    }
  }
}

@Riverpod(keepAlive: true)
SupabaseNotificationRepository notificationRepository(Ref ref) {
  return SupabaseNotificationRepository(ref.watch(supabaseClientProvider));
}
