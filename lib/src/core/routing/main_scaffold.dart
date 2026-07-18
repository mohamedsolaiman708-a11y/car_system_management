import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../features/authentication/presentation/auth_controller.dart';
import '../../features/authentication/domain/user_role.dart';
import '../../features/authentication/presentation/widgets/brand_logo.dart';
import '../../features/authentication/presentation/staff_controller.dart';
import '../../features/investors/presentation/investor_controller.dart';
import '../../features/notifications/presentation/notification_controller.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_layout.dart';
import '../providers/connection_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ResponsiveLayout(
        mobile: _MobileScaffold(user: user, child: child),
        tablet: _TabletScaffold(user: user, child: child),
        desktop: _DesktopScaffold(user: user, child: child),
      ),
    );
  }
}

class _DesktopScaffold extends ConsumerWidget {
  final dynamic user;
  final Widget child;
  const _DesktopScaffold({required this.user, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(isCollapsed: false, user: user),
          Expanded(
            child: Column(
              children: [
                _TopBar(user: user),
                const OfflineBanner(),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8F9FA),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabletScaffold extends ConsumerWidget {
  final dynamic user;
  final Widget child;
  const _TabletScaffold({required this.user, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(isCollapsed: true, user: user),
          Expanded(
            child: Column(
              children: [
                _TopBar(user: user),
                const OfflineBanner(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileScaffold extends ConsumerWidget {
  final dynamic user;
  final Widget child;
  const _MobileScaffold({required this.user, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandLogo(scale: 0.45),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          _NotificationButton(),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(child: _Sidebar(isCollapsed: false, user: user)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primaryNavy,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1) context.go('/crm/customers');
          if (index == 2) context.go('/contracts');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'العملاء'),
          BottomNavigationBarItem(icon: Icon(Icons.history_edu_rounded), label: 'العقود'),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  final bool isCollapsed;
  final dynamic user;
  const _Sidebar({required this.isCollapsed, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingInvestorsControllerProvider).maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );

    final role = user.role as UserRole;

    return Container(
      width: isCollapsed ? 85 : 280,
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                const SizedBox(height: 24),
                _buildLogo(isCollapsed),
                const SizedBox(height: 32),
                
                _SidebarLink(Icons.dashboard_rounded, 'الرئيسية', '/dashboard', isCollapsed),

                if (role == UserRole.admin || role == UserRole.accountant)
                  _SidebarLink(
                    Icons.groups_rounded,
                    'المستثمرون',
                    '/investors',
                    isCollapsed,
                    badge: role == UserRole.admin && pendingCount > 0 ? pendingCount : null,
                  ),

                if (role == UserRole.admin || role == UserRole.sales) ...[
                  _SidebarLink(Icons.person_rounded, 'العملاء', '/crm/customers', isCollapsed),
                  _SidebarLink(Icons.directions_car_filled_rounded, 'السيارات', '/inventory', isCollapsed),
                ],

                _SidebarLink(Icons.history_edu_rounded, 'العقود', '/contracts', isCollapsed),

                if (role == UserRole.admin || role == UserRole.accountant)
                  _SidebarLink(Icons.account_tree_rounded, 'المحاسبة', '/accounting', isCollapsed),

                _SidebarLink(Icons.bar_chart_rounded, 'التقارير', '/reports', isCollapsed),

                if (role == UserRole.admin) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Divider(color: Colors.white10, thickness: 1),
                  ),
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('أدوات الإدارة',
                          style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  _SidebarLink(Icons.admin_panel_settings_rounded, 'إدارة فريق العمل', '/staff-management', isCollapsed),
                  _SidebarLink(Icons.security_rounded, 'سجلات الرقابة', '/audit-logs', isCollapsed),
                  _SidebarLink(Icons.settings_suggest_rounded, 'إعدادات النظام', '/settings', isCollapsed),
                ] else
                  _SidebarLink(Icons.settings_rounded, 'الإعدادات الشخصية', '/settings', isCollapsed),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          _LogoutButton(isCollapsed: isCollapsed),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildLogo(bool collapsed) {
    if (collapsed) {
      return const Center(
        child: Icon(Icons.directions_car_filled_rounded, color: AppColors.accentGold, size: 32),
      );
    }
    return const Center(
      child: BrandLogo(scale: 0.55),
    );
  }
}

class _SidebarLink extends StatelessWidget {
  final IconData icon;
  final String title;
  final String path;
  final bool isCollapsed;
  final int? badge;

  const _SidebarLink(this.icon, this.title, this.path, this.isCollapsed, {this.badge});

  @override
  Widget build(BuildContext context) {
    final bool isSelected = GoRouterState.of(context).matchedLocation.startsWith(path);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Tooltip(
        message: isCollapsed ? title : '',
        child: ListTile(
          onTap: () => context.go(path),
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 22),
              if (badge != null)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.errorRed, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
          title: isCollapsed ? null : Text(title,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              )),
          selected: isSelected,
          selectedTileColor: Colors.white.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          dense: true,
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final dynamic user;
  const _TopBar({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String roleLabel = 'موظف نظام';
    if (user.role is UserRole) {
      roleLabel = (user.role as UserRole).label;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          _buildUserProfileMenu(context, ref, user, roleLabel),
          const Spacer(), // يعطي مساحة كاملة في المنتصف بعد حذف البحث
          _NotificationButton(),
          const SizedBox(width: 16),
          _buildDateDisplay(),
        ],
      ),
    );
  }

  Widget _buildUserProfileMenu(BuildContext context, WidgetRef ref, dynamic user, String roleLabel) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        if (val == 'edit_name') _showEditNameDialog(context, ref, user);
        if (val == 'logout') ref.read(authControllerProvider.notifier).logout();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit_name',
          child: ListTile(
            leading: Icon(Icons.edit_outlined, size: 18),
            title: Text('تعديل الاسم الشخصي'),
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
            title: Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
            dense: true,
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
              child: const Icon(Icons.person_rounded, color: AppColors.primaryNavy, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy)),
                Text(roleLabel, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primaryNavy),
          const SizedBox(width: 10),
          Text(
            intl.DateFormat('dd / MM / yyyy').format(DateTime.now()),
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, dynamic user) {
    final nameController = TextEditingController(text: user.fullName);
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.edit_rounded, color: AppColors.accentGold),
              const SizedBox(width: 12),
              const Text('إعدادات الملف الشخصي'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تعديل اسمك المعروض في النظام والتقارير:'),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل الجديد',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await ref.read(staffListControllerProvider.notifier).updateName(user.id, nameController.text);
                  await ref.read(authControllerProvider.notifier).refreshUserStatus();
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textGrey, size: 24),
          onPressed: () => context.push('/notifications'),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$unreadCount',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  final bool isCollapsed;
  const _LogoutButton({required this.isCollapsed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListTile(
        onTap: () => ref.read(authControllerProvider.notifier).logout(),
        leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        title: isCollapsed ? null : const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(connectionNotifierProvider);
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.errorRed,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'لا يوجد اتصال بالإنترنت. تم تفعيل وضع الاستعراض (أوفلاين).',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => ref.read(connectionNotifierProvider.notifier).forceCheck(),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
