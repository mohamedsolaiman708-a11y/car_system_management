import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../widgets/brand_logo.dart';

class PortalSelectionScreen extends StatelessWidget {
  const PortalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14), 
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const BrandLogo(scale: 1.2),
                  const SizedBox(height: 60),
                  
                  const Text(
                    'مرحباً بك في المنصة الذكية لإدارة الأصول',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'اختر الهوية المخصصة للمتابعة والوصول إلى الأدوات',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 60),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPortalCard(
                        context,
                        title: 'بوابة الإدارة والموظفين',
                        subtitle: 'العمليات، المحاسبة، والرقابة',
                        icon: Icons.admin_panel_settings_rounded,
                        color: AppColors.accentGold,
                        path: '/auth/staff/login',
                      ),
                      const SizedBox(width: 32),
                      _buildPortalCard(
                        context,
                        title: 'بوابة شركاء الاستثمار',
                        subtitle: 'المحافظ المالية، الأرباح، والتقارير',
                        icon: Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        path: '/auth/investor/login',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 70),
                  Text(
                    'نظام السامي لإدارة تمويل السيارات © 2026',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, letterSpacing: 2),
                  ),
                ],
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
    required String path,
  }) {
    return InkWell(
      onTap: () => context.push(path),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 320,
        height: 280,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: color, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
            const SizedBox(height: 24),
            Icon(Icons.arrow_forward_rounded, color: color.withOpacity(0.3), size: 20),
          ],
        ),
      ),
    );
  }
}
