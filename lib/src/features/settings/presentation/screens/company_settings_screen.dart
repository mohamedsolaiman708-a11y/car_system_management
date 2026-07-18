import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings_controller.dart';
import '../../domain/company_settings.dart';
import '../../domain/system_setting.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';

class CompanySettingsScreen extends ConsumerStatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  ConsumerState<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends ConsumerState<CompanySettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _profitRatioController;
  late TextEditingController _taxNumberController;
  late TextEditingController _crNumberController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _profitRatioController = TextEditingController();
    _taxNumberController = TextEditingController();
    _crNumberController = TextEditingController();
    _websiteController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _profitRatioController.dispose();
    _taxNumberController.dispose();
    _crNumberController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('إعدادات المنشأة والنظام'),
          centerTitle: true,
          actions: [
            if (!settingsAsync.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('حفظ الإعدادات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(backgroundColor: Colors.green.shade700),
                ),
              ),
          ],
        ),
        body: settingsAsync.when(
          data: (settingsList) {
            final defaultSetting = SystemSetting(
              id: '',
              key: 'company_profile',
              value: const {
                'companyName': '',
                'address': '',
                'phone': '',
                'email': '',
                'defaultProfitRatio': 15.0,
                'tax_number': '',
                'cr_number': '',
                'website': '',
              },
              updatedAt: DateTime.now(),
            );
            final companySetting = settingsList.firstWhere(
              (s) => s.key == 'company_profile',
              orElse: () => defaultSetting,
            );

            final currentSettings = CompanySettings.fromJson(companySetting.value);

            if (_nameController.text.isEmpty) {
              _nameController.text = currentSettings.companyName;
              _addressController.text = currentSettings.address;
              _phoneController.text = currentSettings.phone;
              _emailController.text = currentSettings.email;
              _profitRatioController.text = currentSettings.defaultProfitRatio.toString();
              _taxNumberController.text = currentSettings.taxNumber;
              _crNumberController.text = currentSettings.crNumber;
              _websiteController.text = currentSettings.website;
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'المعلومات القانونية والتجارية',
                    icon: Icons.gavel_rounded,
                    children: [
                      _buildTextField(_nameController, 'الاسم التجاري للمنشأة'),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_crNumberController, 'رجم السجل التجاري (CR)')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(_taxNumberController, 'الرقم الضريبي (VAT)')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'معلومات الاتصال',
                    icon: Icons.contact_mail_rounded,
                    children: [
                      _buildTextField(_addressController, 'العنوان الوطني / المقر الرئيسي'),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_phoneController, 'رقم الهاتف الموحد')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(_emailController, 'البريد الإلكتروني الرسمي')),
                        ],
                      ),
                      _buildTextField(_websiteController, 'الموقع الإلكتروني'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'الإعدادات المالية الافتراضية',
                    icon: Icons.account_balance_wallet_rounded,
                    children: [
                      _buildTextField(_profitRatioController, 'نسبة ربح الشركة الافتراضية للتمويل (%)', isNumber: true),
                      const Text(
                        'ملاحظة: هذه النسبة يتم اقتراحها عند إنشاء عقود جديدة ويمكن تعديلها لكل عقد على حدة.',
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'التحكم في الوصول والصيانة',
                    icon: Icons.admin_panel_settings_rounded,
                    children: [
                      _buildMaintenanceToggle(),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
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

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade700]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Icon(Icons.business_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('هوية المنشأة', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('قم بتحديث بيانات شركتك التي ستظهر في التقارير والفواتير والعقود.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade800, size: 22),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (val) => val == null || val.isEmpty ? 'هذا الحقل مطلوب لسلامة البيانات' : null,
      ),
    );
  }

  Widget _buildMaintenanceToggle() {
    final isMaintenance = ref.watch(isMaintenanceModeProvider).value ?? false;

    return Container(
      decoration: BoxDecoration(
        color: isMaintenance ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        title: Text(
          'وضع الصيانة العام',
          style: TextStyle(fontWeight: FontWeight.bold, color: isMaintenance ? Colors.red.shade900 : Colors.green.shade900),
        ),
        subtitle: const Text('عند التفعيل، يقتصر دخول النظام على مدراء النظام فقط (Admins) لحماية البيانات أثناء التحديثات.', style: TextStyle(fontSize: 11)),
        value: isMaintenance,
        activeThumbColor: Colors.red.shade700,
        onChanged: (val) {
          ref.read(settingsControllerProvider.notifier).toggleMaintenance(val, 'النظام قيد الصيانة المجدولة حالياً لضمان جودة الخدمة. نعتذر عن الإزعاج.');
        },
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'companyName': _nameController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'defaultProfitRatio': double.tryParse(_profitRatioController.text) ?? 15.0,
        'tax_number': _taxNumberController.text,
        'cr_number': _crNumberController.text,
        'website': _websiteController.text,
      };

      try {
        await ref.read(settingsControllerProvider.notifier).updateSetting('company_profile', updatedData);
        if (mounted) {
          SnackBarHelper.showSuccess(context, 'تم تحديث إعدادات المنشأة بنجاح');
        }
      } catch (e) {
        if (mounted) {
          SnackBarHelper.showError(context, e);
        }
      }
    }
  }
}
