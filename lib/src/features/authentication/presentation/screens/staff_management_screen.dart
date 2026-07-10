import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../staff_controller.dart';
import '../../domain/app_user.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  ConsumerState<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  String searchQuery = '';
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListControllerProvider);
    final rolesAsync = ref.watch(availableRolesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة فريق العمل والموظفين'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(staffListControllerProvider);
                ref.invalidate(availableRolesProvider);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterBar(rolesAsync),
            Expanded(
              child: staffAsync.when(
                data: (staffList) {
                  final filteredList = staffList.where((member) {
                    final matchesSearch = member.fullName.toLowerCase().contains(searchQuery.toLowerCase());
                    final matchesRole = selectedRole == null || member.role.name == selectedRole;
                    return matchesSearch && matchesRole;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return const Center(child: Text('لا يوجد موظفون مطابقون للبحث'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final member = filteredList[index];
                      return _StaffMemberCard(member: member);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('حدث خطأ: $err')),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddStaffDialog(context),
          label: const Text('إضافة موظف جديد'),
          icon: const Icon(Icons.person_add_alt_1_rounded),
        ),
      ),
    );
  }

  Widget _buildFilterBar(AsyncValue<List<Map<String, dynamic>>> rolesAsync) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'بحث بالاسم...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: rolesAsync.maybeWhen(
              data: (roles) => DropdownButtonFormField<String?>(
                value: selectedRole,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(), 
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                hint: const Text('الدور'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('الكل')),
                  ...roles.map((r) => DropdownMenuItem<String>(
                    value: r['slug']?.toString(), 
                    child: Text(r['name']?.toString() ?? 'غير معروف'),
                  )),
                ],
                onChanged: (val) => setState(() => selectedRole = val),
              ),
              orElse: () => const SizedBox(),
            ),
          ),
        ],
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('دعوة موظف جديد'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الكامل للموظف',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'example@company.com',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    rolesAsync.when(
                      data: (roles) {
                        if (roles.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                            child: const Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(child: Text('لا توجد أدوار في النظام، يرجى مراجعة قاعدة البيانات', style: TextStyle(color: Colors.red, fontSize: 12))),
                              ],
                            ),
                          );
                        }
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'تحديد الدور الوظيفي',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.work_outline),
                          ),
                          hint: const Text('اختر الدور الوظيفي'),
                          items: roles.map((r) => DropdownMenuItem<String>(
                            value: r['id'].toString(), 
                            child: Text(r['name'].toString()),
                          )).toList(),
                          onChanged: (val) => selectedRoleId = val,
                        );
                      },
                      loading: () => const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
                      error: (err, _) => Text('خطأ في تحميل الأدوار: $err', style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B3E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (nameController.text.isEmpty || emailController.text.isEmpty || selectedRoleId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى ملء جميع الحقول واختيار الدور الوظيفي للمتابعة'),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    final success = await ref.read(staffListControllerProvider.notifier).inviteStaff(
                      email: emailController.text,
                      fullName: nameController.text,
                      roleId: selectedRoleId!,
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'تم إرسال دعوة الانضمام بنجاح' : 'فشل إرسال الدعوة، قد يكون الإيميل مستخدم مسبقاً'),
                          backgroundColor: success ? Colors.green : Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('إرسال الدعوة الآن'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StaffMemberCard extends ConsumerWidget {
  final AppUser member;
  const _StaffMemberCard({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(availableRolesProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: member.isActive ? const Color(0xFF0D1B3E).withOpacity(0.1) : Colors.grey.shade200,
          child: Text(member.fullName.isNotEmpty ? member.fullName[0] : '?', 
            style: TextStyle(color: member.isActive ? const Color(0xFF0D1B3E) : Colors.grey, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        title: Text(member.fullName, style: TextStyle(
          fontWeight: FontWeight.bold,
          color: member.isActive ? Colors.black : Colors.grey,
          decoration: member.isActive ? null : TextDecoration.lineThrough,
        )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الدور: ${member.role.label}', style: const TextStyle(fontSize: 12)),
            Text(member.email ?? '', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) async {
            if (value == 'toggle_status') {
              ref.read(staffListControllerProvider.notifier).updateStatus(member.id, !member.isActive);
            } else if (value == 'edit_name') {
              _showEditNameDialog(context, ref);
            } else if (value == 'reset_password') {
              final email = member.email;
              if (email != null && email.isNotEmpty) {
                final success = await ref.read(staffListControllerProvider.notifier).resetPassword(email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'تم إرسال رابط التعيين للإيميل' : 'فشل إرسال الرابط'), backgroundColor: success ? Colors.green : Colors.red),
                  );
                }
              }
            } else if (value.startsWith('role_')) {
              final roleId = value.substring('role_'.length);
              ref.read(staffListControllerProvider.notifier).updateRole(member.id, roleId);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit_name',
              child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('تعديل الاسم'), dense: true, contentPadding: EdgeInsets.zero),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: ListTile(
                leading: Icon(member.isActive ? Icons.block : Icons.check_circle, color: member.isActive ? Colors.red : Colors.green),
                title: Text(member.isActive ? 'تعطيل الحساب' : 'تنشيط الحساب'),
                dense: true, contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'reset_password',
              child: ListTile(leading: Icon(Icons.lock_reset), title: Text('إعادة تعيين كلمة المرور'), dense: true, contentPadding: EdgeInsets.zero),
            ),
            const PopupMenuDivider(),
            ...?rolesAsync.value?.map((role) => PopupMenuItem(
              value: 'role_${role['id']}',
              child: Text('تغيير إلى ${role['name']}'),
            )),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: member.fullName);
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل الاسم'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'الاسم الكامل الجديد', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(staffListControllerProvider.notifier).updateName(member.id, nameController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ التعديل'),
            ),
          ],
        ),
      ),
    );
  }
}
