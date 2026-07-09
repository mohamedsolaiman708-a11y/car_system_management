import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings_controller.dart';
import '../../domain/system_setting.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../../authentication/domain/user_role.dart';
import '../../../audit/presentation/disaster_recovery_controller.dart';

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
        appBar: AppBar(
          title: const Text('إعدادات النظام والشركة'),
        ),
        body: settingsAsync.when(
          data: (settings) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('المعلومات الأساسية للمؤسسة'),
              _buildSettingCard(
                context, ref,
                title: 'بيانات التواصل الرسمية',
                icon: Icons.business_rounded,
                settingKey: 'company_info',
                currentValue: _getSettingByKey(settings, 'company_info'),
                fields: {
                  'name': 'اسم الشركة',
                  'address': 'العنوان',
                  'phone': 'رقم الهاتف',
                },
              ),
              const SizedBox(height: 16),
              _buildSectionHeader('الإعدادات المالية'),
              _buildSettingCard(
                context, ref,
                title: 'الحوكمة والنسب الربحية',
                icon: Icons.account_balance_rounded,
                settingKey: 'profit_settings',
                currentValue: _getSettingByKey(settings, 'profit_settings'),
                fields: {
                  'ratio': 'نسبة ربح الشركة (0.2 = 20%)',
                  'currency': 'رمز العملة (ر.س)',
                },
              ),
              
              if (user?.role == UserRole.admin) ...[
                const SizedBox(height: 32),
                _buildSectionHeader('مركز التحكم في الأزمات (Admins Only)'),
                _buildEmergencyControlCard(context, ref, isFrozen, isMaintenance),
                const SizedBox(height: 12),
                _buildIntegrityActionCard(context, ref),
              ],
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ في تحميل الإعدادات: $err')),
        ),
      ),
    );
  }

  Widget _buildEmergencyControlCard(BuildContext context, WidgetRef ref, bool isFrozen, bool isMaintenance) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.red.shade100)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('تجميد العمليات المالية', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              subtitle: const Text('إيقاف فوري لكافة عمليات السداد والسحب في حالات الطوارئ.'),
              value: isFrozen,
              activeColor: Colors.red,
              onChanged: (val) => _confirmAction(context, 'تجمied النظام المالي', () {
                ref.read(disasterRecoveryControllerProvider.notifier).toggleFreeze(val);
              }),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('وضع الصيانة العامة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              subtitle: const Text('منع دخول المستخدمين للتطبيق أثناء التحديثات.'),
              value: isMaintenance,
              activeColor: Colors.orange,
              onChanged: (val) => _confirmAction(context, 'تفعيل وضع الصيانة', () {
                ref.read(settingsControllerProvider.notifier).toggleMaintenance(val, 'النظام تحت الصيانة المجدولة');
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrityActionCard(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.health_and_safety_outlined, color: Colors.green),
        title: const Text('فحص نزاهة البيانات المتقدم'),
        subtitle: const Text('مطابقة القيود المحاسبية مع أرصدة المستثمرين.'),
        trailing: const Icon(Icons.chevron_left),
        onTap: () => _confirmAction(context, 'بدء فحص النزاهة', () {
          ref.read(disasterRecoveryControllerProvider.notifier).runIntegrityCheck();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بدأ الفحص في الخلفية...')));
        }),
      ),
    );
  }

  void _confirmAction(BuildContext context, String action, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد $action'),
        content: const Text('هل أنت متأكد من تنفيذ هذا الإجراء الحساس؟ سيتم تسجيل العملية في سجل الرقابة.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تأكيد التنفيذ'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }

  Map<String, dynamic> _getSettingByKey(List<SystemSetting> settings, String key) {
    try {
      return settings.firstWhere((s) => s.key == key).value;
    } catch (_) {
      return {};
    }
  }

  Widget _buildSettingCard(BuildContext context, WidgetRef ref, {required String title, required IconData icon, required String settingKey, required Map<String, dynamic> currentValue, required Map<String, String> fields}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.1), child: Icon(icon, color: Colors.blue, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(currentValue.values.where((v) => v != null).join(' - '), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.edit_note, color: Colors.blue),
        onTap: () => _showEditDialog(context, ref, settingKey, currentValue, fields),
      ),
    );
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
          title: Text('تعديل $key'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields.entries.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(controller: controllers[f.key], decoration: InputDecoration(labelText: f.value, border: const OutlineInputBorder())),
              )).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final newValue = <String, dynamic>{};
                controllers.forEach((k, v) => newValue[k] = v.text);
                await ref.read(settingsControllerProvider.notifier).updateSetting(key, newValue);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
