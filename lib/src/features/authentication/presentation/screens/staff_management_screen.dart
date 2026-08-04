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

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  String searchQuery = '';
  String? selectedRole;

  final List<String> _allowedRoles = ['admin', 'sales', 'accountant'];

  String _translateRole(String slugOrName) {
    final mapping = {
      'admin': 'مدير نظام',
      'accountant': 'محاسب مالي',
      'sales': 'موظف مبيعات',
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
          preferredSize: const Size.fromHeight(140),
          child: Container(
            color: AppColors.primaryNavy,
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SafeArea(
              child: _buildSimpleHeader(context),
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
                error: (err, _) => Center(child: Text(Failure.fromException(err).message, style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('لا يوجد موظفين حالياً'));
  }

  Widget _buildSimpleHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('إدارة فريق العمل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ElevatedButton.icon(
          onPressed: () => _showAddStaffDialog(context),
          icon: const Icon(Icons.person_add),
          label: const Text('دعوة موظف جديد'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold, foregroundColor: AppColors.primaryNavy),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(AsyncValue<List<Map<String, dynamic>>> rolesAsync) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: const InputDecoration(hintText: 'بحث...', prefixIcon: Icon(Icons.search)),
            ),
          ),
          const SizedBox(width: 16),
          rolesAsync.maybeWhen(
            data: (roles) {
              final filteredRoles = roles.where((r) => _allowedRoles.contains(r['slug'])).toList();
              return DropdownButton<String?>(
                value: selectedRole,
                hint: const Text('الرتبة'),
                onChanged: (val) => setState(() => selectedRole = val),
                items: [
                  const DropdownMenuItem(value: null, child: Text('الكل')),
                  ...filteredRoles.map((r) => DropdownMenuItem(value: r['slug'].toString(), child: Text(_translateRole(r['slug'])))),
                ],
              );
            },
            orElse: () => const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeProfileCard(AppUser member, List roles) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(member.fullName),
        subtitle: Text(_translateRole(member.role.name)),
        trailing: _buildActionsMenu(member, roles),
      ),
    );
  }

  Widget _buildActionsMenu(AppUser member, List roles) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        if (val.startsWith('role_')) {
          ref.read(staffListControllerProvider.notifier).updateRole(member.id, val.substring(5));
        }
      },
      itemBuilder: (context) => roles.map<PopupMenuEntry<String>>((r) => 
        PopupMenuItem(value: 'role_${r['id']}', child: Text('تغيير لـ ${_translateRole(r['slug'])}'))
      ).toList(),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    String? roleId;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final rolesAsync = ref.watch(availableRolesProvider);
          
          return StatefulBuilder(
            builder: (context, setDialogState) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('دعوة موظف جديد'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController, 
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController, 
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                      ),
                      const SizedBox(height: 16),
                      rolesAsync.when(
                        data: (roles) {
                          final filteredRoles = roles.where((r) => _allowedRoles.contains(r['slug'])).toList();
                          return DropdownButtonFormField<String>(
                            value: roleId,
                            disabledHint: const Text('جاري الإرسال...'),
                            decoration: const InputDecoration(labelText: 'الرتبة الوظيفية'),
                            items: filteredRoles.map((r) => DropdownMenuItem(value: r['id'].toString(), child: Text(_translateRole(r['slug'])))).toList(),
                            onChanged: isSubmitting ? null : (val) => setDialogState(() => roleId = val),
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (err, _) => Text('خطأ: $err', style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSubmitting ? null : () => Navigator.pop(context), 
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : () async {
                      if (emailController.text.isEmpty || nameController.text.isEmpty || roleId == null) {
                        SnackBarHelper.showError(context, 'يرجى ملء جميع البيانات واختيار الرتبة');
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      try {
                        final success = await ref.read(staffListControllerProvider.notifier).inviteStaff(
                          email: emailController.text.trim(),
                          fullName: nameController.text.trim(),
                          roleId: roleId!,
                        );

                        if (success) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            SnackBarHelper.showSuccess(context, 'تم إرسال الدعوة بنجاح');
                          }
                        } else {
                          setDialogState(() => isSubmitting = false);
                          if (context.mounted) {
                            SnackBarHelper.showError(context, 'فشل إرسال الدعوة، قد يكون البريد مسجلاً مسبقاً');
                          }
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (context.mounted) {
                          SnackBarHelper.showError(context, 'حدث خطأ: $e');
                        }
                      }
                    },
                    child: isSubmitting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('إرسال الدعوة الآن'),
                  ),
                ],
              ),
            ),
          );
        },
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('تعديل بيانات الموظف', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
          content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'الاسم الكامل كما في الهوية', border: OutlineInputBorder())),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await ref.read(staffListControllerProvider.notifier).updateName(member.id, controller.text);
                  if (context.mounted) Navigator.pop(context);
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
