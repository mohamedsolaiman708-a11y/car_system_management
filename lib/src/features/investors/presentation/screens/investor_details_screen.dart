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
              backgroundColor: AppColors.bgGrey,
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
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primaryNavy))),
      error: (err, _) => Scaffold(body: Center(child: Text(Failure.fromException(err).message))),
    );
  }
}

class _InvestorDetailsSliverHeader extends StatelessWidget {
  final Investor investor;
  const _InvestorDetailsSliverHeader({required this.investor});

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primaryNavy,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryNavy, Color(0xFF1B2A4A)]),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.accentGold.withOpacity(0.1),
                    child: Text(investor.fullName[0], style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 24)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(investor.fullName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('إجمالي المحفظة: ${f.format(investor.availableBalance + investor.deployedCapital)} ر.س', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _HeaderStat('السيولة المتاحة', f.format(investor.availableBalance), Icons.account_balance_wallet, Colors.green),
                  _HeaderStat('رأس المال المشغل', f.format(investor.deployedCapital), Icons.rocket_launch, Colors.blue),
                  _HeaderStat('الأرباح الفعلية', f.format(investor.totalProfitEarned), Icons.trending_up, AppColors.accentGold),
                ],
              ),
            ],
          ),
        ),
      ),
      bottom: const TabBar(
        isScrollable: true,
        indicatorColor: AppColors.accentGold,
        labelColor: AppColors.accentGold,
        unselectedLabelColor: Colors.white70,
        tabs: [
          Tab(text: 'المالية والأرباح'),
          Tab(text: 'العقود الممولة'),
          Tab(text: 'طلبات السحب'),
          Tab(text: 'الأرباح المتوقعة'),
          Tab(text: 'المستندات'),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _HeaderStat(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
        ],
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildProfitFilterCard(context),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _actionBtn(context, 'إيداع رأس مال', Icons.add_circle, Colors.green, () => _showTxDialog(context, investor.id, InvestorTransactionType.deposit))),
              const SizedBox(width: 16),
              Expanded(child: _actionBtn(context, 'سحب أرباح/رصيد', Icons.remove_circle, Colors.red, () => _showTxDialog(context, investor.id, InvestorTransactionType.withdrawal))),
            ],
          ),
          const SizedBox(height: 32),
          const Row(children: [Icon(Icons.history, size: 18), SizedBox(width: 8), Text('سجل العمليات المالية', style: TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 16),
          transactionsAsync.when(
            data: (txs) {
              final filtered = dateRange == null ? txs : txs.where((t) => t.createdAt.isAfter(dateRange!.start) && t.createdAt.isBefore(dateRange!.end)).toList();
              return filtered.isEmpty ? const Center(child: Text('لا توجد عمليات في هذه الفترة')) : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final tx = filtered[i];
                  final isPlus = tx.amount > 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(isPlus ? Icons.arrow_downward : Icons.arrow_upward, color: isPlus ? Colors.green : Colors.red),
                      title: Text(tx.type.label),
                      subtitle: Text(intl.DateFormat('yyyy/MM/dd').format(tx.createdAt)),
                      trailing: Text('${f.format(tx.amount)} ر.س', style: TextStyle(fontWeight: FontWeight.bold, color: isPlus ? Colors.green : Colors.red)),
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

  Widget _buildProfitFilterCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.primaryNavy, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('استعلام عن الأرباح لفترة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (picked != null) onDateRangeSelected(picked);
                },
                icon: const Icon(Icons.date_range, color: AppColors.accentGold),
                label: Text(dateRange == null ? 'اختر الفترة' : '${intl.DateFormat('MM/dd').format(dateRange!.start)} - ${intl.DateFormat('MM/dd').format(dateRange!.end)}', style: const TextStyle(color: AppColors.accentGold)),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatMini('الأرباح في هذه الفترة', '2,450 ر.س', AppColors.accentGold),
              _StatMini('عدد العقود الممولة', '3 عقود', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _StatMini(String l, String v, Color c) => Column(children: [Text(l, style: const TextStyle(color: Colors.white54, fontSize: 11)), Text(v, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 16))]);

  Widget _actionBtn(BuildContext context, String l, IconData i, Color c, VoidCallback onTap) => ElevatedButton.icon(onPressed: onTap, icon: Icon(i, size: 18), label: Text(l), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryNavy, minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

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
        padding: const EdgeInsets.all(24),
        itemCount: contracts.length,
        itemBuilder: (ctx, i) {
          final item = contracts[i];
          final contract = item['financing_contracts'] as Map?;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('عقد رقم ${contract?['contract_no'] ?? '-'}'),
              subtitle: Text('قيمة المساهمة: ${item['amount_allocated']} ر.س'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
        padding: const EdgeInsets.all(24),
        itemCount: reqs.length,
        itemBuilder: (ctx, i) {
          final r = reqs[i];
          return Card(
            child: ListTile(
              title: Text('${r['amount']} ر.س'),
              subtitle: Text(r['status']),
              trailing: r['status'] == 'pending' ? const Icon(Icons.hourglass_empty, color: Colors.orange) : const Icon(Icons.check_circle, color: Colors.green),
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
        padding: const EdgeInsets.all(24),
        itemCount: list.length,
        itemBuilder: (ctx, i) {
          final item = list[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.withOpacity(0.1))),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('دفعة أرباح متوقعة', style: TextStyle(fontWeight: FontWeight.bold)), Text(item['due_date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11))])),
                Text('${f.format((item['total_expected'] as num).toDouble())} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
