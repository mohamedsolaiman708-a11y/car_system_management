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

  // دالة موحدة لتعريب مسميات الأدوار بشكل فخم
  String _translateRole(String slugOrName) {
    final mapping = {
      'admin': 'مدير نظام',
      'system_administrator': 'مدير نظام',
      'manager': 'مدير عمليات',
      'operations_manager': 'مدير عمليات',
      'accountant': 'محاسب مالي',
      'chief_accountant': 'رئيس حسابات',
      'sales': 'مسؤول مبيعات',
      'sales_agent': 'مسؤول مبيعات',
      'employee': 'موظف',
    };
    
    final key = slugOrName.toLowerCase().replaceAll(' ', '_');
    return mapping[key] ?? slugOrName;
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListControllerProvider);
    final rolesAsync = ref.watch(availableRolesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة فريق العمل'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('لا يوجد موظفون مطابقون للبحث', style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final member = filteredList[index];
                      return _StaffMemberCard(member: member, translator: _translateRole);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('حدث خطأ أثناء تحميل البيانات: $err')),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF0D1B3E),
          onPressed: () => _showAddStaffDialog(context),
          label: const Text('إضافة موظف جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterBar(AsyncValue<List<Map<String, dynamic>>> rolesAsync) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'بحث باسم الموظف...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: rolesAsync.maybeWhen(
              data: (roles) {
                // فلترة الأدوار المعروضة في البحث لتشمل المحاسب والمبيعات فقط + الكل
                final relevantSlugs = ['accountant', 'sales', 'chief_accountant', 'sales_agent'];
                final filteredRoles = roles.where((r) => relevantSlugs.contains(r['slug'].toString().toLowerCase())).toList();

                return DropdownButtonFormField<String?>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  hint: const Text('تصفية بالدور'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('كافة الأدوار')),
                    ...filteredRoles.map((r) => DropdownMenuItem<String>(
                      value: r['slug']?.toString(), 
                      child: Text(_translateRole(r['name']?.toString() ?? '')),
                    )),
                  ],
                  onChanged: (val) => setState(() => selectedRole = val),
                );
              },
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
              title: const Text('دعوة موظف جديد', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('سيتم إرسال دعوة للموظف لإنشاء حسابه بالصلاحيات المحددة.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني المهني',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    rolesAsync.when(
                      data: (roles) {
                        // الحصر المطلوب: المحاسب والمبيعات فقط
                        final allowedRoles = roles.where((r) {
                          final slug = r['slug'].toString().toLowerCase();
                          return slug.contains('accountant') || slug.contains('sales');
                        }).toList();

                        if (allowedRoles.isEmpty) {
                          return const Text('لا توجد أدوار محاسبة أو مبيعات معرفة في النظام', style: TextStyle(color: Colors.red));
                        }
                        
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'تحديد الدور الوظيفي',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.work_outline),
                          ),
                          hint: const Text('اختر الدور'),
                          items: allowedRoles.map((r) => DropdownMenuItem<String>(
                            value: r['id'].toString(), 
                            child: Text(_translateRole(r['name'].toString())),
                          )).toList(),
                          onChanged: (val) => selectedRoleId = val,
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
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
                    minimumSize: const Size(140, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (nameController.text.isEmpty || emailController.text.isEmpty || selectedRoleId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى إكمال كافة البيانات المطلوبة'), backgroundColor: Colors.orange),
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
                          content: Text(success ? 'تم إرسال دعوة الانضمام بنجاح' : 'فشل إرسال الدعوة'),
                          backgroundColor: success ? Colors.green : Colors.red,
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
  final String Function(String) translator;
  
  const _StaffMemberCard({required this.member, required this.translator});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(availableRolesProvider);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), 
        side: BorderSide(color: Colors.grey.shade100)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: member.isActive ? const Color(0xFF0D1B3E).withOpacity(0.08) : Colors.grey.shade100,
          child: Text(member.fullName.isNotEmpty ? member.fullName[0] : '?', 
            style: TextStyle(
              color: member.isActive ? const Color(0xFF0D1B3E) : Colors.grey, 
              fontWeight: FontWeight.bold, 
              fontSize: 20
            )),
        ),
        title: Text(member.fullName, style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: member.isActive ? Colors.black87 : Colors.grey,
          decoration: member.isActive ? null : TextDecoration.lineThrough,
        )),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: member.isActive ? Colors.blue.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(translator(member.role.label), style: TextStyle(
                  fontSize: 11, 
                  color: member.isActive ? Colors.blue.shade700 : Colors.grey,
                  fontWeight: FontWeight.w600
                )),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(member.email ?? '', 
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          onSelected: (value) async {
            if (value == 'toggle_status') {
              ref.read(staffListControllerProvider.notifier).updateStatus(member.id, !member.isActive);
            } else if (value == 'edit_name') {
              _showEditNameDialog(context, ref);
            } else if (value == 'reset_password') {
              final email = member.email;
              if (email != null) {
                await ref.read(staffListControllerProvider.notifier).resetPassword(email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال رابط التعيين')));
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
                leading: Icon(member.isActive ? Icons.block_rounded : Icons.check_circle_rounded, color: member.isActive ? Colors.red : Colors.green),
                title: Text(member.isActive ? 'تعطيل الحساب' : 'تنشيط الحساب'),
                dense: true, 
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'reset_password',
              child: ListTile(leading: Icon(Icons.lock_reset_rounded), title: Text('إعادة تعيين كلمة المرور'), dense: true, contentPadding: EdgeInsets.zero),
            ),
            const PopupMenuDivider(),
            ...?rolesAsync.value?.where((r) {
               // حصر خيارات تغيير الدور أيضاً في المحاسب والمبيعات
               final s = r['slug'].toString().toLowerCase();
               return s.contains('accountant') || s.contains('sales');
            }).map((role) => PopupMenuItem(
              value: 'role_${role['id']}',
              child: Text('تغيير إلى ${translator(role['name'])}'),
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
          title: const Text('تعديل اسم الموظف'),
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
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
