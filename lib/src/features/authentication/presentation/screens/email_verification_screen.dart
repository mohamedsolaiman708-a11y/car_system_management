import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../widgets/auth_layout.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthLayout(
      title: l10n.emailVerification,
      subtitle: l10n.verifyEmailMessage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.mark_email_unread_outlined,
            size: 100,
            color: Color(0xFF1B3A5B),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/auth/investor/login'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF0A192F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.backToLogin),
          ),
        ],
      ),
    );
  }
}
