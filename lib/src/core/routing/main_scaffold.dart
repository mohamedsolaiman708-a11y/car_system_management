import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../features/authentication/presentation/auth_controller.dart';
import '../../features/authentication/domain/user_role.dart';
import '../../features/authentication/presentation/widgets/brand_logo.dart';
import '../../features/authentication/presentation/staff_controller.dart';
import '../../features/investors/presentation/investor_controller.dart';
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
    // جلب عدد طلبات الانضمام المعلقة لعرض تنبيه للأدمن
    final pendingCount = ref.watch(pendingInvestorsControllerProvider).maybeWhen(
          data: (list) => list.length,
          orElse: () => 0,
        );

    return Container(
      width: isCollapsed ? 85 : 280,
      color: AppColors.primaryNavy,
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildLogo(isCollapsed),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SidebarLink(Icons.dashboard_rounded, 'الرئيسية', '/dashboard', isCollapsed),
                _SidebarLink(
                  Icons.groups_rounded, 
                  'المستثمرون', 
                  '/investors', 
                  isCollapsed,
                  badge: pendingCount > 0 ? pendingCount : null,
                ),
                _SidebarLink(Icons.person_rounded, 'العملاء', '/crm/customers', isCollapsed),
                _SidebarLink(Icons.directions_car_filled_rounded, 'السيارات', '/inventory', isCollapsed),
                _SidebarLink(Icons.history_edu_rounded, 'العقود', '/contracts', isCollapsed),
                _SidebarLink(Icons.account_tree_rounded, 'المحاسبة', '/accounting', isCollapsed),
                _SidebarLink(Icons.bar_chart_rounded, 'التقارير', '/reports', isCollapsed),
                
                // --- قسم خاص بالأدمن (أدوات النظام) ---
                if (user.role == UserRole.admin) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Divider(color: Colors.white10, thickness: 1),
                  ),
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, marginBottom: 8),
                      child: Text('أدوات الإدارة', 
                        style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  _SidebarLink(Icons.admin_panel_settings_rounded, 'إدارة الموظفين', '/staff-management', isCollapsed),
                  _SidebarLink(Icons.security_rounded, 'سجلات الرقابة', '/audit-logs', isCollapsed),
                  _SidebarLink(Icons.cloud_sync_rounded, 'النسخ الاحتياطي', '/backups', isCollapsed),
                  _SidebarLink(Icons.health_and_safety_rounded, 'التعافي من الكوارث', '/disaster-recovery', isCollapsed),
                  _SidebarLink(Icons.settings_suggest_rounded, 'إعدادات النظام', '/settings', isCollapsed),
                ] else
                  _SidebarLink(Icons.settings_rounded, 'الإعدادات', '/settings', isCollapsed),
              ],
            ),
          ),
          _LogoutButton(isCollapsed: isCollapsed),
        ],
      ),
    );
  }

  Widget _buildLogo(bool collapsed) {
    if (collapsed) {
      return const Icon(Icons.directions_car_filled_rounded, color: AppColors.accentGold, size: 35);
    }
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
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
          selectedTileColor: Colors.white.withOpacity(0.08),
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
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        children: [
          InkWell(
            onTap: () => _showEditNameDialog(context, ref, user),
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryNavy.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppColors.primaryNavy, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 6),
                          const Icon(Icons.edit_outlined, size: 12, color: AppColors.textGrey),
                        ],
                      ),
                      Text(roleLabel, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primaryNavy),
                const SizedBox(width: 8),
                Text(
                  intl.DateFormat('dd / MM / yyyy').format(DateTime.now()),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 13),
                ),
              ],
            ),
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
          title: const Text('إعدادات الملف الشخصي'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('تعديل الاسم المعروض في النظام:'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
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
