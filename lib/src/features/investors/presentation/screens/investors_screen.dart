import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../../../../core/services/export_service.dart';
import '../investor_controller.dart';
import '../widgets/create_investor_dialog.dart';

class InvestorsScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const InvestorsScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<InvestorsScreen> createState() => _InvestorsScreenState();
}

class _InvestorsScreenState extends ConsumerState<InvestorsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          toolbarHeight: 180,
          backgroundColor: AppColors.primaryNavy,
          automaticallyImplyLeading: false,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 60),
              child: _buildHeader(context, ref),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: _buildTabBar(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ActiveInvestorsList(),
            PendingInvestorsList(),
            WithdrawalRequestsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final investorsAsync = ref.watch(investorListControllerProvider);
    double totalCapital = 0;
    int count = 0;

    investorsAsync.whenData((list) {
      count = list.length;
      totalCapital = list.fold(0, (sum, item) => sum + item.deployedCapital + item.availableBalance);
    });

    final f = intl.NumberFormat.compactCurrency(symbol: 'ر.س', locale: 'ar');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'إدارة المستثمرين والشركاء',
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.w900, 
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'متابعة محافظ الشركاء، أرباح الاستثمار، وحركات رأس المال',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildQuickStat('إجمالي المحافظ', f.format(totalCapital)),
                const SizedBox(width: 48),
                _buildQuickStat('الشركاء النشطين', count.toString()),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildExportMenu(ref),
            const SizedBox(width: 12),
            if (ResponsiveLayout.isDesktop(context))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const CreateInvestorDialog()),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                  label: const Text('إضافة مستثمر جديد', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.primaryNavy,
                    minimumSize: const Size(220, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportMenu(WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.file_download_outlined, color: Colors.white),
      ),
      tooltip: 'تصدير البيانات',
      onSelected: (type) => _handleExport(type, ref),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, color: Colors.red), SizedBox(width: 8), Text('تصدير PDF')])),
        const PopupMenuItem(value: 'excel', child: Row(children: [Icon(Icons.table_view, color: Colors.green), SizedBox(width: 8), Text('تصدير Excel')])),
        const PopupMenuItem(value: 'csv', child: Row(children: [Icon(Icons.description, color: Colors.blue), SizedBox(width: 8), Text('تصدير CSV')])),
      ],
    );
  }

  Future<void> _handleExport(String format, WidgetRef ref) async {
    final exportService = ref.read(exportServiceProvider);
    
    if (_tabController.index == 0) {
      final investors = ref.read(investorListControllerProvider).valueOrNull ?? [];
      if (investors.isEmpty) return;

      final columns = ['اسم المستثمر', 'البريد الإلكتروني', 'الرصيد المتاح', 'رأس المال الموظف'];
      
      if (format == 'pdf') {
        final rows = investors.map((inv) => [
          inv.fullName,
          inv.email,
          inv.availableBalance.toString(),
          inv.deployedCapital.toString(),
        ]).toList();
        await exportService.exportToPdf(title: 'قائمة المستثمرين النشطين', columns: columns, rows: rows);
      } else if (format == 'excel') {
        await exportService.exportToExcel(
          fileName: 'active_investors',
          columns: columns,
          data: investors.map((inv) => {
            'fullName': inv.fullName,
            'email': inv.email,
            'availableBalance': inv.availableBalance,
            'deployedCapital': inv.deployedCapital,
          }).toList(),
          dataKeys: ['fullName', 'email', 'availableBalance', 'deployedCapital'],
        );
      } else {
        final rows = investors.map((inv) => [inv.fullName, inv.email, inv.availableBalance, inv.deployedCapital]).toList();
        await exportService.exportToCsv(fileName: 'active_investors', columns: columns, rows: rows);
      }
    } else if (_tabController.index == 1) {
      final pending = ref.read(pendingInvestorsControllerProvider).valueOrNull ?? [];
      if (pending.isEmpty) return;
      final columns = ['الاسم', 'البريد الإلكتروني', 'تاريخ الطلب'];
      final rows = pending.map((p) => [p['full_name'], p['email'], p['created_at']]).toList();
      
      if (format == 'pdf') {
        await exportService.exportToPdf(title: 'طلبات الانضمام المعلقة', columns: columns, rows: rows);
      } else if (format == 'excel') {
        await exportService.exportToExcel(fileName: 'pending_investors', columns: columns, data: pending, dataKeys: ['full_name', 'email', 'created_at']);
      } else {
        await exportService.exportToCsv(fileName: 'pending_investors', columns: columns, rows: rows);
      }
    }
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white30,
      indicatorColor: AppColors.accentGold,
      indicatorWeight: 4,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      padding: EdgeInsets.symmetric(horizontal: 24),
      tabs: const [
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
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(investorListControllerProvider.future),
      child: investorsAsync.when(
        data: (investors) {
          if (investors.isEmpty) {
            return _buildEmptyScrollable(context, 'لا يوجد مستثمرون حالياً', Icons.people_outline_rounded);
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
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: InkWell(
                  onTap: () => context.push('/investors/${inv.id}'),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(inv.fullName.isNotEmpty ? inv.fullName[0] : '?', 
                              style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 20)),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(inv.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy)),
                              const SizedBox(height: 4),
                              Text(inv.email, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            ],
                          ),
                        ),
                        _buildStatColumn('الرصيد المتاح', f.format(inv.availableBalance), AppColors.successGreen),
                        const SizedBox(width: 32),
                        _buildStatColumn('رأس المال الموظف', f.format(inv.deployedCapital), AppColors.primaryNavy),
                        const SizedBox(width: 12),
                        const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              Failure.fromException(e).message,
              style: const TextStyle(color: AppColors.errorRed, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 4),
        Text('$value ر.س', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
      ],
    );
  }
}

class PendingInvestorsList extends ConsumerWidget {
  const PendingInvestorsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingInvestorsControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(pendingInvestorsControllerProvider.future),
      child: pendingAsync.when(
        data: (requests) => requests.isEmpty
            ? _buildEmptyScrollable(context, 'لا توجد طلبات انضمام حالياً', Icons.mark_email_read_outlined)
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: requests.length,
                itemBuilder: (context, index) => _PendingInvestorCard(req: requests[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            Failure.fromException(e).message,
            style: const TextStyle(color: AppColors.errorRed, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class WithdrawalRequestsList extends ConsumerWidget {
  const WithdrawalRequestsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(withdrawalRequestsControllerProvider());

    return RefreshIndicator(
      onRefresh: () => ref.refresh(withdrawalRequestsControllerProvider().future),
      child: requestsAsync.when(
        data: (allRequests) {
          final requests = allRequests.where((r) => 
            r['status'].toString().toLowerCase() == 'pending'
          ).toList();

          if (requests.isEmpty) {
            return _buildEmptyScrollable(context, 'لا توجد طلبات سحب معلقة', Icons.account_balance_wallet_outlined);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: requests.length,
            itemBuilder: (context, index) => _WithdrawalRequestCard(req: requests[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            Failure.fromException(e).message,
            style: const TextStyle(color: AppColors.errorRed, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

Widget _buildEmptyScrollable(BuildContext context, String msg, IconData icon) {
  return LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: constraints.maxHeight,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, size: 64, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 24),
            Text(msg, style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ),
  );
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person_add_rounded, color: AppColors.accentGold, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req['full_name'] ?? 'بدون اسم', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy)),
                const SizedBox(height: 2),
                Text(req['email'] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator(strokeWidth: 2)
          else
            Row(
              children: [
                TextButton(
                  onPressed: _reject,
                  style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
                  child: const Text('رفض الطلب'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _approve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('اعتماد القبول'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _approve() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(pendingInvestorsControllerProvider.notifier).approveInvestor(widget.req['id']);
      if (mounted) SnackBarHelper.showSuccess(context, 'تم اعتماد المستثمر بنجاح');
    } catch (e) {
      if (mounted) SnackBarHelper.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reject() async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('رفض طلب الانضمام'),
          content: TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(labelText: 'سبب الرفض (إلزامي)', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('رفض'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && reasonCtrl.text.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await ref.read(pendingInvestorsControllerProvider.notifier).rejectInvestor(widget.req['id'], reasonCtrl.text.trim());
        if (mounted) SnackBarHelper.showInfo(context, 'تم رفض الطلب');
      } catch (e) {
        if (mounted) SnackBarHelper.showError(context, e);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
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
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(investorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy)),
                const SizedBox(height: 4),
                Text('طلب سحب: ${f.format(amount)} ر.س', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator(strokeWidth: 2)
          else
            ElevatedButton(
              onPressed: _approve,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('صرف المبلغ'),
            ),
        ],
      ),
    );
  }

  Future<void> _approve() async {
    setState(() => _isLoading = true);
    await ref.read(withdrawalRequestsControllerProvider().notifier).approveRequest(widget.req['id']);
    if (mounted) setState(() => _isLoading = false);
  }
}
