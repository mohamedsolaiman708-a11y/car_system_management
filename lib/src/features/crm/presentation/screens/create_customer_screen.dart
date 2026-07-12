import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
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
    
    if (mounted && !ref.read(crmControllerProvider).hasError) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل العميل بنجاح')));
      ref.invalidate(customersListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('تسجيل عميل جديد', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildClassicSection('المعلومات الشخصية', [
                    _buildField(_fullNameController, 'الاسم الكامل كما في الهوية *'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _buildField(_nationalIdController, 'رقم الهوية *', isNumber: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField(_phoneController, 'رقم الجوال *', isNumber: true)),
                    ]),
                  ]),
                  const SizedBox(height: 16),
                  _buildClassicSection('بيانات العمل والدخل', [
                    _buildField(_employerController, 'جهة العمل'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _buildField(_jobTitleController, 'المسمى الوظيفي')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField(_salaryController, 'الراتب الشهري', isNumber: true)),
                    ]),
                  ]),
                  const SizedBox(height: 16),
                  _buildClassicSection('الضامن (الكفيل)', [
                    _buildField(_guarantorNameController, 'اسم الضامن'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _buildField(_guarantorPhoneController, 'جوال الضامن', isNumber: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField(_guarantorRelationshipController, 'صلة القرابة')),
                    ]),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                      child: const Text('حفظ ملف العميل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildClassicSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const Divider(height: 24),
        ...children,
      ]),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => (v == null || v.isEmpty) && label.contains('*') ? 'مطلوب' : null,
    );
  }
}
