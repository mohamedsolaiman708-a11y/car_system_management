import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../investor_controller.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../domain/investor_transaction_type.dart';
import '../../domain/investor.dart';
import 'package:intl/intl.dart' as intl;
import '../../../documents/presentation/widgets/universal_document_manager.dart';
import '../../../../core/utils/app_theme.dart';

class InvestorDetailsScreen extends ConsumerWidget {
  final String id;
  const InvestorDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorAsync = ref.watch(investorDetailsControllerProvider(id));

    return investorAsync.when(
      data: (investor) {
        if (investor == null) return const Scaffold(body: Center(child: Text('غير موجود')));

        return DefaultTabController(
          length: 5,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Text(investor.fullName, style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
              bottom: const TabBar(
                isScrollable: true,
                labelColor: AppColors.primaryNavy,
                indicatorColor: AppColors.primaryNavy,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: 'العمليات المالية'),
                  Tab(text: 'العقود الممولة'),
                  Tab(text: 'طلبات السحب'),
                  Tab(text: 'التوقعات'),
                  Tab(text: 'المستندات'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _FinancialClassicTab(investor: investor),
                _ContractsClassicTab(investorId: investor.id),
                _WithdrawalsClassicTab(investorId: investor.id),
                _ProjectionsClassicTab(investorId: investor.id),
                UniversalDocumentManager(investorId: investor.id),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('خطأ: $err'))),
    );
  }
}

class _FinancialClassicTab extends ConsumerWidget {
  final Investor investor;
  const _FinancialClassicTab({required this.investor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(investorTransactionsControllerProvider(investor.id));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('المتاح', investor.availableBalance, Colors.green, f),
                _buildStatItem('الموظف', investor.deployedCapital, Colors.blue, f),
                _buildStatItem('الأرباح', investor.totalProfitEarned, Colors.orange, f),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _ActionBtn('إيداع', Icons.add, Colors.green, () => _showAddDialog(context, investor.id, InvestorTransactionType.deposit)),
              const SizedBox(width: 8),
              _ActionBtn('سحب', Icons.remove, Colors.red, () => _showAddDialog(context, investor.id, InvestorTransactionType.withdrawal)),
              const SizedBox(width: 8),
              // ميزة ذكية (تم إعادتها): زر توزيع الأرباح
              _ActionBtn('توزيع أرباح', Icons.card_giftcard, Colors.orange, () => _showProfitDialog(context, ref, investor.id)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
            child: transactionsAsync.when(
              data: (txs) => _buildTxTable(txs, f),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => const Text('خطأ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, double val, Color color, intl.NumberFormat f) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text('${f.format(val)} ر.س', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildTxTable(List txs, intl.NumberFormat f) {
    return DataTable(
      headingRowHeight: 40,
      dataRowHeight: 45,
      columns: const [
        DataColumn(label: Text('البيان', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        DataColumn(label: Text('التاريخ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        DataColumn(label: Text('المبلغ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
      ],
      rows: txs.map((tx) => DataRow(cells: [
        DataCell(Text(tx.type.label, style: const TextStyle(fontSize: 12))),
        DataCell(Text(intl.DateFormat('yyyy/MM/dd').format(tx.createdAt), style: const TextStyle(fontSize: 11))),
        DataCell(Text(f.format(tx.amount), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tx.amount > 0 ? Colors.green : Colors.red))),
      ])).toList(),
    );
  }

  void _showAddDialog(BuildContext context, String id, InvestorTransactionType type) {
    showDialog(context: context, builder: (context) => AddTransactionDialog(investorId: id, type: type));
  }

  void _showProfitDialog(BuildContext context, WidgetRef ref, String investorId) {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: const Text('توزيع أرباح يدوية', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: amountController, decoration: const InputDecoration(labelText: 'المبلغ', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'البيان / ملاحظات', border: OutlineInputBorder())),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final val = double.tryParse(amountController.text);
                if (val != null) {
                  await ref.read(investorTransactionsControllerProvider(investorId).notifier).distributeProfit(investorId: investorId, amount: val, description: descController.text);
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

class _ActionBtn extends StatelessWidget {
  final String label; final IconData icon; final Color color; final VoidCallback onTap;
  const _ActionBtn(this.label, this.icon, this.color, this.onTap);
  @override
  Widget build(BuildContext context) {
    return Expanded(child: OutlinedButton.icon(
      onPressed: onTap, icon: Icon(icon, size: 16, color: color), label: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.primaryNavy)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
    ));
  }
}

class _ContractsClassicTab extends ConsumerWidget {
  final String investorId;
  const _ContractsClassicTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(investorFundedContractsControllerProvider(investorId)).valueOrNull ?? [];
    return list.isEmpty ? const Center(child: Text('لا توجد عقود')) : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final c = list[index]['financing_contracts'];
        return Card(elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200)), child: ListTile(dense: true, title: Text('عقد #${c['contract_no']}'), trailing: Text('${list[index]['amount_allocated']} ر.س')));
      },
    );
  }
}

class _WithdrawalsClassicTab extends ConsumerWidget {
  final String investorId;
  const _WithdrawalsClassicTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) { return const Center(child: Text('سجل السحوبات المدمج')); }
}
class _ProjectionsClassicTab extends ConsumerWidget {
  final String investorId;
  const _ProjectionsClassicTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) { return const Center(child: Text('التوقعات المالية المدمجة')); }
}
