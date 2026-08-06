import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../investor_controller.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../domain/investor_transaction_type.dart';
import '../../domain/investor.dart';
import '../../../documents/presentation/widgets/universal_document_manager.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';

// ─── Color Palette & Styling ────────────────────────────────────────────────
const _navy      = Color(0xFF0F172A);
const _gold      = Color(0xFFD4AF37);
const _bg        = Color(0xFFF1F5F9);
const _green     = Color(0xFF10B981);
const _red = Color(0xFFEF4444);
const _blue      = Color(0xFF3B82F6);
const _cardShadow = [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))];

class InvestorDetailsScreen extends ConsumerStatefulWidget {
  final String id;
  final int initialTab;
  const InvestorDetailsScreen({super.key, required this.id, this.initialTab = 0});

  @override
  ConsumerState<InvestorDetailsScreen> createState() => _InvestorDetailsScreenState();
}

class _InvestorDetailsScreenState extends ConsumerState<InvestorDetailsScreen> {
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final investorAsync = ref.watch(investorDetailsControllerProvider(widget.id));

    return investorAsync.when(
      data: (investor) {
        if (investor == null) return const Scaffold(body: Center(child: Text('المستثمر غير موجود')));

        return Directionality(
          textDirection: TextDirection.rtl,
          child: DefaultTabController(
            length: 5,
            initialIndex: widget.initialTab,
            child: Scaffold(
              backgroundColor: _bg,
              body: NestedScrollView(
                headerSliverBuilder: (ctx, _) => [
                  _InvestorDetailsSliverHeader(investor: investor),
                ],
                body: TabBarView(
                  children: [
                    _FinancialTab(
                      investor: investor, 
                      dateRange: _selectedDateRange,
                      onDateRangeSelected: (range) => setState(() => _selectedDateRange = range),
                    ),
                    _ContractsTab(investorId: investor.id),
                    _WithdrawalRequestsTab(investorId: investor.id),
                    _ProjectionsTab(investorId: investor.id),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: UniversalDocumentManager(investorId: investor.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: _navy))),
      error: (err, _) => Scaffold(body: Center(child: Text(Failure.fromException(err).message))),
    );
  }
}

class _InvestorDetailsSliverHeader extends StatelessWidget {
  final Investor investor;
  const _InvestorDetailsSliverHeader({required this.investor});

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final total = investor.availableBalance + investor.deployedCapital;

    return SliverAppBar(
      expandedHeight: 520, // زيادة الارتفاع لضمان عدم القص
      pinned: true,
      backgroundColor: _navy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [_navy, Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100), // مساحة كبيرة في الأسفل (100) لتجنب التبويبات
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 1. التوب بار (الاسم والأفاتار)
                  Row(
                    children: [
                      Hero(
                        tag: 'inv-${investor.id}',
                        child: Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [_gold, Color(0xFFE5C17E)]),
                            boxShadow: [BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 10)],
                          ),
                          child: Center(child: Text(investor.fullName.isNotEmpty ? investor.fullName[0] : 'M', style: const TextStyle(color: _navy, fontWeight: FontWeight.w900, fontSize: 20))),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(investor.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                          Text(investor.email, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      _headerBadge('ملف استثماري نشط'),
                    ],
                  ),
                  
                  const SizedBox(height: 60),

                  // 2. الرصيد الإجمالي الكبير
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 16, color: _gold),
                          const SizedBox(width: 8),
                          Text('إجمالي القيمة المدارة', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        child: Text(
                          f.format(total),
                          style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('ريال سعودي', style: TextStyle(color: _gold, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  const Spacer(), // يوزع المساحة المتبقية قبل الكروت

                  // 3. الكروت الثلاثة
                  Row(
                    children: [
                      _HeaderStatTile(label: 'السيولة المتاحة', value: f.format(investor.availableBalance), color: _green, icon: Icons.account_balance_rounded),
                      const SizedBox(width: 12),
                      _HeaderStatTile(label: 'رأس المال المشغل', value: f.format(investor.deployedCapital), color: _blue, icon: Icons.trending_up_rounded),
                      const SizedBox(width: 12),
                      _HeaderStatTile(label: 'الأرباح المحققة', value: f.format(investor.totalProfitEarned), color: _gold, icon: Icons.stars_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: _navy,
            border: Border(top: BorderSide(color: Colors.white10, width: 1)),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: _gold,
                indicatorWeight: 4,
                labelColor: _gold,
                unselectedLabelColor: Colors.white54,
                labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Cairo'),
                tabs: [
                  Tab(text: 'المالية والأرباح'), 
                  Tab(text: 'العقود الجارية'), 
                  Tab(text: 'طلبات السحب'), 
                  Tab(text: 'التوقعات المستقبلية'), 
                  Tab(text: 'المستندات'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerBadge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: _green.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: _green.withOpacity(0.3))),
    child: Text(text, style: const TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.bold)),
  );
}

class _HeaderStatTile extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _HeaderStatTile({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 18),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            FittedBox(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
          ],
        ),
      ),
    );
  }
}

class _FinancialTab extends ConsumerWidget {
  final Investor investor;
  final DateTimeRange? dateRange;
  final Function(DateTimeRange) onDateRangeSelected;
  const _FinancialTab({required this.investor, this.dateRange, required this.onDateRangeSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(investorTransactionsControllerProvider(investor.id));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildProfitFilterCard(context, f),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _actionBtn(context, 'إيداع رأس مال', Icons.add_circle, Colors.green, () => _showTxDialog(context, investor.id, InvestorTransactionType.deposit))),
              const SizedBox(width: 16),
              Expanded(child: _actionBtn(context, 'سحب أرباح/رصيد', Icons.remove_circle, Colors.red, () => _showTxDialog(context, investor.id, InvestorTransactionType.withdrawal))),
            ],
          ),
          const SizedBox(height: 24),
          // Stats Row
          Row(
            children: [
              _statTile('الرصيد المتاح حالياً', f.format(investor.availableBalance), Icons.account_balance_wallet, _green),
              const SizedBox(width: 16),
              _statTile('رأس المال المشغل', f.format(investor.deployedCapital), Icons.rocket_launch, _blue),
              const SizedBox(width: 16),
              _statTile('إجمالي الأرباح', f.format(investor.totalProfitEarned), Icons.trending_up, _gold),
            ],
          ),
          const SizedBox(height: 32),
          const Row(children: [Icon(Icons.history, size: 20), SizedBox(width: 10), Text('سجل العمليات المالية الأخيرة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _navy))]),
          const SizedBox(height: 16),
          transactionsAsync.when(
            data: (txs) {
              final filtered = dateRange == null ? txs : txs.where((t) => t.createdAt.isAfter(dateRange!.start) && t.createdAt.isBefore(dateRange!.end)).toList();
              if (filtered.isEmpty) return _emptyState('لا توجد عمليات مسجلة في هذه الفترة');
              
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: _cardShadow),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
                  itemBuilder: (ctx, i) {
                    final tx = filtered[i];
                    final isPlus = tx.amount > 0;
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: (isPlus ? _green : _red).withOpacity(0.1), child: Icon(isPlus ? Icons.arrow_downward : Icons.arrow_upward, color: isPlus ? _green : _red, size: 18)),
                      title: Text(tx.type.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(intl.DateFormat('yyyy/MM/dd | HH:mm').format(tx.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      trailing: Text('${isPlus ? "+" : ""}${f.format(tx.amount)} ر.س', style: TextStyle(fontWeight: FontWeight.w900, color: isPlus ? _green : _red, fontSize: 15)),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(e.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitFilterCard(BuildContext context, intl.NumberFormat f) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: _navy.withOpacity(0.2), blurRadius: 15)]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('استعلام الأرباح', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('عرض الأرباح المحققة خلال فترة معينة', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (picked != null) onDateRangeSelected(picked);
                },
                icon: const Icon(Icons.date_range_rounded, size: 18),
                label: Text(dateRange == null ? 'تحديد الفترة' : 'تغيير الفترة'),
                style: ElevatedButton.styleFrom(backgroundColor: _gold, foregroundColor: _navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
          if (dateRange != null) ...[
            const Divider(color: Colors.white10, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [const Text('أرباح الفترة', style: TextStyle(color: Colors.white54, fontSize: 11)), Text('${f.format(0)} ر.س', style: const TextStyle(color: _gold, fontWeight: FontWeight.w900, fontSize: 18))]),
                Container(width: 1, height: 40, color: Colors.white10),
                Column(children: [const Text('العقود النشطة', style: TextStyle(color: Colors.white54, fontSize: 11)), const Text('0 عقد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))]),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String l, IconData i, Color c, VoidCallback onTap) => ElevatedButton.icon(
    onPressed: onTap, 
    icon: Icon(i, size: 20), 
    label: Text(l), 
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white, 
      foregroundColor: _navy, 
      elevation: 0,
      minimumSize: const Size(0, 60), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: c.withOpacity(0.2))),
    ),
  );

  Widget _statTile(String l, String v, IconData i, Color c) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white), boxShadow: _cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(i, color: c, size: 20)),
          const SizedBox(height: 16),
          Text(l, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          FittedBox(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _navy))),
        ],
      ),
    ),
  );

  void _showTxDialog(BuildContext ctx, String invId, InvestorTransactionType type) {
    showDialog(context: ctx, builder: (_) => AddTransactionDialog(investorId: invId, type: type));
  }

  Widget _emptyState(String t) => Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Column(children: [Icon(Icons.inbox_rounded, size: 50, color: Colors.grey.withOpacity(0.3)), const SizedBox(height: 16), Text(t, style: const TextStyle(color: Colors.grey))])));
}

class _ContractsTab extends ConsumerWidget {
  final String investorId;
  const _ContractsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(investorFundedContractsControllerProvider(investorId));
    return contractsAsync.when(
      data: (contracts) => contracts.isEmpty ? const Center(child: Text('لا توجد عقود ممولة لهذا المستثمر حالياً')) : ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: contracts.length,
        itemBuilder: (ctx, i) {
          final item = contracts[i];
          final contract = item['financing_contracts'] as Map?;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _navy.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.description_outlined, color: _navy)),
              title: Text('عقد تمويل رقم ${contract?['contract_no'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('قيمة المساهمة: ${item['amount_allocated']} ر.س'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => context.push('/contracts/${contract?['id']}'),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
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
      data: (reqs) => reqs.isEmpty ? const Center(child: Text('لا توجد طلبات سحب في السجل')) : ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: reqs.length,
        itemBuilder: (ctx, i) {
          final r = reqs[i];
          final isPending = r['status'] == 'pending';
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: Icon(Icons.money_off_rounded, color: isPending ? Colors.orange : Colors.green),
              title: Text('${r['amount']} ريال سعودي', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('الحالة: ${isPending ? "قيد المراجعة والتدقيق" : "تم تحويل المبلغ"}'),
              trailing: isPending ? const Icon(Icons.hourglass_empty_rounded, color: Colors.orange) : const Icon(Icons.check_circle_rounded, color: Colors.green),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _ProjectionsTab extends ConsumerWidget {
  final String investorId;
  const _ProjectionsTab({required this.investorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectionsAsync = ref.watch(investorProjectionsProvider(investorId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    return projectionsAsync.when(
      data: (list) => list.isEmpty ? const Center(child: Text('لا توجد أرباح متوقعة في المستقبل القريب')) : ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: list.length,
        itemBuilder: (ctx, i) {
          final item = list[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _blue.withOpacity(0.1))),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _blue.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.event_repeat_rounded, color: _blue, size: 20)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('دفعة أرباح قادمة', style: TextStyle(fontWeight: FontWeight.bold, color: _navy)), Text('التاريخ المتوقع: ${item['due_date'] ?? ""}', style: const TextStyle(color: Colors.grey, fontSize: 11))])),
                Text('${f.format((item['total_expected'] as num).toDouble())} ر.س', style: const TextStyle(fontWeight: FontWeight.w900, color: _green, fontSize: 16)),
              ],
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}
