import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/utils/app_theme.dart';
import '../investor_controller.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../../documents/presentation/widgets/universal_document_manager.dart';
import '../../../notifications/presentation/notification_controller.dart';

class InvestorDashboardScreen extends ConsumerWidget {
  const InvestorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final investorAsync = ref.watch(investorDetailsControllerProvider(user.id));
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: investorAsync.when(
        data: (investor) {
          // إذا لم يجد النظام سجل مستثمر مرتبط بهذا الإيميل
          if (investor == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('بوابة المستثمر'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                  ),
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_search_rounded, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('عذراً، هذا الحساب غير مربوط بملف مستثمر.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('يرجى التواصل مع الإدارة لتفعيل حسابك كمستثمر.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/dashboard'),
                      child: const Text('العودة للوحة تحكم الإدارة'),
                    )
                  ],
                ),
              ),
            );
          }

          return DefaultTabController(
            length: 5,
            child: Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: AppBar(
                title: const Text('بوابة المستثمر الذكية', style: TextStyle(fontWeight: FontWeight.bold)),
                actions: [
                  _NotificationBadge(count: unreadCount),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                  ),
                  const SizedBox(width: 8),
                ],
                bottom: const TabBar(
                  isScrollable: true,
                  indicatorColor: AppColors.accentGold,
                  labelColor: AppColors.primaryNavy,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard_rounded)),
                    Tab(text: 'محفظة العقود', icon: Icon(Icons.account_balance_rounded)),
                    Tab(text: 'كشف الحساب', icon: Icon(Icons.receipt_long_rounded)),
                    Tab(text: 'التوقعات', icon: Icon(Icons.trending_up_rounded)),
                    Tab(text: 'المستندات', icon: Icon(Icons.folder_copy_rounded)),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _OverviewTab(investor: investor),
                  _PortfolioTab(investorId: investor.id),
                  _TransactionsTab(investorId: investor.id),
                  _ProjectionsTab(investorId: investor.id),
                  UniversalDocumentManager(investorId: investor.id),
                ],
              ),
            ),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, _) => Scaffold(body: Center(child: Text('حدث خطأ: $err'))),
      ),
    );
  }
}

// ... بقية الكود يظل كما هو
class _OverviewTab extends ConsumerWidget {
  final dynamic investor;
  const _OverviewTab({required this.investor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final txAsync = ref.watch(investorTransactionsControllerProvider(investor.id));
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(investorDetailsControllerProvider(investor.id));
        ref.invalidate(investorTransactionsControllerProvider(investor.id));
      }, 
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceHeroCard(investor, f),
            const SizedBox(height: 32),
            const Text('تحليل نمو الأرباح الموزعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            const SizedBox(height: 16),
            _buildProfitChart(txAsync),
            const SizedBox(height: 32),
            Row(
              children: [
                _buildSmallStatCard('إجمالي الأرباح', f.format(investor.totalProfitEarned), Icons.auto_graph_rounded, Colors.orange),
                const SizedBox(width: 16),
                _buildSmallStatCard('العقود الممولة', '${investor.deployedCapital > 0 ? "نشطة" : "لا يوجد"}', Icons.assignment_turned_in_rounded, Colors.green),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showWithdrawalDialog(context, ref, investor),
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('طلب سحب رصيد من المحفظة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitChart(AsyncValue<List<dynamic>> txAsync) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: txAsync.when(
        data: (txs) {
          final profitTxs = txs.where((t) => t.type.name == 'finance_profit_distribution').toList();
          if (profitTxs.isEmpty) return const Center(child: Text('سيظهر الرسم البياني عند تحصيل أول أرباح'));
          
          return LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: profitTxs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.amount.toDouble())).toList(),
                  isCurved: true,
                  color: AppColors.accentGold,
                  barWidth: 4,
                  belowBarData: BarAreaData(show: true, color: AppColors.accentGold.withOpacity(0.1)),
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox(),
      ),
    );
  }

  Widget _buildBalanceHeroCard(investor, intl.NumberFormat f) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B3E), Color(0xFF1A2E5A)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          const Text('إجمالي القيمة الاستثمارية', style: TextStyle(color: Colors.white60, fontSize: 14)),
          const SizedBox(height: 12),
          Text('${f.format(investor.availableBalance + investor.deployedCapital)} ر.س', 
               style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroStat('رصيد متاح للسحب', f.format(investor.availableBalance), Colors.greenAccent),
              _buildHeroStat('رأس مال عامل', f.format(investor.deployedCapital), Colors.blueAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSmallStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalDialog(BuildContext context, WidgetRef ref, dynamic investor) {
    final amountController = TextEditingController();
    final bankController = TextEditingController();
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('طلب سحب أرباح'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('متاح للسحب:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${f.format(investor.availableBalance)} ر.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'المبلغ (ر.س)', border: const OutlineInputBorder(), errorText: errorText),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankController,
                  decoration: const InputDecoration(labelText: 'رقم الآيبان (IBAN)', border: OutlineInputBorder(), hintText: 'SA...'),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0 || amount > investor.availableBalance) {
                    setDialogState(() => errorText = 'مبلغ غير صحيح'); return;
                  }
                  // استدعاء الطلب (مفترض وجود controller للطلبات)
                  // await ref.read(withdrawalRequestsControllerProvider().notifier).requestWithdrawal(amount, bankController.text);
                  if (context.mounted) { Navigator.pop(ctx); }
                },
                child: const Text('إرسال الطلب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  final int count;
  const _NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: () => context.push('/notifications')),
        if (count > 0)
          Positioned(right: 10, top: 10, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), constraints: const BoxConstraints(minWidth: 16, minHeight: 16), child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
      ],
    );
  }
}

class _PortfolioTab extends ConsumerWidget {
  final String investorId;
  const _PortfolioTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(investorFundedContractsControllerProvider(investorId));
    return contractsAsync.when(data: (contracts) => contracts.isEmpty ? const Center(child: Text('لا توجد عقود ممولة')) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: contracts.length, itemBuilder: (context, index) { final item = contracts[index]; final contract = item['financing_contracts']; return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: ListTile(leading: const Icon(Icons.verified_user_rounded, color: Colors.green), title: Text('عقد رقم: ${contract['contract_no']}'), subtitle: Text('تمويلك: ${item['amount_allocated']} ر.س'), trailing: const Icon(Icons.chevron_left))); }), loading: () => const Center(child: CircularProgressIndicator()), error: (err, _) => Center(child: Text('خطأ: $err')));
  }
}

class _TransactionsTab extends ConsumerWidget {
  final String investorId;
  const _TransactionsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(investorTransactionsControllerProvider(investorId));
    return Column(children: [Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('كشف العمليات المالي', style: TextStyle(fontWeight: FontWeight.bold)), TextButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf, color: Colors.red), label: const Text('تصدير كشف حساب'))])), Expanded(child: txAsync.when(data: (txs) => txs.isEmpty ? const Center(child: Text('لا توجد عمليات')) : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: txs.length, itemBuilder: (context, index) { final tx = txs[index]; final isPlus = tx.amount > 0; return ListTile(leading: Icon(isPlus ? Icons.add_circle_outline : Icons.remove_circle_outline, color: isPlus ? Colors.green : Colors.red), title: Text(tx.type.label), subtitle: Text(intl.DateFormat('yyyy/MM/dd').format(tx.createdAt)), trailing: Text('${isPlus ? "+" : ""}${tx.amount} ر.س', style: TextStyle(fontWeight: FontWeight.bold, color: isPlus ? Colors.green : Colors.red))); }), loading: () => const Center(child: CircularProgressIndicator()), error: (err, _) => Center(child: Text('خطأ: $err'))))]);
  }
}

class _ProjectionsTab extends ConsumerWidget {
  final String investorId;
  const _ProjectionsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectionsAsync = ref.watch(investorProjectionsProvider(investorId));
    return projectionsAsync.when(data: (list) { if (list.isEmpty) return const Center(child: Text('لا توجد توقعات حالياً')); double grandTotal = 0; for (var item in list) grandTotal += (item['total_expected'] as num).toDouble(); return Column(children: [Container(width: double.infinity, margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade100)), child: Column(children: [const Text('التدفقات النقدية المتوقعة لمحفظتك', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text('${grandTotal.toStringAsFixed(0)} ر.س', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade900))])), Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: list.length, itemBuilder: (context, index) { final item = list[index]; return Card(margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: ListTile(leading: const Icon(Icons.calendar_month_rounded, color: Colors.blue), title: Text('تاريخ الاستحقاق: ${item['due_date']}'), trailing: Text('${item['total_expected']} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)))); }))]); }, loading: () => const Center(child: CircularProgressIndicator()), error: (err, _) => Center(child: Text('خطأ: $err')));
  }
}
