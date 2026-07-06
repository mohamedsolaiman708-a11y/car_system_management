import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../dashboard_controller.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(staffStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: statsAsync.when(
          data: (stats) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(context, stats),
                const SizedBox(height: 32),
                const Text(
                  'الوصول السريع',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildQuickAccessGrid(context),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('حدث خطأ: $err')),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'إجمالي العملاء',
          value: stats['total_customers'].toString(),
          icon: Icons.people,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'العقود النشطة',
          value: stats['active_contracts'].toString(),
          icon: Icons.description,
          color: Colors.green,
        ),
        _StatCard(
          title: 'إجمالي الإيرادات',
          value: '${stats['total_revenue']} ر.س',
          icon: Icons.account_balance_wallet,
          color: Colors.purple,
        ),
        _StatCard(
          title: 'المستثمرين',
          value: stats['total_investors'].toString(),
          icon: Icons.trending_up,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _QuickAccessCard(
          title: 'إدارة العملاء (CRM)',
          icon: Icons.person_search,
          color: Colors.blue,
          onTap: () => context.push('/crm/customers'),
        ),
        _QuickAccessCard(
          title: 'المخزون والسيارات',
          icon: Icons.directions_car,
          color: Colors.orange,
          onTap: () {}, // To be implemented
        ),
        _QuickAccessCard(
          title: 'إدارة العقود',
          icon: Icons.assignment,
          color: Colors.green,
          onTap: () {}, // To be implemented
        ),
        _QuickAccessCard(
          title: 'التقارير المالية',
          icon: Icons.analytics,
          color: Colors.red,
          onTap: () {}, // To be implemented
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
