import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../investor_controller.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../domain/investor_transaction_type.dart';
import '../../domain/investor.dart';
import '../../../documents/presentation/widgets/universal_document_manager.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';

// ─── Color Palette ──────────────────────────────────────────────────────────
const _navy      = Color(0xFF0F172A);
const _gold      = Color(0xFFD4AF37);
const _bg        = Color(0xFFF1F5F9);
const _green     = Color(0xFF10B981);
const _blue      = Color(0xFF3B82F6);
const _cardShadow = [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))];

class InvestorDetailsScreen extends ConsumerStatefulWidget {
  final String id;
  final int initialTab;
  const InvestorDetailsScreen({super.key, required this.id, this.initialTab = 0});

  @override
  ConsumerState<InvestorDetailsScreen> createState() => _InvestorDetailsScreenState();
}

class _InvestorDetailsScreenState extends ConsumerState<InvestorDetailsScreen> {
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final investorAsync = ref.watch(investorDetailsControllerProvider(widget.id));

    return investorAsync.when(
      data: (investor) {
        if (investor == null) return const Scaffold(body: Center(child: Text('المستثمر غير موجود')));

        return Directionality(
          textDirection: TextDirection.rtl,
          child: DefaultTabController(
            length: 5,
            initialIndex: widget.initialTab,
            child: Scaffold(
              backgroundColor: _bg,
              body: NestedScrollView(
                headerSliverBuilder: (ctx, _) => [
                  _InvestorDetailsSliverHeader(investor: investor),
                ],
                body: TabBarView(
                  children: [
                    _FinancialTab(
                      investor: investor, 
                      dateRange: _selectedDateRange,
                      onDateRangeSelected: (range) => setState(() => _selectedDateRange = range),
                    ),
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
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: _navy))),
      error: (err, _) => Scaffold(body: Center(child: Text(Failure.fromException(err).message))),
    );
  }
}

class _InvestorDetailsSliverHeader extends StatelessWidget {
  final Investor investor;
  const _InvestorDetailsSliverHeader({required this.investor});

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final total = investor.availableBalance + investor.deployedCapital;

    return SliverAppBar(
      expandedHeight: 280, // تصميم ذكي ومضغوط
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
              colors: [_navy, Color(0xFF1E293B)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 60), // بادينج ذكي
              child: Column(
                children: [
                  // 1. توب بار مصغر
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: _gold.withOpacity(0.2),
                        child: Text(investor.fullName[0], style: const TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(investor.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(investor.email, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
                          ],
                        ),
                      ),
                      _headerBadge('ملف نشط'),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // 2. الرصيد (متركز في المنتصف)
                  Column(
                    children: [
                      Text('إجمالي القيمة المدارة', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                      const SizedBox(height: 2),
                      FittedBox(
                        child: Text(
                          f.format(total),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Text('ريال سعودي', style: TextStyle(color: _gold, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 3. الكروت (Row واحد مضغوط)
                  Row(
                    children: [
                      _HeaderStatTile(label: 'السيولة', value: f.format(investor.availableBalance), color: _green, icon: Icons.account_balance_wallet_rounded),
                      const SizedBox(width: 8),
                      _HeaderStatTile(label: 'المشغل', value: f.format(investor.deployedCapital), color: _blue, icon: Icons.trending_up_rounded),
                      const SizedBox(width: 8),
                      _HeaderStatTile(label: 'الأرباح', value: f.format(investor.totalProfitEarned), color: _gold, icon: Icons.stars_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: _navy, border: Border(top: BorderSide(color: Colors.white10))),
          child: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: _gold,
            indicatorWeight: 3,
            labelColor: _gold,
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Cairo'),
            tabs: [
              Tab(text: 'المالية'), Tab(text: 'العقود'), Tab(text: 'السحوبات'), Tab(text: 'التوقعات'), Tab(text: 'المستندات'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerBadge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: _green.withOpacity(0.2))),
    child: Text(text, style: const TextStyle(color: _green, fontSize: 9, fontWeight: FontWeight.bold)),
  );
}

class _HeaderStatTile extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _HeaderStatTile({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 8), maxLines: 1),
                  FittedBox(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialTab extends ConsumerWidget {
  final Investor investor;
  final DateTimeRange? dateRange;
  final Function(DateTimeRange) onDateRangeSelected;
  const _FinancialTab({required this.investor, this.dateRange, required this.onDateRangeSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(investorTransactionsControllerProvider(investor.id));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfitFilterCard(context, f),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _actionBtn(context, 'إيداع', Icons.add_circle, _green, () => _showTxDialog(context, investor.id, InvestorTransactionType.deposit))),
              const SizedBox(width: 12),
              Expanded(child: _actionBtn(context, 'سحب', Icons.remove_circle, Colors.red, () => _showTxDialog(context, investor.id, InvestorTransactionType.withdrawal))),
            ],
          ),
          const SizedBox(height: 24),
          const Row(children: [Icon(Icons.history, size: 18), SizedBox(width: 8), Text('سجل العمليات المكتملة', style: TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          transactionsAsync.when(
            data: (txs) {
              final filtered = dateRange == null ? txs : txs.where((t) => t.createdAt.isAfter(dateRange!.start) && t.createdAt.isBefore(dateRange!.end)).toList();
              if (filtered.isEmpty) return _emptyState('لا توجد حركات حالياً');
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final tx = filtered[i];
                  final isPlus = tx.amount > 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.black.withOpacity(0.03))),
                    child: ListTile(
                      dense: true,
                      leading: Icon(isPlus ? Icons.arrow_downward : Icons.arrow_upward, color: isPlus ? _green : Colors.red, size: 16),
                      title: Text(tx.type.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(intl.DateFormat('yyyy/MM/dd').format(tx.createdAt), style: const TextStyle(fontSize: 11)),
                      trailing: Text('${f.format(tx.amount)} ر.س', style: TextStyle(fontWeight: FontWeight.bold, color: isPlus ? _green : Colors.red, fontSize: 13)),
                    ),
                  );
                },
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text(e.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitFilterCard(BuildContext context, intl.NumberFormat f) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('أرباح الفترة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(dateRange == null ? 'حدد فترة زمنية' : 'تم تصفية النتائج', style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now());
              if (picked != null) onDateRangeSelected(picked);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _gold, foregroundColor: _navy, padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: const Size(0, 36)),
            child: const Text('تصفية', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String l, IconData i, Color c, VoidCallback onTap) => ElevatedButton.icon(onPressed: onTap, icon: Icon(i, size: 16), label: Text(l), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _navy, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.black.withOpacity(0.05)))));

  void _showTxDialog(BuildContext ctx, String invId, InvestorTransactionType type) {
    showDialog(context: ctx, builder: (_) => AddTransactionDialog(investorId: invId, type: type));
  }

  Widget _emptyState(String t) => Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text(t, style: const TextStyle(color: Colors.grey, fontSize: 12))));
}

class _ContractsTab extends ConsumerWidget {
  final String investorId;
  const _ContractsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(investorFundedContractsControllerProvider(investorId));
    return contractsAsync.when(
      data: (contracts) => ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: contracts.length,
        itemBuilder: (ctx, i) {
          final item = contracts[i];
          final contract = item['financing_contracts'] as Map?;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.black.withOpacity(0.03))),
            child: ListTile(
              dense: true,
              title: Text('عقد رقم ${contract?['contract_no'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('المساهمة: ${item['amount_allocated']} ر.س'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 12),
              onTap: () => context.push('/contracts/${contract?['id']}'),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _WithdrawalRequestsTab extends ConsumerWidget {
  final String investorId;
  const _WithdrawalRequestsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(withdrawalRequestsControllerProvider(investorId: investorId));
    return requestsAsync.when(
      data: (reqs) => ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: reqs.length,
        itemBuilder: (ctx, i) {
          final r = reqs[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              title: Text('${r['amount']} ر.س', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(r['status'] == 'pending' ? 'قيد الانتظار' : 'مكتمل'),
              trailing: Icon(r['status'] == 'pending' ? Icons.hourglass_empty : Icons.check_circle, color: r['status'] == 'pending' ? Colors.orange : _green, size: 16),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
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
      data: (list) => ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (ctx, i) {
          final item = list[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _blue.withOpacity(0.1))),
            child: Row(
              children: [
                Icon(Icons.event_note, color: _blue, size: 16),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('دفعة متوقعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text(item['due_date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 10))])),
                Text('${f.format((item['total_expected'] as num).toDouble())} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 13)),
              ],
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}
