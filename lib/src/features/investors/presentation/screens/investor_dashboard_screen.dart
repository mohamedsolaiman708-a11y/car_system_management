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

// ─── Color Palette ──────────────────────────────────────────────────────────
const _navy     = Color(0xFF0D1B3E);
const _navyLight= Color(0xFF1A2E5A);
const _gold     = Color(0xFFC5A35E);
const _bg       = Color(0xFFF0F4FB);
const _green    = Color(0xFF27AE60);
const _red      = Color(0xFFEB5757);

// ─── Main Screen ────────────────────────────────────────────────────────────
class InvestorDashboardScreen extends ConsumerWidget {
  const InvestorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                body: TabBarView(
                  children: [
                    _OverviewTab(investor: investor, userId: user.id),
                    _PortfolioTab(investorId: investor.id),
                    _TransactionsTab(investorId: investor.id),
                    _ProjectionsTab(investorId: investor.id),
                    UniversalDocumentManager(investorId: investor.id),
                  ],
                ),
              );
            },
            loading: () => const _LoadingScreen(),
            error: (err, _) => _ErrorScreen(
              message: Failure.fromException(err).message,
              onRetry: () => ref.invalidate(investorDetailsControllerProvider(user.id)),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sliver App Bar ──────────────────────────────────────────────────────────
class _InvestorSliverAppBar extends StatelessWidget {
  final Investor investor;
  final int unreadCount;
  final VoidCallback onLogout;
  final VoidCallback onNotifications;
  const _InvestorSliverAppBar({
    required this.investor,
    required this.unreadCount,
    required this.onLogout,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final total = investor.availableBalance + investor.deployedCapital;
    final topPadding = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      expandedHeight: 320,
      floating: false,
      pinned: true,
      backgroundColor: _navy,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        _NotificationBadge(count: unreadCount, onTap: onNotifications),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          onPressed: onLogout,
          tooltip: 'تسجيل الخروج',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_navy, _navyLight, Color(0xFF0F2552)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(top: -40, left: -40, child: _Circle(120, Colors.white.withValues(alpha: 0.03))),
              Positioned(bottom: 60, right: -30, child: _Circle(100, _gold.withValues(alpha: 0.07))),
              Positioned(top: 80, right: 40, child: _Circle(50, Colors.white.withValues(alpha: 0.04))),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: _gold.withValues(alpha: 0.2),
                                child: Text(
                                  investor.fullName.isNotEmpty ? investor.fullName[0] : 'م',
                                  style: const TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('مرحباً،', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                    Text(
                                      investor.fullName,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Center(
                            child: Column(
                              children: [
                                const Text('إجمالي قيمة المحفظة', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 8),
                                Text(
                                  '${f.format(total)} ر.س',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                _HeroStat(
                                  label: 'رصيد متاح للسحب',
                                  value: '${f.format(investor.availableBalance)} ر.س',
                                  icon: Icons.account_balance_wallet_rounded,
                                  color: const Color(0xFF4ADE80),
                                ),
                                Container(width: 1, height: 35, color: Colors.white12),
                                _HeroStat(
                                  label: 'رأس مال مشغّل',
                                  value: '${f.format(investor.deployedCapital)} ر.س',
                                  icon: Icons.rocket_launch_rounded,
                                  color: const Color(0xFF60A5FA),
                                ),
                                Container(width: 1, height: 35, color: Colors.white12),
                                _HeroStat(
                                  label: 'إجمالي الأرباح',
                                  value: '${f.format(investor.totalProfitEarned)} ر.س',
                                  icon: Icons.trending_up_rounded,
                                  color: _gold,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          decoration: const BoxDecoration(
            color: _navy,
            border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: _gold,
                indicatorWeight: 3,
                labelColor: _gold,
                unselectedLabelColor: Colors.white54,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, fontFamily: 'Cairo'),
                tabs: [
                  Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard_rounded, size: 18)),
                  Tab(text: 'محفظة العقود', icon: Icon(Icons.account_balance_rounded, size: 18)),
                  Tab(text: 'كشف الحساب', icon: Icon(Icons.receipt_long_rounded, size: 18)),
                  Tab(text: 'التوقعات', icon: Icon(Icons.insights_rounded, size: 18)),
                  Tab(text: 'المستندات', icon: Icon(Icons.folder_copy_rounded, size: 18)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Overview Tab ────────────────────────────────────────────────────────────
class _OverviewTab extends ConsumerWidget {
  final Investor investor;
  final String userId;
  const _OverviewTab({required this.investor, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final txAsync = ref.watch(investorTransactionsControllerProvider(investor.id));

    return RefreshIndicator(
      color: _navy,
      onRefresh: () async {
        await ref.read(investorDetailsControllerProvider(userId).notifier).refresh();
        ref.invalidate(investorTransactionsControllerProvider(investor.id));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            label: 'طلب سحب',
                            icon: Icons.account_balance_wallet_rounded,
                            color: _red,
                            onTap: investor.availableBalance > 0
                                ? () => _showWithdrawalDialog(context, ref, investor)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _QuickActionCard(
                            label: 'كشف الحساب',
                            icon: Icons.receipt_long_rounded,
                            color: _navy,
                            onTap: () => DefaultTabController.of(context).animateTo(2),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _QuickActionCard(
                            label: 'التوقعات',
                            icon: Icons.insights_rounded,
                            color: _green,
                            onTap: () => DefaultTabController.of(context).animateTo(3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    if (isWide) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionHeader(
                                  title: 'مسار الأرباح الموزعة',
                                  subtitle: 'تطور دخلك الاستثماري عبر الزمن',
                                  icon: Icons.auto_graph_rounded,
                                ),
                                const SizedBox(height: 16),
                                _ProfitChartCard(txAsync: txAsync),
                                const SizedBox(height: 24),
                                if (investor.availableBalance > 0)
                                  _WithdrawalCTA(
                                    availableBalance: investor.availableBalance,
                                    f: f,
                                    onTap: () => _showWithdrawalDialog(context, ref, investor),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionHeader(
                                  title: 'مؤشرات الأداء',
                                  subtitle: 'ملخص شامل لأداء محفظتك',
                                  icon: Icons.bar_chart_rounded,
                                ),
                                const SizedBox(height: 16),
                                _PerformanceGrid(investor: investor, f: f),
                                const SizedBox(height: 24),
                                _SectionHeader(
                                  title: 'صحة المحفظة',
                                  subtitle: 'توزيع رأس المال حسب الحالة',
                                  icon: Icons.pie_chart_rounded,
                                ),
                                const SizedBox(height: 16),
                                _PortfolioHealthCard(investor: investor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _SectionHeader(
                        title: 'مسار الأرباح الموزعة',
                        subtitle: 'تطور دخلك الاستثماري عبر الزمن',
                        icon: Icons.auto_graph_rounded,
                      ),
                      const SizedBox(height: 12),
                      _ProfitChartCard(txAsync: txAsync),
                      const SizedBox(height: 28),
                      _SectionHeader(
                        title: 'مؤشرات الأداء',
                        subtitle: 'ملخص شامل لأداء محفظتك',
                        icon: Icons.bar_chart_rounded,
                      ),
                      const SizedBox(height: 12),
                      _PerformanceGrid(investor: investor, f: f),
                      const SizedBox(height: 28),
                      if (investor.availableBalance > 0)
                        _WithdrawalCTA(
                          availableBalance: investor.availableBalance,
                          f: f,
                          onTap: () => _showWithdrawalDialog(context, ref, investor),
                        ),
                    ],
                  ],
                );
              },
            ),
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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          String? errorText;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: _red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.account_balance_wallet_rounded, color: _red, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('طلب سحب رصيد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _navy)),
                                Text('سيتم مراجعة طلبك خلال 24 ساعة', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _green.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: _green, size: 18),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('الرصيد المتاح للسحب', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                Text('${f.format(investor.availableBalance)} ر.س',
                                    style: const TextStyle(color: _green, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'المبلغ المراد سحبه',
                          hintText: 'أدخل المبلغ بالريال',
                          suffixText: 'ر.س',
                          errorText: errorText,
                          prefixIcon: const Icon(Icons.monetization_on_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: bankController,
                        decoration: InputDecoration(
                          labelText: 'رقم الآيبان (IBAN)',
                          hintText: 'SA...',
                          prefixIcon: const Icon(Icons.account_balance_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('إلغاء'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navy,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                final amount = double.tryParse(amountController.text);
                                if (amount == null || amount <= 0 || amount > investor.availableBalance) {
                                  setDialogState(() => errorText = 'المبلغ غير صالح أو يتجاوز الرصيد المتاح');
                                  return;
                                }
                                final success = await ref
                                    .read(withdrawalRequestsControllerProvider().notifier)
                                    .requestWithdrawal(amount, bankController.text);
                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                  if (success) {
                                    SnackBarHelper.showSuccess(context, 'تم إرسال طلب السحب بنجاح ✓');
                                  } else {
                                    SnackBarHelper.showError(context, 'فشل إرسال الطلب');
                                  }
                                }
                              },
                              child: const Text('إرسال الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Portfolio Tab ───────────────────────────────────────────────────────────
class _PortfolioTab extends ConsumerWidget {
  final String investorId;
  const _PortfolioTab({required this.investorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(investorFundedContractsControllerProvider(investorId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return contractsAsync.when(
      skipLoadingOnRefresh: true,
      data: (contracts) {
        if (contracts.isEmpty) {
          return const _EmptyState(
            icon: Icons.account_balance_rounded,
            title: 'لا توجد عقود ممولة',
            subtitle: 'ستظهر عقودك الممولة هنا بمجرد تخصيص رأس المال',
          );
        }

        double totalAllocated = contracts.fold(0.0, (s, c) => s + ((c['amount_allocated'] as num?)?.toDouble() ?? 0));
        int activeCount = contracts.where((c) => (c['financing_contracts'] as Map?)?['status'] == 'active').length;

        return RefreshIndicator(
          color: _navy,
          onRefresh: () => ref.refresh(investorFundedContractsControllerProvider(investorId).future),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [_navy, _navyLight]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _MiniStat(
                                    label: 'إجمالي مبالغ العقود',
                                    value: '${f.format(totalAllocated)} ر.س',
                                    color: _gold,
                                  ),
                                ),
                                Container(width: 1, height: 40, color: Colors.white12),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _MiniStat(
                                    label: 'عقود نشطة',
                                    value: '$activeCount من ${contracts.length}',
                                    color: const Color(0xFF4ADE80),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text('تفاصيل عقود المحفظة', style: TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 15)),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                          final item = contracts[i];
                          final contract = item['financing_contracts'] as Map?;
                          if (contract == null) return const SizedBox();
                          final status   = (contract['status'] ?? '') as String;
                          final statusLabel = switch (status) {
                            'active'          => 'نشط',
                            'closed'          => 'مغلق',
                            'draft'           => 'مسودة',
                            'pending_funding' => 'في انتظار التمويل',
                            'defaulted'       => 'متعثر',
                            _                 => status,
                          };
                          final statusColor = switch (status) {
                            'active'          => _green,
                            'closed'          => Colors.grey,
                            'defaulted'       => _red,
                            _                 => Colors.orange,
                          };

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.assignment_rounded, color: statusColor, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'عقد رقم: ${contract['contract_no'] ?? 'N/A'}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'مساهمتك: ${f.format(item['amount_allocated'] ?? 0)} ر.س',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: contracts.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const _LoadingScreen(),
      error: (err, _) => _ErrorScreen(message: Failure.fromException(err).message),
    );
  }
}

// ─── Transactions Tab ────────────────────────────────────────────────────────
class _TransactionsTab extends ConsumerWidget {
  final String investorId;
  const _TransactionsTab({required this.investorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(investorTransactionsControllerProvider(investorId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return txAsync.when(
      skipLoadingOnRefresh: true,
      data: (txs) {
        if (txs.isEmpty) {
          return const _EmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'لا توجد معاملات بعد',
            subtitle: 'ستظهر جميع حركات حسابك هنا',
          );
        }

        return RefreshIndicator(
          color: _navy,
          onRefresh: () => ref.refresh(investorTransactionsControllerProvider(investorId).future),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Row(
                        children: [
                          const Text('جميع المعاملات', style: TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 15)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _navy.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${txs.length} معاملة', style: const TextStyle(color: _navy, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                          final tx     = txs[i];
                          final isPlus = tx.type.name == 'deposit' || tx.type.name == 'contract_return' || tx.type.name == 'finance_profit_distribution';
                          final color  = isPlus ? _green : _red;
                          final icon   = switch (tx.type.name) {
                            'deposit'                    => Icons.arrow_circle_down_rounded,
                            'withdrawal'                 => Icons.arrow_circle_up_rounded,
                            'contract_allocation'        => Icons.assignment_rounded,
                            'contract_return'            => Icons.assignment_return_rounded,
                            'finance_profit_distribution'=> Icons.auto_graph_rounded,
                            _                            => Icons.swap_horiz_rounded,
                          };

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, color: color, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.type.label,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        intl.DateFormat('yyyy/MM/dd – hh:mm a').format(tx.createdAt),
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${isPlus ? "+" : "-"}${f.format(tx.amount.abs())} ر.س',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: txs.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const _LoadingScreen(),
      error: (err, _) => _ErrorScreen(message: Failure.fromException(err).message),
    );
  }
}

// ─── Projections Tab ─────────────────────────────────────────────────────────
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
        if (list.isEmpty) {
          return const _EmptyState(
            icon: Icons.trending_up_rounded,
            title: 'لا توجد توقعات حالياً',
            subtitle: 'ستظهر هنا جداول الاستحقاق المتوقعة عند ارتباط عقودك',
          );
        }

        double total = list.fold(0.0, (sum, item) => sum + ((item['total_expected'] as num?)?.toDouble() ?? 0.0));

        return RefreshIndicator(
          color: _navy,
          onRefresh: () => ref.refresh(investorProjectionsProvider(investorId).future),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green.shade700, Colors.green.shade900],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.insights_rounded, color: Colors.white70, size: 28),
                                const SizedBox(height: 12),
                                const Text('إجمالي التدفقات النقدية المتوقعة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 8),
                                Text('${f.format(total)} ر.س',
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text('على ${list.length} دفعة قادمة', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text('جدول الاستحقاقات', style: TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 15)),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                          final item = list[i];
                          final dueDate = item['due_date'] as String?;
                          final amount  = (item['total_expected'] as num?)?.toDouble() ?? 0;
                          final isPast  = dueDate != null &&
                              DateTime.tryParse(dueDate)?.isBefore(DateTime.now()) == true;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: isPast
                                  ? Border.all(color: _red.withValues(alpha: 0.3))
                                  : null,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isPast ? _red : Colors.blue).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isPast ? Icons.event_busy_rounded : Icons.calendar_month_rounded,
                                    color: isPast ? _red : Colors.blue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'استحقاق ${i + 1}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        dueDate ?? 'تاريخ غير محدد',
                                        style: TextStyle(color: isPast ? _red : Colors.grey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${f.format(amount)} ر.س',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: list.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const _LoadingScreen(),
      error: (err, _) => _ErrorScreen(message: Failure.fromException(err).message),
    );
  }
}

// ─── Reusable Components ─────────────────────────────────────────────────────

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle(this.size, this.color);
  @override
  Widget build(BuildContext context) =>
      Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}


class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _HeroStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
      ],
    ),
  );
}

class _NotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _NotificationBadge({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: onTap),
      if (count > 0)
        Positioned(
          right: 8, top: 8,
          child: Container(
            width: 16, height: 16,
            decoration: const BoxDecoration(color: _red, shape: BoxShape.circle),
            child: Center(child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
          ),
        ),
    ],
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _SectionHeader({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: _navy.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: _navy, size: 20),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 16)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    ],
  );
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _QuickActionCard({required this.label, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    elevation: 4,
    shadowColor: Colors.black.withValues(alpha: 0.1),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: onTap == null ? Colors.grey : color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: onTap == null ? Colors.grey : _navy,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProfitChartCard extends StatelessWidget {
  final AsyncValue<List<dynamic>> txAsync;
  const _ProfitChartCard({required this.txAsync});

  @override
  Widget build(BuildContext context) => Container(
    height: 320,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
    ),
    child: txAsync.when(
      skipLoadingOnRefresh: true,
      data: (txs) {
        final profitTxs = txs.where((t) => t.type.name == 'finance_profit_distribution').toList();
        if (profitTxs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100, width: double.infinity,
                  child: CustomPaint(painter: _ZigZagPainter()),
                ),
                const SizedBox(height: 20),
                const Text('سيظهر الرسم البياني عند تحصيل أول دفعة أرباح',
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              ],
            ),
          );
        }
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
            ),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: profitTxs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value.amount as num).toDouble())).toList(),
                isCurved: true,
                curveSmoothness: 0.35,
                color: _gold,
                barWidth: 4,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [_gold.withValues(alpha: 0.2), _gold.withValues(alpha: 0.0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (_, __, ___, ____) =>
                      FlDotCirclePainter(radius: 5, color: Colors.white, strokeWidth: 3, strokeColor: _gold),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _navy)),
      error: (_, __) => const Center(child: Icon(Icons.bar_chart_rounded, color: Colors.grey, size: 48)),
    ),
  );
}

class _ZigZagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.4, size.height * 0.8);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.6);
    path.lineTo(size.width, size.height * 0.2);

    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PerformanceGrid extends StatelessWidget {
  final Investor investor;
  final intl.NumberFormat f;
  const _PerformanceGrid({required this.investor, required this.f});

  @override
  Widget build(BuildContext context) {
    final total = investor.availableBalance + investor.deployedCapital;
    final utilizationRate = total > 0 ? (investor.deployedCapital / total * 100) : 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatTile(
          label: 'إجمالي الأرباح المحققة',
          value: '${f.format(investor.totalProfitEarned)} ر.س',
          icon: Icons.auto_graph_rounded,
          color: Colors.orange,
        ),
        _StatTile(
          label: 'نسبة الرأس المال المشغّل',
          value: '${utilizationRate.toStringAsFixed(1)}%',
          icon: Icons.donut_large_rounded,
          color: Colors.blue,
        ),
        _StatTile(
          label: 'حالة المحفظة',
          value: investor.deployedCapital > 0 ? 'نشطة ومدرة' : 'بانتظار تمويل',
          icon: Icons.shield_rounded,
          color: investor.deployedCapital > 0 ? _green : Colors.grey,
        ),
        _StatTile(
          label: 'رأس المال المتاح',
          value: '${f.format(investor.availableBalance)} ر.س',
          icon: Icons.savings_rounded,
          color: _green,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 13)),
          ],
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis),
      ],
    ),
  );
}

class _PortfolioHealthCard extends StatelessWidget {
  final Investor investor;
  const _PortfolioHealthCard({required this.investor});

  @override
  Widget build(BuildContext context) {
    final total    = investor.availableBalance + investor.deployedCapital;
    final deployed = total > 0 ? investor.deployedCapital / total : 0.0;
    final available= total > 0 ? investor.availableBalance / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90, height: 90,
            child: CustomPaint(painter: _DonutPainter(deployed.clamp(0, 1))),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendItem(color: const Color(0xFF60A5FA), label: 'رأس مال مشغّل', pct: (deployed * 100).toStringAsFixed(1)),
                const SizedBox(height: 12),
                _LegendItem(color: const Color(0xFF4ADE80), label: 'رصيد متاح', pct: (available * 100).toStringAsFixed(1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double deployedRatio;
  const _DonutPainter(this.deployedRatio);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;
    const strokeW = 16.0;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFFF3F4F6);
    canvas.drawCircle(center, radius, paint);

    paint.color = const Color(0xFF60A5FA);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * deployedRatio, false, paint);

    paint.color = const Color(0xFF4ADE80);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2 + 2 * pi * deployedRatio, 2 * pi * (1 - deployedRatio), false, paint);
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.deployedRatio != deployedRatio;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String pct;
  const _LegendItem({required this.color, required this.label, required this.pct});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
      Text('$pct%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _navy)),
    ],
  );
}

class _WithdrawalCTA extends StatelessWidget {
  final double availableBalance;
  final intl.NumberFormat f;
  final VoidCallback onTap;
  const _WithdrawalCTA({required this.availableBalance, required this.f, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [_green, Colors.green.shade700]),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('لديك رصيد متاح للسحب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${f.format(availableBalance)} ر.س جاهزة للتحويل', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _green,
            minimumSize: const Size(0, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('اسحب الآن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    ),
  );
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: _navy.withValues(alpha: 0.06), shape: BoxShape.circle),
            child: Icon(icon, size: 52, color: _navy.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 16)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: _bg,
    body: Center(child: CircularProgressIndicator(color: _navy, strokeWidth: 2)),
  );
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorScreen({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _red.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded, color: _red, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('حدث خطأ', style: TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 18)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _NoInvestorPage extends StatelessWidget {
  final VoidCallback onBack;
  const _NoInvestorPage({required this.onBack});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.person_search_rounded, size: 64, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text('الحساب غير مرتبط بمستثمر', style: TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('يرجى التواصل مع الإدارة لربط حسابك بملف المستثمر الخاص بك', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.home_rounded),
              label: const Text('العودة للرئيسية'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
