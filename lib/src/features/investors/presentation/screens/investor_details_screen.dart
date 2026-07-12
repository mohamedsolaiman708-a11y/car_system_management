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
              preferredSize: const Size.fromHeight(170),
              child: AppBar(
                backgroundColor: AppColors.primaryNavy,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accentGold, width: 2),
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColors.accentGold,
                        radius: 28,
                        child: Text(investor.fullName[0].toUpperCase(), 
                          style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(investor.fullName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.verified_user_rounded, size: 24, color: AppColors.accentGold),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('مستثمر بلاتيني', style: TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Text(investor.email,
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 24),
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
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primaryNavy))),
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
          // البطاقة المالية الفاخرة (Diamond Card Style)
          Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondaryNavy, AppColors.primaryNavy, Color(0xFF001529)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: AppColors.primaryNavy.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 15))
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Opacity(
                    opacity: 0.05,
                    child: Icon(Icons.account_balance_rounded, size: 240, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: AppColors.accentGold, size: 18),
                              const SizedBox(width: 10),
                              Text(investor.fullName.toUpperCase(), 
                                style: const TextStyle(color: AppColors.accentGold, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                            ],
                          ),
                          const Text('AL SAMI AUTO', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('إجمالي الرصيد المتاح للاستثمار', style: TextStyle(color: Colors.white70, fontSize: 15)),
                      const SizedBox(height: 6),
                      Text('${f.format(investor.availableBalance)} ر.س',
                          style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniStat('رأس المال الموظف', f.format(investor.deployedCapital)),
                          Container(width: 1.5, height: 40, color: Colors.white12),
                          _buildMiniStat('إجمالي الأرباح المستلمة', f.format(investor.totalProfitEarned), isProfit: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // شريط العمليات
          Row(
            children: [
              const Text('سجل الحركات المالية الموثقة', 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
              const Spacer(),
              _buildActionButton(
                label: 'إيداع رأس مال',
                icon: Icons.add_to_photos_rounded,
                color: AppColors.successGreen,
                onPressed: () => _showTransactionDialog(context, investor.id, InvestorTransactionType.deposit),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                label: 'سحب أرباح',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.errorRed,
                onPressed: () => _showTransactionDialog(context, investor.id, InvestorTransactionType.withdrawal),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // قائمة العمليات
          transactionsAsync.when(
            data: (txs) {
              if (txs.isEmpty) {
                return _buildEmptyTransactions();
              }
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 5))],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txs.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade50, indent: 24, endIndent: 24),
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final isPositive = tx.amount > 0;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      leading: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (isPositive ? AppColors.successGreen : AppColors.errorRed).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(isPositive ? Icons.call_received_rounded : Icons.call_made_rounded,
                            color: isPositive ? AppColors.successGreen : AppColors.errorRed, size: 24),
                      ),
                      title: Row(
                        children: [
                          Text(tx.type.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primaryNavy)),
                          const SizedBox(width: 12),
                          if (tx.description != null && tx.description!.isNotEmpty)
                            _buildTag(tx.description!),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.event_available_rounded, size: 12, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(intl.DateFormat('dd MMMM yyyy • HH:mm', 'ar').format(tx.createdAt),
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${isPositive ? "+" : ""}${f.format(tx.amount)} ر.س',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                                  color: isPositive ? AppColors.successGreen : AppColors.errorRed)),
                          const SizedBox(height: 8),
                          // ختم الاعتماد للموظف بأسلوب فاخر
                          _buildStaffBadge(tx.recordedByName ?? "النظام"),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
            error: (err, _) => Center(child: Text('خطأ في البيانات: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, {bool isProfit = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 6),
        Text('$value ر.س', style: TextStyle(
            color: isProfit ? AppColors.accentGold : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18)),
      ],
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStaffBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryNavy.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user_rounded, size: 12, color: AppColors.primaryNavy),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 11, color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(80),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: const Column(
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text('لا توجد سجلات مالية موثقة لهذا المستثمر حالياً', 
            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
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
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(24),
                leading: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.description_outlined, color: AppColors.primaryNavy),
                ),
                title: Text('عقد تمويل #${contract['contract_no']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('العميل المستفيد: ${contract['customers']?['full_name'] ?? "غير محدد"}', 
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${f.format(item['amount_allocated'])} ر.س',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 20)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                      child: Text(contract['status'].toString().toUpperCase(), 
                        style: TextStyle(fontSize: 11, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
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
          ? const Center(child: Text('لا توجد طلبات سحب معلقة'))
          : ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          final isPending = req['status'] == 'pending';
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: const CircleAvatar(backgroundColor: AppColors.bgGrey, child: Icon(Icons.account_balance_outlined, color: AppColors.accentGold)),
              title: Text('طلب سحب: ${req['amount']} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              subtitle: Text('تاريخ الطلب: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(req['created_at']))}'),
              trailing: isPending ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28), onPressed: () => ref.read(withdrawalRequestsControllerProvider(investorId: investorId).notifier).approveRequest(req['id'])),
                  IconButton(icon: const Icon(Icons.cancel_rounded, color: Colors.red, size: 28), onPressed: () => _showRejectDialog(context, ref, req['id'])),
                ],
              ) : Text(req['status'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          ? const Center(child: Text('لا توجد تدفقات نقدية متوقعة حالياً'))
          : ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade100)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.trending_up_rounded, color: Colors.green),
              ),
              title: Text('تحصيل مستقبلي متوقع', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('تاريخ الاستحقاق: ${item['due_date']}', style: const TextStyle(fontSize: 13)),
              trailing: Text('${item['total_expected']} ر.س',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }
}
