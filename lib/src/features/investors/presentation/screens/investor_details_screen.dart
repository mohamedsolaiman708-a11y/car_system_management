import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../investor_controller.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../domain/investor_transaction_type.dart';
import '../../domain/investor.dart';
import '../../../documents/presentation/widgets/universal_document_manager.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';

// ─── Design Tokens ───────────────────────────────────────────────────────────
const _navy     = Color(0xFF0D1B3E);
const _navyMid  = Color(0xFF1A2E5A);
const _gold     = Color(0xFFC5A35E);
const _bg       = Color(0xFFF0F4FB);
const _green    = Color(0xFF27AE60);
const _red      = Color(0xFFEB5757);

class InvestorDetailsScreen extends ConsumerWidget {
  final String id;
  final int initialTab;
  const InvestorDetailsScreen({super.key, required this.id, this.initialTab = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorAsync = ref.watch(investorDetailsControllerProvider(id));

    return investorAsync.when(
      data: (investor) {
        if (investor == null) {
          return const Scaffold(
            body: Center(child: Text('المستثمر غير موجود')),
          );
        }
        return DefaultTabController(
          length: 5,
          initialIndex: initialTab,
          child: Scaffold(
            backgroundColor: _bg,
            body: NestedScrollView(
              headerSliverBuilder: (ctx, _) => [
                _InvestorDetailsSliverHeader(investor: investor),
              ],
              body: TabBarView(
                children: [
                  _FinancialTab(investor: investor),
                  _ContractsTab(investorId: investor.id),
                  _WithdrawalRequestsTab(investorId: investor.id),
                  _ProjectionsTab(investorId: investor.id),
                  UniversalDocumentManager(investorId: investor.id),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _navy)),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: _red, size: 48),
                const SizedBox(height: 16),
                Text(
                  Failure.fromException(err).message,
                  style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sliver Header ──────────────────────────────────────────────────────────
class _InvestorDetailsSliverHeader extends StatelessWidget {
  final Investor investor;
  const _InvestorDetailsSliverHeader({required this.investor});

  @override
  Widget build(BuildContext context) {
    final f     = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final total = investor.availableBalance + investor.deployedCapital;

    return SliverAppBar(
      expandedHeight: 310,
      floating: false,
      pinned: true,
      backgroundColor: _navy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_navy, _navyMid, Color(0xFF0F2552)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(top: -30, right: -30, child: _Circle(140, Colors.white.withValues(alpha: 0.03))),
              Positioned(bottom: 80, left: -20, child: _Circle(100, _gold.withValues(alpha: 0.06))),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Hero(
                                tag: 'investor-avatar-${investor.id}',
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: _gold.withValues(alpha: 0.2),
                                  child: Text(
                                    investor.fullName.isNotEmpty ? investor.fullName[0].toUpperCase() : 'م',
                                    style: const TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            investor.fullName,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.verified_rounded, size: 16, color: Colors.lightBlueAccent),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      investor.email,
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Column(
                              children: [
                                const Text('إجمالي قيمة المحفظة', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                const SizedBox(height: 6),
                                Text(
                                  '${f.format(total)} ر.س',
                                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _HeaderStat(label: 'رصيد متاح', value: '${f.format(investor.availableBalance)} ر.س', color: const Color(0xFF4ADE80)),
                              Container(width: 1, height: 36, color: Colors.white12, margin: const EdgeInsets.symmetric(horizontal: 14)),
                              _HeaderStat(label: 'رأس مال مشغّل', value: '${f.format(investor.deployedCapital)} ر.س', color: const Color(0xFF60A5FA)),
                              Container(width: 1, height: 36, color: Colors.white12, margin: const EdgeInsets.symmetric(horizontal: 14)),
                              _HeaderStat(label: 'الأرباح المحققة', value: '${f.format(investor.totalProfitEarned)} ر.س', color: _gold),
                            ],
                          ),
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
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: _navy,
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
                tabs: [
                  Tab(text: 'المالية',     icon: Icon(Icons.account_balance_wallet_rounded, size: 16)),
                  Tab(text: 'العقود',      icon: Icon(Icons.assignment_rounded, size: 16)),
                  Tab(text: 'السحوبات',    icon: Icon(Icons.arrow_circle_up_rounded, size: 16)),
                  Tab(text: 'التوقعات',   icon: Icon(Icons.trending_up_rounded, size: 16)),
                  Tab(text: 'المستندات',  icon: Icon(Icons.folder_copy_rounded, size: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Financial Tab ───────────────────────────────────────────────────────────
class _FinancialTab extends ConsumerWidget {
  final Investor investor;
  const _FinancialTab({required this.investor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(investorTransactionsControllerProvider(investor.id));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return RefreshIndicator(
      color: _navy,
      onRefresh: () async {
        ref.invalidate(investorDetailsControllerProvider(investor.id));
        ref.invalidate(investorTransactionsControllerProvider(investor.id));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SmartInsightBanner(investor: investor),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'إيداع رأس مال',
                        sublabel: 'إضافة أموال للمحفظة',
                        icon: Icons.add_circle_rounded,
                        gradientColors: [const Color(0xFF27AE60), const Color(0xFF1E8A4A)],
                        onPressed: () => _showTransactionDialog(context, investor.id, InvestorTransactionType.deposit),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionButton(
                        label: 'سحب رصيد',
                        sublabel: 'تنفيذ عملية سحب',
                        icon: Icons.arrow_circle_up_rounded,
                        gradientColors: [const Color(0xFFEB5757), const Color(0xFFCC3333)],
                        onPressed: investor.availableBalance > 0
                            ? () => _showTransactionDialog(context, investor.id, InvestorTransactionType.withdrawal)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(
                            child: _MiniBalanceCard(
                              label: 'الرصيد المتاح',
                              value: '${f.format(investor.availableBalance)} ر.س',
                              icon: Icons.account_balance_wallet_rounded,
                              color: _green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniBalanceCard(
                              label: 'رأس المال المشغّل',
                              value: '${f.format(investor.deployedCapital)} ر.س',
                              icon: Icons.rocket_launch_rounded,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniBalanceCard(
                              label: 'إجمالي الأرباح',
                              value: '${f.format(investor.totalProfitEarned)} ر.س',
                              icon: Icons.auto_graph_rounded,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniBalanceCard(
                              label: 'نسبة التشغيل',
                              value: () {
                                final total = investor.availableBalance + investor.deployedCapital;
                                return total > 0
                                    ? '${(investor.deployedCapital / total * 100).toStringAsFixed(1)}%'
                                    : '—';
                              }(),
                              icon: Icons.donut_large_rounded,
                              color: _navy,
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _MiniBalanceCard(
                                label: 'الرصيد المتاح',
                                value: '${f.format(investor.availableBalance)} ر.س',
                                icon: Icons.account_balance_wallet_rounded,
                                color: _green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MiniBalanceCard(
                                label: 'رأس المال المشغّل',
                                value: '${f.format(investor.deployedCapital)} ر.س',
                                icon: Icons.rocket_launch_rounded,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniBalanceCard(
                                label: 'إجمالي الأرباح',
                                value: '${f.format(investor.totalProfitEarned)} ر.س',
                                icon: Icons.auto_graph_rounded,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MiniBalanceCard(
                                label: 'نسبة التشغيل',
                                value: () {
                                  final total = investor.availableBalance + investor.deployedCapital;
                                  return total > 0
                                      ? '${(investor.deployedCapital / total * 100).toStringAsFixed(1)}%'
                                      : '—';
                                }(),
                                icon: Icons.donut_large_rounded,
                                color: _navy,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'سجل المعاملات المالية',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _navy),
                      ),
                    ),
                    transactionsAsync.when(
                      data: (txs) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _navy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${txs.length} معاملة',
                            style: const TextStyle(color: _navy, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                transactionsAsync.when(
                  skipLoadingOnRefresh: true,
                  data: (txs) {
                    if (txs.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text('لا توجد سجلات مالية بعد', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: txs.length,
                        separatorBuilder: (_, __) => Divider(height: 1, indent: 70, color: Colors.grey.withValues(alpha: 0.08)),
                        itemBuilder: (ctx, i) {
                          final tx      = txs[i];
                          final isPlus  = tx.type.name == 'deposit' || tx.type.name == 'contract_return' || tx.type.name == 'finance_profit_distribution';
                          final color   = isPlus ? _green : _red;
                          final icon    = switch (tx.type.name) {
                            'deposit'                     => Icons.arrow_circle_down_rounded,
                            'withdrawal'                  => Icons.arrow_circle_up_rounded,
                            'contract_allocation'         => Icons.assignment_rounded,
                            'contract_return'             => Icons.assignment_return_rounded,
                            'finance_profit_distribution' => Icons.auto_graph_rounded,
                            _                             => Icons.swap_horiz_rounded,
                          };

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                      Text(tx.type.label,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(
                                        intl.DateFormat('dd/MM/yyyy • hh:mm a').format(tx.createdAt),
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                      if (tx.recordedByName != null && tx.recordedByName!.isNotEmpty)
                                        Text(
                                          'نفّذه: ${tx.recordedByName}',
                                          style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${isPlus ? "+" : "−"}${f.format(tx.amount.abs())} ر.س',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: _navy, strokeWidth: 2),
                  )),
                  error: (err, _) => Center(
                    child: Text(Failure.fromException(err).message,
                        style: const TextStyle(color: _red, fontFamily: 'Cairo')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, String investorId, InvestorTransactionType type) {
    showDialog(
      context: context,
      builder: (_) => AddTransactionDialog(investorId: investorId, type: type),
    );
  }
}

// ─── Contracts Tab ───────────────────────────────────────────────────────────
class _ContractsTab extends ConsumerWidget {
  final String investorId;
  const _ContractsTab({required this.investorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(investorFundedContractsControllerProvider(investorId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return contractsAsync.when(
      data: (contracts) {
        if (contracts.isEmpty) {
          return const _EmptyState(
            icon: Icons.assignment_rounded,
            title: 'لا توجد عقود ممولة',
            subtitle: 'لم يتم ربط أي عقود بهذا المستثمر بعد',
          );
        }
        final totalAllocated = contracts.fold<double>(
          0, (s, c) => s + ((c['amount_allocated'] as num?)?.toDouble() ?? 0));

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
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [_navy, _navyMid]),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _SummaryPill(label: 'إجمالي التمويل', value: '${f.format(totalAllocated)} ر.س', color: _gold),
                                Container(width: 1, height: 32, color: Colors.white12),
                                _SummaryPill(label: 'عدد العقود', value: '${contracts.length}', color: const Color(0xFF4ADE80)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text('تفاصيل العقود', style: TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 15)),
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
                          final item     = contracts[i];
                          final contract = item['financing_contracts'] as Map?;
                          if (contract == null) return const SizedBox();
                          final status   = (contract['status'] ?? '') as String;
                          final customer = contract['customers'] as Map?;
                          final statusColor = switch (status) {
                            'active'          => _green,
                            'closed'          => Colors.grey,
                            'defaulted'       => _red,
                            _                 => Colors.orange,
                          };
                          final statusLabel = switch (status) {
                            'active'          => 'نشط',
                            'closed'          => 'مغلق',
                            'draft'           => 'مسودة',
                            'pending_funding' => 'ينتظر تمويل',
                            'defaulted'       => 'متعثر',
                            _                 => status,
                          };

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
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
                                      Text('عقد #${contract['contract_no'] ?? 'N/A'}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 13)),
                                      if (customer != null)
                                        Text('العميل: ${customer['full_name'] ?? '—'}',
                                            style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Text('المساهمة: ${f.format(item['amount_allocated'] ?? 0)} ر.س',
                                          style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(statusLabel,
                                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
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
      loading: () => const Center(child: CircularProgressIndicator(color: _navy)),
      error: (err, _) => Center(
        child: Text(Failure.fromException(err).message,
            style: const TextStyle(color: _red, fontFamily: 'Cairo')),
      ),
    );
  }
}

// ─── Withdrawal Requests Tab ─────────────────────────────────────────────────
class _WithdrawalRequestsTab extends ConsumerStatefulWidget {
  final String investorId;
  const _WithdrawalRequestsTab({required this.investorId});
  @override
  ConsumerState<_WithdrawalRequestsTab> createState() => _WithdrawalRequestsTabState();
}

class _WithdrawalRequestsTabState extends ConsumerState<_WithdrawalRequestsTab> {
  String? _processingId;

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(withdrawalRequestsControllerProvider(investorId: widget.investorId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const _EmptyState(
            icon: Icons.arrow_circle_up_rounded,
            title: 'لا توجد طلبات سحب',
            subtitle: 'ستظهر طلبات السحب المقدمة من المستثمر هنا',
          );
        }

        final pendingCount = requests.where((r) => r['status'] == 'pending').length;

        return RefreshIndicator(
          color: _navy,
          onRefresh: () => ref.refresh(
              withdrawalRequestsControllerProvider(investorId: widget.investorId).future),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomScrollView(
                slivers: [
                  if (pendingCount > 0)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.pending_actions_rounded, color: Colors.orange, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                '$pendingCount طلب بانتظار التنفيذ',
                                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final req      = requests[i];
                          final status   = req['status'] as String? ?? '';
                          final isPending = status == 'pending';
                          final statusColor = isPending ? Colors.orange : _green;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: isPending
                                  ? Border.all(color: Colors.orange.withValues(alpha: 0.3))
                                  : null,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        isPending ? Icons.pending_actions_rounded : Icons.check_circle_rounded,
                                        color: statusColor, size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${f.format(req['amount'] ?? 0)} ر.س',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _navy),
                                          ),
                                          Text(
                                            isPending ? 'بانتظار التنفيذ' : 'تم التنفيذ',
                                            style: TextStyle(fontSize: 12, color: statusColor),
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
                                      child: Text(
                                        isPending ? 'معلق' : 'مُنفَّذ',
                                        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                if (req['bank_details'] != null && (req['bank_details'] as String).isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _bg,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.account_balance_rounded, size: 14, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            req['bank_details'] as String,
                                            style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (isPending) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: _processingId == req['id']
                                        ? const Center(child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: CircularProgressIndicator(strokeWidth: 2, color: _navy),
                                          ))
                                        : ElevatedButton.icon(
                                            onPressed: () => _approveRequest(req['id'] as String),
                                            icon: const Icon(Icons.check_rounded, size: 18),
                                            label: const Text('تنفيذ واعتماد السحب'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _navy,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(0, 44),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                        childCount: requests.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: _navy)),
      error: (err, _) => Center(
        child: Text(Failure.fromException(err).message,
            style: const TextStyle(color: _red, fontFamily: 'Cairo')),
      ),
    );
  }

  Future<void> _approveRequest(String requestId) async {
    setState(() => _processingId = requestId);
    try {
      await ref.read(withdrawalRequestsControllerProvider().notifier).approveRequest(requestId);
      if (mounted) {
        SnackBarHelper.showSuccess(context, 'تم تنفيذ السحب واعتماد القيد المحاسبي بنجاح ✓');
      }
    } catch (e) {
      if (mounted) SnackBarHelper.showError(context, e);
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
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
      data: (list) {
        if (list.isEmpty) {
          return const _EmptyState(
            icon: Icons.trending_up_rounded,
            title: 'لا توجد توقعات',
            subtitle: 'ستظهر استحقاقات العقود المستقبلية هنا',
          );
        }
        final total = list.fold<double>(0, (s, i) => s + ((i['total_expected'] as num?)?.toDouble() ?? 0));

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
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green.shade700, Colors.green.shade900],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 5))],
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.insights_rounded, color: Colors.white70, size: 26),
                                const SizedBox(height: 10),
                                const Text('إجمالي التدفقات المتوقعة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 6),
                                Text('${f.format(total)} ر.س',
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text('على ${list.length} دفعة', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text('جدول الاستحقاقات التفصيلي',
                                style: TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 15)),
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
                          final item    = list[i];
                          final dueDate = item['due_date'] as String?;
                          final amount  = (item['total_expected'] as num?)?.toDouble() ?? 0;
                          final isPast  = dueDate != null &&
                              DateTime.tryParse(dueDate)?.isBefore(DateTime.now()) == true;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: isPast ? Border.all(color: _red.withValues(alpha: 0.3)) : null,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: (isPast ? _red : Colors.blue).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text('${i + 1}',
                                        style: TextStyle(
                                            color: isPast ? _red : Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('دفعة ${i + 1}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 13)),
                                      Text(dueDate ?? 'تاريخ غير محدد',
                                          style: TextStyle(color: isPast ? _red : Colors.grey, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Text('${f.format(amount)} ر.س',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 14)),
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
      loading: () => const Center(child: CircularProgressIndicator(color: _navy)),
      error: (err, _) => Center(
        child: Text(Failure.fromException(err).message,
            style: const TextStyle(color: _red, fontFamily: 'Cairo')),
      ),
    );
  }
}

// ─── Reusable Components ─────────────────────────────────────────────────────
class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle(this.size, this.color);
  @override
  Widget build(BuildContext ctx) =>
      Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HeaderStat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext ctx) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis),
      ],
    ),
  );
}

class _SmartInsightBanner extends StatelessWidget {
  final Investor investor;
  const _SmartInsightBanner({required this.investor});

  @override
  Widget build(BuildContext context) {
    final isIdle   = investor.availableBalance > investor.deployedCapital;
    final bgColor  = isIdle ? Colors.amber.shade50 : Colors.blue.shade50;
    final bdColor  = isIdle ? Colors.amber.shade200 : Colors.blue.shade200;
    final txtColor = isIdle ? Colors.amber.shade900 : Colors.blue.shade900;
    final icon     = isIdle ? Icons.lightbulb_rounded : Icons.insights_rounded;
    final icolor   = isIdle ? Colors.amber.shade700 : Colors.blue.shade700;
    final title    = isIdle ? 'توصية ذكية' : 'تحليل المحفظة';
    final body     = isIdle
        ? 'لديك سيولة غير مستثمرة. ننصح بتمويل عقود جديدة لرفع العائد المالي.'
        : 'المحفظة تعمل بكفاءة عالية. توزيع رأس المال متوازن مع العقود الحالية.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bdColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: icolor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: txtColor)),
                const SizedBox(height: 3),
                Text(body, style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onPressed;
  const _ActionButton({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.gradientColors,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDisabled ? [Colors.grey.shade300, Colors.grey.shade400] : gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: isDisabled ? [] : [
              BoxShadow(color: gradientColors.first.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(sublabel, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBalanceCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MiniBalanceCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              Text(value, style: const TextStyle(color: _navy, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryPill({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
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
            child: Icon(icon, size: 48, color: _navy.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 16)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
