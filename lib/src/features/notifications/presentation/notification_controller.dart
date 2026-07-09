import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_notification_repository.dart';
import '../domain/app_notification.dart';

part 'notification_controller.g.dart';

@riverpod
class NotificationController extends _$NotificationController {
  @override
  Stream<List<AppNotification>> build() {
    return ref.watch(notificationRepositoryProvider).watchNotifications();
  }

  Future<void> markAsRead(String id) async {
    await ref.read(notificationRepositoryProvider).markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await ref.read(notificationRepositoryProvider).markAllAsRead();
  }
}

@riverpod
int unreadNotificationsCount(UnreadNotificationsCountRef ref) {
  final notifications = ref.watch(notificationControllerProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
}
