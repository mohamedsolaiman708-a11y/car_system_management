import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:car_system_management/src/features/authentication/presentation/auth_controller.dart';
import 'package:car_system_management/src/features/authentication/presentation/widgets/auth_layout.dart';

class InvestorRegisterScreen extends ConsumerStatefulWidget {
  final String type; // 'investor' أو 'staff'
  const InvestorRegisterScreen({super.key, this.type = 'investor'});

  @override
  ConsumerState<InvestorRegisterScreen> createState() => _InvestorRegisterScreenState();
}

class _InvestorRegisterScreenState extends ConsumerState<InvestorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).registerInvestor(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          nationalId: _nationalIdController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    if (success && mounted) {
      if (widget.type == 'staff') {
        context.go('/dashboard');
      } else {
        context.go('/auth/pending');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isStaff = widget.type == 'staff';
    const inputStyle = TextStyle(color: Colors.white, fontSize: 15);

    return AuthLayout(
      title: isStaff ? 'إنشاء حساب موظف' : 'تسجيل مستثمر جديد',
      subtitle: isStaff 
          ? 'مرحباً بك في فريق العمل، أكمل بياناتك لتفعيل حسابك' 
          : 'انضم إلينا لتبدأ رحلتك الاستثمارية في تمويل السيارات',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _fullNameController,
              style: inputStyle,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل كما في الهوية',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (val) => (val == null || val.isEmpty) ? 'هذا الحقل مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              style: inputStyle,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (val) => (val == null || !val.contains('@')) ? 'يرجى إدخال بريد إلكتروني صحيح' : null,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    style: inputStyle,
                    decoration: const InputDecoration(
                      labelText: 'رقم الجوال',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (val) => (val == null || val.isEmpty) ? 'مطلوب' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _nationalIdController,
                    style: inputStyle,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهوية',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => (val == null || val.length != 10) ? 'يجب أن يكون 10 أرقام' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              style: inputStyle,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (val) => (val == null || val.length < 6) ? 'كلمة المرور قصيرة جداً' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              style: inputStyle,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                prefixIcon: Icon(Icons.lock_reset),
              ),
              obscureText: true,
              validator: (val) => (val != _passwordController.text) ? 'كلمات المرور غير متطابقة' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(0xFF1B3A5B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: authState.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isStaff ? 'تفعيل الحساب والبدء' : 'إنشاء الحساب', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.go(isStaff ? '/auth/staff/login' : '/auth/investor/login'),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text('لديك حساب بالفعل؟ سجل دخولك'),
            ),
          ],
        ),
      ),
    );
  }
}
