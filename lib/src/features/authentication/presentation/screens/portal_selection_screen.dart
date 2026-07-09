import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:car_system_management/src/core/utils/app_theme.dart';
import '../auth_controller.dart';
import '../../domain/user_role.dart';
import '../widgets/brand_logo.dart'; // استيراد اللوجو الجديد

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
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // اللوجو الفخم الموحد
                      const BrandLogo(scale: 1.1),
                      const SizedBox(height: 80),

                      // كروت الدخول بتصميم زجاجي فاخر
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 950),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            bool isDesktop = constraints.maxWidth > 750;
                            return Flex(
                              direction: isDesktop ? Axis.horizontal : Axis.vertical,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildExpandedCard(
                                  isDesktop,
                                  _PortalCard(
                                    title: 'بوابة الموظفين',
                                    description: 'إدارة العمليات، الحسابات، والتقارير المالية للشركة',
                                    icon: Icons.admin_panel_settings_outlined,
                                    mainColor: Colors.white,
                                    onTap: () => context.push('/auth/staff/login'),
                                  ),
                                ),
                                SizedBox(width: isDesktop ? 32 : 0, height: isDesktop ? 0 : 24),
                                _buildExpandedCard(
                                  isDesktop,
                                  _PortalCard(
                                    title: 'بوابة المستثمرين',
                                    description: 'متابعة المحفظة الاستثمارية، الأرباح، وعقود التمويل',
                                    icon: Icons.account_balance_wallet_outlined,
                                    mainColor: AppColors.accentGold,
                                    onTap: () => context.push('/auth/investor/login'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 80),

                      // رابط التسجيل
                      TextButton(
                        onPressed: () => context.push('/auth/investor/register'),
                        style: TextButton.styleFrom(foregroundColor: Colors.white70),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
                            children: [
                              TextSpan(text: 'ليس لديك حساب مستثمر؟ ', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                              const TextSpan(
                                text: 'سجل الآن',
                                style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
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

  Widget _buildExpandedCard(bool isDesktop, Widget card) {
    return isDesktop ? Expanded(child: card) : SizedBox(width: double.infinity, child: card);
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
        transform: Matrix4.identity()..translate(0.0, isHovered ? -10.0 : 0.0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isHovered ? 0.08 : 0.04),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isHovered ? widget.mainColor.withOpacity(0.6) : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                if (isHovered)
                  BoxShadow(
                    color: widget.mainColor.withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.mainColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, size: 44, color: widget.mainColor),
                ),
                const SizedBox(height: 28),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isHovered ? 1.0 : 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('دخول', style: TextStyle(color: widget.mainColor, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18, color: widget.mainColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
