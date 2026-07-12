import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:car_system_management/l10n/app_localizations.dart';
import '../../data/supabase_auth_repository.dart';
import '../auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../../domain/user_role.dart';
import '../../../../core/utils/app_theme.dart';

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
      final updatedUser = await ref.read(authRepositoryProvider).getCurrentUser();
      if (!mounted) return;

      if (updatedUser == null) {
        setState(() => _isChecking = false);
        return;
      }

      if (updatedUser.status == 'approved' || updatedUser.status == 'active') {
        if (updatedUser.role == UserRole.investor) {
          context.go('/investor-portal');
        } else {
          context.go('/dashboard');
        }
      } else if (updatedUser.status == 'rejected') {
        context.go('/auth/rejected');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الطلب لا يزال تحت المراجعة من قبل الإدارة')),
        );
        setState(() => _isChecking = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'طلبك قيد المراجعة',
      subtitle: 'شكراً لتسجيلك. يتم حالياً مراجعة بياناتك من قبل الإدارة لتفعيل الحساب.',
      child: Column(
        children: [
          const Icon(Icons.hourglass_bottom_rounded, size: 64, color: AppColors.accentGold),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isChecking ? null : _checkStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: _isChecking 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('تحديث حالة الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            child: const Text('تسجيل الخروج والعودة', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
