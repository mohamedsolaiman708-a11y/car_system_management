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

const _navy = Color(0xFF0F172A);
const _gold = Color(0xFFD4AF37);
const _bg   = Color(0xFFF8FAFC);

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
        if (investor == null) return const Scaffold(body: Center(child: Text('غير موجود')));
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DefaultTabController(
            length: 5,
            initialIndex: widget.initialTab,
            child: Scaffold(
              backgroundColor: _bg,
              body: NestedScrollView(
                headerSliverBuilder: (ctx, _) => [
                  _buildCompactAppBar(context, investor),
                  _buildQuickStatsSliver(investor),
                ],
                body: TabBarView(
                  children: [
                    _FinancialTab(investor: investor, dateRange: _selectedDateRange, onDateRangeSelected: (range) => setState(() => _selectedDateRange = range)),
                    _ContractsTab(investorId: investor.id),
                    _WithdrawalRequestsTab(investorId: investor.id),
                    _ProjectionsTab(investorId: investor.id),
                    Padding(padding: const EdgeInsets.all(16.0), child: UniversalDocumentManager(investorId: investor.id)),
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

  Widget _buildCompactAppBar(BuildContext context, Investor investor) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    final total = investor.availableBalance + investor.deployedCapital;

    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      backgroundColor: _navy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(investor.fullName, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              Text(investor.email, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(f.format(total), style: const TextStyle(color: _gold, fontSize: 18, fontWeight: FontWeight.w900)),
              const Text('إجمالي المحفظة', style: TextStyle(color: Colors.white38, fontSize: 8)),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: const BoxDecoration(color: _navy, border: Border(top: BorderSide(color: Colors.white10, width: 0.5))),
          child: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: _gold,
            labelColor: _gold,
            unselectedLabelColor: Colors.white38,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            tabs: [Tab(text: 'المالية'), Tab(text: 'العقود'), Tab(text: 'السحوبات'), Tab(text: 'التوقعات'), Tab(text: 'المستندات')],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsSliver(Investor investor) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            _StatChip(label: 'السيولة', value: f.format(investor.availableBalance), color: Colors.green),
            const SizedBox(width: 8),
            _StatChip(label: 'المشغل', value: f.format(investor.deployedCapital), color: Colors.blue),
            const SizedBox(width: 8),
            _StatChip(label: 'الأرباح', value: f.format(investor.totalProfitEarned), color: _gold),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 9, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            FittedBox(child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14))),
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
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _actionBtn(context, 'إيداع رأس مال', Icons.add_circle, Colors.green, () => _showTxDialog(context, investor.id, InvestorTransactionType.deposit))),
              const SizedBox(width: 12),
              Expanded(child: _actionBtn(context, 'سحب أرباح', Icons.remove_circle, Colors.red, () => _showTxDialog(context, investor.id, InvestorTransactionType.withdrawal))),
            ],
          ),
          const SizedBox(height: 20),
          _buildFilterBar(context),
          const SizedBox(height: 16),
          transactionsAsync.when(
            data: (txs) {
              final filtered = dateRange == null ? txs : txs.where((t) => t.createdAt.isAfter(dateRange!.start) && t.createdAt.isBefore(dateRange!.end)).toList();
              if (filtered.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('لا توجد عمليات', style: TextStyle(color: Colors.grey))));
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final tx = filtered[i];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black.withOpacity(0.03))),
                    child: ListTile(
                      dense: true,
                      leading: Icon(tx.amount > 0 ? Icons.add_chart : Icons.pie_chart, color: tx.amount > 0 ? Colors.green : Colors.red, size: 16),
                      title: Text(tx.type.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      subtitle: Text(intl.DateFormat('yyyy/MM/dd').format(tx.createdAt), style: const TextStyle(fontSize: 10)),
                      trailing: Text('${f.format(tx.amount)} ر.س', style: TextStyle(fontWeight: FontWeight.bold, color: tx.amount > 0 ? Colors.green : Colors.red, fontSize: 13)),
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

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('تقرير العمليات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          InkWell(
            onTap: () async {
              final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now());
              if (picked != null) onDateRangeSelected(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(6)),
              child: const Text('فلترة التاريخ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _navy)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String l, IconData i, Color c, VoidCallback onTap) => ElevatedButton.icon(onPressed: onTap, icon: Icon(i, size: 14), label: Text(l), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _navy, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withOpacity(0.05))), minimumSize: const Size(0, 45)));

  void _showTxDialog(BuildContext ctx, String invId, InvestorTransactionType type) {
    showDialog(context: ctx, builder: (_) => AddTransactionDialog(investorId: invId, type: type));
  }
}

class _ContractsTab extends ConsumerWidget {
  final String investorId;
  const _ContractsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(investorFundedContractsControllerProvider(investorId));
    return contractsAsync.when(
      data: (contracts) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contracts.length,
        itemBuilder: (ctx, i) {
          final item = contracts[i];
          final contract = item['financing_contracts'] as Map?;
          return Card(elevation: 0, margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black.withOpacity(0.03))), child: ListTile(dense: true, title: Text('عقد #${contract?['contract_no'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), subtitle: Text('المساهمة: ${item['amount_allocated']} ر.س', style: const TextStyle(fontSize: 10)), trailing: const Icon(Icons.arrow_forward_ios, size: 10), onTap: () => context.push('/contracts/${contract?['id']}')));
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
        padding: const EdgeInsets.all(16),
        itemCount: reqs.length,
        itemBuilder: (ctx, i) {
          final r = reqs[i];
          return Card(margin: const EdgeInsets.only(bottom: 6), child: ListTile(dense: true, title: Text('${r['amount']} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), trailing: Icon(r['status'] == 'pending' ? Icons.access_time : Icons.check_circle, color: r['status'] == 'pending' ? Colors.orange : Colors.green, size: 16)));
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
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (ctx, i) {
          final item = list[i];
          return Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withOpacity(0.1))), child: Row(children: [const Icon(Icons.event_available, color: Colors.blue, size: 16), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('دفعة متوقعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), Text(item['due_date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 9))])), Text('${f.format((item['total_expected'] as num).toDouble())} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12))]));
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}
