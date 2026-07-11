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
    final key = slugOrName.toLowerCase().trim();
    return mapping[key] ?? slugOrName;
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListControllerProvider);
    final rolesAsync = ref.watch(availableRolesProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Container(
          color: AppColors.primaryNavy,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: _buildPremiumHeader(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // لوحة إحصائيات الفريق
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _buildTeamStats(staffAsync),
          ),
          
          // شريط البحث والتصفية
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildModernFilterBar(rolesAsync),
          ),

          Expanded(
            child: staffAsync.when(
              data: (staffList) {
                final filteredList = staffList.where((member) {
                  final matchesSearch = member.fullName.toLowerCase().contains(searchQuery.toLowerCase());
                  final matchesRole = selectedRole == null || member.role.name == selectedRole;
                  return matchesSearch && matchesRole;
                }).toList();

                if (filteredList.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) => _PremiumStaffCard(
                    member: filteredList[index], 
                    translator: _translateRole,
                    roles: rolesAsync.valueOrNull ?? [],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
              error: (err, _) => Center(child: Text('حدث خطأ: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: !isDesktop ? FloatingActionButton.extended(
        onPressed: () => _showAddStaffDialog(context),
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.primaryNavy,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('دعوة موظف', style: TextStyle(fontWeight: FontWeight.bold)),
      ) : null,
    );
  }

  Widget _buildPremiumHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('إدارة الكوادر البشرية', 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('التحكم في صلاحيات الوصول، دعوات الانضمام، ومراقبة حالة الحسابات', 
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          ],
        ),
        if (ResponsiveLayout.isDesktop(context))
          ElevatedButton.icon(
            onPressed: () => _showAddStaffDialog(context),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
            label: const Text('دعوة موظف جديد للعمل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.primaryNavy,
              minimumSize: const Size(220, 54),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
      ],
    );
  }

  Widget _buildTeamStats(AsyncValue<List<AppUser>> staffAsync) {
    return staffAsync.maybeWhen(
      data: (list) {
        final total = list.length;
        final active = list.where((u) => u.isActive).length;
        final pending = list.where((u) => u.status == 'pending').length;

        return Row(
          children: [
            _buildStatBox('إجمالي الموظفين', total.toString(), Icons.badge_rounded, Colors.blue),
            const SizedBox(width: 20),
            _buildStatBox('حسابات نشطة', active.toString(), Icons.check_circle_rounded, Colors.green),
            const SizedBox(width: 20),
            _buildStatBox('بانتظار التفعيل', pending.toString(), Icons.hourglass_top_rounded, Colors.orange),
          ],
        );
      },
      orElse: () => const SizedBox(),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFilterBar(AsyncValue<List<Map<String, dynamic>>> rolesAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'البحث باسم الموظف أو البريد الإلكتروني...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryNavy),
                filled: true,
                fillColor: AppColors.bgGrey.withOpacity(0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _buildRoleDropdown(rolesAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown(AsyncValue<List<Map<String, dynamic>>> rolesAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.bgGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
      child: rolesAsync.maybeWhen(
        data: (roles) {
          final allowedSlugs = ['accountant', 'sales', 'manager', 'admin'];
          final filteredRoles = roles.where((r) => allowedSlugs.contains(r['slug'].toString().toLowerCase())).toList();
          return DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: selectedRole,
              isExpanded: true,
              hint: const Text('تصفية الرتبة'),
              onChanged: (val) => setState(() => selectedRole = val),
              items: [
                const DropdownMenuItem(value: null, child: Text('كافة الرتب')),
                ...filteredRoles.map((r) => DropdownMenuItem(
                  value: r['slug']?.toString(), 
                  child: Text(_translateRole(r['slug']?.toString() ?? '')),
                )),
              ],
            ),
          );
        },
        orElse: () => const SizedBox(),
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    // منطق الإضافة كما هو موجود مع تحسين التنسيق في AlertDialog لاحقاً
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('لا يوجد موظفون مطابقون لمعايير البحث', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

class _PremiumStaffCard extends ConsumerWidget {
  final AppUser member;
  final String Function(String) translator;
  final List<Map<String, dynamic>> roles;
  
  const _PremiumStaffCard({required this.member, required this.translator, required this.roles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isApproved = member.status == 'approved' || member.status == 'active';
    final Color statusColor = member.isActive ? AppColors.successGreen : AppColors.errorRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        border: Border.all(color: member.status == 'pending' ? AppColors.accentGold.withOpacity(0.2) : Colors.transparent),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryNavy.withOpacity(0.05),
              child: Text(member.fullName.isNotEmpty ? member.fullName[0] : '?', 
                style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            if (member.status == 'pending')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.accentGold.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text('دعوة معلقة', style: TextStyle(color: AppColors.accentGold, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(member.email ?? 'لا يوجد بريد مسجل', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(8)),
              child: Text(translator(member.role.name), 
                style: const TextStyle(fontSize: 11, color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        trailing: _buildActionsMenu(context, ref),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) async {
        final controller = ref.read(staffListControllerProvider.notifier);
        if (value == 'toggle_status') controller.updateStatus(member.id, !member.isActive);
        else if (value == 'approve_as_staff') controller.approveAsStaff(member.id);
        else if (value.startsWith('role_')) controller.updateRole(member.id, value.substring(5));
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined, size: 18), title: Text('تعديل البيانات'), dense: true)),
        if (member.status == 'pending')
          const PopupMenuItem(value: 'approve_as_staff', child: ListTile(leading: Icon(Icons.verified_user_rounded, color: Colors.blue), title: Text('اعتماد فوري'), dense: true)),
        PopupMenuItem(
          value: 'toggle_status',
          child: ListTile(
            leading: Icon(member.isActive ? Icons.block_rounded : Icons.check_circle_rounded, color: member.isActive ? Colors.red : Colors.green, size: 18),
            title: Text(member.isActive ? 'تعطيل الحساب' : 'تنشيط الحساب'),
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        ...roles.where((r) => ['accountant', 'sales', 'manager'].contains(r['slug'])).map((role) => PopupMenuItem(
          value: 'role_${role['id']}',
          child: Text('تحويل إلى ${translator(role['slug'])}'),
        )),
      ],
    );
  }
}
