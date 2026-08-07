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
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(130), // ارتفاع ذكي ونحيف جداً
                child: _SmartCompactAppBar(investor: investor),
              ),
              body: TabBarView(
                children: [
                  _FinancialTab(investor: investor, dateRange: _selectedDateRange, onDateRangeSelected: (range) => setState(() => _selectedDateRange = range)),
                  _ContractsTab(investorId: investor.id),
                  _WithdrawalRequestsTab(investorId: investor.id),
                  _ProjectionsTab(investorId: investor.id),
                  Padding(padding: const EdgeInsets.all(12.0), child: UniversalDocumentManager(investorId: investor.id)),
                ],
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

class _SmartCompactAppBar extends StatelessWidget {
  final Investor investor;
  const _SmartCompactAppBar({required this.investor});

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    final total = investor.availableBalance + investor.deployedCapital;

    return Container(
      color: _navy,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18), onPressed: () => context.pop()),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(investor.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(investor.email, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(f.format(total), style: const TextStyle(color: _gold, fontSize: 20, fontWeight: FontWeight.w900)),
                      const Text('إجمالي المحفظة', style: TextStyle(color: Colors.white54, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: _gold,
              indicatorWeight: 2,
              labelColor: _gold,
              unselectedLabelColor: Colors.white38,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Cairo'),
              tabs: [
                Tab(text: 'المالية والأرباح'), Tab(text: 'العقود'), Tab(text: 'السحوبات'), Tab(text: 'التوقعات'), Tab(text: 'المستندات'),
              ],
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
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // شريط الأرصدة (نحيف وموفر للمساحة)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black.withOpacity(0.05))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem('سيولة متاحة', f.format(investor.availableBalance), Colors.green),
                _StatItem('رأس مال مشغل', f.format(investor.deployedCapital), Colors.blue),
                _StatItem('صافي أرباح', f.format(investor.totalProfitEarned), _gold),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _actionBtn(context, 'إيداع جديد', Icons.add_circle, Colors.green, () => _showTxDialog(context, investor.id, InvestorTransactionType.deposit))),
              const SizedBox(width: 8),
              Expanded(child: _actionBtn(context, 'سحب رصيد', Icons.remove_circle, Colors.red, () => _showTxDialog(context, investor.id, InvestorTransactionType.withdrawal))),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterBar(context),
          const SizedBox(height: 8),
          transactionsAsync.when(
            data: (txs) {
              final filtered = dateRange == null ? txs : txs.where((t) => t.createdAt.isAfter(dateRange!.start) && t.createdAt.isBefore(dateRange!.end)).toList();
              if (filtered.isEmpty) return _emptyState('لا توجد عمليات');
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final tx = filtered[i];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.black.withOpacity(0.02))),
                    child: ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: Icon(tx.amount > 0 ? Icons.arrow_downward : Icons.arrow_upward, color: tx.amount > 0 ? Colors.green : Colors.red, size: 14),
                      title: Text(tx.type.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      subtitle: Text(intl.DateFormat('yyyy/MM/dd').format(tx.createdAt), style: const TextStyle(fontSize: 9)),
                      trailing: Text('${f.format(tx.amount)} ر.س', style: TextStyle(fontWeight: FontWeight.bold, color: tx.amount > 0 ? Colors.green : Colors.red, fontSize: 11)),
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

  Widget _StatItem(String l, String v, Color c) => Column(children: [Text(l, style: TextStyle(color: Colors.grey, fontSize: 9)), Text(v, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 13))]);

  Widget _actionBtn(BuildContext context, String l, IconData i, Color c, VoidCallback onTap) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withOpacity(0.05))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 14, color: c), const SizedBox(width: 4), Text(l, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _navy))])));

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: _navy.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('تقرير أرباح الفترة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          InkWell(
            onTap: () async {
              final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now());
              if (picked != null) onDateRangeSelected(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(4)),
              child: const Text('تصفية التاريخ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _navy)),
            ),
          ),
        ],
      ),
    );
  }

  void _showTxDialog(BuildContext ctx, String invId, InvestorTransactionType type) {
    showDialog(context: ctx, builder: (_) => AddTransactionDialog(investorId: invId, type: type));
  }

  Widget _emptyState(String t) => Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(t, style: const TextStyle(color: Colors.grey, fontSize: 10))));
}

class _ContractsTab extends ConsumerWidget {
  final String investorId;
  const _ContractsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(investorFundedContractsControllerProvider(investorId));
    return contractsAsync.when(
      data: (contracts) => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: contracts.length,
        itemBuilder: (ctx, i) {
          final item = contracts[i];
          final contract = item['financing_contracts'] as Map?;
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              dense: true,
              title: Text('عقد #${contract?['contract_no'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              subtitle: Text('مساهمة: ${item['amount_allocated']} ر.س', style: const TextStyle(fontSize: 9)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 10),
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
        padding: const EdgeInsets.all(12),
        itemCount: reqs.length,
        itemBuilder: (ctx, i) {
          final r = reqs[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              dense: true,
              title: Text('${r['amount']} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              trailing: Icon(r['status'] == 'pending' ? Icons.hourglass_empty : Icons.check_circle, color: r['status'] == 'pending' ? Colors.orange : Colors.green, size: 14),
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
      data: (list) => list.isEmpty ? const Center(child: Text('لا توجد أرباح متوقعة', style: TextStyle(fontSize: 10))) : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        itemBuilder: (ctx, i) {
          final item = list[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.withOpacity(0.1))),
            child: Row(
              children: [
                const Icon(Icons.event_note, color: _navy, size: 12),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('دفعة متوقعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)), Text(item['due_date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 8))])),
                Text('${f.format((item['total_expected'] as num).toDouble())} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 11)),
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
