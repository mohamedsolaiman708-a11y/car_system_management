import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../investor_controller.dart';
import '../widgets/create_investor_dialog.dart';

class InvestorsScreen extends ConsumerWidget {
  final int initialIndex;
  const InvestorsScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialIndex,
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
            Text(
              'مركز إدارة المستثمرين',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy),
            ),
            Text(
              'متابعة رؤوس الأموال، المحافظ الاستثمارية، وتوزيع الأرباح',
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
          ],
        ),
        if (ResponsiveLayout.isDesktop(context))
          ElevatedButton.icon(
            onPressed: () => showDialog(
                context: context,
                builder: (context) => const CreateInvestorDialog()),
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

// ─────────────────────────────────────────────
// قائمة المستثمرين النشطين
// ─────────────────────────────────────────────
class ActiveInvestorsList extends ConsumerWidget {
  const ActiveInvestorsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorsAsync = ref.watch(investorListControllerProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(investorListControllerProvider.future),
      child: investorsAsync.when(
        data: (investors) {
          if (investors.isEmpty) {
            return _buildEmptyState(
                'لا يوجد مستثمرون مسجلون حالياً', Icons.people_outline_rounded);
          }
          if (isDesktop) return _buildTable(context, investors, f);
          return _buildCards(context, investors, f);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  Widget _buildTable(
      BuildContext context, List investors, intl.NumberFormat f) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F0F0))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.bgGrey),
            dataRowHeight: 75,
            columns: const [
              DataColumn(
                  label: Text('المستثمر',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('الرصيد المتاح',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('رأس المال العامل',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('إجمالي الأرباح',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('الإجراءات',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: investors
                .map((inv) => DataRow(cells: [
                      DataCell(Row(
                        children: [
                          CircleAvatar(
                              backgroundColor:
                                  AppColors.accentGold.withOpacity(0.1),
                              child: const Icon(Icons.person,
                                  color: AppColors.accentGold, size: 20)),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(inv.fullName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(inv.email,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ],
                      )),
                      DataCell(Text('${f.format(inv.availableBalance)} ر.س',
                          style: const TextStyle(
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.bold))),
                      DataCell(Text('${f.format(inv.deployedCapital)} ر.س')),
                      DataCell(Text('${f.format(inv.totalProfitEarned)} ر.س',
                          style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold))),
                      DataCell(IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 14),
                          onPressed: () =>
                              context.push('/investors/${inv.id}'))),
                    ]))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCards(
      BuildContext context, List investors, intl.NumberFormat f) {
    return ListView.builder(
      itemCount: investors.length,
      itemBuilder: (context, index) {
        final inv = investors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
                backgroundColor: AppColors.accentGold.withOpacity(0.1),
                child: const Icon(Icons.person,
                    color: AppColors.accentGold, size: 20)),
            title: Text(inv.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('متاح: ${f.format(inv.availableBalance)} ر.س',
                    style: const TextStyle(color: AppColors.successGreen)),
                Text('أرباح: ${f.format(inv.totalProfitEarned)} ر.س',
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/investors/${inv.id}'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 60, color: AppColors.bgGrey),
        const SizedBox(height: 16),
        Text(msg, style: const TextStyle(color: AppColors.textGrey)),
      ],
    ));
  }
}

// ─────────────────────────────────────────────
// قائمة طلبات الانضمام المعلقة
// ─────────────────────────────────────────────
class PendingInvestorsList extends ConsumerWidget {
  const PendingInvestorsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // تحديث قائمة المستثمرين النشطين تلقائياً عند قبول أي مستثمر من هذه القائمة
    ref.listen(pendingInvestorsControllerProvider, (previous, next) {
      if (previous?.isLoading == true && !next.isLoading && !next.hasError) {
        ref.invalidate(investorListControllerProvider);
      }
    });

    final pendingAsync = ref.watch(pendingInvestorsControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(pendingInvestorsControllerProvider.future),
      child: pendingAsync.when(
        data: (requests) => requests.isEmpty
            ? _buildEmptyState('لا توجد طلبات انضمام معلقة حالياً')
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return _PendingInvestorCard(req: req);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.inbox_rounded, size: 60, color: AppColors.bgGrey),
        const SizedBox(height: 16),
        Text(msg, style: const TextStyle(color: AppColors.textGrey)),
      ],
    ));
  }
}

class _PendingInvestorCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> req;
  const _PendingInvestorCard({required this.req});

  @override
  ConsumerState<_PendingInvestorCard> createState() =>
      _PendingInvestorCardState();
}

class _PendingInvestorCardState extends ConsumerState<_PendingInvestorCard> {
  bool _isLoading = false;

  Future<void> _approve() async {
    setState(() => _isLoading = true);
    await ref
        .read(pendingInvestorsControllerProvider.notifier)
        .approveInvestor(widget.req['id']);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _reject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الرفض'),
          content: Text(
            'هل أنت متأكد من رفض طلب انضمام "${widget.req['full_name'] ?? 'هذا المستثمر'}"؟\n'
            'لن يتمكن من تسجيل الدخول بعد ذلك.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  foregroundColor: Colors.white),
              child: const Text('تأكيد الرفض'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      await ref
          .read(pendingInvestorsControllerProvider.notifier)
          .rejectInvestor(widget.req['id'], 'رفض من قبل الإدارة');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.req;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0))),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.withOpacity(0.1),
            child: const Icon(Icons.person_outline, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req['full_name'] ?? 'بدون اسم',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(req['email'] ?? '',
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 12)),
                if (req['phone'] != null)
                  Text(req['phone'],
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
          if (_isLoading)
            const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2))
          else
            Row(
              children: [
                OutlinedButton(
                  onPressed: _reject,
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed),
                      minimumSize: const Size(70, 36)),
                  child: const Text('رفض'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _approve,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(90, 36)),
                  child: const Text('قبول'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class WithdrawalRequestsList extends ConsumerWidget {
  const WithdrawalRequestsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync =
        ref.watch(withdrawalRequestsControllerProvider(status: 'pending'));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(
          withdrawalRequestsControllerProvider(status: 'pending').future),
      child: requestsAsync.when(
        data: (requests) => requests.isEmpty
            ? _buildEmptyState('لا توجد طلبات سحب حالياً')
            : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return _WithdrawalRequestCard(req: req);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.hourglass_empty_rounded,
            size: 60, color: AppColors.bgGrey),
        const SizedBox(height: 16),
        Text(msg, style: const TextStyle(color: AppColors.textGrey)),
      ],
    ));
  }
}

class _WithdrawalRequestCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> req;
  const _WithdrawalRequestCard({required this.req});

  @override
  ConsumerState<_WithdrawalRequestCard> createState() =>
      _WithdrawalRequestCardState();
}

class _WithdrawalRequestCardState
    extends ConsumerState<_WithdrawalRequestCard> {
  bool _isLoading = false;

  Future<void> _approve() async {
    setState(() => _isLoading = true);
    await ref
        .read(withdrawalRequestsControllerProvider(status: 'pending').notifier)
        .approveRequest(widget.req['id']);
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تمت الموافقة على طلب السحب'),
            backgroundColor: AppColors.successGreen),
      );
    }
  }

  Future<void> _reject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('رفض طلب السحب'),
          content: Text(
              'هل تريد رفض طلب السحب بقيمة ${widget.req['amount']} ر.س؟'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  foregroundColor: Colors.white),
              child: const Text('رفض الطلب'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      await ref
          .read(
              withdrawalRequestsControllerProvider(status: 'pending').notifier)
          .rejectRequest(widget.req['id'], 'رفض من قبل الإدارة');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم رفض طلب السحب'),
              backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.req;
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final amount = (req['amount'] as num?)?.toDouble() ?? 0;
    final investorName = req['investors']?['full_name'] ?? 'مستثمر';
    final bankInfo = req['bank_details'] ?? req['notes'] ?? 'لا توجد تفاصيل';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.errorRed.withOpacity(0.15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: AppColors.errorRed),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(investorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('المبلغ المطلوب: ${f.format(amount)} ر.س',
                        style: const TextStyle(
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.bgGrey,
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.account_balance_outlined,
                    size: 16, color: AppColors.textGrey),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(bankInfo,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _reject,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('رفض'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _approve,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('الموافقة والتحويل'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
