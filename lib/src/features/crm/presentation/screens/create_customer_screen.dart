import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../crm_controller.dart';

class CreateCustomerScreen extends ConsumerStatefulWidget {
  const CreateCustomerScreen({super.key});

  @override
  ConsumerState<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends ConsumerState<CreateCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for top-level schema fields
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController(); // Matches schema 'phone'
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Controllers for KYC data (stored in kyc_data JSONB)
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
      'full_name': _fullNameController.text,
      'national_id': _nationalIdController.text,
      'phone': _phoneController.text,
      'email': _emailController.text.isEmpty ? null : _emailController.text,
      'address': _addressController.text.isEmpty ? null : _addressController.text,
      'risk_rating': _riskRating,
      'kyc_data': {
        'alt_phone': _altPhoneController.text,
        'city': _cityController.text,
        'employer': _employerController.text,
        'job_title': _jobTitleController.text,
        'salary': double.tryParse(_salaryController.text) ?? 0.0,
        'guarantor': {
          'name': _guarantorNameController.text,
          'phone': _guarantorPhoneController.text,
          'relationship': _guarantorRelationshipController.text,
        },
        'notes': _notesController.text,
      },
    };

    await ref.read(crmControllerProvider.notifier).createCustomer(data);
    
    if (mounted && !ref.read(crmControllerProvider).hasError) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة العميل بنجاح'), backgroundColor: Colors.green),
      );
      ref.invalidate(customersListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عميل جديد'),
      ),
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('المعلومات الأساسية (حسب الهوية)'),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'الاسم الكامل *', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nationalIdController,
                    decoration: const InputDecoration(labelText: 'رقم الهوية الوطنية *', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                      if (v.length != 10) return 'رقم الهوية يجب أن يكون 10 أرقام';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('معلومات التواصل'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'رقم الجوال الأساسي *', border: OutlineInputBorder()),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _altPhoneController,
                          decoration: const InputDecoration(labelText: 'رقم جوال بديل', border: OutlineInputBorder()),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('العنوان والسكن'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'المدينة', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(labelText: 'العنوان بالتفصيل', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('العمل والدخل'),
                  TextFormField(
                    controller: _employerController,
                    decoration: const InputDecoration(labelText: 'جهة العمل', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _jobTitleController,
                          decoration: const InputDecoration(labelText: 'المسمى الوظيفي', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _salaryController,
                          decoration: const InputDecoration(labelText: 'الراتب الشهري', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('معلومات الضامن الكفيل'),
                  TextFormField(
                    controller: _guarantorNameController,
                    decoration: const InputDecoration(labelText: 'اسم الضامن', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _guarantorPhoneController,
                          decoration: const InputDecoration(labelText: 'رقم جوال الضامن', border: OutlineInputBorder()),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _guarantorRelationshipController,
                          decoration: const InputDecoration(labelText: 'صلة القرابة', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('تقييم المخاطر المبدئي'),
                  DropdownButtonFormField<String>(
                    value: _riskRating,
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('منخفض المخاطر')),
                      DropdownMenuItem(value: 'medium', child: Text('متوسط المخاطر')),
                      DropdownMenuItem(value: 'high', child: Text('عالي المخاطر')),
                    ],
                    onChanged: (v) => setState(() => _riskRating = v!),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('ملاحظات الموظف'),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('حفظ بيانات العميل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }
}
