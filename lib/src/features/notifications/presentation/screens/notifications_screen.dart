import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../notification_controller.dart';
import '../../domain/app_notification.dart';
import '../../../../core/utils/error_handler.dart';

const _navy = Color(0xFF0F172A);
const _gold = Color(0xFFD4AF37);
const _bg = Color(0xFFF1F5F9);

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  String _filter = 'الكل';
  final _filters = ['الكل', 'غير مقروء', 'نجاح ✅', 'تحذير ⚠️', 'خطأ ❌', 'معلومات ℹ️'];
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  List<AppNotification> _applyFilter(List<AppNotification> list) {
    switch (_filter) {
      case 'غير مقروء':
        return list.where((n) => !n.isRead).toList();
      case 'نجاح ✅':
        return list.where((n) => n.type == 'success').toList();
      case 'تحذير ⚠️':
        return list.where((n) => n.type == 'warning').toList();
      case 'خطأ ❌':
        return list.where((n) => n.type == 'error').toList();
      case 'معلومات ℹ️':
        return list.where((n) => n.type == null || n.type == 'info').toList();
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationControllerProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium Header ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: _navy,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Back + Title + Mark all
                        Row(
                          children: [
                            // Back button
                            GestureDetector(
                              onTap: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/');
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Icon + Title
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.notifications_rounded, color: _gold, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'مركز التنبيهات الذكي',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'ابقَ على اطلاع بكافة المستجدات',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Mark all as read
                            GestureDetector(
                              onTap: () => ref
                                  .read(notificationControllerProvider.notifier)
                                  .markAllAsRead(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _gold.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.done_all_rounded, color: _gold, size: 14),
                                    SizedBox(width: 5),
                                    Text(
                                      'تحديد الكل كمقروء',
                                      style: TextStyle(
                                        color: _gold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Stats row
                        notificationsAsync.whenOrNull(
                          data: (notifications) {
                            final unread = notifications.where((n) => !n.isRead).length;
                            return _NotificationStatsRow(
                              total: notifications.length,
                              unread: unread,
                            );
                          },
                        ) ?? const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Filter chips ─────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterHeaderDelegate(
              filters: _filters,
              selected: _filter,
              onSelect: (f) => setState(() => _filter = f),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            sliver: notificationsAsync.when(
              data: (allNotifications) {
                final notifications = _applyFilter(allNotifications);
                if (notifications.isEmpty) {
                  return SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildEmptyState(),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => FadeTransition(
                      opacity: _fadeAnim,
                      child: _PremiumNotificationTile(notification: notifications[i]),
                    ),
                    childCount: notifications.length,
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: _navy, strokeWidth: 2),
                        const SizedBox(height: 16),
                        Text(
                          'جاري تحميل التنبيهات...',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              error: (err, _) => SliverToBoxAdapter(
                child: _buildErrorState(err),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon container
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _navy.withValues(alpha: 0.06),
                  _navy.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(
                color: _navy.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.notifications_off_outlined,
                size: 48,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _filter == 'الكل' ? 'لا توجد تنبيهات حالياً' : 'لا توجد تنبيهات في هذه الفئة',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filter == 'الكل'
                ? 'ستظهر هنا جميع التنبيهات والمستجدات\nالمالية والإدارية فور وصولها'
                : 'جرب تغيير الفلتر لعرض تنبيهات أخرى',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
              height: 1.7,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => ref.invalidate(notificationControllerProvider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_navy, Color(0xFF1E293B)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _navy.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'تحديث',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.shade50,
            ),
            child: Icon(Icons.error_outline_rounded, size: 42, color: Colors.red.shade300),
          ),
          const SizedBox(height: 20),
          const Text(
            'حدث خطأ في التحميل',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            Failure.fromException(err).message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(notificationControllerProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────
class _NotificationStatsRow extends StatelessWidget {
  final int total, unread;
  const _NotificationStatsRow({required this.total, required this.unread});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatPill(label: 'إجمالي', value: total.toString(), icon: Icons.notifications_rounded, color: Colors.white),
        const SizedBox(width: 8),
        _StatPill(label: 'غير مقروء', value: unread.toString(), icon: Icons.mark_email_unread_rounded, color: _gold),
        const SizedBox(width: 8),
        _StatPill(label: 'مقروء', value: (total - unread).toString(), icon: Icons.done_all_rounded, color: const Color(0xFF10B981)),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
                    style: TextStyle(
                        color: color, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45), fontSize: 9, fontFamily: 'Cairo')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Header Delegate ────────────────────────────────────────────────────
class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelect;
  const _FilterHeaderDelegate({required this.filters, required this.selected, required this.onSelect});

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final isSelected = f == selected;
          return GestureDetector(
            onTap: () => onSelect(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [_navy, Color(0xFF1E293B)])
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [BoxShadow(color: _navy.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterHeaderDelegate oldDelegate) =>
      selected != oldDelegate.selected;
}

// ── Premium Notification Tile ─────────────────────────────────────────────────
class _PremiumNotificationTile extends ConsumerWidget {
  final AppNotification notification;
  const _PremiumNotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isUnread = !notification.isRead;
    final Color typeColor = _getTypeColor();
    final IconData typeIcon = _getTypeIcon();
    final String typeLabel = _getTypeLabel();
    final Color typeBg = typeColor.withValues(alpha: 0.08);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? typeColor.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isUnread ? 16 : 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isUnread ? typeColor.withValues(alpha: 0.2) : Colors.grey.shade100,
          width: isUnread ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context, ref),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: typeBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: typeColor.withValues(alpha: 0.15)),
                  ),
                  child: Center(child: Icon(typeIcon, color: typeColor, size: 22)),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + unread dot
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 14,
                                color: _navy,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _gold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _gold.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, size: 6, color: _gold),
                                  SizedBox(width: 3),
                                  Text('جديد',
                                      style: TextStyle(
                                          color: _gold, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Body
                      Text(
                        notification.content,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.5,
                          fontSize: 12.5,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Footer: type badge + date + arrow
                      Row(
                        children: [
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              typeLabel,
                              style: TextStyle(
                                  color: typeColor, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.access_time_rounded, size: 11, color: Colors.grey.shade400),
                          const SizedBox(width: 3),
                          Text(
                            intl.DateFormat('dd MMM • HH:mm', 'ar').format(notification.createdAt),
                            style: TextStyle(
                                fontSize: 10.5, color: Colors.grey.shade400, fontFamily: 'Cairo'),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 12, color: Colors.grey.shade300),
                        ],
                      ),
                    ],
                  ),
                ),
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
    final meta = notification.metadata;
    if (meta != null && meta['route'] != null) {
      final route = meta['route'] as String;
      final tab = meta['tab']?.toString();
      if (tab != null) {
        context.push('$route?tab=$tab');
      } else {
        context.push(route);
      }
      return;
    }
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
      case 'success': return const Color(0xFF10B981);
      case 'warning': return const Color(0xFFF59E0B);
      case 'error': return const Color(0xFFEF4444);
      default: return const Color(0xFF3B82F6);
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case 'success': return Icons.check_circle_rounded;
      case 'warning': return Icons.warning_rounded;
      case 'error': return Icons.cancel_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  String _getTypeLabel() {
    switch (notification.type) {
      case 'success': return 'نجاح';
      case 'warning': return 'تحذير';
      case 'error': return 'خطأ';
      default: return 'معلومات';
    }
  }
}
