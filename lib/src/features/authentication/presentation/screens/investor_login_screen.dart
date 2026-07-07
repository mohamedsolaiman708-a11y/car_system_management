import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../auth_controller.dart';
import '../widgets/auth_layout.dart';

class InvestorLoginScreen extends ConsumerStatefulWidget {
  const InvestorLoginScreen({super.key});

  @override
  ConsumerState<InvestorLoginScreen> createState() => _InvestorLoginScreenState();
}

class _InvestorLoginScreenState extends ConsumerState<InvestorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );

    // If login is successful, GoRouter's redirect logic in app_router.dart 
    // will automatically handle the navigation based on the user's status.
    if (success && mounted) {
      // Navigation is reactive
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);

    return AuthLayout(
      title: 'دخول المستثمرين',
      subtitle: 'قم بتسجيل الدخول لمتابعة محفظتك الاستثمارية وأرباحك',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  hintText: 'example@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'البريد الإلكتروني مطلوب';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                    return 'صيغة البريد الإلكتروني غير صحيحة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  hintText: '********',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: _obscurePassword,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'كلمة المرور مطلوبة';
                  return null;
                },
              ),
              
              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (val) => setState(() => _rememberMe = val ?? false),
                      ),
                      const Text('تذكرني'),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.push('/auth/forgot-password'),
                    child: const Text('نسيت كلمة المرور؟'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Error Message
              if (authState.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _getErrorMessage(authState.error),
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                
              // Login Button
              ElevatedButton(
                onPressed: authState.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF1B3A5B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('تسجيل الدخول', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('أو', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 32),
              
              // Create Account Section
              const Text(
                'ليس لديك حساب؟',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.push('/auth/investor/register'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF1B3A5B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('إنشاء حساب مستثمر جديد', style: TextStyle(color: Color(0xFF1B3A5B))),
              ),
              const SizedBox(height: 16),
              
              // Back Button
              TextButton.icon(
                onPressed: () => context.go('/portal-selection'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('العودة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(Object? error) {
    // Implement friendly Arabic messages based on backend errors
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (errorStr.contains('email not confirmed')) {
      return 'يرجى تأكيد البريد الإلكتروني أولاً';
    }
    return 'حدث خطأ أثناء تسجيل الدخول. يرجى المحاولة مرة أخرى';
  }
}
