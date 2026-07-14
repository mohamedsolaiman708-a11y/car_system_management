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
  final int initialTab;
  const InvestorDetailsScreen({
    super.key,
    required this.id,
    this.initialTab = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorAsync = ref.watch(investorDetailsControllerProvider(id));

    return investorAsync.when(
      data: (investor) {
        if (investor == null) {
          return const Scaffold(
            body: Center(child: Text('المستثمر غير موجود')),
          );
        }

        return DefaultTabController(
          length: 5,
          initialIndex: initialTab,
          child: Scaffold(
            backgroundColor: const Color(0xFFFBFBFD),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 90,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryNavy,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryNavy,
                    radius: 22,
                    child: Text(
                      investor.fullName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            investor.fullName,
                            style: const TextStyle(
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      Text(
                        investor.email,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: AppColors.primaryNavy,
                indicatorWeight: 3,
                labelColor: AppColors.primaryNavy,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'المالية'),
                  Tab(text: 'العقود'),
                  Tab(text: 'السحوبات'),
                  Tab(text: 'التوقعات'),
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('حدث خطأ: $err'))),
    );
  }
}

class _FinancialTab extends ConsumerWidget {
  final Investor investor;
  const _FinancialTab({required this.investor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(
      investorTransactionsControllerProvider(investor.id),
    );
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSmartInsightCard(),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNavy.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الرصيد المتاح للاستثمار',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  '${f.format(investor.availableBalance)} ر.س',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 32),
                Container(height: 1, color: Colors.white.withOpacity(0.05)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatBox(
                      'رأس المال الموظف',
                      f.format(investor.deployedCapital),
                    ),
                    _buildStatBox(
                      'إجمالي الأرباح',
                      f.format(investor.totalProfitEarned),
                      isGold: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  label: 'إيداع رأس مال',
                  icon: Icons.add_rounded,
                  color: const Color(0xFFE8F5E9),
                  textColor: Colors.green.shade700,
                  onPressed: () => _showTransactionDialog(
                    context,
                    investor.id,
                    InvestorTransactionType.deposit,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionBtn(
                  label: 'سحب أرباح',
                  icon: Icons.north_east_rounded,
                  color: const Color(0xFFFFEBEE),
                  textColor: Colors.red.shade700,
                  onPressed: () => _showTransactionDialog(
                    context,
                    investor.id,
                    InvestorTransactionType.withdrawal,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Text(
            'آخر المعاملات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 16),

          transactionsAsync.when(
            data: (txs) {
              if (txs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(60.0),
                    child: Text(
                      'لا توجد سجلات مالية',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txs.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.withOpacity(0.05)),
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final isPositive = tx.amount > 0;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            (isPositive ? Colors.green : Colors.red)
                                .withOpacity(0.08),
                        child: Icon(
                          isPositive ? Icons.add_rounded : Icons.remove_rounded,
                          color: isPositive ? Colors.green : Colors.red,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        tx.type.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        intl.DateFormat(
                          'dd/MM/yyyy • HH:mm',
                        ).format(tx.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isPositive ? "+" : ""}${f.format(tx.amount)} ر.س',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: isPositive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          if (tx.recordedByName != null)
                            Text(
                              'المنفذ: ${tx.recordedByName}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.blueGrey,
                              ),
                            ),
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

  Widget _buildSmartInsightCard() {
    bool isIdle = investor.availableBalance > investor.deployedCapital;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isIdle ? Colors.amber.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isIdle ? Colors.amber.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isIdle ? Icons.auto_awesome_rounded : Icons.insights_rounded,
            color: isIdle ? Colors.amber.shade800 : Colors.blue.shade800,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIdle ? 'توصية ذكية' : 'تحليل المحفظة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isIdle
                        ? Colors.amber.shade900
                        : Colors.blue.shade900,
                  ),
                ),
                Text(
                  isIdle
                      ? 'لديك سيولة نقدية متاحة لم تُستثمر بعد. ننصح بتمويل عقود جديدة لرفع العائد المالي.'
                      : 'محفظتك تعمل بكفاءة عالية. توزيع رأس المال متوازن مع العقود الحالية.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, {bool isGold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          '$value ر.س',
          style: TextStyle(
            color: isGold ? AppColors.accentGold : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDialog(
    BuildContext context,
    String investorId,
    InvestorTransactionType type,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          AddTransactionDialog(investorId: investorId, type: type),
    );
  }
}

class _ContractsTab extends ConsumerWidget {
  final String investorId;
  const _ContractsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(
      investorFundedContractsControllerProvider(investorId),
    );
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return contractsAsync.when(
      data: (contracts) => contracts.isEmpty
          ? const Center(child: Text('لا توجد عقود'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: contracts.length,
              itemBuilder: (context, index) {
                final item = contracts[index];
                final contract = item['financing_contracts'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: AppColors.primaryNavy,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'عقد #${contract['contract_no']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'العميل: ${contract['customers']?['full_name']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${f.format(item['amount_allocated'])} ر.س',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
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
    final requestsAsync = ref.watch(
      withdrawalRequestsControllerProvider(investorId: investorId),
    );
    return requestsAsync.when(
      data: (requests) => requests.isEmpty
          ? const Center(child: Text('لا توجد طلبات سحب'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    title: Text('سحب: ${req['amount']} ر.س'),
                    subtitle: Text('الحالة: ${req['status']}'),
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
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
          ? const Center(child: Text('لا توجد تدفقات متوقعة'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    title: Text('تحصيل متوقع في ${item['due_date']}'),
                    trailing: Text(
                      '${item['total_expected']} ر.س',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }
}
