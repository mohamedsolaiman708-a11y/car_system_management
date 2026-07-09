import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B3E);
  static const Color accentGold = Color(0xFFC5A35E);
  static const Color secondaryNavy = Color(0xFF1A294D);
  static const Color bgGrey = Color(0xFFF4F7FE);
  static const Color surfaceWhite = Colors.white;
  static const Color textMain = Color(0xFF0D1B3E);
  static const Color textGrey = Color(0xFF8A94A6);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color errorRed = Color(0xFFEB5757);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryNavy,
        primary: AppColors.primaryNavy,
        secondary: AppColors.accentGold,
        surface: AppColors.surfaceWhite,
        background: AppColors.bgGrey,
      ),
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: AppColors.bgGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.primaryNavy),
        titleTextStyle: TextStyle(
          color: AppColors.primaryNavy,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56), // طول مريح للضغط
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2, // إضافة ظل عشان تحس إنه زرار حقيقي
          shadowColor: AppColors.primaryNavy.withOpacity(0.5),
        ).copyWith(
          // إضافة تأثير "النبضة" لما تضغط
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withOpacity(0.15);
              }
              return null;
            },
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryNavy, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
      ),
    );
  }
}
