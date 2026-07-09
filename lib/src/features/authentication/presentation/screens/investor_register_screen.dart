import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:car_system_management/l10n/app_localizations.dart';
import 'package:car_system_management/src/features/authentication/presentation/auth_controller.dart';
import 'package:car_system_management/src/features/authentication/presentation/widgets/auth_layout.dart';

class InvestorRegisterScreen extends ConsumerStatefulWidget {
  const InvestorRegisterScreen({super.key});

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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى التأكد من صحة جميع البيانات المدخلة')),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).registerInvestor(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          nationalId: _nationalIdController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    if (success && mounted) {
      context.go('/auth/pending');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final authState = ref.watch(authControllerProvider);

    // إضافة مستمع للأخطاء لإظهارها للمستخدم
    ref.listen<AsyncValue>(
      authControllerProvider,
      (previous, next) {
        if (next.hasError && !next.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error.toString()),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );

    return AuthLayout(
      title: 'تسجيل مستثمر جديد',
      subtitle: 'انضم إلينا لتبدأ رحلتك الاستثمارية في تمويل السيارات',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل كما في الهوية',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (val) => (val == null || val.isEmpty) ? 'هذا الحقل مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
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
                    decoration: const InputDecoration(
                      labelText: 'رقم الجوال',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (val) => (val == null || val.isEmpty) ? 'مطلوب' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _nationalIdController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهوية',
                      border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (val) => (val == null || val.length < 6) ? 'كلمة المرور قصيرة جداً' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                prefixIcon: Icon(Icons.lock_reset),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (val) => (val != _passwordController.text) ? 'كلمات المرور غير متطابقة' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF1B3A5B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                disabledBackgroundColor: const Color(0xFF1B3A5B).withOpacity(0.6),
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('إنشاء الحساب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/auth/investor/login'),
              child: const Text('لديك حساب بالفعل؟ سجل دخولك'),
            ),
          ],
        ),
      ),
    );
  }
}
