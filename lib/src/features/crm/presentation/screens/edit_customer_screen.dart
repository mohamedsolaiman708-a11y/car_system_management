import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
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
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _nationalIdController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmControllerProvider);
    final customerAsync = ref.watch(customerDetailsProvider(widget.id));

    // تعبئة البيانات بمجرد تحميلها من المزود
    customerAsync.whenData((customer) {
      if (customer != null && !_isInitialized) {
        _fullNameController.text = customer.fullName;
        _nationalIdController.text = customer.nationalId;
        _phoneController.text = customer.phone;
        _isInitialized = true;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('تعديل ملف العميل', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: customerAsync.when(
        data: (customer) {
          if (customer == null) return const Center(child: Text('العميل غير موجود'));
          
          return state.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildClassicSection('تحديث المعلومات الأساسية', [
                        _buildField(_fullNameController, 'الاسم الكامل'),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _buildField(_nationalIdController, 'رقم الهوية', isNumber: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildField(_phoneController, 'رقم الجوال', isNumber: true)),
                        ]),
                      ]),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await ref.read(crmControllerProvider.notifier).updateCustomer(widget.id, {
                                'full_name': _fullNameController.text.trim(),
                                'national_id': _nationalIdController.text.trim(),
                                'phone': _phoneController.text.trim(),
                              });
                              if (context.mounted) {
                                ref.invalidate(customerDetailsProvider(widget.id));
                                context.pop();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                          child: const Text('حفظ التعديلات', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ في تحميل بيانات العميل: $err')),
      ),
    );
  }

  Widget _buildClassicSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
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
    );
  }
}
