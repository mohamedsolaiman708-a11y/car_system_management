import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../notification_controller.dart';
import '../../domain/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التنبيهات'),
          actions: [
            TextButton(
              onPressed: () => ref.read(notificationControllerProvider.notifier).markAllAsRead(),
              child: const Text('تحديد الكل كمقروء', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: notificationsAsync.when(
          data: (notifications) => _buildNotificationsList(context, ref, notifications),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('حدث خطأ: $err')),
        ),
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, WidgetRef ref, List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد تنبيهات حالياً', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationTile(notification: notification);
      },
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final df = intl.DateFormat('yyyy/MM/dd HH:mm');

    return Container(
      color: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      child: ListTile(
        leading: _buildLeadingIcon(),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.content),
            const SizedBox(height: 4),
            Text(
              df.format(notification.createdAt),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          // 1. تمييز كمقروء
          if (!notification.isRead) {
            ref.read(notificationControllerProvider.notifier).markAsRead(notification.id);
          }
          
          // 2. منطق التوجيه الذكي بناءً على نص التنبيه
          final title = notification.title;
          final content = notification.content;

          if (title.contains('انضمام مستثمر') || content.contains('طلب انضمام جديد')) {
            context.push('/investors'); 
            // ملاحظة: بما أن صفحة المستثمرين بها TabController، 
            // يفضل أن تفتح تلقائياً على التبويب الثاني (طلبات الانضمام).
          } else if (title.contains('سحب') || content.contains('طلب سحب')) {
            context.push('/investors');
          } else if (title.contains('عقد') || content.contains('عقد جديد')) {
            context.push('/contracts');
          }
        },
      ),
    );
  }

  Widget _buildLeadingIcon() {
    IconData iconData = Icons.notifications_none_rounded;
    Color color = Colors.blue;

    switch (notification.type) {
      case 'success':
        iconData = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case 'warning':
        iconData = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      case 'error':
        iconData = Icons.error_outline_rounded;
        color = Colors.red;
        break;
      case 'info':
      default:
        iconData = Icons.info_outline_rounded;
        color = Colors.blue;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}
