import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../dashboard_controller.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(staffStatsProvider);
    final growthAsync = ref.watch(monthlyGrowthDataProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) return const Center(child: CircularProgressIndicator());

    final currencyFormat = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return statsAsync.when(
      data: (stats) => RefreshIndicator(
        onRefresh: () async {
          ref.refresh(staffStatsProvider);
          ref.refresh(monthlyGrowthDataProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildWelcomeHeader(user.fullName),
            const SizedBox(height: 32),
            _buildTopStatsGrid(stats, currencyFormat),
            const SizedBox(height: 32),
            _buildMainSection(stats, growthAsync, currencyFormat, context),
            const SizedBox(height: 32),
            _buildRecentAndActions(stats, context),
            const SizedBox(height: 40),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
            const SizedBox(height: 12),
            Text('حدث خطأ: $err', style: const TextStyle(color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('نظرة عامة على الأداء',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        const SizedBox(height: 4),
        Text('مرحباً بك مجدداً، $name. إليك ملخص العمليات اليوم.',
            style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
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
            _StatCard('إجمالي العملاء', (stats['total_customers'] ?? 0).toString(), Icons.people_alt_rounded, Colors.indigo),
            _StatCard('السيارات المتاحة', (stats['available_cars'] ?? 0).toString(), Icons.directions_car_filled_rounded, Colors.yellow),
            _StatCard('العقود النشطة', (stats['active_contracts'] ?? 0).toString(), Icons.assignment_turned_in_rounded, Colors.orange),
            _StatCard('الأقساط المستحقة', f.format(stats['total_due_installments'] ?? 0), Icons.payments_rounded, Colors.blue),
            _StatCard('أرصدة المستثمرين', f.format(stats['investor_balances'] ?? 0), Icons.account_balance_wallet_rounded, AppColors.accentGold),
            _StatCard('سيولة الصندوق', f.format(stats['cash_liquidity'] ?? 0), Icons.savings_rounded, Colors.teal),
          ],
        );
      },
    );
  }

  Widget _buildMainSection(Map<String, dynamic> stats, AsyncValue<List<Map<String, dynamic>>> growthAsync, intl.NumberFormat f, BuildContext context) {
    bool isCompact = MediaQuery.of(context).size.width < 1100;
    return Flex(
      direction: isCompact ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isCompact ? 0 : 3,
          child: _AppCard(
            title: 'تحليلات النمو والأرباح',
            height: 350,
            child: growthAsync.when(
              data: (data) => _SalesGrowthChart(data: data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('خطأ في تحميل الرسم البياني: $err')),
            ),
          ),
        ),
        if (!isCompact) const SizedBox(width: 24),
        if (isCompact) const SizedBox(height: 24),
        Expanded(
          flex: isCompact ? 0 : 2,
          child: _AppCard(
            title: 'توزيع الأقساط المتأخرة',
            height: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _OverdueItem('أكثر من 90 يوم', f.format(stats['overdue_over_90'] ?? 0), Colors.red, stats['c_max'] ?? 0),
                _OverdueItem('من 60 إلى 90 يوم', f.format(stats['overdue_60_90'] ?? 0), Colors.orange, stats['c_90'] ?? 0),
                _OverdueItem('من 30 إلى 60 يوم', f.format(stats['overdue_30_60'] ?? 0), Colors.amber, stats['c_60'] ?? 0),
                _OverdueItem('أقل من 30 يوم', f.format(stats['overdue_under_30'] ?? 0), Colors.blue, stats['c_30'] ?? 0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAndActions(Map<String, dynamic> stats, BuildContext context) {
    bool isCompact = MediaQuery.of(context).size.width < 1100;
    final recentContracts = (stats['recent_contracts'] as List?) ?? [];

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
                if (recentContracts.isEmpty)
                  const Padding(padding: EdgeInsets.all(40), child: Text('لا توجد عقود مسجلة حالياً'))
                else
                  ...recentContracts.map((c) => ListTile(
                        leading: const CircleAvatar(backgroundColor: AppColors.bgGrey, child: Icon(Icons.description_outlined, size: 18)),
                        title: Text(c['contract_no'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(c['customers']?['full_name'] ?? '-'),
                        trailing: Text('${c['total_contract_value'] ?? 0} ر.س', style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
                        onTap: () => context.push('/contracts/${c['id']}'),
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
                _QuickAction(label: 'عقد جديد', icon: Icons.add_task_rounded, color: Colors.blue, onTap: () => context.push('/contracts/new')),
                _QuickAction(label: 'عميل جديد', icon: Icons.person_add_rounded, color: Colors.green, onTap: () => context.push('/crm/new')),
                _QuickAction(label: 'سيارة جديدة', icon: Icons.add_road_rounded, color: Colors.orange, onTap: () => context.push('/inventory/new')),
                _QuickAction(label: 'سند قبض', icon: Icons.input_rounded, color: Colors.purple, onTap: () => context.push('/accounting/journal')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SalesGrowthChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _SalesGrowthChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('لا توجد بيانات كافية للرسم البياني'));

    final chartData = data.reversed.toList();
    
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 10, left: 10),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                    final dateText = chartData[value.toInt()]['period_text'] ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(dateText.split('-').last, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: chartData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), (e.value['gross_profit'] as num?)?.toDouble() ?? 0.0);
              }).toList(),
              isCurved: true,
              color: AppColors.accentGold,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.accentGold.withOpacity(0.1),
              ),
            ),
            LineChartBarData(
              spots: chartData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), (e.value['company_net_profit'] as num?)?.toDouble() ?? 0.0);
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

// --- المكونات المصغرة الخاصة بالداشبورد ---

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
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
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
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
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
            Text('${count ?? 0} قسط متأخر', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color))
          ])),
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
  final VoidCallback onTap;
  const _QuickAction({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
