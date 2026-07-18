import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../settings_controller.dart';
import '../../domain/system_setting.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../../authentication/domain/user_role.dart';
import '../../../audit/presentation/disaster_recovery_controller.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';

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
          title: const Text(
            'إعدادات النظام والشركة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryNavy,
        ),
        body: settingsAsync.when(
          data: (settings) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              _buildModernSection(
                title: 'المعلومات الأساسية للمؤسسة',
                children: [
                  _buildModernInfoCard(
                    context, ref,
                    title: 'بيانات التواصل الرسمية',
                    icon: Icons.business_center_rounded,
                    settingKey: 'company_profile',
                    data: _getSettingByKey(settings, 'company_profile'),
                    displayFields: {
                      'companyName': 'اسم المنشأة',
                      'cr_number': 'السجل التجاري',
                      'tax_number': 'الرقم الضريبي',
                      'phone': 'رقم التواصل',
                    },
                    fieldsToEdit: {
                      'companyName': 'اسم الشركة',
                      'address': 'العنوان الرسمي',
                      'phone': 'رقم التواصل',
                      'tax_number': 'الرقم الضريبي (VAT)',
                      'cr_number': 'رقم السجل التجاري',
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildModernSection(
                title: 'الإعدادات المالية والحوكمة',
                children: [
                  _buildModernInfoCard(
                    context, ref,
                    title: 'النسب الربحية والعملة',
                    icon: Icons.account_balance_wallet_rounded,
                    settingKey: 'profit_settings',
                    data: _getSettingByKey(settings, 'profit_settings'),
                    displayFields: {
                      'ratio': 'نسبة الربح الافتراضية',
                      'currency': 'العملة المعتمدة',
                    },
                    fieldsToEdit: {
                      'ratio': 'نسبة الربح (مثلاً 0.15 لـ 15%)',
                      'currency': 'رمز العملة (ر.س)',
                    },
                  ),
                ],
              ),

              if (user?.role == UserRole.admin) ...[
                const SizedBox(height: 32),
                _buildModernSection(
                  title: 'مركز التحكم في الأزمات والرقابة',
                  isCritical: true,
                  children: [
                    _buildEmergencyControlDashboard(context, ref, isFrozen, isMaintenance),
                    const SizedBox(height: 16),
                    _buildModernActionTile(
                      context,
                      title: 'فحص نزاهة البيانات المتقدم',
                      subtitle: 'مطابقة القيود المحاسبية آلياً مع أرصدة المستثمرين والعقود.',
                      icon: Icons.shield_outlined,
                      iconColor: Colors.green.shade700,
                      onTap: () => _confirmAction(context, 'بدء فحص النزاهة الشامل', Colors.green, () async {
                        await ref.read(disasterRecoveryControllerProvider.notifier).runIntegrityCheck();
                      }),
                    ),
                    const SizedBox(height: 12),
                    _buildModernActionTile(
                      context,
                      title: 'مراقبة المهام الخلفية',
                      subtitle: 'عرض وإدارة المهام المجدولة في الخلفية مثل التقارير والإشعارات.',
                      icon: Icons.history_toggle_off_rounded,
                      iconColor: Colors.indigo.shade700,
                      onTap: () => context.push('/settings/jobs'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
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
    );
  }

  Widget _buildModernSection({required String title, required List<Widget> children, bool isCritical = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, right: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: isCritical ? AppColors.errorRed : AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isCritical ? AppColors.errorRed : AppColors.primaryNavy,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildModernInfoCard(BuildContext context, WidgetRef ref, {
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryNavy.withValues(alpha: 0.6), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showEditDialog(context, ref, settingKey, data, fieldsToEdit),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('تعديل'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accentGold,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Wrap(
                  spacing: 40,
                  runSpacing: 20,
                  children: displayFields.entries.map((e) {
                    final value = data[e.key]?.toString() ?? 'غير محدد';
                    return SizedBox(
                      width: isWide ? (constraints.maxWidth - 120) / 3 : (constraints.maxWidth - 40) / 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.value,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            value,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.primaryNavy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyControlDashboard(BuildContext context, WidgetRef ref, bool isFrozen, bool isMaintenance) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildModernSwitchTile(
            title: 'تجميد العمليات المالية',
            subtitle: 'إيقاف فوري لكافة عمليات السداد والصرف في حالات الطوارئ.',
            value: isFrozen,
            activeColor: Colors.red,
            onChanged: (val) => _confirmAction(context, val ? 'تجميد النظام المالي' : 'إلغاء تجميد النظام', Colors.red, () async {
              await ref.read(disasterRecoveryControllerProvider.notifier).toggleFreeze(val);
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.red.withValues(alpha: 0.05)),
          ),
          _buildModernSwitchTile(
            title: 'وضع الصيانة العامة',
            subtitle: 'منع دخول المستخدمين للتطبيق أثناء التحديثات (باستثناء الإدارة).',
            value: isMaintenance,
            activeColor: Colors.orange.shade800,
            onChanged: (val) => _confirmAction(context, val ? 'تفعيل وضع الصيانة' : 'إيقاف وضع الصيانة', Colors.orange, () async {
              await ref.read(settingsControllerProvider.notifier).toggleMaintenance(val, 'النظام تحت الصيانة المجدولة حالياً');
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: value ? activeColor : AppColors.primaryNavy,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        value: value,
        activeColor: activeColor,
        activeTrackColor: activeColor.withValues(alpha: 0.2),
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildModernActionTile(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryNavy),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.primaryNavy),
          ],
        ),
      ),
    );
  }

  void _confirmAction(BuildContext context, String action, Color color, Future<void> Function() onConfirm) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(action, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('هذا الإجراء حساس ويؤثر على سير العمل بالكامل. هل أنت متأكد؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  try {
                    await onConfirm();
                    if (context.mounted) {
                      SnackBarHelper.showSuccess(context, 'تم تنفيذ العملية بنجاح ✅');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      SnackBarHelper.showError(context, e);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('تأكيد التنفيذ'),
              ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('تعديل الإعدادات', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: fields.entries.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: controllers[f.key],
                    decoration: InputDecoration(
                      labelText: f.value,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: () async {
                  final newValue = <String, dynamic>{...currentValue};
                  controllers.forEach((k, v) => newValue[k] = v.text);
                  await ref.read(settingsControllerProvider.notifier).updateSetting(key, newValue);
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('حفظ التعديلات'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
