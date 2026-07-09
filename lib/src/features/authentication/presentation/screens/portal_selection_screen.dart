import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:car_system_management/src/core/utils/app_theme.dart';
import '../auth_controller.dart';
import '../../domain/user_role.dart';
import '../widgets/brand_logo.dart';

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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const BrandLogo(scale: 0.8), 
                      const SizedBox(height: 32), 

                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            bool isDesktop = constraints.maxWidth > 650;
                            return Flex(
                              direction: isDesktop ? Axis.horizontal : Axis.vertical,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildExpandedCard(
                                  isDesktop,
                                  _PortalCard(
                                    title: 'بوابة الموظفين',
                                    description: 'إدارة العمليات، الحسابات، والتقارير',
                                    icon: Icons.admin_panel_settings_outlined,
                                    mainColor: Colors.white,
                                    onTap: () => context.push('/auth/staff/login'),
                                  ),
                                ),
                                SizedBox(width: isDesktop ? 24 : 0, height: isDesktop ? 0 : 16),
                                _buildExpandedCard(
                                  isDesktop,
                                  _PortalCard(
                                    title: 'بوابة المستثمرين',
                                    description: 'متابعة الأرباح، العقود، والمحفظة',
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

                      const SizedBox(height: 32),

                      TextButton(
                        onPressed: () => context.push('/auth/investor/register'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
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
        transform: Matrix4.identity()..translate(0.0, isHovered ? -5.0 : 0.0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isHovered ? 0.08 : 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isHovered ? widget.mainColor.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.mainColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, size: 32, color: widget.mainColor),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isHovered ? 1.0 : 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('دخول', style: TextStyle(color: widget.mainColor, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: widget.mainColor),
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
