import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../settings_controller.dart';
import '../../domain/system_setting.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../../authentication/domain/user_role.dart';
import '../../../audit/presentation/disaster_recovery_controller.dart';
import '../../../../core/utils/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final user = ref.watch(currentUserProvider);
    final isFrozen = ref.watch(systemFreezeStatusProvider).value ?? false;
    final isMaintenance = ref.watch(isMaintenanceModeProvider).value ?? false;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          title: const Text('إعدادات النظام والشركة'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: settingsAsync.when(
          data: (settings) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              _buildSectionHeader('المعلومات الأساسية للمؤسسة'),
              _buildInfoCard(
                context, ref,
                title: 'بيانات التواصل الرسمية',
                icon: Icons.business_rounded,
                settingKey: 'company_profile',
                data: _getSettingByKey(settings, 'company_profile'),
                displayFields: {'companyName': 'المنشأة', 'cr_number': 'سجل تجاري', 'tax_number': 'رقم ضريبي'},
                fieldsToEdit: {
                  'companyName': 'اسم الشركة',
                  'address': 'العنوان الرسمي',
                  'phone': 'رقم التواصل',
                  'tax_number': 'الرقم الضريبي (VAT)',
                  'cr_number': 'رقم السجل التجاري',
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('الإعدادات المالية والحوكمة'),
              _buildInfoCard(
                context, ref,
                title: 'النسب الربحية والعملة',
                icon: Icons.account_balance_rounded,
                settingKey: 'profit_settings',
                data: _getSettingByKey(settings, 'profit_settings'),
                displayFields: {'ratio': 'نسبة الربح الافتراضية', 'currency': 'العملة المعمدة'},
                fieldsToEdit: {
                  'ratio': 'نسبة الربح (مثلاً 0.15 لـ 15%)',
                  'currency': 'رمز العملة (ر.س)',
                },
              ),

              if (user?.role == UserRole.admin) ...[
                const SizedBox(height: 32),
                _buildSectionHeader('مركز التحكم في الأزمات (Admins Only)', isCritical: true),
                _buildEmergencyControlCard(context, ref, isFrozen, isMaintenance),
                const SizedBox(height: 16),
                _buildActionCard(
                  context,
                  title: 'فحص نزاهة البيانات المتقدم',
                  subtitle: 'مطابقة القيود المحاسبية آلياً مع أرصدة المستثمرين والعقود.',
                  icon: Icons.health_and_safety_outlined,
                  color: Colors.green.shade700,
                  onTap: () => _confirmAction(context, 'بدء فحص النزاهة الشامل', Colors.green, () {
                    ref.read(disasterRecoveryControllerProvider.notifier).runIntegrityCheck();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بدأت عملية الفحص والتدقيق في الخلفية...')));
                  }),
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  context,
                  title: 'مراقبة المهام الخلفية',
                  subtitle: 'عرض وإدارة المهام المجدولة في الخلفية مثل التقارير والإشعارات.',
                  icon: Icons.work_history_outlined,
                  color: Colors.indigo.shade700,
                  onTap: () => context.push('/settings/jobs'),
                ),
              ],
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
          error: (err, _) => Center(child: Text('خطأ في تحميل الإعدادات: $err')),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isCritical = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isCritical ? AppColors.errorRed : AppColors.primaryNavy.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, WidgetRef ref, {
    required String title,
    required IconData icon,
    required String settingKey,
    required Map<String, dynamic> data,
    required Map<String, String> displayFields,
    required Map<String, String> fieldsToEdit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryNavy.withOpacity(0.08),
              child: Icon(icon, color: AppColors.primaryNavy, size: 20),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            trailing: IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.accentGold),
              onPressed: () => _showEditDialog(context, ref, settingKey, data, fieldsToEdit),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 24,
              runSpacing: 12,
              children: displayFields.entries.map((e) {
                final value = data[e.key]?.toString() ?? 'غير محدد';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.value, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyControlCard(BuildContext context, WidgetRef ref, bool isFrozen, bool isMaintenance) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100, width: 1),
      ),
      child: Column(
        children: [
          _buildCriticalSwitch(
            title: 'تجميد العمليات المالية',
            subtitle: 'إيقاف فوري لكافة عمليات السداد والصرف في حالات الطوارئ القصوى.',
            value: isFrozen,
            activeColor: Colors.red,
            onChanged: (val) => _confirmAction(context, val ? 'تجميد النظام المالي' : 'إلغاء تجميد النظام', Colors.red, () {
              ref.read(disasterRecoveryControllerProvider.notifier).toggleFreeze(val);
            }),
          ),
          const Divider(height: 1),
          _buildCriticalSwitch(
            title: 'وضع الصيانة العامة',
            subtitle: 'منع دخول كافة المستخدمين للتطبيق (باستثناء الإدارة) أثناء التحديثات.',
            value: isMaintenance,
            activeColor: Colors.orange.shade700,
            onChanged: (val) => _confirmAction(context, val ? 'تفعيل وضع الصيانة' : 'إيقاف وضع الصيانة', Colors.orange, () {
              ref.read(settingsControllerProvider.notifier).toggleMaintenance(val, 'النظام تحت الصيانة المجدولة حالياً');
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalSwitch({required String title, required String subtitle, required bool value, required Color activeColor, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: value ? activeColor : AppColors.primaryNavy)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      activeColor: activeColor,
      onChanged: onChanged,
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(icon, color: color, size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }

  void _confirmAction(BuildContext context, String action, Color color, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تأكيد: $action'),
          content: const Text('هذا الإجراء حساس ويؤثر على سير العمل بالكامل. هل أنت متأكد؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () { onConfirm(); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
              child: const Text('تأكيد التنفيذ'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getSettingByKey(List<SystemSetting> settings, String key) {
    try {
      return settings.firstWhere((s) => s.key == key).value;
    } catch (_) {
      return {};
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, String key, Map<String, dynamic> currentValue, Map<String, String> fields) {
    final controllers = <String, TextEditingController>{};
    fields.forEach((fieldKey, label) {
      controllers[fieldKey] = TextEditingController(text: currentValue[fieldKey]?.toString() ?? '');
    });

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تعديل $key', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields.entries.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: controllers[f.key],
                  decoration: InputDecoration(
                    labelText: f.value,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              )).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final newValue = <String, dynamic>{...currentValue};
                controllers.forEach((k, v) => newValue[k] = v.text);
                await ref.read(settingsControllerProvider.notifier).updateSetting(key, newValue);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }
}


