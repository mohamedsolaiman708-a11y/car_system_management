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
      'sales': 'مسؤول مبيعات',
    };
    return mapping[slugOrName.toLowerCase().trim()] ?? slugOrName;
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListControllerProvider);
    final rolesAsync = ref.watch(availableRolesProvider);

    ref.listen<AsyncValue<List<AppUser>>>(
      staffListControllerProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, _) => SnackBarHelper.showError(context, error),
          data: (_) {
            // الإصلاح: لا تظهر الرسالة إلا إذا كان هناك قيمة سابقة (أي كانت عملية تحديث وليس أول تحميل)
            if (previous != null && previous.isLoading && previous.hasValue) {
              SnackBarHelper.showSuccess(context, 'تمت العملية بنجاح');
            }
          },
        );
      },
    );

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
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      Failure.fromException(err).message,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          Text('لا يوجد موظفين يطابقون معايير البحث', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'إدارة فريق العمل والكوادر',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'تنظيم أدوار الموظفين ومتابعة النشاط الإداري للنظام',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddStaffDialog(context),
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
          label: const Text('دعوة موظف جديد',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGold,
            foregroundColor: AppColors.primaryNavy,
            minimumSize: const Size(220, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ],
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
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4))],
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20)],
      ),
      child: rolesAsync.maybeWhen(
        data: (roles) {
          final filteredRoles = roles.where((r) => _allowedRoles.contains(r['slug'])).toList();
          return DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: selectedRole,
              hint: const Text('تصفية حسب الرتبة', style: TextStyle(fontSize: 14)),
              icon: const Icon(Icons.filter_list_rounded, color: AppColors.primaryNavy),
              onChanged: (val) => setState(() => selectedRole = val),
              items: [
                const DropdownMenuItem(value: null, child: Text('كافة الرتب')),
                ...filteredRoles.map((r) => DropdownMenuItem(value: r['slug'].toString(), child: Text(_translateRole(r['slug'])))),
              ],
            ),
          );
        },
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 6))],
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
          colors: [AppColors.primaryNavy, AppColors.primaryNavy.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.primaryNavy.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
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
        color: AppColors.primaryNavy.withValues(alpha: 0.05),
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
        if (value == 'toggle') {
          notifier.updateStatus(member.id, !member.isActive);
        } else if (value == 'approve') {
          notifier.approveAsStaff(member.id);
        } else if (value == 'edit_name') {
          _showEditNameDialog(context, member);
        } else if (value == 'reset_password') {
          if (member.email != null && member.email!.isNotEmpty) {
            final success = await notifier.resetPassword(member.email!);
            if (mounted) {
              if (success) {
                SnackBarHelper.showSuccess(context, 'تم إرسال رابط إعادة التعيين لبريد الموظف');
              } else {
                SnackBarHelper.showError(context, 'فشل إرسال البريد');
              }
            }
          }
        } else if (value.startsWith('role_')) {
          notifier.updateRole(member.id, value.substring(5));
        }
      },
      itemBuilder: (context) {
        final filteredRoles = roles.where((r) => _allowedRoles.contains(r['slug'])).toList();
        return [
          PopupMenuItem(value: 'edit_name', child: _buildPopupItem(Icons.edit_rounded, 'تعديل البيانات')),
          if (member.status == 'pending')
            PopupMenuItem(value: 'approve', child: _buildPopupItem(Icons.verified_rounded, 'اعتماد الموظف', color: Colors.green)),
          PopupMenuItem(value: 'toggle', child: _buildPopupItem(
            member.isActive ? Icons.block_rounded : Icons.check_circle_rounded, 
            member.isActive ? 'تعطيل الحساب' : 'تنشيط الحساب',
            color: member.isActive ? Colors.red : Colors.green,
          )),
          PopupMenuItem(value: 'reset_password', child: _buildPopupItem(Icons.vpn_key_rounded, 'إعادة تعيين المرور')),
          const PopupMenuDivider(),
          ...filteredRoles.where((r) => r['slug'] != member.role.name).map((r) => 
            PopupMenuItem(value: 'role_${r['id']}', child: Text('تغيير لـ ${_translateRole(r['slug'])}'))
          ),
        ];
      },
    );
  }

  Widget _buildPopupItem(IconData icon, String text, {Color? color}) {
    return Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 12), Text(text)]);
  }

  void _showAddStaffDialog(BuildContext context) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    String? roleId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('دعوة موظف جديد للفريق', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('سيتم إرسال دعوة رسمية للبريد الإلكتروني الموضح أدناه لإكمال عملية التسجيل.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 20),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline))),
                  const SizedBox(height: 16),
                  TextField(controller: emailController, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined))),
                  const SizedBox(height: 16),
                  ref.watch(availableRolesProvider).maybeWhen(
                    data: (roles) {
                      final filteredRoles = roles.where((r) => _allowedRoles.contains(r['slug'])).toList();
                      return DropdownButtonFormField<String>(
                        value: roleId,
                        decoration: const InputDecoration(labelText: 'الرتبة الوظيفية', prefixIcon: Icon(Icons.work_outline)),
                        items: filteredRoles.map((r) => DropdownMenuItem(value: r['id'].toString(), child: Text(_translateRole(r['slug'])))).toList(),
                        onChanged: (val) => setState(() => roleId = val),
                      );
                    },
                    orElse: () => const Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  if (emailController.text.isNotEmpty && nameController.text.isNotEmpty && roleId != null) {
                    final success = await ref.read(staffListControllerProvider.notifier).inviteStaff(
                      email: emailController.text,
                      fullName: nameController.text,
                      roleId: roleId!,
                    );
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      SnackBarHelper.showSuccess(context, 'تم إرسال الدعوة بنجاح');
                    }
                  }
                },
                child: const Text('إرسال الدعوة الآن'),
              ),
            ],
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
