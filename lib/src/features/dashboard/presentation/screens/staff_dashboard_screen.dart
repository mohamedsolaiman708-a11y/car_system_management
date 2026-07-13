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
      backgroundColor: const Color(0xFFF6F8FA),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(staffStatsProvider);
            ref.invalidate(monthlyGrowthDataProvider);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Executive Header Section
              SliverToBoxAdapter(
                child: _buildExecutiveHeader(user.fullName),
              ),

              // 2. Statistics Row (Floating Impact)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Transform.translate(
                    offset: const Offset(0, -40),
                    child: _buildKPISection(stats, f),
                  ),
                ),
              ),

              // 3. Main Dashboard Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionHeader('توصيات النظام والذكاء المالي', Icons.auto_awesome_rounded),
                    const SizedBox(height: 16),
                    _buildInsightsGrid(stats, context),
                    const SizedBox(height: 32),
                    
                    // Analytics Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _DashboardCard(
                            title: 'تحليل النمو المالي',
                            subtitle: 'صافي الأرباح لآخر 6 أشهر',
                            child: SizedBox(
                              height: 250,
                              child: growthAsync.when(
                                data: (data) => _ModernGrowthChart(data: data),
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (_, __) => const Center(child: Text('لا توجد بيانات كافية')),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _DashboardCard(
                            title: 'إدارة المخاطر',
                            subtitle: 'توزيع المتأخرات المالية',
                            child: _RiskAnalysisList(stats: stats, f: f),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Operations Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _DashboardCard(
                            title: 'آخر العمليات المبرمة',
                            subtitle: 'متابعة فورية للعقود الجديدة',
                            child: _RecentOperationsList(stats: stats, context: context),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _DashboardCard(
                            title: 'إجراءات سريعة',
                            subtitle: 'العمليات الأكثر تكراراً',
                            child: _QuickActionsSection(context: context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                  ]),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildExecutiveHeader(String name) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryNavy, Color(0xFF1E293B)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 60, 32, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('نظام الإدارة الذكي', style: TextStyle(color: AppColors.accentGold.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text('أهلاً بك، $name', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                Text('إليك نظرة شاملة على أداء المنظومة اليوم', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
            _buildClock(),
          ],
        ),
      ),
    );
  }

  Widget _buildKPISection(Map<String, dynamic> stats, intl.NumberFormat f) {
    return Row(
      children: [
        _KPICard('السيارات المتاحة', (stats['available_cars'] ?? 0).toString(), Icons.directions_car_filled_rounded, Colors.orange),
        const SizedBox(width: 16),
        _KPICard('العقود النشطة', (stats['active_contracts'] ?? 0).toString(), Icons.assignment_turned_in_rounded, Colors.green),
        const SizedBox(width: 16),
        _KPICard('سيولة الممولين', f.format(stats['investor_balances'] ?? 0), Icons.account_balance_wallet_rounded, AppColors.accentGold),
      ],
    );
  }

  Widget _buildInsightsGrid(Map<String, dynamic> stats, BuildContext context) {
    final double investorCash = (stats['investor_balances'] as num?)?.toDouble() ?? 0;
    return Row(
      children: [
        if (investorCash > 500000)
          Expanded(child: _InsightTile('سيولة فائضة', 'يوجد ${intl.NumberFormat.compact().format(investorCash)} ر.س جاهزة للتوظيف', Icons.trending_up_rounded, Colors.blue, () => context.push('/inventory/new'))),
        const SizedBox(width: 16),
        Expanded(child: _InsightTile('المخزون الحالي', 'توجد سيارات بانتظار التخصيص للمستثمرين', Icons.inventory_2_rounded, Colors.purple, () => context.push('/inventory'))),
        const SizedBox(width: 16),
        Expanded(child: _InsightTile('التحصيل', 'راجع تقرير الأقساط المستحقة خلال هذا الأسبوع', Icons.payments_rounded, Colors.teal, () => context.push('/reports'))),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryNavy, size: 20),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
      ],
    );
  }

  Widget _buildClock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Row(
        children: [
          const Icon(Icons.access_time_filled_rounded, color: AppColors.accentGold, size: 16),
          const SizedBox(width: 8),
          Text(intl.DateFormat('HH:mm').format(DateTime.now()), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _KPICard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryNavy), overflow: TextOverflow.ellipsis),
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String title, desc;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _InsightTile(this.title, this.desc, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 10), Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14))]),
            const SizedBox(height: 12),
            Text(desc, style: const TextStyle(fontSize: 11, color: Colors.blueGrey, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _DashboardCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 30, offset: const Offset(0, 10))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(height: 1, color: Color(0xFFF1F1F1))),
          child,
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
    if (data.isEmpty) return const Center(child: Text('لا توجد بيانات كافية للتحليل'));
    final chartData = data.reversed.toList();
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['gross_profit'] as num?)?.toDouble() ?? 0.0)).toList(),
            isCurved: true,
            color: AppColors.primaryNavy,
            barWidth: 6,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.primaryNavy.withOpacity(0.2), AppColors.primaryNavy.withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
      ),
    );
  }
}

class _RiskAnalysisList extends StatelessWidget {
  final Map<String, dynamic> stats;
  final intl.NumberFormat f;
  const _RiskAnalysisList({required this.stats, required this.f});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow('متأخرات حرجة', f.format(stats['overdue_over_90'] ?? 0), Colors.red, stats['c_max'] ?? 0),
        const SizedBox(height: 20),
        _buildRow('تحت المتابعة', f.format(stats['overdue_60_90'] ?? 0), Colors.orange, stats['c_90'] ?? 0),
        const SizedBox(height: 20),
        _buildRow('مستحقات قريبة', f.format(stats['overdue_under_30'] ?? 0), Colors.blue, stats['c_30'] ?? 0),
      ],
    );
  }

  Widget _buildRow(String label, String value, Color color, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [Container(width: 4, height: 32, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), Text('$count حالة', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))])]),
        Text('$value ر.س', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryNavy)),
      ],
    );
  }
}

class _RecentOperationsList extends StatelessWidget {
  final Map<String, dynamic> stats;
  final BuildContext context;
  const _RecentOperationsList({required this.stats, required this.context});

  @override
  Widget build(BuildContext context) {
    final recent = (stats['recent_contracts'] as List?) ?? [];
    if (recent.isEmpty) return const Center(child: Text('لا توجد عقود مسجلة بعد'));
    return Column(
      children: recent.take(4).map((c) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)),
        child: ListTile(dense: true, leading: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.description_outlined, color: AppColors.primaryNavy, size: 18)), title: Text(c['contract_no'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text(c['customers']?['full_name'] ?? '-', style: const TextStyle(fontSize: 12)), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey), onTap: () => context.push('/contracts/${c['id']}')),
      )).toList(),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final BuildContext context;
  const _QuickActionsSection({required this.context});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionBtn('إصدار عقد جديد', Icons.add_moderator_rounded, Colors.blue, () => context.push('/contracts/new')),
        const SizedBox(height: 12),
        _ActionBtn('إضافة مستثمر', Icons.person_add_rounded, AppColors.accentGold, () => context.push('/investors')),
        const SizedBox(height: 12),
        _ActionBtn('تسجيل مركبة', Icons.add_road_rounded, Colors.orange, () => context.push('/inventory/new')),
      ],
    );
  }

  Widget _ActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
        child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 16), Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy)), const Spacer(), const Icon(Icons.add, size: 16, color: Colors.grey)]),
      ),
    );
  }
}
