import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings_controller.dart';
import '../../domain/company_settings.dart';
import '../../../../core/utils/app_theme.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('إعدادات هوية المنشأة', 
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: settingsAsync.when(
        data: (settingsList) {
          final companySetting = settingsList.firstWhere(
            (s) => s.key == 'company_profile',
            orElse: () => throw Exception('الإعدادات غير موجودة'),
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
                _buildClassicSection('المعلومات الرسمية', [
                  _buildSimpleField(_nameController, 'الاسم التجاري للمؤسسة'),
                  Row(children: [
                    Expanded(child: _buildSimpleField(_crNumberController, 'رقم السجل التجاري')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSimpleField(_taxNumberController, 'الرقم الضريبي')),
                  ]),
                ]),
                const SizedBox(height: 16),
                _buildClassicSection('قنوات التواصل', [
                  _buildSimpleField(_addressController, 'العنوان'),
                  Row(children: [
                    Expanded(child: _buildSimpleField(_phoneController, 'الهاتف')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSimpleField(_emailController, 'البريد الإلكتروني')),
                  ]),
                ]),
                const SizedBox(height: 16),
                _buildClassicSection('التفضيلات والتحكم', [
                  _buildSimpleField(_profitRatioController, 'نسبة الربح الافتراضية (%)', isNumber: true),
                  const SizedBox(height: 12),
                  _buildMaintenanceControl(),
                ]),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('حفظ كافة الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => const Center(child: Text('خطأ في التحميل')),
      ),
    );
  }

  Widget _buildClassicSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSimpleField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
      ),
    );
  }

  Widget _buildMaintenanceControl() {
    final isMaintenance = ref.watch(isMaintenanceModeProvider).value ?? false;
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: const Text('وضع الصيانة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: const Text('تقييد دخول النظام للمشرفين فقط', style: TextStyle(fontSize: 11)),
      value: isMaintenance,
      onChanged: (val) {
        ref.read(settingsControllerProvider.notifier).toggleMaintenance(val, 'النظام قيد الصيانة');
      },
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
      await ref.read(settingsControllerProvider.notifier).updateSetting('company_profile', updatedData);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ')));
    }
  }
}
