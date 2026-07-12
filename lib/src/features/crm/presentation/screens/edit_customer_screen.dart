import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    await ref.read(crmControllerProvider.notifier).updateCustomer(widget.id, data);

    if (mounted && !ref.read(crmControllerProvider).hasError) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث بيانات العميل بنجاح'), backgroundColor: Colors.green),
      );
      ref.invalidate(customerDetailsProvider(widget.id));
      ref.invalidate(customersListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerAsync = ref.watch(customerDetailsProvider(widget.id));
    final state = ref.watch(crmControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات العميل'),
      ),
      body: customerAsync.when(
        data: (customer) {
          if (customer == null) return const Center(child: Text('العميل غير موجود'));
          _initFields(customer);

          return state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('المعلومات الأساسية'),
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

                  _buildSectionTitle('معلومات الضامن'),
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

                  _buildSectionTitle('تقييم المخاطر'),
                  DropdownButtonFormField<String>(
                    value: _riskRating,
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                      DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                      DropdownMenuItem(value: 'high', child: Text('عالية')),
                    ],
                    onChanged: (v) => setState(() => _riskRating = v!),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('ملاحظات'),
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
                      onPressed: _update,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('تحديث بيانات العميل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
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
