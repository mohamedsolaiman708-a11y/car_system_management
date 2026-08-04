import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../staff_controller.dart';
import '../../domain/app_user.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  ConsumerState<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> with SingleTickerProviderStateMixin {
  String searchQuery = '';
  String? selectedRole;
  late TabController _tabController;

  final List<String> _allowedRoles = ['admin', 'sales', 'accountant'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  String _translateRole(String slugOrName) {
    final mapping = {
      'admin': 'مدير نظام',
      'accountant': 'محاسب مالي',
      'sales': 'موظف مبيعات',
      'investor': 'طلب انضمام جديد',
    };
    final key = slugOrName.toLowerCase().trim();
    return mapping[key] ?? slugOrName;
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListControllerProvider);
    final rolesAsync = ref.watch(availableRolesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(180),
          child: Container(
            color: AppColors.primaryNavy,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
                    child: _buildSimpleHeader(context),
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.accentGold,
                    labelColor: AppColors.accentGold,
                    unselectedLabelColor: Colors.white60,
                    tabs: const [
                      Tab(text: 'فريق العمل النشط'),
                      Tab(text: 'طلبات الانضمام المعلقة'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: staffAsync.when(
          data: (staffList) {
            final activeStaff = staffList.where((u) => u.status != 'pending' && u.role.name != 'investor').toList();
            final pendingUsers = staffList.where((u) => u.status == 'pending').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildStaffList(activeStaff, rolesAsync),
                _buildPendingList(pendingUsers, rolesAsync),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
          error: (err, _) => Center(child: Text(Failure.fromException(err).message)),
        ),
      ),
    );
  }

  Widget _buildStaffList(List<AppUser> list, AsyncValue rolesAsync) {
    final filtered = list.where((member) {
      final matchesSearch = member.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (member.email?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
      final matchesRole = selectedRole == null || member.role.name == selectedRole;
      return matchesSearch && matchesRole;
    }).toList();

    return Column(
      children: [
        _buildSearchAndFilter(rolesAsync),
        Expanded(
          child: filtered.isEmpty 
            ? _buildEmptyState('لا يوجد موظفين نشطين حالياً')
            : GridView.builder(
                padding: const EdgeInsets.all(32),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 450,
                  mainAxisExtent: 140,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _buildEmployeeProfileCard(filtered[index], rolesAsync.valueOrNull ?? []),
              ),
        ),
      ],
    );
  }

  Widget _buildPendingList(List<AppUser> list, AsyncValue rolesAsync) {
    if (list.isEmpty) return _buildEmptyState('لا توجد طلبات انضمام جديدة');

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final user = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
              child: Text(user.fullName[0], style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
            ),
            title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.email ?? 'بدون بريد'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => _showApprovalDialog(context, user, rolesAsync.valueOrNull ?? []),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text('اعتماد كموظف'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.block, color: Colors.red),
                  onPressed: () { /* رفض الطلب */ },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showApprovalDialog(BuildContext context, AppUser user, List roles) {
    String? selectedRoleId;
    final filteredRoles = roles.where((r) => _allowedRoles.contains(r['slug'])).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('اعتماد انضمام: ${user.fullName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('يرجى تحديد الرتبة الوظيفية للموظف الجديد لتفعيل حسابه:'),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedRoleId,
                  decoration: const InputDecoration(labelText: 'الرتبة الوظيفية'),
                  items: filteredRoles.map((r) => DropdownMenuItem(value: r['id'].toString(), child: Text(_translateRole(r['slug'])))).toList(),
                  onChanged: (val) => setState(() => selectedRoleId = val),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: selectedRoleId == null ? null : () async {
                  await ref.read(staffListControllerProvider.notifier).updateRole(user.id, selectedRoleId!);
                  await ref.read(staffListControllerProvider.notifier).approveAsStaff(user.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    SnackBarHelper.showSuccess(context, 'تم تفعيل حساب الموظف بنجاح');
                  }
                },
                child: const Text('تفعيل الحساب الآن'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          Text(msg, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('إدارة فريق العمل', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('تنظيم أدوار الموظفين ومتابعة طلبات الانضمام', style: TextStyle(color: Colors.white60, fontSize: 14)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddStaffDialog(context),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('دعوة موظف جديد'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold, foregroundColor: AppColors.primaryNavy),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(AsyncValue rolesAsync) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: const InputDecoration(hintText: 'البحث عن موظف...', prefixIcon: Icon(Icons.search_rounded)),
            ),
          ),
          const SizedBox(width: 20),
          _buildRoleFilter(rolesAsync),
        ],
      ),
    );
  }

  Widget _buildRoleFilter(AsyncValue rolesAsync) {
    return rolesAsync.maybeWhen(
      data: (roles) {
        final filteredRoles = (roles as List).where((r) => _allowedRoles.contains(r['slug'])).toList();
        return DropdownButton<String?>(
          value: selectedRole,
          hint: const Text('تصفية'),
          onChanged: (val) => setState(() => selectedRole = val),
          items: [
            const DropdownMenuItem(value: null, child: Text('الكل')),
            ...filteredRoles.map((r) => DropdownMenuItem(value: r['slug'].toString(), child: Text(_translateRole(r['slug'])))),
          ],
        );
      },
      orElse: () => const SizedBox(),
    );
  }

  Widget _buildEmployeeProfileCard(AppUser member, List roles) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15)]),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _buildAvatar(member),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.primaryNavy)),
                  _buildRoleBadge(_translateRole(member.role.name)),
                ],
              ),
            ),
            _buildActionsMenu(member, roles),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(AppUser member) {
    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryNavy, AppColors.primaryNavy.withValues(alpha: 0.8)]), borderRadius: BorderRadius.circular(18)),
      child: Center(child: Text(member.fullName[0], style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w900, fontSize: 24))),
    );
  }

  Widget _buildRoleBadge(String roleName) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.primaryNavy.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
      child: Text(roleName, style: const TextStyle(color: AppColors.primaryNavy, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionsMenu(AppUser member, List roles) {
    return PopupMenuButton<String>(
      onSelected: (val) async {
        if (val == 'toggle') ref.read(staffListControllerProvider.notifier).updateStatus(member.id, !member.isActive);
        if (val == 'edit_name') _showEditNameDialog(context, member);
        if (val.startsWith('role_')) ref.read(staffListControllerProvider.notifier).updateRole(member.id, val.substring(5));
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit_name', child: const Text('تعديل البيانات')),
        PopupMenuItem(value: 'toggle', child: Text(member.isActive ? 'تعطيل الحساب' : 'تنشيط الحساب', style: TextStyle(color: member.isActive ? Colors.red : Colors.green))),
      ],
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    String? roleId;

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) => StatefulBuilder(
          builder: (context, setState) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('دعوة موظف جديد'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم الكامل')),
                  const SizedBox(height: 16),
                  TextField(controller: emailController, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () async {
                    if (emailController.text.isNotEmpty && nameController.text.isNotEmpty) {
                      await ref.read(staffListControllerProvider.notifier).inviteStaff(email: emailController.text, fullName: nameController.text, roleId: 'admin');
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('إرسال الدعوة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, AppUser member) {
    final controller = TextEditingController(text: member.fullName);
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل البيانات'),
          content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'الاسم الكامل')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(onPressed: () async {
              await ref.read(staffListControllerProvider.notifier).updateName(member.id, controller.text);
              if (context.mounted) Navigator.pop(context);
            }, child: const Text('حفظ')),
          ],
        ),
      ),
    );
  }
}
