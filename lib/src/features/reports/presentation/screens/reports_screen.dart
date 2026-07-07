import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../reports_controller.dart';
import '../../../investors/presentation/investor_controller.dart';
import '../../../crm/presentation/crm_controller.dart';
import 'package:intl/intl.dart' as intl;

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final filters = ref.watch(reportFiltersControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مركز التقارير المتقدم'),
          actions: [
            _buildExportButton(context),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshAll(),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => _refreshAll(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterBar(),
                const SizedBox(height: 24),
                _buildSummaryStats(f, filters['investorId']),
                const SizedBox(height: 32),
                _buildReportSection(
                  title: 'تحليل الأرباح والتدفق النقدي',
                  child: _ProfitAndCashFlowTable(
                    startDate: startDate,
                    endDate: endDate,
                    investorId: filters['investorId'],
                    customerId: filters['customerId'],
                  ),
                ),
                const SizedBox(height: 32),
                _buildReportSection(
                  title: 'أداء المحفظة الاستثمارية',
                  child: _InvestorsPerformanceTable(),
                ),
                const SizedBox(height: 32),
                _buildReportSection(
                  title: 'متابعة المتأخرات والتحصيل',
                  child: _OverdueReportList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _refreshAll() {
    ref.invalidate(revenueReportProvider);
    ref.invalidate(profitReportProvider);
    ref.invalidate(cashFlowReportProvider);
    ref.invalidate(investorsPerformanceProvider);
    ref.invalidate(overdueReportProvider);
    ref.invalidate(contractsSummaryProvider);
  }

  Widget _buildFilterBar() {
    final investorsAsync = ref.watch(investorListControllerProvider);
    final customersAsync = ref.watch(customersListProvider());
    final filters = ref.watch(reportFiltersControllerProvider);

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('فلاتر التقرير المتقدمة', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.read(reportFiltersControllerProvider.notifier).clearFilters(),
                  child: const Text('إعادة ضبط'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // فلتر المستثمر
                Expanded(
                  child: investorsAsync.when(
                    data: (list) => DropdownButtonFormField<String?>(
                      value: filters['investorId'],
                      decoration: const InputDecoration(labelText: 'تصفية بالمستثمر', border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('كل المستثمرين')),
                        ...list.map((inv) => DropdownMenuItem(value: inv.id, child: Text(inv.fullName))),
                      ],
                      onChanged: (val) => ref.read(reportFiltersControllerProvider.notifier).setInvestor(val),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('خطأ في تحميل المستثمرين'),
                  ),
                ),
                const SizedBox(width: 12),
                // فلتر العميل
                Expanded(
                  child: customersAsync.when(
                    data: (list) => DropdownButtonFormField<String?>(
                      value: filters['customerId'],
                      decoration: const InputDecoration(labelText: 'تصفية بالعميل', border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('كل العملاء')),
                        ...list.map((c) => DropdownMenuItem(value: c.id, child: Text(c.fullName))),
                      ],
                      onChanged: (val) => ref.read(reportFiltersControllerProvider.notifier).setCustomer(val),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('خطأ في تحميل العملاء'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.download_rounded),
      tooltip: 'تصدير التقرير',
      onSelected: (value) => _handleExport(value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'pdf',
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text('تصدير كـ PDF'),
          ),
        ),
        const PopupMenuItem(
          value: 'excel',
          child: ListTile(
            leading: Icon(Icons.table_chart, color: Colors.green),
            title: Text('تصدير كـ Excel'),
          ),
        ),
      ],
    );
  }

  void _handleExport(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('جاري تحضير ملف الـ $type...')),
    );
    // هنا سيتم استدعاء خدمات التصدير في المرحلة 19
  }

  Widget _buildDateSelector() {
    final df = intl.DateFormat('yyyy/MM/dd');
    return InkWell(
      onTap: () => _selectDateRange(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
            const SizedBox(width: 12),
            Text('الفترة: ${df.format(startDate)} - ${df.format(endDate)}'),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(intl.NumberFormat f, String? investorId) {
    final summaryAsync = ref.watch(contractsSummaryProvider);
    return summaryAsync.when(
      data: (data) {
        double totalValue = 0;
        double totalRemaining = 0;
        for (var row in data) {
          totalValue += (row['total_value'] ?? 0);
          totalRemaining += (row['total_remaining'] ?? 0);
        }
        return Row(
          children: [
            _StatCard(title: 'إجمالي المحفظة', value: '${f.format(totalValue)} ر.س', color: Colors.blue),
            const SizedBox(width: 16),
            _StatCard(title: 'الديون المتبقية', value: '${f.format(totalRemaining)} ر.س', color: Colors.orange),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildReportSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 24, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ProfitAndCashFlowTable extends ConsumerWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String? investorId;
  final String? customerId;
  const _ProfitAndCashFlowTable({
    required this.startDate, 
    required this.endDate,
    this.investorId,
    this.customerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profitAsync = ref.watch(profitReportProvider(
      startDate: startDate, 
      endDate: endDate,
      investorId: investorId,
      customerId: customerId,
    ));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('تحليل الأرباح والسيولة المفلترة', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            profitAsync.when(
              data: (data) {
                if (data.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('لا توجد بيانات لهذه الفلاتر'));
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('الشهر')),
                      DataColumn(label: Text('إجمالي الربح')),
                      DataColumn(label: Text('حصة المستثمرين')),
                      DataColumn(label: Text('ربح الشركة')),
                    ],
                    rows: data.map((row) => DataRow(cells: [
                      DataCell(Text(row['period_text'] ?? '')),
                      DataCell(Text('${row['gross_profit'] ?? 0} ر.س')),
                      DataCell(Text('${row['investor_share'] ?? 0} ر.س', style: const TextStyle(color: Colors.red))),
                      DataCell(Text('${row['company_net_profit'] ?? 0} ر.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                    ])).toList(),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvestorsPerformanceTable extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceAsync = ref.watch(investorsPerformanceProvider);

    return performanceAsync.when(
      data: (data) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('المستثمر')),
              DataColumn(label: Text('رأس المال الموظف')),
              DataColumn(label: Text('الأرباح المحققة')),
              DataColumn(label: Text('العقود النشطة')),
            ],
            rows: data.map((row) => DataRow(cells: [
              DataCell(Text(row['investor_name'] ?? '')),
              DataCell(Text('${row['deployed_capital'] ?? 0} ر.س')),
              DataCell(Text('${row['profit_earned'] ?? 0} ر.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              DataCell(Text(row['active_contracts_count'].toString())),
            ])).toList(),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}

class _OverdueReportList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdueAsync = ref.watch(overdueReportProvider);

    return overdueAsync.when(
      data: (data) {
        if (data.isEmpty) return const Card(child: ListTile(title: Text('لا توجد أقساط متأخرة حالياً', style: TextStyle(color: Colors.green))));
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.red.shade100)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length > 5 ? 5 : data.length, // عرض آخر 5 فقط في الشاشة الرئيسية
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final row = data[index];
              return ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.warning_amber_rounded, color: Colors.white)),
                title: Text(row['customer_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('عقد: ${row['contract_no']} | متأخر منذ ${row['days_overdue']} يوم'),
                trailing: Text('${row['amount']} ر.س', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}
