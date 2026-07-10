import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../data/supabase_auth_repository.dart';
import '../auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../../domain/user_role.dart';

class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);

    try {
      // جلب البروفايل مباشرة من قاعدة البيانات
      final updatedUser = await ref.read(authRepositoryProvider).getCurrentUser();

      if (!mounted) return;

      if (updatedUser == null) {
        setState(() => _isChecking = false);
        return;
      }

      if (updatedUser.status == 'approved') {
        // تم الموافقة — وجّه المستخدم للبوابة الصحيحة
        if (updatedUser.role == UserRole.investor) {
          context.go('/investor-portal');
        } else {
          context.go('/dashboard');
        }
      } else if (updatedUser.status == 'rejected') {
        context.go('/auth/rejected');
      } else {
        // لا يزال قيد الانتظار
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('طلبك لا يزال قيد المراجعة. يرجى الانتظار.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isChecking = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthLayout(
      title: l10n.pendingApprovalTitle,
      subtitle: l10n.pendingApprovalMessage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.hourglass_empty_rounded,
            size: 100,
            color: Colors.orange,
          ),
          const SizedBox(height: 32),
          // زر التحقق من الحالة
          ElevatedButton.icon(
            onPressed: _isChecking ? null : _checkStatus,
            icon: _isChecking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_rounded),
            label: Text(_isChecking ? 'جاري التحقق...' : 'تحقق من حالة الطلب'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFF1B3A5B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isChecking
                ? null
                : () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.backToLogin),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
