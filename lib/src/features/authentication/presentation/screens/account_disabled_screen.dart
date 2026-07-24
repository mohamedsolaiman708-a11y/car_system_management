import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_controller.dart';
import '../../../../core/utils/app_theme.dart';

class AccountDisabledScreen extends ConsumerWidget {
  const AccountDisabledScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block_flipped, size: 100, color: AppColors.errorRed),
                const SizedBox(height: 32),
                const Text(
                  'عذراً، هذا الحساب معطل حالياً',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'لقد تم إيقاف صلاحية الوصول الخاصة بك للنظام. يرجى التواصل مع المدير المسؤول لإعادة تفعيل الحساب.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('تسجيل الخروج والعودة للرئيسية'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
