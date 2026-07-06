import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../auth_controller.dart';
import '../widgets/auth_layout.dart';

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
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).registerInvestor(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _fullNameController.text,
          nationalId: _nationalIdController.text,
          phone: _phoneController.text,
        );

    if (success && mounted) {
      context.go('/auth/verify-email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);

    return AuthLayout(
      title: l10n.investorPortal,
      subtitle: l10n.register,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: l10n.fullName,
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(),
              ),
              validator: (val) =>
                  (val == null || val.isEmpty) ? l10n.errorFieldRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.email_outlined),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.isEmpty) return l10n.errorFieldRequired;
                if (!val.contains('@')) return l10n.errorInvalidEmail;
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (val) =>
                  (val == null || val.isEmpty) ? l10n.errorFieldRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nationalIdController,
              decoration: InputDecoration(
                labelText: l10n.nationalId,
                prefixIcon: const Icon(Icons.badge_outlined),
                border: const OutlineInputBorder(),
              ),
              validator: (val) =>
                  (val == null || val.isEmpty) ? l10n.errorFieldRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (val) {
                if (val == null || val.isEmpty) return l10n.errorFieldRequired;
                if (val.length < 6) return l10n.errorPasswordTooShort;
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: l10n.confirmPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (val) {
                if (val == null || val.isEmpty) return l10n.errorFieldRequired;
                if (val != _passwordController.text) return l10n.errorPasswordsDontMatch;
                return null;
              },
            ),
            const SizedBox(height: 24),
            if (authState.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  authState.error.toString(),
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
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
                  : Text(l10n.register),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/auth/investor/login'),
              child: Text(l10n.backToLogin),
            ),
          ],
        ),
      ),
    );
  }
}
