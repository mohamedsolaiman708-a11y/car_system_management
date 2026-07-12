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

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(staffStatsProvider);
            ref.invalidate(monthlyGrowthDataProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSimpleHeader(user.fullName),
              const SizedBox(height: 20),
              _buildCompactStatsGrid(stats, f),
              const SizedBox(height: 20),
              _buildMainDataSection(stats, growthAsync, f, context),
              const SizedBox(height: 20),
              _buildQuickAccessSection(stats, context),
              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSimpleHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('لوحة المؤشرات الرئيسية', 
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.1)),
            const SizedBox(height: 4),
            Text('أهلاً بك، $name', 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          ],
        ),
        _buildDateBadge(),
      ],
    );
  }

  Widget _buildDateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(intl.DateFormat('yyyy/MM/dd').format(DateTime.now()),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryNavy)),
    );
  }

  Widget _buildCompactStatsGrid(Map<String, dynamic> stats, intl.NumberFormat f) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200 ? 6 : (constraints.maxWidth > 800 ? 3 : 2);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: 2.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _ClassicStatItem('إجمالي العملاء', (stats['total_customers'] ?? 0).toString(), Icons.people_outline, Colors.blue),
            _ClassicStatItem('السيارات المتاحة', (stats['available_cars'] ?? 0).toString(), Icons.directions_car_outlined, Colors.orange),
            _ClassicStatItem('العقود النشطة', (stats['active_contracts'] ?? 0).toString(), Icons.assignment_outlined, Colors.green),
            _ClassicStatItem('أرصدة المستثمرين', f.format(stats['investor_balances'] ?? 0), Icons.account_balance_wallet_outlined, Colors.purple),
            _ClassicStatItem('الأقساط المستحقة', f.format(stats['total_due_installments'] ?? 0), Icons.payments_outlined, Colors.red),
            _ClassicStatItem('سيولة الصندوق', f.format(stats['cash_liquidity'] ?? 0), Icons.savings_outlined, Colors.teal),
          ],
        );
      },
    );
  }

  Widget _buildMainDataSection(Map<String, dynamic> stats, AsyncValue<List<Map<String, dynamic>>> growthAsync, intl.NumberFormat f, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _ClassicPanel(
            title: 'نمو الأرباح الشهرية',
            height: 300,
            child: growthAsync.when(
              data: (data) => _SimpleLineChart(data: data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const SizedBox(),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _ClassicPanel(
            title: 'تنبيهات التحصيل',
            height: 300,
            child: _OverdueClassicList(stats: stats, f: f),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection(Map<String, dynamic> stats, BuildContext context) {
    final recentContracts = (stats['recent_contracts'] as List?) ?? [];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _ClassicPanel(
            title: 'أحدث العقود المبرمة',
            child: _CompactContractsTable(contracts: recentContracts, context: context),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _ClassicPanel(
            title: 'اختصارات سريعة',
            child: _ActionsButtonsList(context: context),
          ),
        ),
      ],
    );
  }
}

class _ClassicStatItem extends StatelessWidget {
  final String title, value;
  final Icon_Data = Icons.abc; // Just dummy to show structure
  final IconData icon;
  final Color color;
  const _ClassicStatItem(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassicPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;
  const _ClassicPanel({required this.title, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          const Divider(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SimpleLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _SimpleLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('لا توجد بيانات'));
    final chartData = data.reversed.toList();
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['gross_profit'] as num?)?.toDouble() ?? 0.0)).toList(),
            isCurved: false,
            color: AppColors.primaryNavy,
            barWidth: 2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppColors.primaryNavy.withOpacity(0.02)),
          ),
        ],
      ),
    );
  }
}

class _OverdueClassicList extends StatelessWidget {
  final Map<String, dynamic> stats;
  final intl.NumberFormat f;
  const _OverdueClassicList({required this.stats, required this.f});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow('متأخر +90 يوم', f.format(stats['overdue_over_90'] ?? 0), Colors.red, stats['c_max'] ?? 0),
        const Divider(height: 20),
        _buildRow('متأخر 30-90 يوم', f.format(stats['overdue_60_90'] ?? 0), Colors.orange, stats['c_90'] ?? 0),
        const Divider(height: 20),
        _buildRow('أقل من 30 يوم', f.format(stats['overdue_under_30'] ?? 0), Colors.blue, stats['c_30'] ?? 0),
      ],
    );
  }

  Widget _buildRow(String label, String value, Color color, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text('$count حالة', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        Text('$value ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy)),
      ],
    );
  }
}

class _CompactContractsTable extends StatelessWidget {
  final List contracts;
  final BuildContext context;
  const _CompactContractsTable({required this.contracts, required this.context});

  @override
  Widget build(BuildContext context) {
    if (contracts.isEmpty) return const Center(child: Text('لا توجد سجلات'));
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contracts.length > 4 ? 4 : contracts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final c = contracts[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(c['contract_no'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          subtitle: Text(c['customers']?['full_name'] ?? '-', style: const TextStyle(fontSize: 11)),
          trailing: Text('${c['total_contract_value'] ?? 0} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 12)),
          onTap: () => context.push('/contracts/${c['id']}'),
        );
      },
    );
  }
}

class _ActionsButtonsList extends StatelessWidget {
  final BuildContext context;
  const _ActionsButtonsList({required this.context});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ClassicActionBtn('إصدار عقد جديد', Icons.add_task, () => context.push('/contracts/new')),
        const SizedBox(height: 8),
        _ClassicActionBtn('إضافة عميل', Icons.person_add, () => context.push('/crm/new')),
        const SizedBox(height: 8),
        _ClassicActionBtn('إضافة سيارة', Icons.add_road, () => context.push('/inventory/new')),
      ],
    );
  }
}

class _ClassicActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ClassicActionBtn(this.label, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryNavy,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
