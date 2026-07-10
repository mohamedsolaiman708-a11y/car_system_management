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
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
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
    // ننتظر قليلاً لإظهار الهوية البصرية (اللوغو) بفخامة
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
      backgroundColor: const Color(0xFF0A1227), // لون كحلي أغمق وأفخم للـ Splash
      body: Stack(
        children: [
          // تدرج لوني خفيف في الخلفية لإعطاء عمق
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  const Color(0xFF162A4D).withOpacity(0.3),
                  const Color(0xFF0A1227),
                ],
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const BrandLogo(scale: 1.2), // تكبير اللوجو في الإسبلاش ليملأ العين
              ),
            ),
          ),
          // مؤشر تحميل هادئ في الأسفل
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(
                    width: 40,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white10,
                      color: Color(0xFFC5A35E),
                      minHeight: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'جارٍ تهيئة النظام...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
