import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    // ننتظر قليلاً لإظهار الهوية البصرية (اللوغو)
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // فحص الحالة الحالية
    final authState = ref.read(authStateProvider);
    
    // إذا اكتمل التحميل ولم يقم الـ Router بالتوجيه تلقائياً، نقوم به يدوياً هنا
    if (authState.hasValue) {
      final user = authState.value;
      if (user == null) {
        context.go('/portal-selection');
      } else {
        // الـ Router سيتكفل بالباقي، ولكن للتأكيد:
        if (user.role.name == 'investor') {
          context.go('/investor-portal');
        } else {
          context.go('/dashboard');
        }
      }
    } else {
      // في حالة التأخر الشديد أو الخطأ، نتوجه لصفحة الدخول كإجراء احترازي
      context.go('/portal-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E), // اللون الكحلي الرسمي للعميل
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة السيارة الرسمية كما في الصور
            const Icon(
              Icons.directions_car_filled_rounded,
              size: 100,
              color: Color(0xFFC5A35E), // اللون الذهبي
            ),
            const SizedBox(height: 24),
            const Text(
              'نظام السامي لإدارة التمويل',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Color(0xFFC5A35E),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
