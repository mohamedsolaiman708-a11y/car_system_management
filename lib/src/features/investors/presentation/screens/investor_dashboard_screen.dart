import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../../domain/investor.dart';
import '../investor_controller.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../../documents/presentation/widgets/universal_document_manager.dart';
import '../../../notifications/presentation/notification_controller.dart';

class InvestorDashboardScreen extends ConsumerWidget {
  const InvestorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // نستخدم user.id كمعرف أساسي وموحد لجلب بيانات المستثمر
    final investorAsync = ref.watch(investorDetailsControllerProvider(user.id));
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text(
              'بوابة المستثمر الذكية',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              _NotificationBadge(count: unreadCount),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                tooltip: 'تسجيل الخروج',
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
          body: investorAsync.when(
            skipLoadingOnRefresh: true, // الحفاظ على البيانات القديمة أثناء التحديث لمنع "الرمشة"
            data: (investor) {
              if (investor == null) return _buildNoInvestorLinked(context);

              return TabBarView(
                children: [
                  _OverviewTab(investor: investor, userId: user.id),
                  _PortfolioTab(investorId: investor.id),
                  _TransactionsTab(investorId: investor.id),
                  _ProjectionsTab(investorId: investor.id),
                  UniversalDocumentManager(investorId: investor.id),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      Failure.fromException(err).message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(investorDetailsControllerProvider(user.id)),
                      child: const Text('إعادة المحاولة'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoInvestorLinked(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_search_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('عذراً، هذا الحساب غير مربوط بملف مستثمر.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('العودة للوحة التحكم'),
          ),
        ],
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

    return RefreshIndicator(
      onRefresh: () async {
        // نستخدم userId الموحد لضمان تحديث الـ Provider الصحيح
        await ref.read(investorDetailsControllerProvider(userId).notifier).refresh();
        ref.invalidate(investorTransactionsControllerProvider(investor.id));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                _buildSmallStatCard('إجمالي الأرباح المحققة', f.format(investor.totalProfitEarned), Icons.auto_graph_rounded, Colors.orange),
                const SizedBox(width: 16),
                _buildSmallStatCard('حالة الاستثمار', investor.deployedCapital > 0 ? "نشط ومدر للدخل" : "بانتظار فرص تمويل", Icons.assignment_turned_in_rounded, investor.deployedCapital > 0 ? Colors.green : Colors.blue),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showWithdrawalDialog(context, ref, investor),
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('طلب سحب رصيد متاح من المحفظة'),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100)),
      child: txAsync.when(
        skipLoadingOnRefresh: true,
        data: (txs) {
          try {
            final profitTxs = txs.where((t) => t.type.name == 'finance_profit_distribution').toList();
            if (profitTxs.isEmpty) {
              return const Center(child: Text('سيظهر الرسم البياني عند تحصيل أول دفعة أرباح', style: TextStyle(color: Colors.grey, fontSize: 12)));
            }

            return LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: profitTxs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value.amount as num).toDouble())).toList(),
                    isCurved: true,
                    color: AppColors.accentGold,
                    barWidth: 4,
                    belowBarData: BarAreaData(show: true, color: AppColors.accentGold.withValues(alpha: 0.1)),
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            );
          } catch (e) {
            return const Center(child: Icon(Icons.show_chart_rounded, color: Colors.grey));
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Icon(Icons.show_chart_rounded, color: Colors.grey)),
      ),
    );
  }

  Widget _buildBalanceHeroCard(Investor investor, intl.NumberFormat f) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0D1B3E), Color(0xFF1A2E5A)]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          const Text('إجمالي القيمة الاستثمارية (المحفظة)', style: TextStyle(color: Colors.white60, fontSize: 14)),
          const SizedBox(height: 12),
          Text('${f.format(investor.availableBalance + investor.deployedCapital)} ر.س', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroStat('رصيد متاح للسحب', f.format(investor.availableBalance), Colors.greenAccent),
              _buildHeroStat('رأس مال قيد التشغيل', f.format(investor.deployedCapital), Colors.blueAccent),
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
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSmallStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryNavy), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalDialog(BuildContext context, WidgetRef ref, Investor investor) {
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
            title: const Text('طلب سحب أرباح ونقدية'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الرصيد المتاح:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${f.format(investor.availableBalance)} ر.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'المبلغ المراد سحبه (ر.س)', border: const OutlineInputBorder(), errorText: errorText, prefixIcon: const Icon(Icons.money_rounded)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankController,
                  decoration: const InputDecoration(labelText: 'تفاصيل الحساب البنكي (IBAN)', border: OutlineInputBorder(), hintText: 'SA...', prefixIcon: Icon(Icons.account_balance_rounded)),
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
                    setDialogState(() => errorText = 'المبلغ يتجاوز الرصيد المتاح');
                    return;
                  }
                  final success = await ref.read(withdrawalRequestsControllerProvider().notifier).requestWithdrawal(amount, bankController.text);
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    if (success) {
                      SnackBarHelper.showSuccess(context, 'تم إرسال طلب السحب بنجاح');
                    } else {
                      SnackBarHelper.showError(context, 'فشل إرسال الطلب');
                    }
                  }
                },
                child: const Text('إرسال طلب السحب'),
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
    return Stack(alignment: Alignment.center, children: [
      IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: () => context.push('/notifications')),
      if (count > 0) Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), constraints: const BoxConstraints(minWidth: 16, minHeight: 16), child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
    ]);
  }
}

class _PortfolioTab extends ConsumerWidget {
  final String investorId;
  const _PortfolioTab({required this.investorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(investorFundedContractsControllerProvider(investorId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return contractsAsync.when(
      skipLoadingOnRefresh: true,
      data: (contracts) => contracts.isEmpty 
        ? const Center(child: Text('لا توجد عقود ممولة في محفظتك حالياً')) 
        : ListView.builder(
            padding: const EdgeInsets.all(16), 
            itemCount: contracts.length, 
            itemBuilder: (context, index) {
              final item = contracts[index];
              final contract = item['financing_contracts'] as Map?;
              if (contract == null) return const SizedBox();
              
              final status = (contract['status'] ?? 'unknown') as String;
              return Card(
                elevation: 0, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100)), 
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: (status == 'active' ? Colors.green : Colors.orange).withValues(alpha: 0.1), child: Icon(Icons.assignment_rounded, color: status == 'active' ? Colors.green : Colors.orange, size: 20)), 
                  title: Text('عقد رقم: ${contract['contract_no'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)), 
                  subtitle: Text('قيمة مساهمتك: ${f.format(item['amount_allocated'] ?? 0)} ر.س'),
                )
              );
            }
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          Failure.fromException(err).message,
          style: const TextStyle(color: Colors.red, fontFamily: 'Cairo'),
        ),
      ),
    );
  }
}

class _TransactionsTab extends ConsumerWidget {
  final String investorId;
  const _TransactionsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(investorTransactionsControllerProvider(investorId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return txAsync.when(
      skipLoadingOnRefresh: true,
      data: (txs) => txs.isEmpty 
        ? const Center(child: Text('لا توجد عمليات مسجلة حتى الآن')) 
        : ListView.builder(
            padding: const EdgeInsets.all(16), 
            itemCount: txs.length, 
            itemBuilder: (context, index) {
              final tx = txs[index];
              final isPlus = tx.amount > 0;
              return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: Icon(isPlus ? Icons.add_circle_outline : Icons.remove_circle_outline, color: isPlus ? Colors.green : Colors.red), title: Text(tx.type.label), subtitle: Text(intl.DateFormat('yyyy/MM/dd HH:mm').format(tx.createdAt)), trailing: Text('${isPlus ? "+" : ""}${f.format(tx.amount)} ر.س', style: TextStyle(fontWeight: FontWeight.bold, color: isPlus ? Colors.green : Colors.red))));
            }
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          Failure.fromException(err).message,
          style: const TextStyle(color: Colors.red, fontFamily: 'Cairo'),
        ),
      ),
    );
  }
}

class _ProjectionsTab extends ConsumerWidget {
  final String investorId;
  const _ProjectionsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectionsAsync = ref.watch(investorProjectionsProvider(investorId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    return projectionsAsync.when(
      skipLoadingOnRefresh: true,
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('لا توجد تدفقات نقدية متوقعة حالياً'));
        double total = list.fold(0.0, (sum, item) => sum + ((item['total_expected'] as num?)?.toDouble() ?? 0.0));
        return Column(children: [
          Container(width: double.infinity, margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade900]), borderRadius: BorderRadius.circular(24)), child: Column(children: [const Text('إجمالي التدفقات النقدية القادمة لمحفظتك', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text('${f.format(total)} ر.س', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))])),
          Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: list.length, itemBuilder: (context, index) {
            final item = list[index];
            return Card(margin: const EdgeInsets.only(bottom: 12), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100)), child: ListTile(leading: const Icon(Icons.calendar_month_rounded, color: Colors.blue), title: Text('موعد استحقاق: ${item['due_date'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)), trailing: Text('${f.format(item['total_expected'] ?? 0)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))));
          })),
        ]);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          Failure.fromException(err).message,
          style: const TextStyle(color: Colors.red, fontFamily: 'Cairo'),
        ),
      ),
    );
  }
}
