import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../../../../core/utils/error_handler.dart';
import '../../domain/customer.dart';
import '../crm_controller.dart';

class EditCustomerScreen extends ConsumerStatefulWidget {
  final String id;
  const EditCustomerScreen({super.key, required this.id});

  @override
  ConsumerState<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends ConsumerState<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _nationalIdController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  late TextEditingController _altPhoneController;
  late TextEditingController _cityController;
  late TextEditingController _employerController;
  late TextEditingController _jobTitleController;
  late TextEditingController _salaryController;
  late TextEditingController _guarantorNameController;
  late TextEditingController _guarantorPhoneController;
  late TextEditingController _guarantorRelationshipController;
  late TextEditingController _notesController;

  String _riskRating = 'medium';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _nationalIdController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _altPhoneController = TextEditingController();
    _cityController = TextEditingController();
    _employerController = TextEditingController();
    _jobTitleController = TextEditingController();
    _salaryController = TextEditingController();
    _guarantorNameController = TextEditingController();
    _guarantorPhoneController = TextEditingController();
    _guarantorRelationshipController = TextEditingController();
    _notesController = TextEditingController();
  }

  void _initFields(Customer customer) {
    if (_initialized) return;

    _fullNameController.text = customer.fullName;
    _nationalIdController.text = customer.nationalId;
    _phoneController.text = customer.phone;
    _emailController.text = customer.email ?? '';
    _addressController.text = customer.address ?? '';
    _riskRating = customer.riskRating;

    final kyc = customer.kycData;
    _altPhoneController.text = kyc['alt_phone']?.toString() ?? '';
    _cityController.text = kyc['city']?.toString() ?? '';
    _employerController.text = kyc['employer']?.toString() ?? '';
    _jobTitleController.text = kyc['job_title']?.toString() ?? '';
    _salaryController.text = kyc['salary']?.toString() ?? '';

    final guarantor = kyc['guarantor'] as Map<String, dynamic>? ?? {};
    _guarantorNameController.text = guarantor['name']?.toString() ?? '';
    _guarantorPhoneController.text = guarantor['phone']?.toString() ?? '';
    _guarantorRelationshipController.text = guarantor['relationship']?.toString() ?? '';
    _notesController.text = kyc['notes']?.toString() ?? '';

    _initialized = true;
  }

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

  Future<void> _update() async {
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

    await ref.read(crmControllerProvider.notifier).updateCustomer(widget.id, data);
    final state = ref.read(crmControllerProvider);

    if (mounted) {
      if (state.hasError) {
        SnackBarHelper.showError(context, state.error);
      } else {
        context.pop();
        SnackBarHelper.showSuccess(context, 'تم تحديث بيانات العميل بنجاح');
        ref.invalidate(customerDetailsProvider(widget.id));
        ref.invalidate(customersListProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerAsync = ref.watch(customerDetailsProvider(widget.id));
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
        title: const Text('تعديل الملف الائتماني',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: customerAsync.when(
        data: (customer) {
          if (customer == null) return const Center(child: Text('العميل غير موجود'));
          _initFields(customer);

          return state.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy))
              : SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Column(
                        children: [
                          _buildFormHeader(customer.fullName),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveLayout.isMobile(context) ? 16 : 32,
                              vertical: 24,
                            ),
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
                                      ResponsiveFormRow(
                                        children: [
                                          _buildPremiumTextField(
                                            controller: _nationalIdController,
                                            label: 'رقم الهوية الوطنية',
                                            prefixIcon: Icons.fingerprint_rounded,
                                            keyboardType: TextInputType.number,
                                            validator: (v) => (v == null || v.length != 10) ? 'يجب أن يكون 10 أرقام' : null,
                                          ),
                                          _buildPremiumTextField(
                                            controller: _cityController,
                                            label: 'المدينة',
                                            prefixIcon: Icons.location_city_rounded,
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
                                      ResponsiveFormRow(
                                        children: [
                                          _buildPremiumTextField(
                                            controller: _phoneController,
                                            label: 'رقم الجوال الأساسي',
                                            prefixIcon: Icons.phone_android_rounded,
                                            keyboardType: TextInputType.phone,
                                            validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                          ),
                                          _buildPremiumTextField(
                                            controller: _altPhoneController,
                                            label: 'رقم بديل (اختياري)',
                                            prefixIcon: Icons.phone_rounded,
                                            keyboardType: TextInputType.phone,
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
                                      ResponsiveFormRow(
                                        children: [
                                          _buildPremiumTextField(
                                            controller: _jobTitleController,
                                            label: 'المسمى الوظيفي',
                                            prefixIcon: Icons.work_outline_rounded,
                                          ),
                                          _buildPremiumTextField(
                                            controller: _salaryController,
                                            label: 'الراتب الشهري',
                                            prefixIcon: Icons.payments_rounded,
                                            suffix: const Text('ر.س', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            keyboardType: TextInputType.number,
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
                                      const SizedBox(height: 24),
                                      _buildPremiumTextField(
                                        controller: _notesController,
                                        label: 'ملاحظات وتوصيات ائتمانية',
                                        prefixIcon: Icons.notes_rounded,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),
                                  ElevatedButton.icon(
                                    onPressed: _update,
                                    icon: const Icon(Icons.check_circle_rounded, size: 22),
                                    label: const Text('تحديث وحفظ بيانات العميل',
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryNavy,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 60),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                      elevation: 4,
                                      shadowColor: AppColors.primaryNavy.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: const Text('إلغاء والتراجع', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              Failure.fromException(err).message,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(String name) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveLayout.isMobile(context) ? 20 : 32),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note_rounded, color: AppColors.accentGold, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'قسم إدارة العلاقات — تحديث البيانات',
                style: TextStyle(color: AppColors.accentGold, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'تعديل ملف العميل: $name',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveLayout.isMobile(context) ? 20 : 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'يرجى التأكد من مطابقة أي تعديلات للوثائق الرسمية المعتمدة.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryNavy.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.accentGold, size: 20),
              ),
              const SizedBox(width: 14),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            ],
          ),
          const SizedBox(height: 28),
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
        prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.primaryNavy),
        suffix: suffix,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
        ),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.grey.withValues(alpha: 0.2), width: isSelected ? 1.5 : 1),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
