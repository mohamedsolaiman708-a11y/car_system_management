import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth_controller.dart';
import '../widgets/brand_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack)),
    );

    _controller.forward();
    _startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startApp() async {
    // انتظار 4 ثواني لترك انطباع قوي بالهوية البصرية الفخمة
    await Future.delayed(const Duration(seconds: 4));
    
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    
    if (authState.hasValue) {
      final user = authState.value;
      if (user == null) {
        context.go('/portal-selection');
      } else {
        if (user.role.name == 'investor') {
          context.go('/investor-portal');
        } else {
          context.go('/dashboard');
        }
      }
    } else {
      context.go('/portal-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1227), // لون كحلي ملكي عميق
      body: Stack(
        children: [
          // تدرج لوني في الخلفية لإعطاء عمق وفخامة
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  const Color(0xFF1A2E5A).withOpacity(0.4),
                  const Color(0xFF0A1227),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: const BrandLogo(scale: 1.5), // اللوجو الذهبي الفخم بحجم كبير في الإسبلاش
                  ),
                ),
                const SizedBox(height: 60),
                // مؤشر تحميل هادئ وأنيق
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: Color(0xFFC5A35E),
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // جملة ترحيبية في الأسفل
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'السامي للسيارات - الريادة في حلول التمويل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white10,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
