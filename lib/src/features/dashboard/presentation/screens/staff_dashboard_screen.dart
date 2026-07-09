import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../authentication/presentation/auth_controller.dart';
import '../../../core/utils/app_theme.dart';
import '../dashboard_controller.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(staffStatsProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) return const Center(child: CircularProgressIndicator());

    final currencyFormat = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return statsAsync.when(
      data: (stats) => RefreshIndicator(
        onRefresh: () => ref.refresh(staffStatsProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildWelcomeHeader(user.fullName),
            const SizedBox(height: 32),
            _buildTopStatsGrid(stats, currencyFormat),
            const SizedBox(height: 32),
            _buildMainSection(stats, currencyFormat, context),
            const SizedBox(height: 32),
            _buildRecentAndActions(stats, context),
            const SizedBox(height: 40),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('حدث خطأ: $err')),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نظرة عامة على الأداء', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        const SizedBox(height: 4),
        Text('مرحباً بك مجدداً، $name. إليك ملخص العمليات اليوم.', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
      ],
    );
  }

  Widget _buildTopStatsGrid(Map<String, dynamic> stats, intl.NumberFormat f) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200 ? 6 : (constraints.maxWidth > 800 ? 3 : 2);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _StatCard('إجمالي العملاء', stats['total_customers'], Icons.people_alt_rounded, Colors.indigo),
            _StatCard('السيارات المتاحة', stats['available_cars'], Icons.directions_car_filled_rounded, Colors.emerald),
            _StatCard('العقود النشطة', stats['active_contracts'], Icons.assignment_turned_in_rounded, Colors.orange),
            _StatCard('الأقساط المستحقة', f.format(stats['total_due_installments'] ?? 0), Icons.payments_rounded, Colors.blue),
            _StatCard('أرصدة المستثمرين', f.format(stats['investor_balances'] ?? 0), Icons.account_balance_wallet_rounded, AppColors.accentGold),
            _StatCard('سيولة الصندوق', f.format(stats['cash_liquidity'] ?? 0), Icons.savings_rounded, Colors.teal),
          ],
        );
      },
    );
  }

  Widget _buildMainSection(Map<String, dynamic> stats, intl.NumberFormat f, BuildContext context) {
    bool isCompact = MediaQuery.of(context).size.width < 1100;
    return Flex(
      direction: isCompact ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isCompact ? 0 : 3,
          child: _AppCard(
            title: 'إحصائيات المبيعات والإيرادات',
            height: 400,
            child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart_rounded, size: 80, color: AppColors.bgGrey),
                const SizedBox(height: 16),
                const Text('الرسم البياني سيكون متاحاً في المرحلة 18', style: TextStyle(color: AppColors.textGrey)),
              ],
            )),
          ),
        ),
        if (!isCompact) const SizedBox(width: 24),
        if (isCompact) const SizedBox(height: 24),
        Expanded(
          flex: isCompact ? 0 : 2,
          child: _AppCard(
            title: 'توزيع الأقساط المتأخرة',
            child: Column(
              children: [
                _OverdueItem('أكثر من 90 يوم', f.format(stats['overdue_over_90'] ?? 0), Colors.red, stats['c_max']),
                _OverdueItem('من 60 إلى 90 يوم', f.format(stats['overdue_60_90'] ?? 0), Colors.orange, stats['c_90']),
                _OverdueItem('من 30 إلى 60 يوم', f.format(stats['overdue_30_60'] ?? 0), Colors.amber, stats['c_60']),
                _OverdueItem('أقل من 30 يوم', f.format(stats['overdue_under_30'] ?? 0), Colors.blue, stats['c_30']),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAndActions(Map<String, dynamic> stats, BuildContext context) {
    bool isCompact = MediaQuery.of(context).size.width < 1100;
    return Flex(
      direction: isCompact ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isCompact ? 0 : 3,
          child: _AppCard(
            title: 'العقود الأخيرة',
            child: Column(
              children: [
                if ((stats['recent_contracts'] as List).isEmpty)
                  const Padding(padding: EdgeInsets.all(40), child: Text('لا توجد عقود مسجلة حالياً'))
                else
                  ...(stats['recent_contracts'] as List).map((c) => ListTile(
                    leading: const CircleAvatar(backgroundColor: AppColors.bgGrey, child: Icon(Icons.description_outlined, size: 18)),
                    title: Text(c['contract_no'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(c['customers']?['full_name'] ?? '-'),
                    trailing: Text('${c['total_contract_value']} ر.س', style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
                  )),
              ],
            ),
          ),
        ),
        if (!isCompact) const SizedBox(width: 24),
        if (isCompact) const SizedBox(height: 24),
        Expanded(
          flex: isCompact ? 0 : 2,
          child: _AppCard(
            title: 'إجراءات سريعة',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickAction(label: 'عقد جديد', icon: Icons.add_task_rounded, color: Colors.blue),
                _QuickAction(label: 'عميل جديد', icon: Icons.person_add_rounded, color: Colors.green),
                _QuickAction(label: 'سيارة جديدة', icon: Icons.add_road_rounded, color: Colors.orange),
                _QuickAction(label: 'سند قبض', icon: Icons.input_rounded, color: Colors.purple),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- المكونات المصغرة الخاصة بالداشبورد ---

class _StatCard extends StatelessWidget {
  final String title;
  final dynamic value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryNavy.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
          const Spacer(),
          Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;
  const _AppCard({required this.title, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF0F0F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          const SizedBox(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _OverdueItem extends StatelessWidget {
  final String label, amount;
  final Color color;
  final dynamic count;
  const _OverdueItem(this.label, this.amount, this.color, this.count);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)), Text('$count قسط متأخر', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color))])),
          Text(amount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickAction({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
