import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../investor_controller.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../domain/investor_transaction_type.dart';
import '../../domain/investor.dart';
import '../../../documents/presentation/widgets/universal_document_manager.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';

// ─── Color Palette & Styling ────────────────────────────────────────────────
const _navy      = Color(0xFF0F172A);
const _navyLight = Color(0xFF1E293B);
const _gold      = Color(0xFFD4AF37);
const _bg        = Color(0xFFF1F5F9);
const _green     = Color(0xFF10B981);
const _red       = Color(0xFFEF4444);
const _blue      = Color(0xFF3B82F6);
const _cardShadow = [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))];

class InvestorDetailsScreen extends ConsumerWidget {
  final String id;
  final int initialTab;
  const InvestorDetailsScreen({super.key, required this.id, this.initialTab = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorAsync = ref.watch(investorDetailsControllerProvider(id));

    return investorAsync.when(
      data: (investor) {
        if (investor == null) return const Scaffold(body: Center(child: Text('المستثمر غير موجود')));

        return Directionality(
          textDirection: TextDirection.rtl,
          child: DefaultTabController(
            length: 5,
            initialIndex: initialTab,
            child: Scaffold(
              backgroundColor: _bg,
              body: NestedScrollView(
                headerSliverBuilder: (ctx, _) => [
                  _InvestorDetailsSliverHeader(investor: investor),
                ],
                body: Container(
                  color: _bg,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: TabBarView(
                        children: [
                          _FinancialTab(investor: investor),
                          _ContractsTab(investorId: investor.id),
                          _WithdrawalRequestsTab(investorId: investor.id),
                          _ProjectionsTab(investorId: investor.id),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: UniversalDocumentManager(investorId: investor.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: _navy))),
      error: (err, _) => Scaffold(body: Center(child: Text(Failure.fromException(err).message))),
    );
  }
}

// ─── Professional Adaptive Header ─────────────────────────────────────────────
class _InvestorDetailsSliverHeader extends StatelessWidget {
  final Investor investor;
  const _InvestorDetailsSliverHeader({required this.investor});

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final total = investor.availableBalance + investor.deployedCapital;

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: _navy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [_navy, Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: Column(
                    children: [
                      // ── Top Bar: Avatar + Investor Info + Badge ──
                      Row(
                        children: [
                          Hero(
                            tag: 'inv-${investor.id}',
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [_gold, Color(0xFFE5C17E)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _gold.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  investor.fullName.isNotEmpty ? investor.fullName[0] : 'M',
                                  style: const TextStyle(
                                    color: _navy,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                investor.fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                investor.email,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                              ),
                            ],
                          ),
                          const Spacer(),
                          _headerBadge('ملف استثماري نشط'),
                        ],
                      ),

                      const Spacer(),

                      // ── Hero Total Balance ──
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, size: 14, color: _gold.withValues(alpha: 0.8)),
                              const SizedBox(width: 6),
                              Text(
                                'إجمالي القيمة المدارة',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _gold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'ر.س',
                                  style: TextStyle(
                                    color: _gold,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Spacer(),

                      // ── 3 Mini KPI Cards ──
                      Row(
                        children: [
                          _HeaderStatTile(
                            label: 'السيولة المتاحة',
                            value: '${f.format(investor.availableBalance)} ر.س',
                            color: _green,
                            icon: Icons.account_balance_rounded,
                          ),
                          const SizedBox(width: 10),
                          _HeaderStatTile(
                            label: 'رأس المال المشغل',
                            value: '${f.format(investor.deployedCapital)} ر.س',
                            color: _blue,
                            icon: Icons.trending_up_rounded,
                          ),
                          const SizedBox(width: 10),
                          _HeaderStatTile(
                            label: 'الأرباح المحققة',
                            value: '${f.format(investor.totalProfitEarned)} ر.س',
                            color: _gold,
                            icon: Icons.stars_rounded,
                          ),
                        ],
                      ),
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
          decoration: BoxDecoration(
            color: _navy,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: _gold,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: _gold,
                unselectedLabelColor: Colors.white54,
                labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Cairo'),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Cairo'),
                tabs: [
                  Tab(text: 'المالية'),
                  Tab(text: 'العقود'),
                  Tab(text: 'السحوبات'),
                  Tab(text: 'التوقعات'),
                  Tab(text: 'المستندات'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderStatTile extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;

  const _HeaderStatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
  Widget _headerBadge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _green.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _green.withValues(alpha: 0.3)),
    ),
    child: Text(text, style: const TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.bold)),
  );

// ─── Financial Tab (Refined Grid Layout) ────────────────────────────────────
  class _FinancialTab extends ConsumerWidget {
  final Investor investor;
  const _FinancialTab({required this.investor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final transactionsAsync = ref.watch(investorTransactionsControllerProvider(investor.id));
  final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

  return RefreshIndicator(
  onRefresh: () async {
  ref.invalidate(investorDetailsControllerProvider(investor.id));
  ref.invalidate(investorTransactionsControllerProvider(investor.id));
  },
  child: SingleChildScrollView(
  padding: const EdgeInsets.all(24),
  child: Column(
  children: [
  // Row 1: Actions
  Row(
  children: [
  Expanded(child: _actionBtn(context, 'إيداع رأس مال', Icons.add_circle_outline, _green, () => _showTxDialog(context, investor.id, InvestorTransactionType.deposit))),
  const SizedBox(width: 16),
  Expanded(child: _actionBtn(context, 'سحب من الرصيد', Icons.remove_circle_outline, _red, investor.availableBalance > 0 ? () => _showTxDialog(context, investor.id, InvestorTransactionType.withdrawal) : null)),
  ],
  ),
  const SizedBox(height: 24),

  // Row 2: Stats Grid
  GridView.count(
  crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.2,
  children: [
  _statTile('الرصيد المتاح', f.format(investor.availableBalance), Icons.account_balance_wallet, _green),
  _statTile('رأس المال المشغل', f.format(investor.deployedCapital), Icons.rocket_launch, _blue),
  _statTile('إجمالي الأرباح', f.format(investor.totalProfitEarned), Icons.trending_up, _gold),
  ],
  ),

  const SizedBox(height: 32),
  _SectionHeader(title: 'سجل الحركات المالية', subtitle: 'تفاصيل الإيداعات والأرباح والسحوبات', icon: Icons.history_rounded),
  const SizedBox(height: 12),

  // Transactions List
  transactionsAsync.when(
  data: (txs) => txs.isEmpty
  ? _emptyState('لا توجد معاملات مادية حالياً')
      : Container(
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: _cardShadow),
  child: ListView.separated(
  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
  itemCount: txs.length,
  separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
  itemBuilder: (ctx, i) {
  final tx = txs[i];
  final isPlus = tx.type == InvestorTransactionType.deposit || tx.type == InvestorTransactionType.financeProfitDistribution || tx.type == InvestorTransactionType.contractReturn;
  return ListTile(
  leading: CircleAvatar(radius: 16, backgroundColor: (isPlus ? _green : _red).withOpacity(0.1), child: Icon(isPlus ? Icons.arrow_downward : Icons.arrow_upward, color: isPlus ? _green : _red, size: 16)),
  title: Text(tx.type.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  subtitle: Text(intl.DateFormat('yyyy/MM/dd | hh:mm a').format(tx.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
  trailing: Text('${isPlus ? "+" : "-"}${f.format(tx.amount.abs())}', style: TextStyle(fontWeight: FontWeight.bold, color: isPlus ? _green : _red, fontSize: 14)),
  );
  },
  ),
  ),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Text(e.toString()),
  ),
  ],
  ),
  ),
  );
  }

  Widget _actionBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback? onTap) => Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  child: InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(16),
  child: Container(
  padding: const EdgeInsets.symmetric(vertical: 20),
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
  child: Column(children: [
  Icon(icon, color: onTap == null ? Colors.grey : color, size: 24),
  const SizedBox(height: 8),
  Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: onTap == null ? Colors.grey : _navy)),
  ]),
  ),
  ),
  );

  Widget _statTile(String l, String v, IconData i, Color c) => Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: _cardShadow),
  child: Row(children: [
  CircleAvatar(radius: 18, backgroundColor: c.withOpacity(0.1), child: Icon(i, color: c, size: 18)),
  const SizedBox(width: 12),
  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
  Text(l, style: const TextStyle(color: Colors.grey, fontSize: 10)),
  FittedBox(child: Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
  ])),
  ]),
  );

  void _showTxDialog(BuildContext ctx, String invId, InvestorTransactionType type) {
  showDialog(context: ctx, builder: (_) => AddTransactionDialog(investorId: invId, type: type));
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
  data: (contracts) => contracts.isEmpty ? _emptyState('لا توجد عقود ممولة') : ListView.builder(
  padding: const EdgeInsets.all(24),
  itemCount: contracts.length,
  itemBuilder: (ctx, i) {
  final item = contracts[i];
  final contract = item['financing_contracts'] as Map?;
  if (contract == null) return const SizedBox();
  return Container(
  margin: const EdgeInsets.only(bottom: 16),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: _cardShadow),
  child: Row(children: [
  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _navy.withOpacity(0.05), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.assignment_outlined, color: _navy)),
  const SizedBox(width: 16),
  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text('عقد رقم ${contract['contract_no']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  Text('مساهمة المستثمر: ${f.format(item['amount_allocated'])} ر.س', style: const TextStyle(color: Colors.grey, fontSize: 11)),
  ])),
  _statusBadge(contract['status'] ?? ''),
  ]),
  );
  },
  ),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Center(child: Text(e.toString())),
  );
  }
  }

// ─── Withdrawal Tab (Logic already fixed before) ────────────────────────────
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
  data: (reqs) => reqs.isEmpty ? _emptyState('لا توجد طلبات سحب') : ListView.builder(
  padding: const EdgeInsets.all(24),
  itemCount: reqs.length,
  itemBuilder: (ctx, i) {
  final r = reqs[i];
  final isPending = r['status'] == 'pending';
  return Container(
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: isPending ? Border.all(color: Colors.orange.withOpacity(0.3)) : null),
  child: Row(children: [
  const Icon(Icons.payments_outlined, color: _blue),
  const SizedBox(width: 16),
  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(f.format(r['amount']), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
  Text(r['bank_details'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
  ])),
  if (isPending) TextButton(onPressed: _processingId != null ? null : () => _approve(r['id']), child: const Text('اعتماد التنفيذ'))
  else _statusBadge('completed'),
  ]),
  );
  },
  ),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Center(child: Text(e.toString())),
  );
  }
  Future<void> _approve(String id) async {
  setState(() => _processingId = id);
  try {
  await ref.read(withdrawalRequestsControllerProvider().notifier).approveRequest(id);
  SnackBarHelper.showSuccess(context, 'تم تنفيذ السحب بنجاح');
  } catch (e) { SnackBarHelper.showError(context, e); }
  finally { setState(() => _processingId = null); }
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
  data: (list) => list.isEmpty ? _emptyState('لا توجد تدفقات متوقعة') : ListView.builder(
  padding: const EdgeInsets.all(24),
  itemCount: list.length,
  itemBuilder: (ctx, i) {
  final item = list[i];
  return Container(
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _blue.withOpacity(0.1))),
  child: Row(children: [
  Container(width: 36, height: 36, decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Center(child: Text('${i+1}', style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)))),
  const SizedBox(width: 16),
  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  const Text('دفعة أرباح متوقعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  Text(item['due_date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
  ])),
  Text('${f.format((item['total_expected'] as num).toDouble())} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: _green)),
  ]),
  );
  },
  ),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Center(child: Text(e.toString())),
  );
  }
  }

// ─── UI Utilities ────────────────────────────────────────────────────────────

  Widget _statusBadge(String s) {
  final color = (s == 'active' || s == 'completed') ? _green : Colors.orange;
  return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Text(s == 'active' ? 'نشط' : (s == 'completed' ? 'تم' : 'قيد الانتظار'), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)));
  }

  Widget _emptyState(String t) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey), const SizedBox(height: 16), Text(t, style: const TextStyle(color: Colors.grey))]));

  class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _SectionHeader({required this.title, required this.subtitle, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [
  Icon(icon, color: _navy.withValues(alpha: 0.7), size: 18),
  const SizedBox(width: 10),
  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _navy)),
  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
  ]),
  ]);
  }
