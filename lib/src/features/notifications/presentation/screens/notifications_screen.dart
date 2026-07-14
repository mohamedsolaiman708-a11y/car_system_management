import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../notification_controller.dart';
import '../../domain/app_notification.dart';
import '../../../../core/utils/app_theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Container(
          color: AppColors.primaryNavy,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('مركز التنبيهات الذكي', 
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('ابقَ على اطلاع بكافة المستجدات الإدارية والمالية', 
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => ref.read(notificationControllerProvider.notifier).markAllAsRead(),
                    icon: const Icon(Icons.done_all_rounded, color: AppColors.accentGold),
                    label: const Text('تحديد الكل كمقروء', 
                      style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: notificationsAsync.when(
        data: (notifications) => notifications.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: notifications.length,
                itemBuilder: (context, index) => _PremiumNotificationTile(notification: notifications[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('لا توجد تنبيهات جديدة حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

class _PremiumNotificationTile extends ConsumerWidget {
  final AppNotification notification;
  const _PremiumNotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isUnread = !notification.isRead;
    final Color typeColor = _getTypeColor();
    final IconData typeIcon = _getTypeIcon();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isUnread ? 0.05 : 0.01), blurRadius: 10)],
        border: Border.all(color: isUnread ? typeColor.withOpacity(0.1) : Colors.transparent),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context, ref),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(notification.title, 
                              style: TextStyle(
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.primaryNavy,
                              )),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: AppColors.accentGold, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(notification.content, 
                        style: TextStyle(color: Colors.grey.shade600, height: 1.4, fontSize: 14)),
                      const SizedBox(height: 12),
                      Text(intl.DateFormat('dd MMMM • HH:mm', 'ar').format(notification.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (!notification.isRead) {
      ref.read(notificationControllerProvider.notifier).markAsRead(notification.id);
    }
    
    // التوجيه الذكي باستخدام البيانات الإضافية (Metadata)
    final meta = notification.metadata;
    if (meta != null && meta['route'] != null) {
      final route = meta['route'] as String;
      final tab = meta['tab']?.toString();
      
      // إذا كان هناك تبويب محدد في الـ Metadata، نضيفه للرابط
      if (tab != null) {
        context.push('$route?tab=$tab');
      } else {
        context.push(route);
      }
      return;
    }

    // منطق احتياطي (Fallback) يعتمد على تحليل النص لو الـ Metadata مش موجودة
    final title = notification.title;
    final content = notification.content;

    if (title.contains('سحب') || content.contains('طلب سحب')) {
      context.push('/investors?tab=2'); 
    } else if (title.contains('انضمام') || content.contains('انضمام')) {
      context.push('/investors?tab=1');
    } else if (title.contains('عقد') || content.contains('عقد')) {
      context.push('/contracts');
    }
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case 'success': return Colors.green;
      case 'warning': return Colors.orange;
      case 'error': return Colors.red;
      default: return Colors.blue;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case 'success': return Icons.check_circle_outline_rounded;
      case 'warning': return Icons.warning_amber_rounded;
      case 'error': return Icons.error_outline_rounded;
      default: return Icons.info_outline_rounded;
    }
  }
}
