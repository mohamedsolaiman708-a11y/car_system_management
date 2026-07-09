import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../authentication/presentation/auth_controller.dart';
import '../../../authentication/domain/user_role.dart';
import '../dashboard_controller.dart';
import '../widgets/global_search_delegate.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  static const Color primaryNavy = Color(0xFF0D1B3E);
  static const Color accentGold = Color(0xFFC5A35E);
  static const Color bgGrey = Color(0xFFF4F7FE);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(staffStatsProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgGrey,
        appBar: _buildAppBar(context, ref, user),
        body: statsAsync.when(
          data: (stats) => RefreshIndicator(
            onRefresh: () => ref.refresh(staffStatsProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // 1. الصف العلوي: إحصائيات سريعة (6 صناديق كما في الصورة 10)
                _buildTopStatsRow(stats),
                const SizedBox(height: 24),

                // 2. المنطقة الوسطى: الرسم البياني وتنبيهات الأقساط المتأخرة
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildMainChartAndRevenue(stats),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: _buildOverdueBreakdown(stats),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. المنطقة السفلية: العقود الأخيرة والعمليات السريعة
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildRecentContracts(context, stats['recent_contracts']),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: _buildQuickActionsGrid(context, user.role),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('حدث خطأ: $err')),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, dynamic user) {
    final now = DateTime.now();
    final hijriDate = '17 / 11 / 1445 هـ';
    final gregorianDate = intl.DateFormat('yyyy/MM/dd').format(now);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      title: const Text('لوحة التحكم الرئيسية', style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold, fontSize: 18)),
      actions: [
        _buildDateBadge(hijriDate, gregorianDate),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.search_rounded, color: primaryNavy),
          onPressed: () => showSearch(context: context, delegate: GlobalSearchDelegate(ref)),
        ),
        _buildNotificationIcon(ref, context),
        const VerticalDivider(width: 30, indent: 20, endIndent: 20),
        _buildUserProfile(user, ref),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildDateBadge(String hijri, String greg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: bgGrey, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_outlined, size: 16, color: accentGold),
          const SizedBox(width: 8),
          Text('$hijri | $greg م', style: const TextStyle(color: primaryNavy, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildUserProfile(dynamic user, WidgetRef ref) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(user.fullName, style: const TextStyle(color: primaryNavy, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(_getRoleLabel(user.role), style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 20,
          backgroundColor: primaryNavy.withOpacity(0.1),
          child: const Icon(Icons.person_rounded, color: primaryNavy),
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(WidgetRef ref, BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_none_rounded, color: primaryNavy),
      onPressed: () => context.push('/notifications'),
    );
  }

  Widget _buildTopStatsRow(Map<String, dynamic> stats) {
    return Row(
      children: [
        _buildStatCard('إجمالي العملاء', stats['total_customers'], Icons.people_outline, Colors.blue),
        _buildStatCard('السيارات المتاحة', stats['available_cars'], Icons.directions_car_outlined, Colors.green),
        _buildStatCard('العقود النشطة', stats['active_contracts'], Icons.description_outlined, Colors.orange),
        _buildStatCard('الأقساط المستحقة', '1,125,500', Icons.account_balance_wallet_outlined, Colors.purple),
        _buildStatCard('أرصدة المستثمرين', '8,752,300', Icons.trending_up_rounded, accentGold),
        _buildStatCard('سيولة الصندوق والبنك', '2,350,700', Icons.savings_outlined, Colors.teal),
      ],
    );
  }

  Widget _buildStatCard(String title, dynamic value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(value.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainChartAndRevenue(Map<String, dynamic> stats) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إحصائيات المبيعات والإيرادات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
              DropdownButton<String>(
                value: '6 أشهر',
                underline: const SizedBox(),
                items: ['6 أشهر', 'سنة'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildRevenueMiniCard('إيرادات اليوم', f.format(stats['today_revenue']), Icons.arrow_upward, Colors.green),
              const SizedBox(width: 16),
              _buildRevenueMiniCard('مصروفات اليوم', '23,850', Icons.arrow_downward, Colors.red),
              const SizedBox(width: 16),
              _buildRevenueMiniCard('صافي أرباح اليوم', '101,600', Icons.payments_outlined, accentGold, isDark: true),
            ],
          ),
          const SizedBox(height: 32),
          // مكان الرسم البياني (يمكن استخدام LineChart لاحقاً)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(color: bgGrey, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('رسم بياني للمبيعات (قيد التطوير)', style: TextStyle(color: Colors.grey))),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueMiniCard(String title, String value, IconData icon, Color color, {bool isDark = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? primaryNavy : bgGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.blueGrey, fontSize: 11)),
                Icon(icon, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text('$value ر.س', style: TextStyle(color: isDark ? accentGold : primaryNavy, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueBreakdown(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الأقساط المتأخرة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryNavy)),
          const SizedBox(height: 20),
          _buildOverdueItem('أكثر من 90 يوم', stats['overdue_over_90'] ?? 285450, Colors.red, '28 قسط'),
          _buildOverdueItem('من 60 إلى 90 يوم', stats['overdue_60_90'] ?? 412380, Colors.orange, '34 قسط'),
          _buildOverdueItem('من 30 إلى 60 يوم', stats['overdue_30_60'] ?? 256700, Colors.amber, '51 قسط'),
          _buildOverdueItem('أقل من 30 يوم', stats['overdue_under_30'] ?? 170970, Colors.blue, '76 قسط'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, foregroundColor: Colors.white),
              child: const Text('عرض جميع التنبيهات'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueItem(String label, dynamic amount, Color color, String count) {
    final f = intl.NumberFormat.compact();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(count, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text('${f.format(amount)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryNavy)),
          const SizedBox(width: 8),
          Icon(Icons.error_outline, color: color, size: 16),
        ],
      ),
    );
  }

  Widget _buildRecentContracts(BuildContext context, List<dynamic> contracts) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('العقود الأخيرة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryNavy)),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: contracts.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final c = contracts[index];
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: bgGrey, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.description_outlined, color: primaryNavy, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['contract_no'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(c['customers']?['full_name'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text('${c['total_contract_value']} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 24),
                  _buildStatusChip(c['status']),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(onPressed: () => context.push('/contracts'), child: const Text('عرض جميع العقود')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    String label = status;
    if (status == 'active') { color = Colors.green; label = 'مكتمل'; }
    if (status == 'pending_funding') { color = Colors.orange; label = 'قيد التنفيذ'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, UserRole role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('العمليات السريعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryNavy)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _QuickActionItem(title: 'إضافة عقد جديد', icon: Icons.add_circle_outline, color: Colors.blue, onTap: () => context.push('/contracts/new')),
            _QuickActionItem(title: 'إضافة عميل جديد', icon: Icons.person_add_outlined, color: Colors.teal, onTap: () => context.push('/crm/customers/new')),
            _QuickActionItem(title: 'إضافة سيارة جديدة', icon: Icons.add_road_outlined, color: Colors.orange, onTap: () => context.push('/inventory/new')),
            _QuickActionItem(title: 'سند قبض', icon: Icons.receipt_long_outlined, color: Colors.green, onTap: () {}),
            _QuickActionItem(title: 'سند صرف', icon: Icons.payments_outlined, color: Colors.red, onTap: () {}),
            _QuickActionItem(title: 'تحصيل قسط', icon: Icons.request_quote_outlined, color: accentGold, onTap: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white24))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('جميع الحقوق محفوظة © 2024 | معرض السامي للسيارات', style: TextStyle(fontSize: 12, color: Colors.grey)),
          Row(
            children: [
              _FooterInfoItem('ترخيص رقم', '91'),
              const SizedBox(width: 24),
              _FooterInfoItem('الرقم الضريبي', '311281617800003'),
              const SizedBox(width: 24),
              const Text('إصدار النظام 1.0.0', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _FooterInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryNavy)),
      ],
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin: return 'مدير النظام';
      case UserRole.accountant: return 'محاسب مالي';
      case UserRole.manager: return 'مدير عمليات';
      default: return 'موظف';
    }
  }
}

class _QuickActionItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionItem({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: StaffDashboardScreen.primaryNavy)),
          ],
        ),
      ),
    );
  }
}
