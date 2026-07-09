import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../investor_controller.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../domain/investor_transaction_type.dart';
import 'package:intl/intl.dart' as intl;
import '../../../documents/presentation/widgets/universal_document_manager.dart';

class InvestorDetailsScreen extends ConsumerWidget {
  final String id;
  const InvestorDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorAsync = ref.watch(investorDetailsControllerProvider(id));

    return investorAsync.when(
      data: (investor) {
        if (investor == null) return const Scaffold(body: Center(child: Text('المستثمر غير موجود')));

        return DefaultTabController(
          length: 5, // تم زيادة العدد لـ 5 تبويبات
          child: Scaffold(
            appBar: AppBar(
              title: Text(investor.fullName),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.invalidate(investorDetailsControllerProvider(id));
                    ref.invalidate(investorTransactionsControllerProvider(id));
                    ref.invalidate(investorFundedContractsControllerProvider(id));
                    ref.invalidate(investorProjectionsProvider(id));
                    ref.invalidate(withdrawalRequestsControllerProvider(investorId: id));
                  },
                ),
              ],
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'العمليات المالية'),
                  Tab(text: 'العقود الممولة'),
                  Tab(text: 'طلبات السحب'),
                  Tab(text: 'التوقعات الماليّة'),
                  Tab(text: 'المستندات'),
                ],
              ),
            ),
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
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('خطأ: $err'))),
    );
  }
}

class _FinancialTab extends ConsumerWidget {
  final dynamic investor;
  const _FinancialTab({required this.investor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(investorTransactionsControllerProvider(investor.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, investor),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('كشف الحساب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showTransactionDialog(context, investor.id, InvestorTransactionType.deposit),
                    icon: const Icon(Icons.add),
                    label: const Text('إيداع'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showTransactionDialog(context, investor.id, InvestorTransactionType.withdrawal),
                    icon: const Icon(Icons.remove),
                    label: const Text('سحب'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showProfitDistributionDialog(context, ref, investor.id),
                    icon: const Icon(Icons.card_giftcard),
                    label: const Text('توزيع أرباح'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTransactionsList(transactionsAsync),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, investor) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('الرصيد المتاح', investor.availableBalance, Colors.green, f),
            _buildStatItem('رأس المال الموظف', investor.deployedCapital, Colors.blue, f),
            _buildStatItem('إجمالي الأرباح', investor.totalProfitEarned, Colors.orange, f),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double value, Color color, intl.NumberFormat f) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text('${f.format(value)} ر.س', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }

  Widget _buildTransactionsList(transactionsAsync) {
    return transactionsAsync.when(
      data: (txs) {
        if (txs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('لا توجد عمليات')));
        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: txs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tx = txs[index];
              return ListTile(
                title: Text(tx.type.label),
                subtitle: Text(intl.DateFormat('yyyy/MM/dd HH:mm').format(tx.createdAt)),
                trailing: Text(
                  '${tx.amount > 0 ? "+" : ""}${tx.amount.toStringAsFixed(2)} ر.س',
                  style: TextStyle(fontWeight: FontWeight.bold, color: tx.amount > 0 ? Colors.green : Colors.red),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }

  void _showTransactionDialog(BuildContext context, String investorId, InvestorTransactionType type) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(investorId: investorId, type: type),
    );
  }

  void _showProfitDistributionDialog(BuildContext context, WidgetRef ref, String investorId) {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('توزيع أرباح يدوية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: amountController, decoration: const InputDecoration(labelText: 'المبلغ', suffixText: 'ر.س'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'الوصف / ملاحظات')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  await ref.read(investorTransactionsControllerProvider(investorId).notifier).distributeProfit(investorId: investorId, amount: amount, description: descController.text);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('تأكيد التوزيع'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractsTab extends ConsumerWidget {
  final String investorId;
  const _ContractsTab({required this.investorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(investorFundedContractsControllerProvider(investorId));
    return contractsAsync.when(
      data: (contracts) => contracts.isEmpty 
        ? const Center(child: Text('لا توجد عقود ممولة حالياً'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final item = contracts[index];
              final contract = item['financing_contracts'];
              return Card(
                child: ListTile(
                  title: Text('عقد رقم: ${contract['contract_no']}'),
                  subtitle: Text('المبلغ الممول: ${item['amount_allocated']} ر.س'),
                  trailing: Text(contract['status'], style: const TextStyle(fontSize: 12)),
                ),
              );
            },
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
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
      data: (requests) => requests.isEmpty 
        ? const Center(child: Text('لا توجد طلبات سحب لهذا المستثمر'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final isPending = req['status'] == 'pending';
              return Card(
                child: ListTile(
                  title: Text('طلب سحب مبلغ: ${req['amount']} ر.س'),
                  subtitle: Text('الحالة: ${req['status']} | التاريخ: ${req['created_at'].toString().split('T')[0]}'),
                  trailing: isPending ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => ref.read(withdrawalRequestsControllerProvider(investorId: investorId).notifier).approveRequest(req['id'])),
                      IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => _showRejectDialog(context, ref, req['id'])),
                    ],
                  ) : null,
                ),
              );
            },
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, String requestId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('رفض طلب السحب'),
          content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'سبب الرفض')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(onPressed: () {
              ref.read(withdrawalRequestsControllerProvider(investorId: investorId).notifier).rejectRequest(requestId, controller.text);
              Navigator.pop(context);
            }, child: const Text('تأكيد الرفض')),
          ],
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
    return projectionsAsync.when(
      data: (list) => list.isEmpty 
        ? const Center(child: Text('لا توجد تدفقات متوقعة حالياً'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event_available, color: Colors.blue),
                  title: Text('استحقاق تاريخ: ${item['due_date']}'),
                  trailing: Text('${item['total_expected']} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ),
              );
            },
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }
}
