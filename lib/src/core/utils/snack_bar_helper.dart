import 'package:flutter/material.dart';
import './app_theme.dart';
import './error_handler.dart';

class SnackBarHelper {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: AppColors.successGreen,
    );
  }

  static void showError(BuildContext context, dynamic error) {
    final failure = Failure.fromException(error);
    _showSnackBar(
      context,
      message: failure.message,
      icon: Icons.error_outline_rounded,
      backgroundColor: AppColors.errorRed,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: Colors.orange.shade700,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: AppColors.primaryNavy,
    );
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
  }) {
    // Clear existing SnackBars to prevent queue buildup
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    final double? snackBarWidth = isWideScreen ? 480.0 : null;
    final EdgeInsetsGeometry? snackBarMargin = isWideScreen ? null : const EdgeInsets.all(16);

    messenger.showSnackBar(
      SnackBar(
        width: snackBarWidth,
        margin: snackBarMargin,
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        duration: const Duration(seconds: 4),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
