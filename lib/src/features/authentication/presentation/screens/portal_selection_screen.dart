import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth_controller.dart';
import '../../domain/user_role.dart';

class PortalSelectionScreen extends ConsumerWidget {
  const PortalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    // Redirect authenticated users immediately
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (user.role == UserRole.investor) {
          context.go('/investor-portal');
        } else {
          context.go('/dashboard');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Company Logo
                  const Icon(
                    Icons.directions_car_filled,
                    size: 80,
                    color: Color(0xFF0A192F),
                  ),
                  const SizedBox(height: 16),
                  
                  // 2. System Name
                  const Text(
                    'نظام إدارة تمويل السيارات',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A192F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 3. Short Description
                  const Text(
                    'اختر طريقة الدخول إلى النظام',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Cards Section (Responsive)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 700) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildStaffCard(context)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildInvestorCard(context)),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildStaffCard(context),
                            const SizedBox(height: 24),
                            _buildInvestorCard(context),
                          ],
                        );
                      }
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ليس لديك حساب؟',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () => context.push('/auth/investor/register'),
                        child: const Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A192F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context) {
    return _PortalCard(
      title: 'دخول الموظفين',
      description: 'للإدارة والمحاسبين وموظفي الشركة',
      icon: Icons.business_center,
      color: const Color(0xFF0A192F),
      onTap: () => context.push('/auth/staff/login'),
    );
  }

  Widget _buildInvestorCard(BuildContext context) {
    return _PortalCard(
      title: 'دخول المستثمرين',
      description: 'لمتابعة الاستثمارات والأرباح والمحفظة الاستثمارية',
      icon: Icons.account_balance,
      color: const Color(0xFF1B3A5B),
      onTap: () => context.push('/auth/investor/login'),
    );
  }
}

class _PortalCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PortalCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A192F),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
