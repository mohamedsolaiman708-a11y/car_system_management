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
    final pendingCount = ref.watch(pendingInvestorsControllerProvider).maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );
    final withdrawalCount = ref.watch(withdrawalRequestsControllerProvider()).maybeWhen(
      data: (list) => list.where((r) => r['status'].toString().toLowerCase() == 'pending').length,
      orElse: () => 0,
    );

    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white30,
      indicatorColor: AppColors.accentGold,
      indicatorWeight: 4,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      tabs: [
        const Tab(text: 'المستثمرون النشطون'),
        Tab(
          child: Row(
            children: [
              const Text('طلبات الانضمام'),
              if (pendingCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                  child: Text('$pendingCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
        Tab(
          child: Row(
            children: [
              const Text('طلبات السحب'),
              if (withdrawalCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                  child: Text('$withdrawalCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
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

    return investorsAsync.when(
      data: (investors) => RefreshIndicator(
        onRefresh: () => ref.refresh(investorListControllerProvider.future),
        child: investors.isEmpty
            ? _buildEmptyScrollable(context, 'لا يوجد مستثمرون حالياً', Icons.people_outline_rounded)
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: investors.length,
                itemBuilder: (context, index) {
                  final inv = investors[index];
                  return Container(
                    key: ValueKey(inv.id),
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
              ),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
      error: (e, _) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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

    return pendingAsync.when(
      data: (requests) => RefreshIndicator(
        onRefresh: () => ref.refresh(pendingInvestorsControllerProvider.future),
        child: requests.isEmpty
            ? _buildEmptyScrollable(context, 'لا توجد طلبات انضمام حالياً', Icons.mark_email_read_outlined)
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: requests.length,
                itemBuilder: (context, index) => _PendingInvestorCard(
                  key: ValueKey(requests[index]['id'] ?? index),
                  req: requests[index],
                ),
              ),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
      error: (e, _) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
}

class WithdrawalRequestsList extends ConsumerWidget {
  const WithdrawalRequestsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(withdrawalRequestsControllerProvider());

    return requestsAsync.when(
      data: (allRequests) {
        // عرض الطلبات المعلقة أولاً، ثم الباقية
        final pending  = allRequests.where((r) => r['status']?.toString().toLowerCase() == 'pending').toList();
        final others   = allRequests.where((r) => r['status']?.toString().toLowerCase() != 'pending').toList();
        final requests = [...pending, ...others];

        return RefreshIndicator(
          onRefresh: () => ref.refresh(withdrawalRequestsControllerProvider().future),
          child: requests.isEmpty
              ? _buildEmptyScrollable(context, 'لا توجد طلبات سحب حالياً', Icons.account_balance_wallet_outlined)
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  itemCount: requests.length,
                  itemBuilder: (context, index) => _WithdrawalRequestCard(
                    key: ValueKey(requests[index]['id'] ?? index),
                    req: requests[index],
                  ),
                ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
      error: (e, _) => LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.errorRed.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'تعذّر تحميل طلبات السحب',
                        style: TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Failure.fromException(e).message,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontFamily: 'Cairo'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تلميح: إذا كانت المشكلة تتعلق بالصلاحيات، شغّل ملف fix_withdrawal_requests_rls.sql في Supabase SQL Editor',
                        style: TextStyle(color: Colors.orange.shade700, fontSize: 12, fontFamily: 'Cairo'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => ref.invalidate(withdrawalRequestsControllerProvider()),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildEmptyScrollable(BuildContext context, String msg, IconData icon) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final minH = constraints.maxHeight.isFinite ? constraints.maxHeight : 300.0;
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          constraints: BoxConstraints(minHeight: minH),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Icon(icon, size: 56, color: Colors.grey.shade300),
              ),
              const SizedBox(height: 20),
              Text(
                msg,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PendingInvestorCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> req;
  const _PendingInvestorCard({super.key, required this.req});

  @override
  ConsumerState<_PendingInvestorCard> createState() => _PendingInvestorCardState();
}

class _PendingInvestorCardState extends ConsumerState<_PendingInvestorCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final req = widget.req;
    final fullName = (req['full_name'] ?? req['name'] ?? 'بدون اسم').toString();
    final email = (req['email'] ?? '').toString();
    final phone = (req['phone'] ?? '').toString();
    final nationalId = (req['national_id'] ?? '').toString();
    final createdAtRaw = req['created_at'];

    String formattedDate = '';
    if (createdAtRaw != null) {
      final dt = DateTime.tryParse(createdAtRaw.toString());
      if (dt != null) {
        formattedDate = intl.DateFormat('yyyy/MM/dd').format(dt);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_add_rounded, color: AppColors.accentGold, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    if (email.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    if (phone.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    if (nationalId.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.badge_outlined, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('هوية: $nationalId', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    if (formattedDate.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(formattedDate, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (_isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryNavy),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _reject,
                  style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
                  child: const Text('رفض الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _approve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('اعتماد القبول', style: TextStyle(fontWeight: FontWeight.bold)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 44),
              ),
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
  const _WithdrawalRequestCard({super.key, required this.req});

  @override
  ConsumerState<_WithdrawalRequestCard> createState() => _WithdrawalRequestCardState();
}

class _WithdrawalRequestCardState extends ConsumerState<_WithdrawalRequestCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final req = widget.req;
    final amount = (req['amount'] as num?)?.toDouble() ?? 0;
    final String reqStatus   = req['status']?.toString().toLowerCase() ?? 'pending';

    final String investorName = (
        req['profiles']?['full_name'] ??
            req['profiles']?['name'] ??
            req['investors']?['full_name'] ??
            req['full_name'] ??
            req['name'] ??
            'مستثمر'
    ).toString();
    final bankDetails = (req['bank_account_details'] ?? req['bank_details'] ?? '') as String;
    final createdAtStr = req['created_at'] != null 
        ? intl.DateFormat('yyyy/MM/dd • hh:mm a').format(DateTime.parse(req['created_at']))
        : 'تاريخ غير محدد';
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    // تحديد لون ونص بادج الحالة
    Color statusColor;
    String statusLabel;
    switch (reqStatus) {
      case 'approved':
        statusColor = AppColors.successGreen;
        statusLabel = '✓ تم الاعتماد';
        break;
      case 'rejected':
        statusColor = AppColors.errorRed;
        statusLabel = '✗ مرفوض';
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        statusLabel = 'ملغى';
        break;
      default:
        statusColor = Colors.orange;
        statusLabel = '⏳ معلق';
    }

    final bool isPending = reqStatus == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        border: Border.all(color: isPending ? Colors.amber.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.account_balance_wallet_rounded, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(investorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy)),
                    const SizedBox(height: 2),
                    Text(createdAtStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${f.format(amount)} ر.س',
                    style: TextStyle(color: isPending ? AppColors.errorRed : Colors.grey.shade600, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          if (bankDetails.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_rounded, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الحساب البنكي / IBAN: $bankDetails',
                      style: const TextStyle(fontSize: 12, color: AppColors.primaryNavy, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryNavy))
          else if (isPending)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _approve,
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('اعتماد وصرف المبلغ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reject,
                    icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.errorRed),
                    label: const Text('رفض الطلب', style: TextStyle(color: AppColors.errorRed)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.errorRed),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            )
          else
            // طلب تمت معالجته - عرض وقت المعالجة فقط
            if (req['processed_at'] != null)
              Text(
                'تمت المعالجة: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(req['processed_at']))}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
        ],
      ),
    );
  }

  Future<void> _approve() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(withdrawalRequestsControllerProvider().notifier).approveRequest(widget.req['id']);
      if (mounted) SnackBarHelper.showSuccess(context, 'تم اعتماد صرف المبلغ وقيد العملية المحاسبية بنجاح ✓');
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('رفض طلب السحب'),
          content: TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(
              labelText: 'سبب الرفض (إلزامي)',
              hintText: 'أدخل سبب عدم قبول الطلب...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 44),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('تأكيد الرفض'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && reasonCtrl.text.trim().isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await ref.read(withdrawalRequestsControllerProvider().notifier).rejectRequest(widget.req['id'], reasonCtrl.text.trim());
        if (mounted) SnackBarHelper.showInfo(context, 'تم رفض طلب السحب');
      } catch (e) {
        if (mounted) SnackBarHelper.showError(context, e);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
