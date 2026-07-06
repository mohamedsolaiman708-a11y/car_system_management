import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../widgets/auth_layout.dart';

class SessionExpiredScreen extends StatelessWidget {
  const SessionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthLayout(
      title: l10n.sessionExpired,
      subtitle: 'يرجى تسجيل الدخول مرة أخرى لمواصلة استخدام التطبيق',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.history_toggle_off_rounded,
            size: 100,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/portal-selection'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF0A192F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.login),
          ),
        ],
      ),
    );
  }
}
