import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../../../../core/utils/app_theme.dart';

class AccountRejectedScreen extends ConsumerWidget {
  const AccountRejectedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthLayout(
      title: 'تم رفض طلب الانضمام',
      subtitle: 'نعتذر منك، لم تتم الموافقة على طلب تفعيل حسابك من قبل الإدارة في الوقت الحالي.',
      child: Column(
        children: [
          const Icon(Icons.block_rounded, size: 64, color: AppColors.errorRed),
          const SizedBox(height: 32),
          const Text(
            'لمزيد من التفاصيل أو للاعتراض، يرجى التواصل مع الدعم الفني للمؤسسة.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('تسجيل الخروج والعودة', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
