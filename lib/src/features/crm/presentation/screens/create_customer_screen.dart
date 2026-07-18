import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../crm_controller.dart';

class CreateCustomerScreen extends ConsumerStatefulWidget {
  const CreateCustomerScreen({super.key});

  @override
  ConsumerState<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends ConsumerState<CreateCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  final _altPhoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _employerController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _salaryController = TextEditingController();
  final _guarantorNameController = TextEditingController();
  final _guarantorPhoneController = TextEditingController();
  final _guarantorRelationshipController = TextEditingController();
  final _notesController = TextEditingController();

  String _riskRating = 'medium';

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _altPhoneController.dispose();
    _cityController.dispose();
    _employerController.dispose();
    _jobTitleController.dispose();
    _salaryController.dispose();
    _guarantorNameController.dispose();
    _guarantorPhoneController.dispose();
    _guarantorRelationshipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'full_name': _fullNameController.text.trim(),
      'national_id': _nationalIdController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.isEmpty ? null : _emailController.text.trim(),
      'address': _addressController.text.isEmpty ? null : _addressController.text.trim(),
      'risk_rating': _riskRating,
      'kyc_data': {
        'alt_phone': _altPhoneController.text.trim(),
        'city': _cityController.text.trim(),
        'employer': _employerController.text.trim(),
        'job_title': _jobTitleController.text.trim(),
        'salary': double.tryParse(_salaryController.text) ?? 0.0,
        'guarantor': {
          'name': _guarantorNameController.text.trim(),
          'phone': _guarantorPhoneController.text.trim(),
          'relationship': _guarantorRelationshipController.text.trim(),
        },
        'notes': _notesController.text.trim(),
      },
    };

    await ref.read(crmControllerProvider.notifier).createCustomer(data);
    final state = ref.read(crmControllerProvider);

    if (mounted) {
      if (state.hasError) {
        SnackBarHelper.showError(context, state.error);
      } else {
        context.pop();
        SnackBarHelper.showSuccess(context, 'تم تسجيل العميل بنجاح في قاعدة البيانات');
        ref.invalidate(customersListProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('تسجيل ملف ائتماني جديد',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy))
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildFormHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSectionCard(
                      title: 'الهوية والمعلومات الشخصية',
                      icon: Icons.badge_rounded,
                      children: [
                        _buildPremiumTextField(
                          controller: _fullNameController,
                          label: 'الاسم الكامل (كما في الهوية)',
                          prefixIcon: Icons.person_rounded,
                          validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال الاسم الكامل' : null,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPremiumTextField(
                                controller: _nationalIdController,
                                label: 'رقم الهوية الوطنية',
                                prefixIcon: Icons.fingerprint_rounded,
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.length != 10) ? 'يجب أن يكون 10 أرقام' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPremiumTextField(
                                controller: _cityController,
                                label: 'المدينة',
                                prefixIcon: Icons.location_city_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildPremiumTextField(
                          controller: _addressController,
                          label: 'العنوان بالتفصيل',
                          prefixIcon: Icons.map_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      title: 'معلومات التواصل والدخل',
                      icon: Icons.contact_mail_rounded,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildPremiumTextField(
                                controller: _phoneController,
                                label: 'رقم الجوال الأساسي',
                                prefixIcon: Icons.phone_android_rounded,
                                keyboardType: TextInputType.phone,
                                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPremiumTextField(
                                controller: _altPhoneController,
                                label: 'رقم بديل (اختياري)',
                                prefixIcon: Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildPremiumTextField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني',
                          prefixIcon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        _buildPremiumTextField(
                          controller: _employerController,
                          label: 'جهة العمل / المؤسسة',
                          prefixIcon: Icons.business_rounded,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPremiumTextField(
                                controller: _jobTitleController,
                                label: 'المسمى الوظيفي',
                                prefixIcon: Icons.work_outline_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPremiumTextField(
                                controller: _salaryController,
                                label: 'الراتب الشهري',
                                prefixIcon: Icons.payments_rounded,
                                suffix: const Text('ر.س', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      title: 'الضمانات والتقييم الائتماني',
                      icon: Icons.gpp_good_rounded,
                      children: [
                        _buildPremiumTextField(
                          controller: _guarantorNameController,
                          label: 'اسم الضامن (الكفيل)',
                          prefixIcon: Icons.person_pin_rounded,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPremiumTextField(
                                controller: _guarantorPhoneController,
                                label: 'جوال الضامن',
                                prefixIcon: Icons.phone_iphone_rounded,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPremiumTextField(
                                controller: _guarantorRelationshipController,
                                label: 'صلة القرابة',
                                prefixIcon: Icons.people_outline_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('تصنيف المخاطر المبدئي',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy)),
                        const SizedBox(height: 12),
                        _buildRiskSelector(),
                      ],
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        shadowColor: AppColors.primaryNavy.withValues(alpha: 0.4),
                      ),
                      child: const Text('حفظ واعتماد ملف العميل',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('إلغاء العملية والعودة', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('نموذج تسجيل متعامل',
              style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          const Text('إدخال البيانات الديموغرافية والائتمانية',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('يرجى التأكد من مطابقة البيانات للوثائق الرسمية لضمان دقة التقييم الائتماني.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.accentGold, size: 20),
              ),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            ],
          ),
          const SizedBox(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, size: 20, color: Colors.grey.shade400),
        suffix: suffix,
        filled: true,
        fillColor: AppColors.bgGrey.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5)),
      ),
    );
  }

  Widget _buildRiskSelector() {
    return Row(
      children: [
        _RiskOption(label: 'منخفضة', value: 'low', color: Colors.green, groupValue: _riskRating, onChanged: (v) => setState(() => _riskRating = v)),
        const SizedBox(width: 12),
        _RiskOption(label: 'متوسطة', value: 'medium', color: Colors.orange, groupValue: _riskRating, onChanged: (v) => setState(() => _riskRating = v)),
        const SizedBox(width: 12),
        _RiskOption(label: 'عالية', value: 'high', color: Colors.red, groupValue: _riskRating, onChanged: (v) => setState(() => _riskRating = v)),
      ],
    );
  }
}

class _RiskOption extends StatelessWidget {
  final String label, value, groupValue;
  final Color color;
  final Function(String) onChanged;

  const _RiskOption({required this.label, required this.value, required this.color, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.grey.shade200),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            )),
          ),
        ),
      ),
    );
  }
}
