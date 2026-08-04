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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          elevation: 0,
          toolbarHeight: 120,
          centerTitle: false,
          title: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إدارة فريق العمل والكوادر', 
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
                Text('تنظيم أدوار الموظفين والموافقة على طلبات الانضمام الجديدة', 
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Cairo')),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ElevatedButton.icon(
                onPressed: () => _showAddStaffDialog(context),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('دعوة موظف جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold, 
                  foregroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accentGold,
            indicatorWeight: 4,
            labelColor: AppColors.accentGold,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo'),
            tabs: const [
              Tab(text: 'فريق العمل النشط'),
              Tab(text: 'طلبات الانضمام المعلقة'),
            ],
          ),
        ),
        body: staffAsync.when(
          data: (staffList) {
            final activeStaff = staffList.where((u) => u.status != 'pending' && u.role.name != 'investor').toList();
            final pendingUsers = staffList.where((u) => u.status == 'pending').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildActiveStaffTab(activeStaff, rolesAsync),
                _buildPendingRequestsTab(pendingUsers, rolesAsync),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
          error: (err, _) => Center(child: Text(Failure.fromException(err).message)),
        ),
      ),
    );
  }

  Widget _buildActiveStaffTab(List<AppUser> list, AsyncValue rolesAsync) {
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
            ? _buildEmptyState('لا يوجد موظفين نشطين حالياً يطابقون البحث', Icons.people_outline_rounded)
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

  Widget _buildPendingRequestsTab(List<AppUser> list, AsyncValue rolesAsync) {
    if (list.isEmpty) return _buildEmptyState('لا توجد طلبات انضمام جديدة حالياً', Icons.person_add_disabled_rounded);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView.builder(
          padding: const EdgeInsets.all(32),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final user = list[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    _buildAvatar(user),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(user.fullName, 
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryNavy),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Text(user.email ?? 'بدون بريد إلكتروني', 
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // أزرار القبول والرفض
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showApprovalDialog(context, user, rolesAsync.valueOrNull ?? []),
                          icon: const Icon(Icons.check_circle_rounded, size: 20),
                          label: const Text('اعتماد وقبول', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _showRejectDialog(context, user),
                          icon: const Icon(Icons.cancel_rounded, size: 20, color: Colors.red),
                          label: const Text('رفض الطلب', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(msg, style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontFamily: 'Cairo')),
        ],
      ),
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
              decoration: InputDecoration(
                hintText: 'البحث عن موظف بالاسم أو الإيميل...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
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
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: selectedRole,
              hint: const Text('تصفية الرتبة'),
              onChanged: (val) => setState(() => selectedRole = val),
              items: [
                const DropdownMenuItem(value: null, child: Text('كافة الرتب')),
                ...filteredRoles.map((r) => DropdownMenuItem(value: r['slug'].toString(), child: Text(_translateRole(r['slug'])))),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox(),
    );
  }

  Widget _buildEmployeeProfileCard(AppUser member, List roles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)]
      ),
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
                  Text(member.fullName, 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.primaryNavy),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
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
      width: 60, height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primaryNavy, AppColors.primaryNavy.withOpacity(0.8)]), 
        borderRadius: BorderRadius.circular(16)
      ),
      child: Center(
        child: Text(
          member.fullName.isNotEmpty ? member.fullName[0] : '?', 
          style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w900, fontSize: 24)
        )
      ),
    );
  }

  Widget _buildRoleBadge(String roleName) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.primaryNavy.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Text(roleName, style: const TextStyle(color: AppColors.primaryNavy, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionsMenu(AppUser member, List roles) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (val) async {
        if (val == 'toggle') ref.read(staffListControllerProvider.notifier).updateStatus(member.id, !member.isActive);
        if (val == 'edit_name') _showEditNameDialog(context, member);
        if (val.startsWith('role_')) ref.read(staffListControllerProvider.notifier).updateRole(member.id, val.substring(5));
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit_name', child: Text('تعديل البيانات')),
        PopupMenuItem(
          value: 'toggle', 
          child: Text(
            member.isActive ? 'تعطيل الحساب' : 'تنشيط الحساب', 
            style: TextStyle(color: member.isActive ? Colors.red : Colors.green)
          )
        ),
      ],
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('دعوة موظف جديد', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder())),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  if (emailController.text.isNotEmpty && nameController.text.isNotEmpty) {
                    await ref.read(staffListControllerProvider.notifier).inviteStaff(email: emailController.text, fullName: nameController.text, roleId: 'admin');
                    if (context.mounted) {
                      Navigator.pop(context);
                      SnackBarHelper.showSuccess(context, 'تم إرسال الدعوة بنجاح');
                    }
                  }
                },
                child: const Text('إرسال الدعوة'),
              ),
            ],
          ),
        ),
      ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('اعتماد انضمام: ${user.fullName}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('يرجى تحديد الرتبة الوظيفية للموظف الجديد لتفعيل حسابه وصلاحياته:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: selectedRoleId,
                  decoration: InputDecoration(
                    labelText: 'الرتبة الوظيفية',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.work_outline, color: AppColors.primaryNavy),
                  ),
                  items: filteredRoles.map((r) => DropdownMenuItem(value: r['id'].toString(), child: Text(_translateRole(r['slug'])))).toList(),
                  onChanged: (val) => setState(() => selectedRoleId = val),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, foregroundColor: Colors.white),
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

  void _showRejectDialog(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تأكيد رفض الطلب'),
          content: Text('هل أنت متأكد من رفض طلب انضمام "${user.fullName}"؟ سيتم تعطيل الحساب ومنعه من الدخول.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                await ref.read(staffListControllerProvider.notifier).updateStatus(user.id, false);
                if (context.mounted) {
                  Navigator.pop(context);
                  SnackBarHelper.showSuccess(context, 'تم رفض الطلب بنجاح');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('تأكيد الرفض'),
            ),
          ],
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تعديل البيانات الشخصية'),
          content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'الاسم الكامل الجديد', border: OutlineInputBorder())),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(onPressed: () async {
              await ref.read(staffListControllerProvider.notifier).updateName(member.id, controller.text);
              if (context.mounted) Navigator.pop(context);
            }, child: const Text('حفظ التعديلات')),
          ],
        ),
      ),
    );
  }
}
