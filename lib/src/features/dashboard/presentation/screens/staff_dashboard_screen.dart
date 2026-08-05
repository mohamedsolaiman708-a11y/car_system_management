import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../dashboard_controller.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(staffStatsProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        body: statsAsync.when(
          data: (stats) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(staffStatsProvider),
            child: CustomScrollView(
              slivers: [
                _buildHeader(user.fullName),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUrgentTasks(stats, context),
                        const SizedBox(height: 32),
                        _buildQuickActions(context),
                        const SizedBox(height: 32),
                        const Text('نظرة عامة على الأداء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildStatsGrid(stats),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('حدث خطأ: $err')),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryNavy, Color(0xFF1B2A4A)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('أهلاً بك، $name 👋', 
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('إليك ملخص سريع لما يحتاج انتباهك اليوم', 
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrgentTasks(Map<String, dynamic> stats, BuildContext context) {
    // محاكاة لمهام عاجلة بناءً على الإحصائيات
    final pendingContracts = stats['active_contracts'] ?? 0; // سنفترض وجود عقود تحتاج مراجعة
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('مهام تتطلب اتخاذ إجراء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTaskCard(
                'عقود بانتظار التمويل',
                '$pendingContracts عقد جديد',
                Icons.pending_actions_rounded,
                Colors.orange,
                () => context.push('/contracts'),
              ),
              const SizedBox(width: 16),
              _buildTaskCard(
                'تحصيلات اليوم',
                '12 قسط مستحق',
                Icons.payments_rounded,
                AppColors.successGreen,
                () => context.push('/payments'),
              ),
              const SizedBox(width: 16),
              _buildTaskCard(
                'طلبات انضمام موظفين',
                '2 طلب معلق',
                Icons.person_add_rounded,
                Colors.blue,
                () => context.push('/staff'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('إجراءات سريعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildActionButton(context, 'عقد جديد', Icons.add_moderator_rounded, AppColors.primaryNavy, '/contracts/new'),
            _buildActionButton(context, 'إضافة عميل', Icons.person_add_alt_1_rounded, Colors.teal, '/crm/customers/new'),
            _buildActionButton(context, 'تسجيل قسط', Icons.add_card_rounded, AppColors.accentGold, '/payments'),
            _buildActionButton(context, 'إضافة سيارة', Icons.add_road_rounded, Colors.blueGrey, '/inventory/new'),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, String route) {
    return ElevatedButton.icon(
      onPressed: () => context.push(route),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    final f = intl.NumberFormat.compactCurrency(symbol: 'ر.س', locale: 'ar');
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatTile('السيولة المتاحة', f.format(stats['investor_balances'] ?? 0), Icons.account_balance_wallet_rounded, AppColors.accentGold),
        _buildStatTile('السيارات المتوفرة', (stats['available_cars'] ?? 0).toString(), Icons.directions_car_filled_rounded, Colors.orange),
        _buildStatTile('العقود النشطة', (stats['active_contracts'] ?? 0).toString(), Icons.assignment_turned_in_rounded, AppColors.successGreen),
        _buildStatTile('إجمالي الاستثمارات', f.format(1250000), Icons.trending_up_rounded, Colors.blue),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
