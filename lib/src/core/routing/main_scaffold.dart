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
import '../../features/dashboard/presentation/widgets/global_search_delegate.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_layout.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        drawer: ResponsiveLayout.isMobile(context) ? _ClassicSidebar(user: user, isCollapsed: false) : null,
        body: Row(
          children: [
            if (!ResponsiveLayout.isMobile(context))
              _ClassicSidebar(
                user: user, 
                isCollapsed: _isSidebarCollapsed,
                onToggle: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
              ),
            Expanded(
              child: Column(
                children: [
                  _ClassicTopBar(
                    user: user,
                    onSearch: () => showSearch(context: context, delegate: GlobalSearchDelegate(ref)),
                  ),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassicSidebar extends ConsumerWidget {
  final dynamic user;
  final bool isCollapsed;
  final VoidCallback? onToggle;
  const _ClassicSidebar({required this.user, required this.isCollapsed, this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = user.role as UserRole;
    final pendingCount = ref.watch(pendingInvestorsControllerProvider).maybeWhen(
          data: (list) => list.length,
          orElse: () => 0,
        );

    return Container(
      width: isCollapsed ? 80 : 260,
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isCollapsed) const BrandLogo(scale: 0.5),
              if (onToggle != null && !ResponsiveLayout.isMobile(context))
                IconButton(
                  icon: Icon(isCollapsed ? Icons.menu_open_rounded : Icons.menu_rounded, color: Colors.white60, size: 20),
                  onPressed: onToggle,
                ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SidebarHeader('القائمة الرئيسية', isCollapsed),
                _SidebarItem(Icons.dashboard_outlined, 'الرئيسية', '/dashboard', isCollapsed),
                
                if (role == UserRole.admin || role == UserRole.accountant)
                  _SidebarItem(Icons.group_outlined, 'المستثمرون', '/investors', isCollapsed, 
                    badge: role == UserRole.admin && pendingCount > 0 ? pendingCount : null),

                if (role == UserRole.admin || role == UserRole.sales) ...[
                  _SidebarItem(Icons.person_outline_rounded, 'العملاء', '/crm/customers', isCollapsed),
                  _SidebarItem(Icons.directions_car_outlined, 'السيارات', '/inventory', isCollapsed),
                ],

                _SidebarItem(Icons.description_outlined, 'العقود', '/contracts', isCollapsed),

                if (role == UserRole.admin || role == UserRole.accountant) ...[
                  _SidebarHeader('المالية والمحاسبة', isCollapsed),
                  _SidebarItem(Icons.account_balance_outlined, 'دليل الحسابات', '/accounting', isCollapsed),
                  _SidebarItem(Icons.receipt_long_outlined, 'القيود اليومية', '/accounting/journal', isCollapsed),
                ],

                _SidebarHeader('التقارير والرقابة', isCollapsed),
                _SidebarItem(Icons.analytics_outlined, 'مركز التقارير', '/reports', isCollapsed),
                
                if (role == UserRole.admin) ...[
                  _SidebarItem(Icons.admin_panel_settings_outlined, 'إدارة الفريق', '/staff-management', isCollapsed),
                  _SidebarItem(Icons.security_outlined, 'سجلات الرقابة', '/audit-logs', isCollapsed),
                  _SidebarItem(Icons.health_and_safety_outlined, 'التعافي والنزاهة', '/disaster-recovery', isCollapsed),
                  _SidebarItem(Icons.settings_outlined, 'إعدادات النظام', '/settings', isCollapsed),
                ],
              ],
            ),
          ),
          _LogoutTile(isCollapsed: isCollapsed),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final String title;
  final bool isCollapsed;
  const _SidebarHeader(this.title, this.isCollapsed);

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) return const Divider(color: Colors.white10, height: 32);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String path;
  final bool isCollapsed;
  final int? badge;

  const _SidebarItem(this.icon, this.title, this.path, this.isCollapsed, {this.badge});

  @override
  Widget build(BuildContext context) {
    final bool isSelected = GoRouterState.of(context).matchedLocation.startsWith(path);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Tooltip(
        message: isCollapsed ? title : '',
        child: ListTile(
          onTap: () => context.go(path),
          dense: true,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.white60, size: 18),
              if (badge != null)
                Positioned(
                  right: -8, top: -8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
          title: isCollapsed ? null : Text(title, 
            style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          selected: isSelected,
          selectedTileColor: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }
}

class _ClassicTopBar extends ConsumerWidget {
  final dynamic user;
  final VoidCallback onSearch;
  const _ClassicTopBar({required this.user, required this.onSearch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(
        children: [
          if (ResponsiveLayout.isMobile(context))
            IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
          
          _buildUserMenu(context, ref, user),
          const Spacer(),
          // إعادة ميزة البحث الشامل المفقودة
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.blueGrey, size: 20),
            onPressed: onSearch,
            tooltip: 'بحث سريع (Alt+F)',
          ),
          const SizedBox(width: 8),
          _NotificationButton(),
          const SizedBox(width: 16),
          _buildSystemDate(),
        ],
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context, WidgetRef ref, dynamic user) {
    final role = user.role as UserRole;
    return PopupMenuButton<String>(
      onSelected: (val) {
        if (val == 'edit') _showEditNameDialog(context, ref, user);
        if (val == 'logout') ref.read(authControllerProvider.notifier).logout();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined, size: 16), title: Text('الملف الشخصي', style: TextStyle(fontSize: 12)), dense: true)),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'logout', child: ListTile(leading: Icon(Icons.logout, size: 16, color: Colors.red), title: Text('خروج', style: TextStyle(fontSize: 12, color: Colors.red)), dense: true)),
      ],
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: AppColors.primaryNavy.withOpacity(0.1), child: const Icon(Icons.person, size: 16, color: AppColors.primaryNavy)),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryNavy)),
              Text(role.label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSystemDate() {
    return Text(intl.DateFormat('yyyy/MM/dd').format(DateTime.now()), 
      style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold));
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, dynamic user) {
    final nameController = TextEditingController(text: user.fullName);
    showDialog(
      context: context,
      builder: (context) \u003d\u003e Directionality(
        text_direction: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: const Text(\u0027إعدادات الحساب\u0027, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: TextField(controller: nameController, decoration: const InputDecoration(labelText: \u0027الاسم الجديد\u0027, border: OutlineInputBorder())),
          actions: [
            TextButton(onPressed: () \u003d\u003e Navigator.pop(context), child: const Text(\u0027إلغاء\u0027)),
            ElevatedButton(onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await ref.read(staffListControllerProvider.notifier).updateName(user.id, nameController.text);
                await ref.read(authControllerProvider.notifier).refreshUserStatus();
                if (context.mounted) Navigator.pop(context);
              }
            }, child: const Text(\u0027حفظ\u0027)),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadNotificationsCountProvider);
    return InkWell(
      onTap: () => context.push('/notifications'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none_rounded, color: Colors.blueGrey, size: 20),
          if (count > 0)
            Positioned(
              right: -4, top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}

class _LogoutTile extends ConsumerWidget {
  final bool isCollapsed;
  const _LogoutTile({required this.isCollapsed});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () => ref.read(authControllerProvider.notifier).logout(),
      leading: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
      title: isCollapsed ? null : const Text('خروج آمن', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
