import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../../domain/investor.dart';
import '../investor_controller.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../../documents/presentation/widgets/universal_document_manager.dart';
import '../../../notifications/presentation/notification_controller.dart';
import '../../domain/investor_transaction_type.dart';

// ─── Color Palette ──────────────────────────────────────────────────────────
const _navy      = Color(0xFF0F172A);
const _navyLight = Color(0xFF1E293B);
const _gold      = Color(0xFFD4AF37);
const _bg        = Color(0xFFF1F5F9); 
const _green     = Color(0xFF10B981);
const _red       = Color(0xFFEF4444);
const _blue      = Color(0xFF3B82F6);
const _cardShadow = [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))];

// ─── Main Screen ────────────────────────────────────────────────────────────
class InvestorDashboardScreen extends ConsumerWidget {
  const InvestorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final investorAsync = ref.watch(investorDetailsControllerProvider(user.id));
    final unreadCount   = ref.watch(unreadNotificationsCountProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: _bg,
          body: investorAsync.when(
            skipLoadingOnRefresh: true,
            data: (investor) {
              if (investor == null) return _NoInvestorPage(onBack: () => context.go('/dashboard'));
              return NestedScrollView(
                headerSliverBuilder: (ctx, _) => [
                  _InvestorSliverAppBar(
                    investor: investor,
                    unreadCount: unreadCount,
                    onLogout: () => ref.read(authControllerProvider.notifier).logout(),
                    onNotifications: () => context.push('/notifications'),
                  ),
                ],
                body: Container(
                  color: _bg,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: TabBarView(
                        children: [
                          _OverviewTab(investor: investor, userId: user.id),
                          _PortfolioTab(investorId: investor.id),
                          _TransactionsTab(investorId: investor.id),
                          _ProjectionsTab(investorId: investor.id),
                          UniversalDocumentManager(investorId: investor.id),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const _LoadingScreen(),
            error: (err, _) => _ErrorScreen(message: Failure.fromException(err).message),
          ),
        ),
      ),
    );
  }
}

class _InvestorSliverAppBar extends StatelessWidget {
  final Investor investor;
  final int unreadCount;
  final VoidCallback onLogout, onNotifications;
  const _InvestorSliverAppBar({required this.investor, required this.unreadCount, required this.onLogout, required this.onNotifications});

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final total = investor.availableBalance + investor.deployedCapital;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: _navy,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        _NotificationBadge(count: unreadCount, onTap: onNotifications),
        IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20), onPressed: onLogout),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [_navy, Color(0xFF1E1B4B)]),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 18, backgroundColor: _gold.withOpacity(0.1), child: Text(investor.fullName[0], style: const TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 14))),
                          const SizedBox(width: 10),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('أهلاً بك،', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                            Text(investor.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ]),
                          const Spacer(),
                          _CompactStatsRow(investor: investor, f: f),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('إجمالي قيمة المحفظة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      FittedBox(child: Text('${f.format(total)} ر.س', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          width: double.infinity,
          color: _navy,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: _gold,
                indicatorWeight: 3,
                labelColor: _gold,
                unselectedLabelColor: Colors.white54,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
                tabs: [Tab(text: 'نظرة عامة'), Tab(text: 'المحفظة'), Tab(text: 'العمليات'), Tab(text: 'التوقعات'), Tab(text: 'المستندات')],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  final Investor investor;
  final String userId;
  const _OverviewTab({required this.investor, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final txAsync = ref.watch(investorTransactionsControllerProvider(investor.id));
    final projAsync = ref.watch(investorProjectionsProvider(investor.id));
    final requestsAsync = ref.watch(withdrawalRequestsControllerProvider(investorId: investor.id));

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(investorDetailsControllerProvider(userId).notifier).refresh();
        ref.invalidate(investorTransactionsControllerProvider(investor.id));
        ref.invalidate(withdrawalRequestsControllerProvider(investorId: investor.id));
      },
      child: LayoutBuilder(builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 850;

        return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40), // مسافة معقولة في الأسفل
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. تنبيهات طلبات السحب
              requestsAsync.when(
                data: (requests) {
                  final activeReqs = requests.where((r) => r['status'] == 'pending' || r['status'] == 'rejected').toList();
                  if (activeReqs.isEmpty) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _WithdrawalSummaryAlert(requests: activeReqs, f: f),
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

              // 2. كروت الأداء السريع
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: projAsync.when(
                      data: (list) => list.isEmpty 
                        ? _emptyActionPlaceholder('لا توجد استحقاقات قادمة حالياً')
                        : _NextPayoutCard(amount: (list.first['total_expected'] as num).toDouble(), date: list.first['due_date'] ?? '', f: f),
                      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                      error: (_, __) => const SizedBox(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _WithdrawActionCard(investor: investor),
                  ),
                ],
              ),

              const SizedBox(height: 24), 
              
              // 3. الرسم البياني والمؤشرات
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(title: 'تحليل الأداء', subtitle: 'نمو الأرباح المحققة', icon: Icons.auto_graph_rounded),
                        const SizedBox(height: 12),
                        _ProfitChartCard(txAsync: txAsync, totalProfit: investor.totalProfitEarned, f: f),
                      ],
                    ),
                  ),
                  if (isWide) const SizedBox(width: 24),
                  if (isWide) 
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(title: 'مؤشرات المحفظة', subtitle: 'أرقامك الحالية', icon: Icons.grid_view_rounded),
                          const SizedBox(height: 12),
                          _PerformanceColumn(investor: investor, f: f),
                        ],
                      ),
                    ),
                ],
              ),
              
              if (!isWide) ...[
                const SizedBox(height: 24),
                const _SectionHeader(title: 'مؤشرات المحفظة', subtitle: 'أرقامك الحالية', icon: Icons.grid_view_rounded),
                const SizedBox(height: 12),
                _PerformanceColumn(investor: investor, f: f),
              ],

            ],
          ),
        );
      }),
    );
  }

  Widget _emptyActionPlaceholder(String msg) => Container(
    height: 100,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: _cardShadow),
    child: Center(child: Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 12))),
  );
}

class _WithdrawalSummaryAlert extends StatelessWidget {
  final List<dynamic> requests;
  final intl.NumberFormat f;
  const _WithdrawalSummaryAlert({required this.requests, required this.f});

  @override
  Widget build(BuildContext context) {
    final rejected = requests.where((r) => r['status'] == 'rejected').length;
    final pending = requests.where((r) => r['status'] == 'pending').length;
    final hasRejected = rejected > 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _showDetailsSheet(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: (hasRejected ? _red : Colors.orange).withOpacity(0.2)),
            boxShadow: _cardShadow,
          ),
          child: Row(
            children: [
              Icon(hasRejected ? Icons.warning_amber_rounded : Icons.info_outline_rounded, 
                color: hasRejected ? _red : Colors.orange, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasRejected ? 'تنبيه: تم رفض بعض طلبات السحب' : 'متابعة طلبات السحب',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: hasRejected ? _red : _navy),
                    ),
                    Text(
                      'لديك $pending قيد المراجعة و $rejected مرفوضة. اضغط للتفاصيل.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text('تفاصيل تنبيهات السحب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _navy)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, i) {
                    final req = requests[i];
                    final isRej = req['status'] == 'rejected';
                    final color = isRej ? _red : Colors.orange;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.1))),
                      child: Row(
                        children: [
                          Icon(isRej ? Icons.cancel_outlined : Icons.pending_actions_rounded, color: color),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${f.format(req['amount'])} ر.س', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                                if (isRej && req['rejection_reason'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('سبب الرفض: ${req['rejection_reason']}', style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
                                  ),
                                Text(isRej ? 'تم الرفض' : 'قيد المراجعة', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WithdrawActionCard extends ConsumerWidget {
  final Investor investor;
  const _WithdrawActionCard({required this.investor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool active = investor.availableBalance > 0;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: active ? () => _showWithdrawalDialog(context, ref, investor) : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? _red.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
            boxShadow: _cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: active ? _red : Colors.grey, size: 28),
              const SizedBox(height: 8),
              const Text('سحب رصيد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _navy)),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawalDialog(BuildContext context, WidgetRef ref, Investor investor) {
    final amountController = TextEditingController();
    final bankController   = TextEditingController();
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        String? errorText;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('طلب سحب رصيد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _navy)),
                    const SizedBox(height: 20),
                    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المتاح للسحب', style: TextStyle(color: Colors.grey)), Text('${f.format(investor.availableBalance)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: _green))])),
                    const SizedBox(height: 20),
                    TextField(controller: amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'المبلغ المطلوب', suffixText: 'ر.س', errorText: errorText, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 16),
                    TextField(controller: bankController, decoration: InputDecoration(labelText: 'رقم الآيبان (IBAN)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _navy, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () async {
                      final amount = double.tryParse(amountController.text);
                      if (amount == null || amount <= 0 || amount > investor.availableBalance) { setDialogState(() => errorText = 'المبلغ غير صالح'); return; }
                      final success = await ref.read(withdrawalRequestsControllerProvider().notifier).requestWithdrawal(amount, bankController.text);
                      if (context.mounted) { Navigator.pop(ctx); if (success) SnackBarHelper.showSuccess(context, 'تم إرسال الطلب بنجاح ✓'); }
                    }, child: const Text('إرسال الطلب'))),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CompactStatsRow extends StatelessWidget {
  final Investor investor;
  final intl.NumberFormat f;
  const _CompactStatsRow({required this.investor, required this.f});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      _miniHeaderStat('المتاح', f.format(investor.availableBalance), _green),
      const SizedBox(width: 20),
      _miniHeaderStat('المشغل', f.format(investor.deployedCapital), _blue),
    ],
  );

  Widget _miniHeaderStat(String label, String val, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
      Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    ],
  );
}

class _ProfitChartCard extends StatelessWidget {
  final AsyncValue<List<dynamic>> txAsync;
  final double totalProfit;
  final intl.NumberFormat f;
  const _ProfitChartCard({required this.txAsync, required this.totalProfit, required this.f});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _cardShadow,
      ),
      child: txAsync.when(
        data: (txs) {
          final profits = txs.where((t) => t.type == InvestorTransactionType.financeProfitDistribution).toList();
          if (profits.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart_rounded, color: Colors.grey, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'سيظهر منحنى نمو الأرباح هنا فور تحصيل أول قسط وتوزيع الأرباح',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          final sortedProfits = profits.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          // 1. حساب الأرباح التراكمية والتواريخ
          final List<FlSpot> spots = [];
          final List<DateTime> dates = [];
          final List<double> singlePresents = [];

          double cumulativeSum = 0;

          // نقطة البداية (قبل أول عملية لبيان الانطلاق من الصفر)
          final DateTime firstDate = sortedProfits.first.createdAt;
          spots.add(const FlSpot(0, 0));
          dates.add(firstDate.subtract(const Duration(days: 1)));
          singlePresents.add(0);

          for (int i = 0; i < sortedProfits.length; i++) {
            final tx = sortedProfits[i];
            final amt = (tx.amount as num).toDouble().abs();
            cumulativeSum += amt;
            spots.add(FlSpot((i + 1).toDouble(), cumulativeSum));
            dates.add(tx.createdAt);
            singlePresents.add(amt);
          }

          final double maxVal = cumulativeSum > 0 ? cumulativeSum : 100;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر العلوي للشارت
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إجمالي التراكم المالي',
                        style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${f.format(totalProfit)} ر.س',
                        style: const TextStyle(color: _navy, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_upward_rounded, color: _green, size: 14),
                        SizedBox(width: 4),
                        Text('تزايد مستمر', style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // الرسم البياني التفاعلي
              Expanded(
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: _navy,
                        tooltipRoundedRadius: 12,
                        tooltipPadding: const EdgeInsets.all(12),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.toInt();
                            final dateStr = (idx >= 0 && idx < dates.length)
                                ? intl.DateFormat('dd/MM/yyyy').format(dates[idx])
                                : '';
                            final added = (idx >= 0 && idx < singlePresents.length) ? singlePresents[idx] : 0.0;

                            return LineTooltipItem(
                              'الأرباح التراكمية: ${f.format(spot.y)} ر.س\n',
                              const TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 12),
                              children: [
                                if (added > 0)
                                  TextSpan(
                                    text: 'دفعة ربح جديدة: +${f.format(added)} ر.س\n',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                TextSpan(
                                  text: 'التاريخ: $dateStr',
                                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxVal / 3).clamp(1.0, double.infinity),
                      getDrawingHorizontalLine: (val) => FlLine(
                        color: Colors.grey.withValues(alpha: 0.08),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                      // المحور الأفقي (التواريخ والأشهر)
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: (spots.length / 4).clamp(1.0, double.infinity),
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < dates.length) {
                              final dt = dates[idx];
                              // طباعة التواريخ بتنسيق يوم/شهر واضح بالعربية
                              final label = intl.DateFormat('dd/MM').format(dt);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  label,
                                  style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),

                      // المحور الرأسي (المبالغ المالية بالعربية)
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 55,
                          interval: (maxVal / 3).clamp(1.0, double.infinity),
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('0', style: TextStyle(color: Colors.grey, fontSize: 9));
                            String text;
                            if (value >= 1000000) {
                              text = '${(value / 1000000).toStringAsFixed(1)} مليون';
                            } else if (value >= 1000) {
                              text = '${(value / 1000).toStringAsFixed(1)} ألف';
                            } else {
                              text = value.toStringAsFixed(0);
                            }
                            return Text(
                              text,
                              style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.25,
                        color: _gold,
                        barWidth: 3.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: _gold,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              _gold.withValues(alpha: 0.25),
                              _gold.withValues(alpha: 0.01),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: _navy, strokeWidth: 2)),
        error: (_, __) => const SizedBox(),
      ),
    );
  }
}

class _PerformanceColumn extends StatelessWidget {
  final Investor investor;
  final intl.NumberFormat f;
  const _PerformanceColumn({required this.investor, required this.f});
  @override
  Widget build(BuildContext context) => Column(children: [_statCard('أرباح محققة', '${f.format(investor.totalProfitEarned)} ر.س', Icons.trending_up, _gold), const SizedBox(height: 12), _statCard('رأس مال عامل', '${f.format(investor.deployedCapital)} ر.س', Icons.rocket_launch, _blue), const SizedBox(height: 12), _statCard('سيولة متاحة', '${f.format(investor.availableBalance)} ر.س', Icons.account_balance_wallet, _green)]);
  Widget _statCard(String label, String val, IconData icon, Color color) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow), child: Row(children: [CircleAvatar(radius: 16, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 16)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)), FittedBox(child: Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))]))]));
}

class _NextPayoutCard extends StatelessWidget {
  final double amount;
  final String date;
  final intl.NumberFormat f;
  const _NextPayoutCard({required this.amount, required this.date, required this.f});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_blue, Color(0xFF1E40AF)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: _blue.withOpacity(0.2), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [const Text('الاستحقاق القادم', style: TextStyle(color: Colors.white70, fontSize: 10)), const SizedBox(height: 4), Text('${f.format(amount)} ر.س', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 4), Text(date, style: const TextStyle(color: Colors.white54, fontSize: 10))]));
}

class _RecentActivityList extends StatelessWidget {
  final AsyncValue<List<dynamic>> txAsync;
  final intl.NumberFormat f;
  const _RecentActivityList({required this.txAsync, required this.f});
  @override
  Widget build(BuildContext context) => txAsync.when(
    data: (txs) => txs.isEmpty ? const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('لا توجد عمليات مسجلة بعد.', style: TextStyle(color: Colors.grey, fontSize: 11)))) : Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: _cardShadow), child: ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: min(txs.length, 5), separatorBuilder: (_, __) => const Divider(height: 1, indent: 60), itemBuilder: (ctx, i) {
      final tx = txs[i];
      final isPlus = tx.type == InvestorTransactionType.deposit || tx.type == InvestorTransactionType.financeProfitDistribution || tx.type == InvestorTransactionType.contractReturn;
      return ListTile(dense: true, leading: CircleAvatar(radius: 14, backgroundColor: (isPlus ? _green : _red).withOpacity(0.1), child: Icon(isPlus ? Icons.arrow_downward : Icons.arrow_upward, color: isPlus ? _green : _red, size: 14)), title: Text(tx.type.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), subtitle: Text(intl.DateFormat('yyyy/MM/dd HH:mm').format(tx.createdAt), style: const TextStyle(fontSize: 10, color: Colors.grey)), trailing: Text('${isPlus ? "+" : "-"}${f.format(tx.amount.abs())}', style: TextStyle(fontWeight: FontWeight.bold, color: isPlus ? _green : _red, fontSize: 13)));
    })),
    loading: () => const SizedBox(),
    error: (_, __) => const SizedBox(),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _SectionHeader({required this.title, required this.subtitle, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: _navy.withOpacity(0.7), size: 16), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _navy)), Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10))])]);
}

class _PortfolioTab extends ConsumerWidget {
  final String investorId;
  const _PortfolioTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(investorFundedContractsControllerProvider(investorId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return contractsAsync.when(data: (contracts) => contracts.isEmpty ? const _EmptyState(icon: Icons.assignment_outlined, title: 'لا توجد استثمارات', subtitle: 'لم يتم تخصيص عقود لمحفظتك بعد') : ListView.builder(padding: const EdgeInsets.all(24), itemCount: contracts.length, itemBuilder: (ctx, i) {
      final item = contracts[i];
      final contract = item['financing_contracts'] as Map?;
      if (contract == null) return const SizedBox();
      return Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: _cardShadow), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _navy.withOpacity(0.05), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.description_outlined, color: _navy)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('عقد رقم ${contract['contract_no']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text('المبلغ المستثمر: ${f.format(item['amount_allocated'])} ر.س', style: const TextStyle(color: Colors.grey, fontSize: 11))])), _StatusBadge(status: contract['status'] ?? '')]));
    }), loading: () => const _LoadingScreen(), error: (e, _) => _ErrorScreen(message: e.toString()));
  }
}

class _TransactionsTab extends ConsumerWidget {
  final String investorId;
  const _TransactionsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(investorTransactionsControllerProvider(investorId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return txAsync.when(data: (txs) => txs.isEmpty ? const _EmptyState(icon: Icons.history, title: 'لا توجد عمليات', subtitle: 'سجل معاملاتك المالية سيظهر هنا') : ListView.separated(padding: const EdgeInsets.all(24), itemCount: txs.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (ctx, i) {
      final tx = txs[i];
      final isPlus = tx.type == InvestorTransactionType.deposit || tx.type == InvestorTransactionType.financeProfitDistribution || tx.type == InvestorTransactionType.contractReturn;
      return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: _cardShadow), child: Row(children: [CircleAvatar(backgroundColor: (isPlus ? _green : _red).withValues(alpha: 0.1), child: Icon(isPlus ? Icons.arrow_downward : Icons.arrow_upward, color: isPlus ? _green : _red, size: 18)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tx.type.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(intl.DateFormat('yyyy/MM/dd | hh:mm a').format(tx.createdAt.toLocal()), style: const TextStyle(color: Colors.grey, fontSize: 10))])), Text('${isPlus ? "+" : "-"}${f.format(tx.amount.abs())}', style: TextStyle(fontWeight: FontWeight.bold, color: isPlus ? _green : _red, fontSize: 14))]));
    }), loading: () => const _LoadingScreen(), error: (e, _) => _ErrorScreen(message: e.toString()));
  }
}

class _ProjectionsTab extends ConsumerWidget {
  final String investorId;
  const _ProjectionsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectionsAsync = ref.watch(investorProjectionsProvider(investorId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    return projectionsAsync.when(data: (list) => list.isEmpty ? const _EmptyState(icon: Icons.event_note, title: 'لا توجد توقعات', subtitle: 'سيتم جدولة أرباحك عند تفعيل العقود') : ListView.builder(padding: const EdgeInsets.all(24), itemCount: list.length, itemBuilder: (ctx, i) {
      final item = list[i];
      return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _blue.withOpacity(0.1))), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text('${i + 1}', style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)))), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('دفعة استحقاق أرباح', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(item['due_date'] ?? 'غير محدد', style: const TextStyle(color: Colors.grey, fontSize: 11))])), Text('${f.format((item['total_expected'] as num).toDouble())} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: _green))]));
    }), loading: () => const _LoadingScreen(), error: (e, _) => _ErrorScreen(message: e.toString()));
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = status == 'active' ? _green : Colors.orange;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(status == 'active' ? 'نشط' : 'قيد الانتظار', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)));
  }
}

class _NotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _NotificationBadge({required this.count, required this.onTap});
  @override
  Widget build(BuildContext context) => IconButton(icon: Badge(label: Text('$count'), isLabelVisible: count > 0, child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20)), onPressed: onTap);
}

class _LoadingScreen extends StatelessWidget { const _LoadingScreen(); @override Widget build(BuildContext context) => const Center(child: CircularProgressIndicator(color: _navy)); }
class _ErrorScreen extends StatelessWidget { final String message; const _ErrorScreen({required this.message}); @override Widget build(BuildContext context) => Center(child: Text(message)); }
class _NoInvestorPage extends StatelessWidget { final VoidCallback onBack; const _NoInvestorPage({required this.onBack}); @override Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.person_off_outlined, size: 48, color: Colors.grey), const SizedBox(height: 16), const Text('غير مرتبط بمستثمر'), TextButton(onPressed: onBack, child: const Text('العودة'))])); }
class _EmptyState extends StatelessWidget { final IconData icon; final String title, subtitle; const _EmptyState({required this.icon, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 48, color: Colors.grey.withOpacity(0.5)), const SizedBox(height: 16), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: _navy)), Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12))])); }
