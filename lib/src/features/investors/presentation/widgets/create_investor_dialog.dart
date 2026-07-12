import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../investor_controller.dart';
import '../../../../core/utils/app_theme.dart';

class CreateInvestorDialog extends ConsumerStatefulWidget {
  const CreateInvestorDialog({super.key});

  @override
  ConsumerState<CreateInvestorDialog> createState() => _CreateInvestorDialogState();
}

class _CreateInvestorDialogState extends ConsumerState<CreateInvestorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text('تسجيل مستثمر جديد', 
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('إضافة بيانات المستثمر يدوياً للنظام المالي', 
                style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 20),
              _buildField(_nameController, 'الاسم الكامل للمستثمر *', Icons.person_outline),
              const SizedBox(height: 12),
              _buildField(_emailController, 'البريد الإلكتروني *', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildField(_phoneController, 'رقم الجوال (اختياري)', Icons.phone_android_rounded, keyboardType: TextInputType.phone),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: _isSubmitting 
              ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('إنشاء الحساب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        prefixIcon: Icon(icon, size: 18),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      validator: (val) {
        if (label.contains('*') && (val == null || val.isEmpty)) return 'مطلوب';
        if (label.contains('البريد') && val != null && !val.contains('@')) return 'بريد غير صحيح';
        return null;
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(investorListControllerProvider.notifier).createInvestor(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء ملف المستثمر بنجاح')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
