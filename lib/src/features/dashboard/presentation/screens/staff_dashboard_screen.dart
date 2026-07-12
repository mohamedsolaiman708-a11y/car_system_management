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
      backgroundColor: AppColors.bgGrey,
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(staffStatsProvider);
            ref.invalidate(monthlyGrowthDataProvider);
          },
          child: CustomScrollView(
            slivers: [
              // هيدر فاخر بأسلوب "المركز القيادي"
              SliverToBoxAdapter(
                child: _buildExecutiveHeader(user.fullName, stats, f),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMainAnalyticsRow(stats, growthAsync, f, context),
                    const SizedBox(height: 24),
                    _buildOperationsRow(stats, context),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildExecutiveHeader(String name, Map<String, dynamic> stats, intl.NumberFormat f) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('لوحة البيانات التنفيذية', 
                      style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Text('أهلاً بك، $name', 
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    Text('إليك ملخص مؤشرات الأداء المالي والتشغيلي لليوم', 
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                  ],
                ),
                _buildLiveClock(),
              ],
            ),
          ),
          
          // إحصائيات مدمجة داخل الهيدر (Floating Style)
          Transform.translate(
            offset: const Offset(0, 30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  _buildHeaderStatCard('إجمالي العملاء', (stats['total_customers'] ?? 0).toString(), Icons.people_outline, Colors.blue),
                  const SizedBox(width: 16),
                  _buildHeaderStatCard('السيارات المتاحة', (stats['available_cars'] ?? 0).toString(), Icons.directions_car_outlined, Colors.orange),
                  const SizedBox(width: 16),
                  _buildHeaderStatCard('العقود النشطة', (stats['active_contracts'] ?? 0).toString(), Icons.assignment_outlined, Colors.green),
                  const SizedBox(width: 16),
                  _buildHeaderStatCard('أرصدة المستثمرين', f.format(stats['investor_balances'] ?? 0), Icons.account_balance_wallet_outlined, Colors.purple),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeaderStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveClock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded, color: AppColors.accentGold, size: 18),
          const SizedBox(width: 12),
          Text(intl.DateFormat('HH:mm').format(DateTime.now()), 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMainAnalyticsRow(Map<String, dynamic> stats, AsyncValue<List<Map<String, dynamic>>> growthAsync, intl.NumberFormat f, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // كارت الرسم البياني (Creative White Card)
        Expanded(
          flex: 2,
          child: _CreativeCard(
            title: 'مؤشر النمو المالي',
            subtitle: 'تحليل أرباح الـ 6 أشهر الماضية',
            child: growthAsync.when(
              data: (data) => _ModernSimpleChart(data: data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),
          ),
        ),
        const SizedBox(width: 24),
        // كارت المتأخرات
        Expanded(
          child: _CreativeCard(
            title: 'مخاطر التحصيل',
            subtitle: 'الأقساط المتأخرة حسب المدة',
            child: _OverdueClassicList(stats: stats, f: f),
          ),
        ),
      ],
    );
  }

  Widget _buildOperationsRow(Map<String, dynamic> stats, BuildContext context) {
    final recentContracts = (stats['recent_contracts'] as List?) ?? [];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _CreativeCard(
            title: 'أحدث العمليات التعاقدية',
            subtitle: 'متابعة مباشرة لآخر العقود المبرمة',
            child: _CompactContractsList(contracts: recentContracts, context: context),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _CreativeCard(
            title: 'الوصول السريع',
            subtitle: 'إجراءات تشغيلية فورية',
            child: _QuickActionsList(context: context),
          ),
        ),
      ],
    );
  }
}

class _CreativeCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _CreativeCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1)),
          child,
        ],
      ),
    );
  }
}

class _ModernSimpleChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _ModernSimpleChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('لا توجد بيانات'));
    final chartData = data.reversed.toList();
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['gross_profit'] as num?)?.toDouble() ?? 0.0)).toList(),
              isCurved: true,
              color: AppColors.accentGold,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.accentGold.withOpacity(0.2), AppColors.accentGold.withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            ),
          ],
        ),
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
        const SizedBox(height: 16),
        _buildRow('متأخر 30-90 يوم', f.format(stats['overdue_60_90'] ?? 0), Colors.orange, stats['c_90'] ?? 0),
        const SizedBox(height: 16),
        _buildRow('أقل من 30 يوم', f.format(stats['overdue_under_30'] ?? 0), Colors.blue, stats['c_30'] ?? 0),
      ],
    );
  }

  Widget _buildRow(String label, String value, Color color, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 4, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text('$count حالة', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        Text('$value ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _CompactContractsList extends StatelessWidget {
  final List contracts;
  final BuildContext context;
  const _CompactContractsList({required this.contracts, required this.context});

  @override
  Widget build(BuildContext context) {
    if (contracts.isEmpty) return const Center(child: Text('لا توجد عقود حديثة'));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contracts.length > 3 ? 3 : contracts.length,
      itemBuilder: (context, index) {
        final c = contracts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: AppColors.bgGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            dense: true,
            leading: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.description_outlined, size: 16, color: AppColors.primaryNavy)),
            title: Text(c['contract_no'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(c['customers']?['full_name'] ?? '-'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
            onTap: () => context.push('/contracts/${c['id']}'),
          ),
        );
      },
    );
  }
}

class _QuickActionsList extends StatelessWidget {
  final BuildContext context;
  const _QuickActionsList({required this.context});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionBtn('إصدار عقد تمويل', Icons.add_task_rounded, Colors.blue, () => context.push('/contracts/new')),
        const SizedBox(height: 8),
        _ActionBtn('تسجيل عميل جديد', Icons.person_add_rounded, Colors.green, () => context.push('/crm/new')),
        const SizedBox(height: 8),
        _ActionBtn('إضافة سيارة للمخزون', Icons.add_road_rounded, Colors.orange, () => context.push('/inventory/new')),
      ],
    );
  }

  Widget _ActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.grey.shade200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
