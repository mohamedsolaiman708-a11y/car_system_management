import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/services/export_service.dart';
import '../investor_controller.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../../documents/presentation/widgets/universal_document_manager.dart';
import '../../../notifications/presentation/notification_controller.dart';

class InvestorDashboardScreen extends ConsumerWidget {
  const InvestorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final investorAsync = ref.watch(investorDetailsControllerProvider(user.id));
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: investorAsync.when(
        data: (investor) {
          if (investor == null) return const Scaffold(body: Center(child: Text('لم يتم العثور على بيانات المستثمر.')));

          return DefaultTabController(
            length: 5, // زيادة عدد التبويبات إلى 5
            child: Scaffold(
              appBar: AppBar(
                title: const Text('بوابة المستثمر الذكية'),
                actions: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded),
                        onPressed: () => Navigator.of(context).pushNamed('/notifications'),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                  ),
                ],
                bottom: const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard_outlined)),
                    Tab(text: 'محفظة العقود', icon: Icon(Icons.pie_chart_outline_rounded)),
                    Tab(text: 'كشف الحساب', icon: Icon(Icons.receipt_long_outlined)),
                    Tab(text: 'التوقعات المالية', icon: Icon(Icons.auto_graph_outlined)), // التبويب الجديد
                    Tab(text: 'مستنداتي', icon: Icon(Icons.folder_shared_outlined)),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _OverviewTab(investor: investor),
                  _PortfolioTab(investorId: investor.id),
                  _TransactionsTab(investorId: investor.id),
                  _ProjectionsTab(investorId: investor.id), // الويدجت الجديد
                  UniversalDocumentManager(investorId: investor.id),
                ],
              ),
            ),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, _) => Scaffold(body: Center(child: Text('حدث خطأ: $err'))),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  final dynamic investor;
  const _OverviewTab({required this.investor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(investorDetailsControllerProvider(investor.id));
      }, 
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBalanceHeroCard(investor, f),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildSmallStatCard('أرباحك المحققة', f.format(investor.totalProfitEarned), Icons.card_giftcard, Colors.orange),
                const SizedBox(width: 16),
                _buildSmallStatCard('رأس المال الموظف', f.format(investor.deployedCapital), Icons.account_tree_outlined, Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showWithdrawalDialog(context, ref, investor),
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    label: const Text('طلب سحب رصيد متاح'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalDialog(BuildContext context, WidgetRef ref, investor) {
    final amountController = TextEditingController();
    final bankController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('طلب سحب رصيد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الرصيد المتاح: ${investor.availableBalance} ر.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'المبلغ المطلوب سحبه', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bankController,
                decoration: const InputDecoration(labelText: 'تفاصيل الحساب البنكي (IBAN)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0 && amount <= investor.availableBalance) {
                  final success = await ref.read(withdrawalRequestsControllerProvider().notifier).requestWithdrawal(amount, bankController.text);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? 'تم إرسال طلب السحب بنجاح' : 'فشل إرسال الطلب'), backgroundColor: success ? Colors.green : Colors.red),
                    );
                  }
                }
              },
              child: const Text('إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceHeroCard(investor, intl.NumberFormat f) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade700]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('إجمالي القيمة الاستثمارية', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text('${f.format(investor.availableBalance + investor.deployedCapital)} ر.س', 
               style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeroStat('رصيد متاح', f.format(investor.availableBalance)),
              _buildHeroStat('رأس مال عامل', f.format(investor.deployedCapital)),
              _buildHeroStat('أرباح محققة', f.format(investor.totalProfitEarned)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSmallStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortfolioTab extends ConsumerWidget {
  final String investorId;
  const _PortfolioTab({required this.investorId});

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
                  leading: const Icon(Icons.assignment_turned_in_outlined, color: Colors.green),
                  title: Text('عقد رقم: ${contract['contract_no']}'),
                  subtitle: Text('تمويلك: ${item['amount_allocated']} ر.س'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                ),
              );
            },
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }
}

class _TransactionsTab extends ConsumerWidget {
  final String investorId;
  const _TransactionsTab({required this.investorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(investorTransactionsControllerProvider(investorId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('آخر العمليات المالية', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _exportStatement(ref, txAsync.value ?? []),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                label: const Text('تصدير كشف الحساب'),
              ),
            ],
          ),
        ),
        Expanded(
          child: txAsync.when(
            data: (txs) => txs.isEmpty 
              ? const Center(child: Text('لا توجد عمليات مسجلة'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: txs.length,
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final isPlus = tx.amount > 0;
                    return ListTile(
                      leading: Icon(isPlus ? Icons.add_circle_outline : Icons.remove_circle_outline, color: isPlus ? Colors.green : Colors.red),
                      title: Text(tx.type.label),
                      subtitle: Text(intl.DateFormat('yyyy/MM/dd').format(tx.createdAt)),
                      trailing: Text('${isPlus ? "+" : ""}${tx.amount} ر.س', style: TextStyle(fontWeight: FontWeight.bold, color: isPlus ? Colors.green : Colors.red)),
                    );
                  },
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('خطأ: $err')),
          ),
        ),
      ],
    );
  }

  Future<void> _exportStatement(WidgetRef ref, List<dynamic> txs) async {
    final exportService = ref.read(exportServiceProvider);
    final columns = ['التاريخ', 'العملية', 'المبلغ'];
    final rows = txs.map((tx) => [
      intl.DateFormat('yyyy/MM/dd').format(tx.createdAt),
      tx.type.label,
      '${tx.amount} ر.س',
    ]).toList();

    await exportService.exportToPdf(
      title: 'كشف حساب مستثمر',
      columns: columns,
      rows: rows,
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
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('لا توجد تدفقات متوقعة حالياً (يرجى مراجعة العقود النشطة)'));
        
        double grandTotal = 0;
        for (var item in list) grandTotal += (item['total_expected'] as num).toDouble();

        return Column(
          children: [
            _buildProjectionsHeader(grandTotal),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.event_available, color: Colors.blue),
                      title: Text('تاريخ الاستحقاق: ${item['due_date']}'),
                      subtitle: Text('عدد الأقساط: ${item['contract_count']}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${item['total_expected']} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          const Text('متوقع تحصيله', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }

  Widget _buildProjectionsHeader(double total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        children: [
          const Text('إجمالي التدفقات النقدية المتوقعة مستقبلاً', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${intl.NumberFormat.currency(symbol: '').format(total)} ر.س', 
               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
        ],
      ),
    );
  }
}
