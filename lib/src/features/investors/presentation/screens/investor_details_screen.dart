import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../investor_controller.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../domain/investor_transaction_type.dart';
import 'package:intl/intl.dart' as intl;

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
          length: 3,
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
                    ref.invalidate(investorDocumentsControllerProvider(id));
                  },
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'العمليات المالية'),
                  Tab(text: 'العقود الممولة'),
                  Tab(text: 'المستندات'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _FinancialTab(investor: investor),
                _ContractsTab(investorId: investor.id),
                _DocumentsTab(investorId: investor.id),
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('الرصيد المتاح', investor.availableBalance, Colors.green),
                _buildStatItem('رأس المال المستثمر', investor.deployedCapital, Colors.blue),
                _buildStatItem('إجمالي الأرباح', investor.totalProfitEarned, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '${intl.NumberFormat.currency(symbol: '', decimalDigits: 2).format(value)} ر.س',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
        ),
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
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'المبلغ', suffixText: 'ر.س'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'الوصف / ملاحظات'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  await ref.read(investorTransactionsControllerProvider(investorId).notifier).distributeProfit(
                    investorId: investorId,
                    amount: amount,
                    description: descController.text,
                  );
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
      data: (contracts) {
        if (contracts.isEmpty) return const Center(child: Text('لا توجد عقود ممولة حالياً'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contracts.length,
          itemBuilder: (context, index) {
            final item = contracts[index];
            final contract = item['financing_contracts'];
            return Card(
              child: ListTile(
                title: Text('عقد رقم: ${contract['contract_no'] ?? contract['id'].toString().substring(0, 8)}'),
                subtitle: Text('العميل: ${contract['customers']?['full_name'] ?? 'غير معروف'}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'المبلغ الممول: ${item['amount_allocated']} ر.س',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    Text(
                      'الحالة: ${contract['status']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
            ));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}

class _DocumentsTab extends ConsumerWidget {
  final String investorId;
  const _DocumentsTab({required this.investorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(investorDocumentsControllerProvider(investorId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showUploadDialog(context, ref),
            icon: const Icon(Icons.upload_file),
            label: const Text('رفع مستند جديد'),
          ),
        ),
        Expanded(
          child: docsAsync.when(
            data: (docs) {
              if (docs.isEmpty) return const Center(child: Text('لا توجد مستندات'));
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.description, color: Colors.blue),
                      title: Text(doc.name),
                      subtitle: Text(intl.DateFormat('yyyy/MM/dd').format(doc.createdAt)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => ref.read(investorDocumentsControllerProvider(investorId).notifier).deleteDocument(doc.id),
                      ),
                      onTap: () {
                        // Open URL
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  void _showUploadDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final urlController = TextEditingController(); // Simulation: in real app use file picker

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('رفع مستند'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المستند (مثلاً: الهوية الوطنية)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'رابط الملف (محاكاة)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await ref.read(investorDocumentsControllerProvider(investorId).notifier).uploadDocument(
                    nameController.text,
                    urlController.text.isEmpty ? 'https://example.com/file.pdf' : urlController.text,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('رفع'),
            ),
          ],
        ),
      ),
    );
  }
}
