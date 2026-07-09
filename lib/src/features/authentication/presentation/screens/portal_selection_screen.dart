import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:car_system_management/src/core/utils/app_theme.dart';
import '../auth_controller.dart';
import '../../domain/user_role.dart';

class PortalSelectionScreen extends ConsumerWidget {
  const PortalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
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
      body: Stack(
        children: [
          // خلفية متدرجة مع أشكال جمالية
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: AppColors.primaryNavy.withOpacity(0.03),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: AppColors.accentGold.withOpacity(0.03),
            ),
          ),
          
          SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // شعار الشركة بتصميم أرقى
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_car_filled,
                          size: 60,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'نظام إدارة تمويل السيارات',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryNavy,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'مرحباً بك، يرجى اختيار بوابة الدخول المناسبة',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 60),
                      
                      // الكروت
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 700) {
                              return Row(
                                children: [
                                  Expanded(child: _buildStaffCard(context)),
                                  const SizedBox(width: 32),
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
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // رابط التسجيل بتصميم مودرن
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ليس لديك حساب مستثمر؟',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            TextButton(
                              onPressed: () => context.push('/auth/investor/register'),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text(
                                'سجل الآن',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentGold,
                                ),
                              ),
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

  Widget _buildStaffCard(BuildContext context) {
    return _PortalCard(
      title: 'بوابة الموظفين',
      description: 'إدارة العمليات، المحاسبة، والتقارير الرقابية',
      icon: Icons.admin_panel_settings_rounded,
      mainColor: AppColors.primaryNavy,
      onTap: () => context.push('/auth/staff/login'),
    );
  }

  Widget _buildInvestorCard(BuildContext context) {
    return _PortalCard(
      title: 'بوابة المستثمرين',
      description: 'متابعة أرباحك، استثماراتك، وعقود التمويل القائمة',
      icon: Icons.account_balance_wallet_rounded,
      mainColor: AppColors.accentGold,
      onTap: () => context.push('/auth/investor/login'),
    );
  }
}

class _PortalCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color mainColor;
  final VoidCallback onTap;

  const _PortalCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.mainColor,
    required this.onTap,
  });

  @override
  State<_PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<_PortalCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..translate(0.0, isHovered ? -10.0 : 0.0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isHovered ? widget.mainColor.withOpacity(0.5) : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovered 
                      ? widget.mainColor.withOpacity(0.15) 
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.mainColor, widget.mainColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.mainColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey.shade400,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: isHovered ? widget.mainColor : Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
