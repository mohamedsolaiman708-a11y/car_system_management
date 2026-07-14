import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../staff_controller.dart';
import '../../domain/app_user.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  ConsumerState<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  String searchQuery = '';
  String? selectedRole;

  String _translateRole(String slugOrName) {
    final mapping = {
      'admin': 'مدير نظام',
      'accountant': 'محاسب مالي',
      'sales': 'مسؤول مبيعات',
      'manager': 'مدير عمليات',
    };
    return mapping[slugOrName.toLowerCase().trim()] ?? slugOrName;
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
          preferredSize: const Size.fromHeight(200), // ارتفاع فخم لإظهار العنوان والإحصائيات
          child: Container(
            color: AppColors.primaryNavy,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: _buildHeader(context, staffAsync),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            _buildSearchAndFilter(rolesAsync),
            Expanded(
              child: staffAsync.when(
                data: (staffList) {
                  final filteredList = staffList.where((member) {
                    final matchesSearch = member.fullName.toLowerCase().contains(searchQuery.toLowerCase()) || 
                                         (member.email?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
                    final matchesRole = selectedRole == null || member.role.name == selectedRole;
                    return matchesSearch && matchesRole;
                  }).toList();

                  if (filteredList.isEmpty) return _buildEmptyState();

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 450,
                      mainAxisExtent: 140,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) => _buildEmployeeProfileCard(filteredList[index], rolesAsync.valueOrNull ?? []),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
                error: (err, _) => const Center(child: Text('حدث خطأ في جلب بيانات الفريق')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<List<AppUser>> staffAsync) {
    int total = 0;
    int active = 0;
    staffAsync.whenData((list) {
      total = list.length;
      active = list.where((m) => m.isActive).length;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إدارة فريق العمل والكوادر', // العنوان الرئيسي بارز
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHeaderStatCard('إجمالي الفريق', total.toString(), Icons.groups_rounded),
                const SizedBox(width: 24),
                _buildHeaderStatCard('الأعضاء النشطين', active.toString(), Icons.verified_user_rounded),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddStaffDialog(context),
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 22),
          label: const Text('دعوة موظف جديد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGold,
            foregroundColor: AppColors.primaryNavy,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGold, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(AsyncValue<List<Map<String, dynamic>>> rolesAsync) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
              ),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'البحث عن موظف بالاسم أو البريد الإلكتروني...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryNavy, size: 22),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          _buildRoleFilter(rolesAsync),
        ],
      ),
    );
  }

  Widget _buildRoleFilter(AsyncValue<List<Map<String, dynamic>>> rolesAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
      ),
      child: rolesAsync.maybeWhen(
        data: (roles) => DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: selectedRole,
            hint: const Text('تصفية حسب الرتبة', style: TextStyle(fontSize: 14)),
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.primaryNavy),
            onChanged: (val) => setState(() => selectedRole = val),
            items: [
              const DropdownMenuItem(value: null, child: Text('كافة الرتب')),
              ...roles.where((r) => r['slug'] != 'investor').map((r) => DropdownMenuItem(value: r['slug'].toString(), child: Text(_translateRole(r['slug'])))),
            ],
          ),
        ),
        orElse: () => const SizedBox(),
      ),
    );
  }

  Widget _buildEmployeeProfileCard(AppUser member, List roles) {
    final bool isActive = member.isActive;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 6))],
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
                  Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.primaryNavy)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildRoleBadge(_translateRole(member.role.name)),
                      const SizedBox(width: 12),
                      _buildStatusIndicator(isActive),
                    ],
                  ),
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
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryNavy, AppColors.primaryNavy.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.primaryNavy.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Center(
        child: Text(member.fullName.isNotEmpty ? member.fullName[0] : '?', 
          style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w900, fontSize: 24)),
      ),
    );
  }

  Widget _buildRoleBadge(String roleName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(roleName, style: const TextStyle(color: AppColors.primaryNavy, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusIndicator(bool isActive) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: isActive ? Colors.green : Colors.red, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(isActive ? 'نشط' : 'معطل', style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildActionsMenu(AppUser member, List roles) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      onSelected: (value) async {
        final notifier = ref.read(staffListControllerProvider.notifier);
        if (value == 'toggle') notifier.updateStatus(member.id, !member.isActive);
        else if (value == 'approve') notifier.approveAsStaff(member.id);
        else if (value == 'edit_name') _showEditNameDialog(context, member);
        else if (value == 'reset_password') {
          if (member.email != null) {
            await notifier.resetPassword(member.email!);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال رابط إعادة تعيين كلمة المرور')));
          }
        }
        else if (value.startsWith('role_')) notifier.updateRole(member.id, value.substring(5));
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit_name', child: Row(children: [Icon(Icons.edit_rounded, size: 18), SizedBox(width: 12), Text('تعديل البيانات')])),
        if (member.status == 'pending')
          const PopupMenuItem(value: 'approve', child: Row(children: [Icon(Icons.verified_rounded, size: 18, color: Colors.green), SizedBox(width: 12), Text('اعتماد الموظف')])),
        PopupMenuItem(value: 'toggle', child: Row(children: [Icon(member.isActive ? Icons.block_rounded : Icons.check_circle_rounded, size: 18, color: member.isActive ? Colors.red : Colors.green), SizedBox(width: 12), Text(member.isActive ? 'تعطيل الحساب' : 'تنشيط الحساب')])),
        const PopupMenuItem(value: 'reset_password', child: Row(children: [Icon(Icons.vpn_key_rounded, size: 18), SizedBox(width: 12), Text('إعادة تعيين المرور')])),
        const PopupMenuDivider(),
        ...roles.where((r) => ['accountant', 'sales'].contains(r['slug'])).map((r) => PopupMenuItem(value: 'role_${r['id']}', child: Text('تغيير لـ ${_translateRole(r['slug'])}'))),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context, AppUser member) {
    final controller = TextEditingController(text: member.fullName);
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('تعديل بيانات الموظف', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
          content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'الاسم الكامل كما في الهوية', border: OutlineInputBorder())),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref.read(staffListControllerProvider.notifier).updateName(member.id, controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('تحديث البيانات'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String? selectedRoleId;
    
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final rolesAsync = ref.watch(availableRolesProvider);
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('دعوة موظف جديد للفريق', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.primaryNavy)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('سيتم إرسال دعوة رسمية عبر البريد الإلكتروني للوصول إلى المنظومة المالية', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 24),
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline_rounded))),
                    const SizedBox(height: 16),
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: 'البريد الإلكتروني المهني', prefixIcon: Icon(Icons.email_outlined))),
                    const SizedBox(height: 16),
                    rolesAsync.when(
                      data: (roles) => DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'الصلاحية والوظيفة المخططة', prefixIcon: Icon(Icons.work_outline_rounded)),
                        items: roles.where((r) => ['accountant', 'sales'].contains(r['slug'])).map((r) => DropdownMenuItem(value: r['id'].toString(), child: Text(_translateRole(r['slug'])))).toList(),
                        onChanged: (val) => selectedRoleId = val,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('خطأ في تحميل الأدوار'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty && emailController.text.isNotEmpty && selectedRoleId != null) {
                      await ref.read(staffListControllerProvider.notifier).inviteStaff(email: emailController.text, fullName: nameController.text, roleId: selectedRoleId!);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('إرسال الدعوة الرسمية'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.supervised_user_circle_rounded, size: 100, color: Colors.grey.shade200),
        const SizedBox(height: 24),
        const Text('لم يتم العثور على موظفين في قاعدة البيانات', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
