import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../../domain/investor.dart';
import '../../domain/investor_transaction.dart';
import '../investor_controller.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../../documents/presentation/widgets/universal_document_manager.dart';
import '../../../notifications/presentation/notification_controller.dart';
import '../../domain/investor_transaction_type.dart';

// ─── Color Palette ──────────────────────────────────────────────────────────
const _navy = Color(0xFF0F172A);
const _gold = Color(0xFFD4AF37);
const _bg = Color(0xFFF1F5F9);
const _green = Color(0xFF10B981);
const _red = Color(0xFFEF4444);
const _blue = Color(0xFF3B82F6);
const _cardShadow = [
  BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
];

// ─── Main Screen ────────────────────────────────────────────────────────────
class InvestorDashboardScreen extends ConsumerWidget {
  const InvestorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final investorAsync = ref.watch(investorDetailsControllerProvider(user.id));
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: _bg,
          body: investorAsync.when(
            skipLoadingOnRefresh: true,
            data: (investor) {
              if (investor == null)
                return _NoInvestorPage(onBack: () => context.go('/dashboard'));
              return NestedScrollView(
                headerSliverBuilder: (ctx, _) => [
                  _InvestorSliverAppBar(
                    investor: investor,
                    unreadCount: unreadCount,
                    onLogout: () =>
                        ref.read(authControllerProvider.notifier).logout(),
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
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: UniversalDocumentManager(
                              investorId: investor.id,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const _LoadingScreen(),
            error: (err, _) =>
                _ErrorScreen(message: Failure.fromException(err).message),
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

    return SliverAppBar(
      expandedHeight: 270,
      pinned: true,
      backgroundColor: _navy,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 30,),
                  // ── Row 1: Avatar + Name + Actions ──────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [_gold, Color(0xFFE5C17E)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withValues(alpha: 0.35),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            investor.fullName.isNotEmpty ? investor.fullName[0] : 'م',
                            style: const TextStyle(
                              color: _navy,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Name + subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    investor.fullName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _gold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _gold.withValues(alpha: 0.4)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified_rounded, size: 10, color: _gold),
                                      SizedBox(width: 3),
                                      Text('مستثمر', style: TextStyle(color: _gold, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'مرحباً بك في محفظتك الاستثمارية',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Action Pill
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _NotificationBadge(count: unreadCount, onTap: onNotifications),
                            Container(width: 1, height: 16, color: Colors.white.withValues(alpha: 0.1)),
                            IconButton(
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.logout_rounded, color: Colors.white60, size: 16),
                              tooltip: 'تسجيل الخروج',
                              onPressed: onLogout,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Row 2: Hero Balance (center) ─────────────────────────
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 12, color: _gold.withValues(alpha: 0.7)),
                          const SizedBox(width: 5),
                          Text(
                            'إجمالي قيمة المحفظة',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            f.format(total),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: _gold.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Text(
                              'ر.س',
                              style: TextStyle(color: _gold, fontWeight: FontWeight.w900, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Row 3: 3 Mini KPI Cards ───────────────────────────────
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        _HeaderStatCard(
                          label: 'السيولة المتاحة',
                          value: f.format(investor.availableBalance),
                          color: _green,
                          icon: Icons.account_balance_rounded,
                        ),
                        const SizedBox(width: 8),
                        _HeaderStatCard(
                          label: 'رأس المال المشغل',
                          value: f.format(investor.deployedCapital),
                          color: _blue,
                          icon: Icons.trending_up_rounded,
                        ),
                        const SizedBox(width: 8),
                        _HeaderStatCard(
                          label: 'الأرباح المحققة',
                          value: f.format(investor.totalProfitEarned),
                          color: _gold,
                          icon: Icons.stars_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(46),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _navy,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: _gold,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: _gold,
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Cairo'),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, fontFamily: 'Cairo'),
            tabs: [
              Tab(text: 'نظرة عامة'),
              Tab(text: 'المحفظة'),
              Tab(text: 'العمليات'),
              Tab(text: 'التوقعات'),
              Tab(text: 'المستندات'),
            ],
          ),
        ),
      ),
    );
  }
}



class _HeaderStatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;

  const _HeaderStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
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
    final txAsync = ref.watch(
      investorTransactionsControllerProvider(investor.id),
    );
    final projAsync = ref.watch(investorProjectionsProvider(investor.id));
    final requestsAsync = ref.watch(
      withdrawalRequestsControllerProvider(investorId: investor.id),
    );

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(investorDetailsControllerProvider(userId).notifier)
            .refresh();
        ref.invalidate(investorTransactionsControllerProvider(investor.id));
        ref.invalidate(
          withdrawalRequestsControllerProvider(investorId: investor.id),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 850;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. تنبيهات طلبات السحب
                requestsAsync.when(
                  data: (requests) {
                    final activeReqs = requests
                        .where(
                          (r) =>
                              r['status'] == 'pending' ||
                              r['status'] == 'rejected',
                        )
                        .toList();
                    if (activeReqs.isEmpty) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _WithdrawalSummaryAlert(
                        requests: activeReqs,
                        f: f,
                      ),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),

                // 2. كروت الأداء والتأطير السريع
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: projAsync.when(
                        data: (list) => list.isEmpty
                            ? _emptyActionPlaceholder(
                                'لا توجد استحقاقات قادمة حالياً',
                              )
                            : _NextPayoutCard(
                                amount: (list.first['total_expected'] as num)
                                    .toDouble(),
                                date: list.first['due_date'] ?? '',
                                f: f,
                              ),
                        loading: () => const SizedBox(
                          height: 110,
                          child: Center(child: CircularProgressIndicator()),
                        ),
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
                          const _SectionHeader(
                            title: 'تحليل الأداء',
                            subtitle: 'نمو الأرباح المحققة',
                            icon: Icons.auto_graph_rounded,
                          ),
                          const SizedBox(height: 12),
                          _ProfitChartCard(
                            txAsync: txAsync,
                            totalProfit: investor.totalProfitEarned,
                            f: f,
                          ),
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
                            const _SectionHeader(
                              title: 'مؤشرات المحفظة',
                              subtitle: 'أرقامك الحالية',
                              icon: Icons.grid_view_rounded,
                            ),
                            const SizedBox(height: 12),
                            _PerformanceColumn(investor: investor, f: f),
                          ],
                        ),
                      ),
                  ],
                ),

                if (!isWide) ...[
                  const SizedBox(height: 24),
                  const _SectionHeader(
                    title: 'مؤشرات المحفظة',
                    subtitle: 'أرقامك الحالية',
                    icon: Icons.grid_view_rounded,
                  ),
                  const SizedBox(height: 12),
                  _PerformanceColumn(investor: investor, f: f),
                ],

                const SizedBox(height: 28),

                // 4. قسم أحدث العمليات السريعة
                const _SectionHeader(
                  title: 'أحدث العمليات',
                  subtitle: 'آخر الحركات الموثقة في محفظتك',
                  icon: Icons.history_rounded,
                ),
                const SizedBox(height: 12),
                _OverviewRecentActivity(txAsync: txAsync, f: f),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _emptyActionPlaceholder(String msg) => Container(
    height: 100,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: _cardShadow,
    ),
    child: Center(
      child: Text(
        msg,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    ),
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
            border: Border.all(
              color: (hasRejected ? _red : Colors.orange).withOpacity(0.2),
            ),
            boxShadow: _cardShadow,
          ),
          child: Row(
            children: [
              Icon(
                hasRejected
                    ? Icons.warning_amber_rounded
                    : Icons.info_outline_rounded,
                color: hasRejected ? _red : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasRejected
                          ? 'تنبيه: تم رفض بعض طلبات السحب'
                          : 'متابعة طلبات السحب',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: hasRejected ? _red : _navy,
                      ),
                    ),
                    Text(
                      'لديك $pending قيد المراجعة و $rejected مرفوضة. اضغط للتفاصيل.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey,
              ),
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'تفاصيل تنبيهات السحب',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: _navy,
                ),
              ),
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
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isRej
                                ? Icons.cancel_outlined
                                : Icons.pending_actions_rounded,
                            color: color,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${f.format(req['amount'])} ر.س',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: color,
                                  ),
                                ),
                                if (isRej && req['rejection_reason'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'سبب الرفض: ${req['rejection_reason']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: color.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                Text(
                                  isRej ? 'تم الرفض' : 'قيد المراجعة',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
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
        onTap: active
            ? () => _showWithdrawalDialog(context, ref, investor)
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 110,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active
                  ? _red.withValues(alpha: 0.25)
                  : Colors.grey.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: _cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (active ? _red : Colors.grey).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: active ? _red : Colors.grey,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'طلب سحب رصيد',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: active ? _navy : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                active ? 'متاح للسحب' : 'لا يوجد رصيد',
                style: TextStyle(
                  fontSize: 10,
                  color: active ? _green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawalDialog(
    BuildContext context,
    WidgetRef ref,
    Investor investor,
  ) {
    final amountController = TextEditingController();
    final bankController = TextEditingController();
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          String? errorText;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'طلب سحب رصيد',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'المتاح للسحب',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              '${f.format(investor.availableBalance)} ر.س',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'المبلغ المطلوب',
                          suffixText: 'ر.س',
                          errorText: errorText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: bankController,
                        decoration: InputDecoration(
                          labelText: 'رقم الآيبان (IBAN)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final amount = double.tryParse(
                              amountController.text,
                            );
                            if (amount == null ||
                                amount <= 0 ||
                                amount > investor.availableBalance) {
                              setDialogState(
                                () => errorText = 'المبلغ غير صالح',
                              );
                              return;
                            }
                            final success = await ref
                                .read(
                                  withdrawalRequestsControllerProvider()
                                      .notifier,
                                )
                                .requestWithdrawal(amount, bankController.text);
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              if (success)
                                SnackBarHelper.showSuccess(
                                  context,
                                  'تم إرسال الطلب بنجاح ✓',
                                );
                            }
                          },
                          child: const Text('إرسال الطلب'),
                        ),
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
      Text(
        label,
        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9),
      ),
      Text(
        val,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    ],
  );
}

class _ProfitChartCard extends StatelessWidget {
  final AsyncValue<List<dynamic>> txAsync;
  final double totalProfit;
  final intl.NumberFormat f;
  const _ProfitChartCard({
    required this.txAsync,
    required this.totalProfit,
    required this.f,
  });

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
          final profits = txs
              .where(
                (t) =>
                    t.type == InvestorTransactionType.financeProfitDistribution,
              )
              .toList();
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

          final sortedProfits = profits.toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

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
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${f.format(totalProfit)} ر.س',
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          color: _green,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'تزايد مستمر',
                          style: TextStyle(
                            color: _green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                                ? intl.DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(dates[idx])
                                : '';
                            final added =
                                (idx >= 0 && idx < singlePresents.length)
                                ? singlePresents[idx]
                                : 0.0;

                            return LineTooltipItem(
                              'الأرباح التراكمية: ${f.format(spot.y)} ر.س\n',
                              const TextStyle(
                                color: _gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              children: [
                                if (added > 0)
                                  TextSpan(
                                    text:
                                        'دفعة ربح جديدة: +${f.format(added)} ر.س\n',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                TextSpan(
                                  text: 'التاريخ: $dateStr',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
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
                      horizontalInterval: (maxVal / 3).clamp(
                        1.0,
                        double.infinity,
                      ),
                      getDrawingHorizontalLine: (val) => FlLine(
                        color: Colors.grey.withValues(alpha: 0.08),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      // المحور الأفقي (التواريخ والأشهر)
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: (spots.length / 4).clamp(
                            1.0,
                            double.infinity,
                          ),
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
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                            if (value == 0)
                              return const Text(
                                '0',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 9,
                                ),
                              );
                            String text;
                            if (value >= 1000000) {
                              text =
                                  '${(value / 1000000).toStringAsFixed(1)} مليون';
                            } else if (value >= 1000) {
                              text = '${(value / 1000).toStringAsFixed(1)} ألف';
                            } else {
                              text = value.toStringAsFixed(0);
                            }
                            return Text(
                              text,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
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
        loading: () => const Center(
          child: CircularProgressIndicator(color: _navy, strokeWidth: 2),
        ),
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
  Widget build(BuildContext context) => Column(
    children: [
      _statCard(
        'أرباح محققة',
        '${f.format(investor.totalProfitEarned)} ر.س',
        Icons.trending_up,
        _gold,
      ),
      const SizedBox(height: 12),
      _statCard(
        'رأس مال عامل',
        '${f.format(investor.deployedCapital)} ر.س',
        Icons.rocket_launch,
        _blue,
      ),
      const SizedBox(height: 12),
      _statCard(
        'سيولة متاحة',
        '${f.format(investor.availableBalance)} ر.س',
        Icons.account_balance_wallet,
        _green,
      ),
    ],
  );
  Widget _statCard(String label, String val, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _cardShadow,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  FittedBox(
                    child: Text(
                      val,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _NextPayoutCard extends StatelessWidget {
  final double amount;
  final String date;
  final intl.NumberFormat f;
  const _NextPayoutCard({
    required this.amount,
    required this.date,
    required this.f,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _blue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        'الاستحقاق القادم',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'أقرب دفعة ⭐',
                          style: TextStyle(color: _gold, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${f.format(amount)} ر.س',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 10, color: Colors.white.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _OverviewRecentActivity extends StatelessWidget {
  final AsyncValue<List<dynamic>> txAsync;
  final intl.NumberFormat f;

  const _OverviewRecentActivity({
    required this.txAsync,
    required this.f,
  });

  @override
  Widget build(BuildContext context) {
    return txAsync.when(
      data: (txs) {
        if (txs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: _cardShadow,
            ),
            child: const Center(
              child: Text(
                'لا توجد عمليات موثقة بعد',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          );
        }

        final recentList = txs.take(4).toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _cardShadow,
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentList.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
            itemBuilder: (ctx, i) {
              final tx = recentList[i];
              final isPlus = tx.type == InvestorTransactionType.deposit ||
                  tx.type == InvestorTransactionType.financeProfitDistribution ||
                  tx.type == InvestorTransactionType.contractReturn;

              final accentColor = isPlus ? _green : _red;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlus ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                title: Text(
                  tx.type.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _navy,
                  ),
                ),
                subtitle: Text(
                  intl.DateFormat('yyyy/MM/dd | hh:mm a').format(tx.createdAt.toLocal()),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                trailing: Text(
                  '${isPlus ? "+" : "-"}${f.format(tx.amount.abs())} ر.س',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  final AsyncValue<List<dynamic>> txAsync;
  final intl.NumberFormat f;
  const _RecentActivityList({required this.txAsync, required this.f});
  @override
  Widget build(BuildContext context) => txAsync.when(
    data: (txs) => txs.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'لا توجد عمليات مسجلة بعد.',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: _cardShadow,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: min(txs.length, 5),
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
              itemBuilder: (ctx, i) {
                final tx = txs[i];
                final isPlus =
                    tx.type == InvestorTransactionType.deposit ||
                    tx.type ==
                        InvestorTransactionType.financeProfitDistribution ||
                    tx.type == InvestorTransactionType.contractReturn;
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: (isPlus ? _green : _red).withOpacity(0.1),
                    child: Icon(
                      isPlus ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isPlus ? _green : _red,
                      size: 14,
                    ),
                  ),
                  title: Text(
                    tx.type.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Text(
                    intl.DateFormat('yyyy/MM/dd HH:mm').format(tx.createdAt),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  trailing: Text(
                    '${isPlus ? "+" : "-"}${f.format(tx.amount.abs())}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPlus ? _green : _red,
                      fontSize: 13,
                    ),
                  ),
                );
              },
            ),
          ),
    loading: () => const SizedBox(),
    error: (_, __) => const SizedBox(),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: _navy.withOpacity(0.7), size: 16),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: _navy,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    ],
  );
}

class _PortfolioTab extends ConsumerStatefulWidget {
  final String investorId;
  const _PortfolioTab({required this.investorId});

  @override
  ConsumerState<_PortfolioTab> createState() => _PortfolioTabState();
}

class _PortfolioTabState extends ConsumerState<_PortfolioTab> {
  String _selectedFilter = 'all'; // 'all', 'active', 'completed', 'pending'
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(
      investorFundedContractsControllerProvider(widget.investorId),
    );
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return contractsAsync.when(
      data: (contracts) {
        if (contracts.isEmpty) {
          return const _EmptyState(
            icon: Icons.assignment_outlined,
            title: 'لا توجد استثمارات',
            subtitle: 'لم يتم تخصيص عقود لمحفظتك بعد',
          );
        }

        // حساب الإحصائيات الشاملة للمحفظة
        double totalAllocatedSum = 0;
        int activeCount = 0;
        int completedCount = 0;
        int pendingCount = 0;

        for (final item in contracts) {
          final allocated = (item['amount_allocated'] as num?)?.toDouble() ?? 0.0;
          totalAllocatedSum += allocated;
          final contract = item['financing_contracts'] as Map?;
          final status = (contract?['status'] as String?)?.toLowerCase() ?? '';

          if (status == 'active' || status == 'نشط') {
            activeCount++;
          } else if (status == 'completed' || status == 'مكتمل') {
            completedCount++;
          } else {
            pendingCount++;
          }
        }

        // تصفية العقود بحسب الحالة والبحث
        final filteredContracts = contracts.where((item) {
          final contract = item['financing_contracts'] as Map?;
          if (contract == null) return false;

          final status = (contract['status'] as String?)?.toLowerCase() ?? '';
          final contractNo = (contract['contract_no'] ?? '').toString().toLowerCase();
          final customerMap = contract['customers'] as Map?;
          final customerName = (customerMap?['full_name'] ?? '').toString().toLowerCase();

          // فلترة الحالة
          bool matchesStatus = true;
          if (_selectedFilter == 'active') {
            matchesStatus = status == 'active' || status == 'نشط';
          } else if (_selectedFilter == 'completed') {
            matchesStatus = status == 'completed' || status == 'مكتمل';
          } else if (_selectedFilter == 'pending') {
            matchesStatus = status != 'active' && status != 'نشط' && status != 'completed' && status != 'مكتمل';
          }

          // فلترة البحث
          bool matchesSearch = true;
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.trim().toLowerCase();
            matchesSearch = contractNo.contains(query) || customerName.contains(query);
          }

          return matchesStatus && matchesSearch;
        }).toList();

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. كارت ملخص المحفظة العلوي
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _navy.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _gold.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.pie_chart_rounded, color: _gold, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'ملخص عقود المحفظة',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${contracts.length} عقود إجمالاً',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPortfolioSummaryStat(
                                  label: 'المبالغ المخصصة',
                                  value: '${f.format(totalAllocatedSum)} ر.س',
                                  color: _gold,
                                ),
                              ),
                              Container(width: 1, height: 36, color: Colors.white12),
                              Expanded(
                                child: _buildPortfolioSummaryStat(
                                  label: 'عقود نشطة',
                                  value: '$activeCount عقد',
                                  color: _green,
                                ),
                              ),
                              Container(width: 1, height: 36, color: Colors.white12),
                              Expanded(
                                child: _buildPortfolioSummaryStat(
                                  label: 'عقود مكتملة',
                                  value: '$completedCount عقد',
                                  color: _blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. شريط البحث والفلاتر
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _cardShadow,
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() => _searchQuery = val);
                              },
                              decoration: InputDecoration(
                                hintText: 'بحث برقم العقد أو اسم العميل...',
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // فلاتر الحالة (Pills)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'الكل (${contracts.length})', Icons.border_all_rounded),
                          const SizedBox(width: 8),
                          _buildFilterChip('active', 'نشط ($activeCount)', Icons.check_circle_outline_rounded),
                          const SizedBox(width: 8),
                          _buildFilterChip('completed', 'مكتمل ($completedCount)', Icons.task_alt_rounded),
                          if (pendingCount > 0) ...[
                            const SizedBox(width: 8),
                            _buildFilterChip('pending', 'قيد التجميع ($pendingCount)', Icons.hourglass_empty_rounded),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. قائمة العقود الممولة
            filteredContracts.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد عقود تطابق البحث أو الفلتر المحدد',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final item = filteredContracts[i];
                          final contract = item['financing_contracts'] as Map?;
                          if (contract == null) return const SizedBox();

                          final allocated = (item['amount_allocated'] as num?)?.toDouble() ?? 0.0;
                          final principal = (contract['principal_amount'] as num?)?.toDouble() ?? 0.0;
                          final profitRate = (contract['profit_rate'] as num?)?.toDouble() ??
                              (contract['profit_margin'] as num?)?.toDouble() ??
                              0.0;
                          final customer = contract['customers'] as Map?;
                          final customerName = customer?['full_name'] as String? ?? 'غير محدد';
                          final status = (contract['status'] as String?) ?? '';
                          final durationMonths = (contract['duration_months'] as num?)?.toInt() ?? 12;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: _cardShadow,
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // الصف العلوي: أيقونة + رقم العقد + العميل + حالة العقد
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _navy.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.description_outlined, color: _navy, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'عقد رقم #${contract['contract_no']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                              color: _navy,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(Icons.person_outline_rounded, size: 12, color: Colors.grey.shade600),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  'العميل: $customerName',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    _StatusBadge(status: status),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1),
                                ),

                                // شبكة الأرقام المالية
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildContractMetric(
                                        label: 'مساهمتك بالمحفظة',
                                        value: '${f.format(allocated)} ر.س',
                                        valueColor: _navy,
                                        isPrimary: true,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildContractMetric(
                                        label: 'قيمة العقد الكلية',
                                        value: principal > 0 ? '${f.format(principal)} ر.س' : 'غير محدد',
                                        valueColor: Colors.grey.shade800,
                                      ),
                                    ),
                                    if (profitRate > 0)
                                      Expanded(
                                        child: _buildContractMetric(
                                          label: 'معدل الربح',
                                          value: '${profitRate.toStringAsFixed(1)}%',
                                          valueColor: _green,
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // شريط التفاصيل التوضيحي
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _bg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey.shade600),
                                          const SizedBox(width: 6),
                                          Text(
                                            'مدة العقد: $durationMonths شهر',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.shield_outlined, size: 14, color: _gold),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'مضمون وموثق',
                                            style: TextStyle(
                                              color: _navy,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: filteredContracts.length,
                      ),
                    ),
                  ),
          ],
        );
      },
      loading: () => const _LoadingScreen(),
      error: (e, _) => _ErrorScreen(message: e.toString()),
    );
  }

  Widget _buildPortfolioSummaryStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _navy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _navy : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _navy.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? _gold : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractMetric({
    required String label,
    required String value,
    required Color valueColor,
    bool isPrimary = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: isPrimary ? 13 : 12,
            fontWeight: isPrimary ? FontWeight.w900 : FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TransactionsTab extends ConsumerStatefulWidget {
  final String investorId;
  const _TransactionsTab({required this.investorId});

  @override
  ConsumerState<_TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends ConsumerState<_TransactionsTab> {
  String _selectedFilter = 'all'; // 'all', 'inflow', 'outflow', 'profit'
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(
      investorTransactionsControllerProvider(widget.investorId),
    );
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return txAsync.when(
      data: (txs) {
        if (txs.isEmpty) {
          return const _EmptyState(
            icon: Icons.history,
            title: 'لا توجد عمليات',
            subtitle: 'سجل معاملاتك المالية سيظهر هنا',
          );
        }

        // حساب الإحصائيات التحليلية للعمليات
        double totalInflowSum = 0;
        double totalOutflowSum = 0;
        double totalProfitSum = 0;

        for (final tx in txs) {
          final isPlus = tx.type == InvestorTransactionType.deposit ||
              tx.type == InvestorTransactionType.financeProfitDistribution ||
              tx.type == InvestorTransactionType.contractReturn;

          if (isPlus) {
            totalInflowSum += tx.amount.abs();
          } else {
            totalOutflowSum += tx.amount.abs();
          }

          if (tx.type == InvestorTransactionType.financeProfitDistribution) {
            totalProfitSum += tx.amount.abs();
          }
        }

        // التصفية والفلترة بحسب النوع والبحث
        final filteredTxs = txs.where((tx) {
          final isPlus = tx.type == InvestorTransactionType.deposit ||
              tx.type == InvestorTransactionType.financeProfitDistribution ||
              tx.type == InvestorTransactionType.contractReturn;

          // فلترة حسب الفئة
          bool matchesCategory = true;
          if (_selectedFilter == 'inflow') {
            matchesCategory = isPlus;
          } else if (_selectedFilter == 'outflow') {
            matchesCategory = !isPlus;
          } else if (_selectedFilter == 'profit') {
            matchesCategory = tx.type == InvestorTransactionType.financeProfitDistribution;
          }

          // فلترة البحث
          bool matchesSearch = true;
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.trim().toLowerCase();
            final label = tx.type.label.toLowerCase();
            final desc = (tx.description ?? '').toLowerCase();
            final amountStr = f.format(tx.amount.abs());
            matchesSearch = label.contains(query) || desc.contains(query) || amountStr.contains(query);
          }

          return matchesCategory && matchesSearch;
        }).toList();

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. كارت ملخص الحركة المالية العلوي
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _navy.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _gold.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.receipt_long_rounded, color: _gold, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'ملخص حركة الحساب',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${txs.length} حركة',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTxSummaryStat(
                                  label: 'إجمالي المقبوضات (+)',
                                  value: '${f.format(totalInflowSum)} ر.س',
                                  color: _green,
                                ),
                              ),
                              Container(width: 1, height: 36, color: Colors.white12),
                              Expanded(
                                child: _buildTxSummaryStat(
                                  label: 'إجمالي المدفوعات (-)',
                                  value: '${f.format(totalOutflowSum)} ر.س',
                                  color: _red,
                                ),
                              ),
                              Container(width: 1, height: 36, color: Colors.white12),
                              Expanded(
                                child: _buildTxSummaryStat(
                                  label: 'الأرباح الموزعة',
                                  value: '${f.format(totalProfitSum)} ر.س',
                                  color: _gold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. شريط البحث
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _cardShadow,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                        decoration: InputDecoration(
                          hintText: 'بحث في المعاملات بالوصف أو المبلغ...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // أزرار تصفية النوع (Pills)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'الكل (${txs.length})', Icons.border_all_rounded),
                          const SizedBox(width: 8),
                          _buildFilterChip('inflow', 'مقبوضات وأرباح (+)', Icons.arrow_downward_rounded),
                          const SizedBox(width: 8),
                          _buildFilterChip('outflow', 'سحوبات وتأطير (-)', Icons.arrow_upward_rounded),
                          const SizedBox(width: 8),
                          _buildFilterChip('profit', 'أرباح فقط ⭐', Icons.stars_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. قائمة المعاملات المالية
            filteredTxs.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد عمليات تطابق فلتر البحث المحدد',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final tx = filteredTxs[i];
                          final isPlus = tx.type == InvestorTransactionType.deposit ||
                              tx.type == InvestorTransactionType.financeProfitDistribution ||
                              tx.type == InvestorTransactionType.contractReturn;

                          final colorConfig = _getTxTypeVisuals(tx.type);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: _cardShadow,
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              children: [
                                // الأيقونة الملونة على اليسار
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: colorConfig.gradientColors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorConfig.accentColor.withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      colorConfig.icon,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // العنوان + التوضيح / التاريخ
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.type.label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: _navy,
                                        ),
                                      ),
                                      if (tx.description != null && tx.description!.trim().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          tx.description!,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time_rounded, size: 11, color: Colors.grey.shade400),
                                          const SizedBox(width: 4),
                                          Text(
                                            intl.DateFormat('yyyy/MM/dd | hh:mm a').format(tx.createdAt.toLocal()),
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // المبلغ المالي والمؤشر
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${isPlus ? "+" : "-"}${f.format(tx.amount.abs())}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: colorConfig.accentColor,
                                        fontSize: 15,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: colorConfig.accentColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'ر.س',
                                        style: TextStyle(
                                          color: colorConfig.accentColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: filteredTxs.length,
                      ),
                    ),
                  ),
          ],
        );
      },
      loading: () => const _LoadingScreen(),
      error: (e, _) => _ErrorScreen(message: e.toString()),
    );
  }

  _TxVisualConfig _getTxTypeVisuals(InvestorTransactionType type) {
    switch (type) {
      case InvestorTransactionType.deposit:
        return _TxVisualConfig(
          icon: Icons.add_circle_outline_rounded,
          gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
          accentColor: _green,
        );
      case InvestorTransactionType.financeProfitDistribution:
        return _TxVisualConfig(
          icon: Icons.stars_rounded,
          gradientColors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          accentColor: const Color(0xFFD97706),
        );
      case InvestorTransactionType.contractReturn:
        return _TxVisualConfig(
          icon: Icons.assignment_return_rounded,
          gradientColors: [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
          accentColor: const Color(0xFF0891B2),
        );
      case InvestorTransactionType.withdrawal:
        return _TxVisualConfig(
          icon: Icons.remove_circle_outline_rounded,
          gradientColors: [const Color(0xFFEF4444), const Color(0xFFDC2626)],
          accentColor: _red,
        );
      case InvestorTransactionType.contractAllocation:
        return _TxVisualConfig(
          icon: Icons.rocket_launch_rounded,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          accentColor: _blue,
        );
    }
  }

  Widget _buildTxSummaryStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _navy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _navy : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _navy.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? _gold : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TxVisualConfig {
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;

  const _TxVisualConfig({
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
  });
}

class _ProjectionsTab extends ConsumerStatefulWidget {
  final String investorId;
  const _ProjectionsTab({required this.investorId});

  @override
  ConsumerState<_ProjectionsTab> createState() => _ProjectionsTabState();
}

class _ProjectionsTabState extends ConsumerState<_ProjectionsTab> {
  String _selectedFilter = 'all'; // 'all', 'next', 'this_year'
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectionsAsync = ref.watch(
      investorProjectionsProvider(widget.investorId),
    );
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return projectionsAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return const _EmptyState(
            icon: Icons.event_note,
            title: 'لا توجد توقعات',
            subtitle: 'سيتم جدولة أرباحك عند تفعيل العقود',
          );
        }

        // الحسابات التحليلية
        double totalExpectedSum = 0;
        for (final item in list) {
          totalExpectedSum += (item['total_expected'] as num?)?.toDouble() ?? 0.0;
        }

        final nextPayout = list.first;
        final nextAmount = (nextPayout['total_expected'] as num?)?.toDouble() ?? 0.0;
        final nextDateStr = (nextPayout['due_date'] as String?) ?? '';

        final currentYear = DateTime.now().year;

        // التصفية
        final filteredList = list.where((item) {
          final dueDateStr = (item['due_date'] as String?) ?? '';
          final amount = (item['total_expected'] as num?)?.toDouble() ?? 0.0;

          // فلترة الفئة
          bool matchesCategory = true;
          if (_selectedFilter == 'next') {
            matchesCategory = item == list.first;
          } else if (_selectedFilter == 'this_year') {
            matchesCategory = dueDateStr.contains(currentYear.toString());
          }

          // فلترة البحث
          bool matchesSearch = true;
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.trim().toLowerCase();
            final amtStr = f.format(amount);
            matchesSearch = dueDateStr.contains(query) || amtStr.contains(query);
          }

          return matchesCategory && matchesSearch;
        }).toList();

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. كارت ملخص التوقعات والتدفقات المالية
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _navy.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _gold.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.event_available_rounded, color: _gold, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'التدفقات المالية المتوقعة',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${list.length} دفعات مجدولة',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildProjectionSummaryStat(
                                  label: 'إجمالي الأرباح المتوقعة',
                                  value: '${f.format(totalExpectedSum)} ر.س',
                                  color: _gold,
                                ),
                              ),
                              Container(width: 1, height: 36, color: Colors.white12),
                              Expanded(
                                child: _buildProjectionSummaryStat(
                                  label: 'الاستحقاق الأقرب',
                                  value: '${f.format(nextAmount)} ر.س',
                                  color: _green,
                                ),
                              ),
                              Container(width: 1, height: 36, color: Colors.white12),
                              Expanded(
                                child: _buildProjectionSummaryStat(
                                  label: 'تاريخ الاستحقاق',
                                  value: nextDateStr,
                                  color: _blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. شريط البحث والفلاتر
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _cardShadow,
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() => _searchQuery = val);
                              },
                              decoration: InputDecoration(
                                hintText: 'بحث بتاريخ الاستحقاق أو المبلغ...',
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // أزرار الفلترة (Pills)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'جميع الدفعات (${list.length})', Icons.border_all_rounded),
                          const SizedBox(width: 8),
                          _buildFilterChip('next', 'الاستحقاق الأقرب ⭐', Icons.stars_rounded),
                          const SizedBox(width: 8),
                          _buildFilterChip('this_year', 'عام $currentYear 📅', Icons.calendar_today_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. قائمة الدفعات المتوقعة
            filteredList.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد دفعات متوقعة تطابق فلتر البحث المحدد',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final item = filteredList[i];
                          final amount = (item['total_expected'] as num?)?.toDouble() ?? 0.0;
                          final dateStr = (item['due_date'] as String?) ?? 'غير محدد';
                          final isFirstPayout = item == list.first;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: isFirstPayout
                                  ? [
                                      BoxShadow(
                                        color: _gold.withValues(alpha: 0.25),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : _cardShadow,
                              border: Border.all(
                                color: isFirstPayout ? _gold.withValues(alpha: 0.6) : Colors.grey.shade100,
                                width: isFirstPayout ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                // رقم الدفعة
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isFirstPayout
                                          ? [_gold, const Color(0xFFD97706)]
                                          : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isFirstPayout ? _gold : _blue).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // العنوان وتاريخ الاستحقاق
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'دفعة استحقاق أرباح',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                              color: _navy,
                                            ),
                                          ),
                                          if (isFirstPayout) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _gold.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: _gold.withValues(alpha: 0.4)),
                                              ),
                                              child: const Text(
                                                'الاستحقاق الأقرب',
                                                style: TextStyle(
                                                  color: Color(0xFFB45309),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Text(
                                            'تاريخ الاستحقاق: $dateStr',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // المبلغ المتوقع
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${f.format(amount)} ر.س',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: _green,
                                        fontSize: 15,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'مرفق بالعقد',
                                        style: TextStyle(
                                          color: _green,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: filteredList.length,
                      ),
                    ),
                  ),
          ],
        );
      },
      loading: () => const _LoadingScreen(),
      error: (e, _) => _ErrorScreen(message: e.toString()),
    );
  }

  Widget _buildProjectionSummaryStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _navy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _navy : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _navy.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? _gold : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = status == 'active' ? _green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status == 'active' ? 'نشط' : 'قيد الانتظار',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _NotificationBadge({required this.count, required this.onTap});
  @override
  Widget build(BuildContext context) => IconButton(
    icon: Badge(
      label: Text('$count'),
      isLabelVisible: count > 0,
      child: const Icon(
        Icons.notifications_none_rounded,
        color: Colors.white,
        size: 20,
      ),
    ),
    onPressed: onTap,
  );
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: _navy));
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  const _ErrorScreen({required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Text(message));
}

class _NoInvestorPage extends StatelessWidget {
  final VoidCallback onBack;
  const _NoInvestorPage({required this.onBack});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person_off_outlined, size: 48, color: Colors.grey),
        const SizedBox(height: 16),
        const Text('غير مرتبط بمستثمر'),
        TextButton(onPressed: onBack, child: const Text('العودة')),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: Colors.grey.withOpacity(0.5)),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: _navy),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    ),
  );
}
