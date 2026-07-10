import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../features/authentication/presentation/auth_controller.dart';
import '../../features/authentication/domain/user_role.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_layout.dart';

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

/// --- الديسكتوب: Sidebar كامل ثابت ---
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
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --- التابلت: Sidebar أيقوني (Collapsed) ---
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
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --- الموبايل: Drawer مخفي وقائمة سفلية ---
class _MobileScaffold extends ConsumerWidget {
  final dynamic user;
  final Widget child;
  const _MobileScaffold({required this.user, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AL SAMI ERP'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(child: _Sidebar(isCollapsed: false, user: user)),
      body: child,
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
    return Container(
      width: isCollapsed ? 85 : 280,
      color: AppColors.primaryNavy,
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildLogo(isCollapsed),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SidebarLink(Icons.dashboard_rounded, 'الرئيسية', '/dashboard', isCollapsed),
                _SidebarLink(Icons.groups_rounded, 'المستثمرون', '/investors', isCollapsed),
                _SidebarLink(Icons.person_rounded, 'العملاء', '/crm/customers', isCollapsed),
                _SidebarLink(Icons.directions_car_filled_rounded, 'السيارات', '/inventory', isCollapsed),
                _SidebarLink(Icons.history_edu_rounded, 'العقود', '/contracts', isCollapsed),
                _SidebarLink(Icons.account_tree_rounded, 'المحاسبة', '/accounting', isCollapsed),
                _SidebarLink(Icons.bar_chart_rounded, 'التقارير', '/reports', isCollapsed),
                if (user.role == UserRole.admin)
                   _SidebarLink(Icons.admin_panel_settings_rounded, 'إدارة الموظفين', '/staff-management', isCollapsed),
                _SidebarLink(Icons.settings_suggest_rounded, 'الإعدادات', '/settings', isCollapsed),
              ],
            ),
          ),
          _LogoutButton(isCollapsed: isCollapsed),
        ],
      ),
    );
  }

  Widget _buildLogo(bool collapsed) {
    return Column(
      children: [
        const Icon(Icons.directions_car_filled_rounded, color: AppColors.accentGold, size: 35),
        if (!collapsed) ...[
          const SizedBox(height: 10),
          const Text('AL SAMI', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('AUTO ERP', style: TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
        ]
      ],
    );
  }
}

class _SidebarLink extends StatelessWidget {
  final IconData icon;
  final String title;
  final String path;
  final bool isCollapsed;
  const _SidebarLink(this.icon, this.title, this.path, this.isCollapsed);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = GoRouterState.of(context).matchedLocation.startsWith(path);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: isCollapsed ? title : '',
        child: ListTile(
          onTap: () => context.go(path),
          leading: Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 22),
          title: isCollapsed ? null : Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          selected: isSelected,
          selectedTileColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final dynamic user;
  const _TopBar({required this.user});

  @override
  Widget build(BuildContext context) {
    // جلب المسمى الوظيفي من دور المستخدم الفعلي بدلاً من نص ثابت
    String roleLabel = 'موظف نظام';
    if (user.role is UserRole) {
      roleLabel = (user.role as UserRole).label;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.bgGrey, child: const Icon(Icons.person, color: AppColors.primaryNavy)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(roleLabel, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const Spacer(),
          // عرض التاريخ الحالي بشكل ديناميكي
          Text(
            intl.DateFormat('dd / MM / yyyy').format(DateTime.now()),
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
          ),
        ],
      ),
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
