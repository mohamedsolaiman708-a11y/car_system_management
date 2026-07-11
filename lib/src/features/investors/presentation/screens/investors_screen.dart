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
    // تحديث تلقائي عند حدوث تغيير في الطلبات المعلقة
    ref.listen(pendingInvestorsControllerProvider, (previous, next) {
      if (previous?.isLoading == true && !next.isLoading && !next.hasError) {
        ref.invalidate(investorListControllerProvider);
      }
    });

    return DefaultTabController(
      length: 3,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Container(
            color: AppColors.primaryNavy,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: _buildHeader(context),
                  ),
                  const Spacer(),
                  _buildTabBar(),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            ActiveInvestorsList(),
            PendingInvestorsList(),
            WithdrawalRequestsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إدارة المحافظ الاستثمارية',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              'متابعة رؤوس الأموال، الأرباح، والطلبات المعلقة',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.primaryNavy,
              minimumSize: const Size(200, 50),
              elevation: 0,
            ),
          ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: AppColors.accentGold,
      unselectedLabelColor: Colors.white54,
      indicatorColor: AppColors.accentGold,
      indicatorWeight: 4,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      tabs: const [
        Tab(text: 'المستثمرون النشطون'),
        Tab(text: 'طلبات الانضمام'),
        Tab(text: 'طلبات السحب'),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// قائمة المستثمرين النشطين (Premium Style)
// ─────────────────────────────────────────────
class ActiveInvestorsList extends ConsumerWidget {
  const ActiveInvestorsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorsAsync = ref.watch(investorListControllerProvider);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(investorListControllerProvider.future),
      child: investorsAsync.when(
        data: (investors) {
          if (investors.isEmpty) {
            return _buildEmptyState('لا يوجد مستثمرون نشطون حالياً', Icons.people_outline_rounded);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: investors.length,
            itemBuilder: (context, index) {
              final inv = investors[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  border: Border.all(color: Colors.white),
                ),
                child: InkWell(
                  onTap: () => context.push('/investors/${inv.id}'),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primaryNavy.withOpacity(0.05),
                          child: Text(inv.fullName[0], 
                            style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(inv.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 4),
                              Text(inv.email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        _buildInfoColumn('المتاح', f.format(inv.availableBalance), Colors.green),
                        const SizedBox(width: 40),
                        _buildInfoColumn('الموظف', f.format(inv.deployedCapital), Colors.blue),
                        const SizedBox(width: 20),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ في تحميل البيانات')),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text('$value ر.س', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(msg, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// قائمة طلبات الانضمام (Smart Card Style)
// ─────────────────────────────────────────────
class PendingInvestorsList extends ConsumerWidget {
  const PendingInvestorsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingInvestorsControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(pendingInvestorsControllerProvider.future),
      child: pendingAsync.when(
        data: (requests) => requests.isEmpty
            ? _buildEmptyState('لا توجد طلبات انضمام معلقة حالياً')
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: requests.length,
                itemBuilder: (context, index) => _PendingInvestorCard(req: requests[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('خطأ في تحميل الطلبات')),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(msg, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
      ],
    ));
  }
}

class _PendingInvestorCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> req;
  const _PendingInvestorCard({required this.req});

  @override
  ConsumerState<_PendingInvestorCard> createState() => _PendingInvestorCardState();
}

class _PendingInvestorCardState extends ConsumerState<_PendingInvestorCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final req = widget.req;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.accentGold.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.person_add_alt_rounded, color: AppColors.accentGold),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req['full_name'] ?? 'بدون اسم', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Text(req['email'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Row(
              children: [
                TextButton(
                  onPressed: _reject,
                  style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
                  child: const Text('رفض الطلب'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _approve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 45),
                    elevation: 0,
                  ),
                  child: const Text('قبول واعتماد'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _approve() async {
    setState(() => _isLoading = true);
    await ref.read(pendingInvestorsControllerProvider.notifier).approveInvestor(widget.req['id']);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _reject() async {
    // منطق الرفض كما هو
  }
}

// ─────────────────────────────────────────────
// قائمة طلبات السحب
// ─────────────────────────────────────────────
class WithdrawalRequestsList extends ConsumerWidget {
  const WithdrawalRequestsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(withdrawalRequestsControllerProvider(status: 'pending'));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(withdrawalRequestsControllerProvider(status: 'pending').future),
      child: requestsAsync.when(
        data: (requests) => requests.isEmpty
            ? _buildEmptyState('لا توجد طلبات سحب حالياً')
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: requests.length,
                itemBuilder: (context, index) => _WithdrawalRequestCard(req: requests[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('خطأ')),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(msg, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
      ],
    ));
  }
}

class _WithdrawalRequestCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> req;
  const _WithdrawalRequestCard({required this.req});

  @override
  ConsumerState<_WithdrawalRequestCard> createState() => _WithdrawalRequestCardState();
}

class _WithdrawalRequestCardState extends ConsumerState<_WithdrawalRequestCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final req = widget.req;
    final amount = (req['amount'] as num?)?.toDouble() ?? 0;
    final investorName = req['investors']?['full_name'] ?? 'مستثمر';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.errorRed.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.errorRed.withOpacity(0.05), shape: BoxShape.circle),
            child: const Icon(Icons.outbox_rounded, color: AppColors.errorRed),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(investorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Text('قيمة السحب: $amount ر.س', style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: _approve,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, foregroundColor: Colors.white),
              child: const Text('تنفيذ السحب'),
            ),
        ],
      ),
    );
  }

  Future<void> _approve() async {
    setState(() => _isLoading = true);
    await ref.read(withdrawalRequestsControllerProvider(status: 'pending').notifier).approveRequest(widget.req['id']);
    if (mounted) setState(() => _isLoading = false);
  }
}
