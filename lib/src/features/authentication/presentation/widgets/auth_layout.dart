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
      backgroundColor: const Color(0xFFF5F7FA), // خلفية كلاسيكية هادئة
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BrandLogo(scale: 0.7),
                const SizedBox(height: 32),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: _buildClassicInputTheme(),
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecorationTheme _buildClassicInputTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      prefixIconColor: AppColors.primaryNavy,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryNavy, width: 1.5),
      ),
    );
  }
}
