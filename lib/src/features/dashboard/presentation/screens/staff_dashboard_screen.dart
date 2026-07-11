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

    final currencyFormat = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(staffStatsProvider);
            ref.invalidate(monthlyGrowthDataProvider);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            children: [
              _buildModernHeader(user.fullName),
              const SizedBox(height: 40),
              _buildPremiumStatsGrid(stats, currencyFormat),
              const SizedBox(height: 40),
              _buildAnalyticsSection(stats, growthAsync, currencyFormat, context),
              const SizedBox(height: 40),
              _buildBottomSection(stats, context),
              const SizedBox(height: 60),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildModernHeader(String name) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('لوحة التحكم التنفيذية',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accentGold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text('أهلاً بك، $name 👋',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          ],
        ),
        const Spacer(),
        _buildHeaderAction(Icons.calendar_month_rounded, intl.DateFormat('MMMM yyyy', 'ar').format(DateTime.now())),
      ],
    );
  }

  Widget _buildHeaderAction(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryNavy),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        ],
      ),
    );
  }

  Widget _buildPremiumStatsGrid(Map<String, dynamic> stats, intl.NumberFormat f) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1400 ? 6 : (constraints.maxWidth > 900 ? 3 : 2);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.4,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          children: [
            _PremiumStatCard('إجمالي العملاء', (stats['total_customers'] ?? 0).toString(), Icons.people_rounded, [const Color(0xFF6366F1), const Color(0xFF4F46E5)]),
            _PremiumStatCard('السيارات المتاحة', (stats['available_cars'] ?? 0).toString(), Icons.directions_car_filled_rounded, [const Color(0xFFF59E0B), const Color(0xFFD97706)]),
            _PremiumStatCard('العقود النشطة', (stats['active_contracts'] ?? 0).toString(), Icons.assignment_turned_in_rounded, [const Color(0xFF10B981), const Color(0xFF059669)]),
            _PremiumStatCard('أرصدة المستثمرين', f.format(stats['investor_balances'] ?? 0), Icons.account_balance_wallet_rounded, [const Color(0xFFEC4899), const Color(0xFFDB2777)]),
            _PremiumStatCard('الأقساط المستحقة', f.format(stats['total_due_installments'] ?? 0), Icons.payments_rounded, [const Color(0xFF3B82F6), const Color(0xFF2563EB)]),
            _PremiumStatCard('سيولة الصندوق', f.format(stats['cash_liquidity'] ?? 0), Icons.savings_rounded, [AppColors.primaryNavy, const Color(0xFF1A294D)]),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsSection(Map<String, dynamic> stats, AsyncValue<List<Map<String, dynamic>>> growthAsync, intl.NumberFormat f, BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 1200;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _SectionCard(
            title: 'تحليلات الأداء المالي',
            subtitle: 'نمو الأرباح والعوائد خلال الأشهر الأخيرة',
            height: 400,
            child: growthAsync.when(
              data: (data) => _ModernGrowthChart(data: data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('خطأ في البيانات')),
            ),
          ),
        ),
        if (isWide) const SizedBox(width: 32),
        if (isWide)
          Expanded(
            flex: 1,
            child: _SectionCard(
              title: 'توزيع المخاطر',
              subtitle: 'تحليل الأقساط المتأخرة حسب المدة',
              height: 400,
              child: _RiskDistributionList(stats: stats, f: f),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomSection(Map<String, dynamic> stats, BuildContext context) {
    final recentContracts = (stats['recent_contracts'] as List?) ?? [];
    bool isWide = MediaQuery.of(context).size.width > 1200;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _SectionCard(
            title: 'آخر العقود المبرمة',
            subtitle: 'متابعة أحدث عمليات التمويل والتعاقد',
            child: _RecentContractsList(contracts: recentContracts, context: context),
          ),
        ),
        if (isWide) const SizedBox(width: 32),
        if (isWide)
          Expanded(
            flex: 1,
            child: _SectionCard(
              title: 'الوصول السريع',
              subtitle: 'إجراءات تشغيلية فورية',
              child: _QuickActionsGrid(context: context),
            ),
          ),
      ],
    );
  }
}

class _PremiumStatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final List<Color> gradient;
  const _PremiumStatCard(this.title, this.value, this.icon, this.gradient);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: gradient.last.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Positioned(right: -20, top: -20, child: Icon(icon, size: 100, color: Colors.white.withOpacity(0.1))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(title, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  final double? height;
  const _SectionCard({required this.title, required this.subtitle, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 32),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ModernGrowthChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _ModernGrowthChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('لا توجد بيانات كافية'));
    final chartData = data.reversed.toList();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 50000, 
          getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(chartData[value.toInt()]['period_text']?.split('-').last ?? '', 
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
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
            spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['gross_profit'] as num?)?.toDouble() ?? 0.0)).toList(),
            isCurved: true,
            color: AppColors.accentGold,
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.accentGold.withOpacity(0.2), AppColors.accentGold.withOpacity(0)])),
          ),
        ],
      ),
    );
  }
}

class _RiskDistributionList extends StatelessWidget {
  final Map<String, dynamic> stats;
  final intl.NumberFormat f;
  const _RiskDistributionList({required this.stats, required this.f});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RiskItem('تأخر حرج (+90 يوم)', f.format(stats['overdue_over_90'] ?? 0), Colors.red, stats['c_max'] ?? 0),
        _RiskItem('تأخر مرتفع (60-90 يوم)', f.format(stats['overdue_60_90'] ?? 0), Colors.orange, stats['c_90'] ?? 0),
        _RiskItem('تأخر متوسط (30-60 يوم)', f.format(stats['overdue_30_60'] ?? 0), Colors.amber, stats['c_60'] ?? 0),
        _RiskItem('تأخر منخفض (-30 يوم)', f.format(stats['overdue_under_30'] ?? 0), Colors.blue, stats['c_30'] ?? 0),
      ],
    );
  }
}

class _RiskItem extends StatelessWidget {
  final String label, amount;
  final Color color;
  final int count;
  const _RiskItem(this.label, this.amount, this.color, this.count);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(height: 45, width: 6, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy)),
                Text('$count حالة متأخرة', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _RecentContractsList extends StatelessWidget {
  final List contracts;
  final BuildContext context;
  const _RecentContractsList({required this.contracts, required this.context});

  @override
  Widget build(BuildContext context) {
    if (contracts.isEmpty) return const Center(child: Text('لا توجد عقود حديثة'));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contracts.length > 5 ? 5 : contracts.length,
      itemBuilder: (context, index) {
        final c = contracts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: AppColors.bgGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.description_outlined, size: 18, color: AppColors.primaryNavy)),
            title: Text(c['contract_no'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(c['customers']?['full_name'] ?? '-', style: const TextStyle(fontSize: 12)),
            trailing: Text('${c['total_contract_value'] ?? 0} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            onTap: () => context.push('/contracts/${c['id']}'),
          ),
        );
      },
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final BuildContext context;
  const _QuickActionsGrid({required this.context});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _QuickAction(Icons.add_task_rounded, 'عقد تمويل', Colors.blue, () => context.push('/contracts/new')),
        _QuickAction(Icons.person_add_rounded, 'إضافة عميل', Colors.green, () => context.push('/crm/new')),
        _QuickAction(Icons.add_road_rounded, 'إضافة سيارة', Colors.orange, () => context.push('/inventory/new')),
        _QuickAction(Icons.receipt_long_rounded, 'قيد محاسبي', Colors.purple, () => context.push('/accounting/journal')),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
