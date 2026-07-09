import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../investor_controller.dart';
import '../widgets/create_investor_dialog.dart';

class InvestorsScreen extends ConsumerWidget {
  const InvestorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildTabBar(),
              const SizedBox(height: 16),
              const Expanded(
                child: TabBarView(
                  children: [
                    ActiveInvestorsList(),
                    PendingInvestorsList(),
                    WithdrawalRequestsList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مركز إدارة المستثمرين', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            Text('متابعة رؤوس الأموال، المحافظ الاستثمارية، وتوزيع الأرباح', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          ],
        ),
        if (ResponsiveLayout.isDesktop(context))
          ElevatedButton.icon(
            onPressed: () => showDialog(context: context, builder: (context) => const CreateInvestorDialog()),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: const Text('إضافة مستثمر جديد'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
          ),
      ],
    );
  }

  Widget _buildTabBar() {
    return const TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: AppColors.primaryNavy,
      unselectedLabelColor: AppColors.textGrey,
      indicatorColor: AppColors.accentGold,
      indicatorWeight: 3,
      tabs: [
        Tab(text: 'المستثمرون النشطون'),
        Tab(text: 'طلبات الانضمام'),
        Tab(text: 'طلبات السحب'),
      ],
    );
  }
}

class ActiveInvestorsList extends ConsumerWidget {
  const ActiveInvestorsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorsAsync = ref.watch(investorListControllerProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return investorsAsync.when(
      data: (investors) {
        if (isDesktop) return _buildTable(context, investors, f);
        return _buildCards(context, investors, f);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }

  Widget _buildTable(BuildContext context, List investors, intl.NumberFormat f) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF0F0F0))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.bgGrey),
          dataRowHeight: 75,
          columns: const [
            DataColumn(label: Text('المستثمر', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الرصيد المتاح', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('رأس المال العامل', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('إجمالي الأرباح', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: investors.map((inv) => DataRow(
            cells: [
              DataCell(Row(
                children: [
                  CircleAvatar(backgroundColor: AppColors.accentGold.withOpacity(0.1), child: const Icon(Icons.person, color: AppColors.accentGold, size: 20)),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inv.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(inv.email, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              )),
              DataCell(Text('${f.format(inv.availableBalance)} ر.س', style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold))),
              DataCell(Text('${f.format(inv.deployedCapital)} ر.س')),
              DataCell(Text('${f.format(inv.totalProfitEarned)} ر.س', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
              DataCell(IconButton(icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14), onPressed: () => context.push('/investors/${inv.id}'))),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildCards(BuildContext context, List investors, intl.NumberFormat f) {
    return ListView.builder(
      itemCount: investors.length,
      itemBuilder: (context, index) {
        final inv = investors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(inv.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('المتاح: ${f.format(inv.availableBalance)} ر.س'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/investors/${inv.id}'),
          ),
        );
      },
    );
  }
}

class PendingInvestorsList extends ConsumerWidget {
  const PendingInvestorsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingInvestorsControllerProvider);

    return pendingAsync.when(
      data: (requests) => requests.isEmpty 
        ? _buildEmptyState('لا توجد طلبات انضمام معلقة حالياً')
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0F0F0))),
                child: Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person_outline)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req['full_name'] ?? 'بدون اسم', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(req['email'] ?? '', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => ref.read(pendingInvestorsControllerProvider.notifier).approveInvestor(req['id']),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, minimumSize: const Size(100, 40)),
                      child: const Text('قبول وتفعيل'),
                    ),
                  ],
                ),
              );
            },
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.inbox_rounded, size: 60, color: AppColors.bgGrey),
        const SizedBox(height: 16),
        Text(msg, style: const TextStyle(color: AppColors.textGrey)),
      ],
    ));
  }
}

class WithdrawalRequestsList extends ConsumerWidget {
  const WithdrawalRequestsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(withdrawalRequestsControllerProvider(status: 'pending'));

    return requestsAsync.when(
      data: (requests) => requests.isEmpty
        ? _buildEmptyState('لا توجد طلبات سحب حالياً')
        : ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.errorRed.withOpacity(0.1))),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: AppColors.errorRed),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req['investors']['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('المبلغ المطلوب: ${req['amount']} ر.س', style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('مراجعة التفاصيل')),
                  ],
                ),
              );
            },
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.hourglass_empty_rounded, size: 60, color: AppColors.bgGrey),
        const SizedBox(height: 16),
        Text(msg, style: const TextStyle(color: AppColors.textGrey)),
      ],
    ));
  }
}
