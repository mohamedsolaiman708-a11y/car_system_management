import 'package:flutter/material.dart';
import 'package:car_system_management/src/core/utils/app_theme.dart';
import 'brand_logo.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const AuthLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية كحلية ملكية عميقة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF040B1A), Color(0xFF0D1B3E)],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 460,
                  ), // عرض ملموم أكثر
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // اللوجو بحجم ملموم واحترافي
                      const BrandLogo(scale: 0.8),
                      const SizedBox(height: 24), 
                      // كرت البيانات بتصميم زجاجي رشيق
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ), 
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22, 
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Cairo',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                subtitle!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 24), 
                            // تغليف المدخلات بالثيم المودرن وتعديل لون الخط
                            Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme: _buildDarkInputTheme(),
                                // هذا الجزء يضمن أن النص المكتوب سيكون أبيض
                                textTheme: Theme.of(context).textTheme.copyWith(
                                  bodyLarge: const TextStyle(color: Colors.white),
                                  bodyMedium: const TextStyle(color: Colors.white),
                                ),
                                textSelectionTheme: const TextSelectionThemeData(
                                  cursorColor: AppColors.accentGold,
                                  selectionColor: AppColors.accentGold,
                                  selectionHandleColor: AppColors.accentGold,
                                ),
                              ),
                              child: child,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecorationTheme _buildDarkInputTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
      floatingLabelStyle: const TextStyle(color: AppColors.accentGold, fontSize: 14),
      prefixIconColor: AppColors.accentGold,
      suffixIconColor: AppColors.accentGold,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ), 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
      ),
    );
  }
}
