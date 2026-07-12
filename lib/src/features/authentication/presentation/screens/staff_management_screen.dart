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
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('إدارة شؤون الموظفين', 
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () => _showAddStaffDialog(context),
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text('دعوة موظف جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Column(
        children: [
          _buildCompactFilterBar(rolesAsync),
          Expanded(
            child: staffAsync.when(
              data: (staffList) {
                final filteredList = staffList.where((member) {
                  final matchesSearch = member.fullName.toLowerCase().contains(searchQuery.toLowerCase());
                  final matchesRole = selectedRole == null || member.role.name == selectedRole;
                  return matchesSearch && matchesRole;
                }).toList();

                if (filteredList.isEmpty) return _buildEmptyState();

                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowHeight: 40,
                      dataRowHeight: 55,
                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                      columns: const [
                        DataColumn(label: Text('الموظف', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('البريد الإلكتروني', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الرتبة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الحالة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('إجراءات', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      ],
                      rows: filteredList.map((member) => DataRow(
                        cells: [
                          DataCell(Text(member.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                          DataCell(Text(member.email ?? '-', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                          DataCell(Text(_translateRole(member.role.name), style: const TextStyle(fontSize: 12))),
                          DataCell(_buildStatusChip(member)),
                          DataCell(_buildActionsMenu(member, rolesAsync.valueOrNull ?? [])),
                        ],
                      )).toList(),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const Center(child: Text('خطأ في التحميل')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AppUser member) {
    final bool isActive = member.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(isActive ? 'نشط' : 'معطل', 
        style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCompactFilterBar(AsyncValue<List<Map<String, dynamic>>> rolesAsync) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(hintText: 'بحث...', prefixIcon: Icon(Icons.search, size: 14), border: InputBorder.none, contentPadding: EdgeInsets.zero),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
            child: rolesAsync.maybeWhen(
              data: (roles) => DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: selectedRole,
                  style: const TextStyle(fontSize: 12, color: AppColors.primaryNavy),
                  onChanged: (val) => setState(() => selectedRole = val),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('كافة الرتب')),
                    ...roles.where((r) => r['slug'] != 'investor').map((r) => DropdownMenuItem(value: r['slug'].toString(), child: Text(_translateRole(r['slug'])))),
                  ],
                ),
              ),
              orElse: () => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu(AppUser member, List roles) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
      onSelected: (value) async {
        final notifier = ref.read(staffListControllerProvider.notifier);
        if (value == 'toggle') notifier.updateStatus(member.id, !member.isActive);
        else if (value == 'approve') notifier.approveAsStaff(member.id);
        else if (value == 'edit_name') _showEditNameDialog(context, member);
        else if (value == 'reset_password') {
          if (member.email != null) {
            await notifier.resetPassword(member.email!);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال رابط إعادة التعيين')));
          }
        }
        else if (value.startsWith('role_')) notifier.updateRole(member.id, value.substring(5));
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit_name', child: Text('تعديل الاسم')),
        if (member.status == 'pending')
          const PopupMenuItem(value: 'approve', child: Text('اعتماد كـموظف')),
        PopupMenuItem(value: 'toggle', child: Text(member.isActive ? 'تعطيل الحساب' : 'تنشيط الحساب')),
        const PopupMenuItem(value: 'reset_password', child: Text('إعادة تعيين كلمة المرور')),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: const Text('تعديل الاسم', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: TextField(controller: controller, decoration: const InputDecoration(border: OutlineInputBorder())),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref.read(staffListControllerProvider.notifier).updateName(member.id, controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ'),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              title: const Text('دعوة موظف جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    rolesAsync.when(
                      data: (roles) => DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'الدور الوظيفي', border: OutlineInputBorder()),
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
                  child: const Text('إرسال الدعوة'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text('لا يوجد موظفون', style: TextStyle(color: Colors.grey)));
}
