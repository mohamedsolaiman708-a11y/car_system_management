import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../widgets/brand_logo.dart';

class PortalSelectionScreen extends StatelessWidget {
  const PortalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1227), // كحلي فاخر
      body: Stack(
        children: [
          // خلفية بتدرج ناعم
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF162A4D).withOpacity(0.2),
                  const Color(0xFF0A1227),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const BrandLogo(scale: 1.0), // اللوجو الفخم في المنتصف
                    const SizedBox(height: 60),
                    const Text(
                      'مرحباً بك في نظام السامي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'يرجى اختيار بوابة الدخول للمتابعة',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 50),
                    
                    // كروت الاختيار
                    _buildPortalCard(
                      context,
                      title: 'بوابة الموظفين',
                      subtitle: 'الإدارة، المحاسبة، والعمليات',
                      icon: Icons.admin_panel_settings_rounded,
                      color: AppColors.accentGold,
                      onTap: () => context.push('/auth/staff/login'),
                    ),
                    const SizedBox(height: 20),
                    _buildPortalCard(
                      context,
                      title: 'بوابة المستثمرين',
                      subtitle: 'متابعة الاستثمارات والأرباح',
                      icon: Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      onTap: () => context.push('/auth/investor/login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortalCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}
