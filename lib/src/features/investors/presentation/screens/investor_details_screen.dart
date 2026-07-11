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
        if (investor == null) {
          return const Scaffold(body: Center(child: Text('المستثمر غير موجود')));
        }

        return DefaultTabController(
          length: 5,
          child: Scaffold(
            backgroundColor: AppColors.bgGrey,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(140),
              child: AppBar(
                backgroundColor: AppColors.primaryNavy,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(investor.fullName, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                    Text(investor.email, 
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: () {
                        ref.invalidate(investorDetailsControllerProvider(id));
                        ref.invalidate(investorTransactionsControllerProvider(id));
                      },
                    ),
                  ),
                ],
                bottom: TabBar(
                  isScrollable: true,
                  indicatorColor: AppColors.accentGold,
                  indicatorWeight: 4,
                  labelColor: AppColors.accentGold,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(text: 'نظرة مالية'),
                    Tab(text: 'العقود الممولة'),
                    Tab(text: 'طلبات السحب'),
                    Tab(text: 'التوقعات المالية'),
                    Tab(text: 'المستندات'),
                  ],
                ),
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
      error: (err, stack) => Scaffold(body: Center(child: Text('حدث خطأ: $err'))),
    );
  }
}

class _FinancialTab extends ConsumerWidget {
  final Investor investor;
  const _FinancialTab({required this.investor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(investorTransactionsControllerProvider(investor.id));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // لوحة الأرصدة الرئيسية (Credit Card Style)
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondaryNavy, AppColors.primaryNavy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: AppColors.primaryNavy.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -50,
                  top: -50,
                  child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.03)),
                ),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('إجمالي الرصيد المتاح', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('${f.format(investor.availableBalance)} ر.س', 
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Row(
                            children: [
                              _buildMiniStat('رأس المال الموظف', f.format(investor.deployedCapital)),
                              const SizedBox(width: 40),
                              _buildMiniStat('إجمالي الأرباح', f.format(investor.totalProfitEarned), isProfit: true),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded, color: AppColors.accentGold, size: 48),
                          const SizedBox(height: 12),
                          const Text('المحفظة الذكية', style: TextStyle(color: AppColors.accentGold, fontSize: 10, letterSpacing: 1.2)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // شريط الأدوات التنفيذية
          Row(
            children: [
              const Text('سجل المعاملات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showTransactionDialog(context, investor.id, InvestorTransactionType.deposit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(0, 45),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('إيداع رأس مال'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _showTransactionDialog(context, investor.id, InvestorTransactionType.withdrawal),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                  side: const BorderSide(color: AppColors.errorRed),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(0, 45),
                ),
                icon: const Icon(Icons.outbox_rounded),
                label: const Text('سحب أرباح'),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // قائمة العمليات بتصميم فاخر
          transactionsAsync.when(
            data: (txs) {
              if (txs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(60),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Column(
                    children: [
                      Icon(Icons.history_rounded, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('لا توجد معاملات مالية مسجلة بعد', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txs.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final isPositive = tx.amount > 0;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(isPositive ? Icons.south_west_rounded : Icons.north_east_rounded, 
                          color: isPositive ? Colors.green : Colors.red, size: 20),
                      ),
                      title: Text(tx.type.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(intl.DateFormat('dd MMMM yyyy • HH:mm', 'ar').format(tx.createdAt), 
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${isPositive ? "+" : ""}${f.format(tx.amount)} ر.س',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, 
                              color: isPositive ? Colors.green : Colors.red)),
                          if (tx.description != null && tx.description!.isNotEmpty)
                            Text(tx.description!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('خطأ: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, {bool isProfit = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text('$value ر.س', style: TextStyle(
          color: isProfit ? AppColors.accentGold : Colors.white, 
          fontWeight: FontWeight.bold, 
          fontSize: 14)),
      ],
    );
  }

  void _showTransactionDialog(BuildContext context, String investorId, InvestorTransactionType type) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(investorId: investorId, type: type),
    );
  }
}

class _ContractsTab extends ConsumerWidget {
  final String investorId;
  const _ContractsTab({required this.investorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(investorFundedContractsControllerProvider(investorId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return contractsAsync.when(
      data: (contracts) {
        if (contracts.isEmpty) return const Center(child: Text('لا توجد عقود ممولة حالياً'));
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: contracts.length,
          itemBuilder: (context, index) {
            final item = contracts[index];
            final contract = item['financing_contracts'];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: const CircleAvatar(backgroundColor: AppColors.bgGrey, child: Icon(Icons.description_outlined, color: AppColors.primaryNavy)),
                title: Text('عقد تمويل #${contract['contract_no']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('العميل: ${contract['customers']?['full_name'] ?? "غير محدد"}', style: const TextStyle(color: Colors.grey)),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${f.format(item['amount_allocated'])} ر.س', 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 16)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                      child: Text(contract['status'], style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
            padding: const EdgeInsets.all(24),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final isPending = req['status'] == 'pending';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.account_balance_outlined, color: AppColors.accentGold),
                  title: Text('طلب سحب: ${req['amount']} ر.س', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('تاريخ الطلب: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(req['created_at']))}'),
                  trailing: isPending ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.check_circle_rounded, color: Colors.green), onPressed: () => ref.read(withdrawalRequestsControllerProvider(investorId: investorId).notifier).approveRequest(req['id'])),
                      IconButton(icon: const Icon(Icons.cancel_rounded, color: Colors.red), onPressed: () => _showRejectDialog(context, ref, req['id'])),
                    ],
                  ) : Text(req['status'], style: const TextStyle(fontWeight: FontWeight.bold)),
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
            padding: const EdgeInsets.all(24),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.trending_up_rounded, color: Colors.green),
                  title: Text('تحصيل متوقع تاريخ: ${item['due_date']}'),
                  trailing: Text('${item['total_expected']} ر.س', 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                ),
              );
            },
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }
}
