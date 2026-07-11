import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../reports_controller.dart';
import '../../../../core/utils/app_theme.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 90)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final profitAsync = ref.watch(profitReportProvider(
      startDate: dateRange.start,
      endDate: dateRange.end,
    ));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('مركز التقارير المالية والتحليل'),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextButton.icon(
                icon: const Icon(Icons.date_range_rounded, size: 18),
                label: Text(
                  '${intl.DateFormat('yyyy/MM/dd').format(dateRange.start)} - ${intl.DateFormat('yyyy/MM/dd').format(dateRange.end)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                onPressed: _selectDateRange,
              ),
            ),
          ],
        ),
        body: profitAsync.when(
          data: (reportData) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickSummary(reportData),
                const SizedBox(height: 40),
                const Text(
                  'قائمة التقارير المتاحة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                ),
                const SizedBox(height: 20),
                _buildReportGrid(),
                const SizedBox(height: 40),
                _buildRecentPerformanceTable(reportData),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ في تحميل بيانات التقارير: $err')),
        ),
      ),
    );
  }

  Widget _buildQuickSummary(List<Map<String, dynamic>> reportData) {
    double totalGross = 0;
    double totalInvestor = 0;
    double totalCompany = 0;

    for (var item in reportData) {
      totalGross += (item['gross_profit'] as num?)?.toDouble() ?? 0;
      totalInvestor += (item['investor_share'] as num?)?.toDouble() ?? 0;
      totalCompany += (item['company_net_profit'] as num?)?.toDouble() ?? 0;
    }

    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Row(
      children: [
        Expanded(child: _SummaryCard(title: 'إجمالي الأرباح', value: '${f.format(totalGross)} ر.س', icon: Icons.account_balance_wallet_rounded, color: Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _SummaryCard(title: 'حصة المستثمرين', value: '${f.format(totalInvestor)} ر.س', icon: Icons.groups_rounded, color: Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _SummaryCard(title: 'صافي ربح الشركة', value: '${f.format(totalCompany)} ر.س', icon: Icons.trending_up_rounded, color: Colors.green)),
      ],
    );
  }

  Widget _buildReportGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _ReportCategoryCard(
          title: 'تقرير الأرباح',
          icon: Icons.pie_chart_rounded,
          description: 'تحليل الأرباح الموزعة والصافية',
          color: Colors.indigo,
          onTap: () => _openReport('profit'),
        ),
        _ReportCategoryCard(
          title: 'سجل التحصيل',
          icon: Icons.payments_rounded,
          description: 'متابعة الدفعات المستلمة',
          color: Colors.teal,
          onTap: () => _openReport('collections'),
        ),
        _ReportCategoryCard(
          title: 'التدفق النقدي',
          icon: Icons.swap_horizontal_circle_rounded,
          description: 'حركة السيولة الداخلة والخارجة',
          color: Colors.amber.shade800,
          onTap: () => _openReport('cashflow'),
        ),
        _ReportCategoryCard(
          title: 'ميزان المراجعة',
          icon: Icons.account_tree_rounded,
          description: 'التقرير المحاسبي الشامل',
          color: Colors.blueGrey,
          onTap: () => _openReport('trial_balance'),
        ),
      ],
    );
  }

  Future<void> _openReport(String type) async {
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
    
    try {
      List<Map<String, dynamic>> data = [];
      String title = '';
      List<String> columns = [];
      List<String> keys = [];

      if (type == 'profit') {
        title = 'تقرير الأرباح والنمو';
        columns = ['الفترة', 'إجمالي الربح', 'حصة المستثمر', 'ربح الشركة'];
        keys = ['period_text', 'gross_profit', 'investor_share', 'company_net_profit'];
        data = await ref.read(profitReportProvider(startDate: dateRange.start, endDate: dateRange.end).future);
      } else if (type == 'collections') {
        title = 'سجل التحصيل التفصيلي';
        columns = ['التاريخ', 'رقم العقد', 'العميل', 'المبلغ', 'الوسيلة'];
        keys = ['payment_date', 'financing_contracts.contract_no', 'financing_contracts.customers.full_name', 'amount_total', 'payment_method'];
        data = await ref.read(collectionsReportProvider(startDate: dateRange.start, endDate: dateRange.end).future);
      } else if (type == 'cashflow') {
        title = 'تقرير التدفق النقدي';
        columns = ['الشهر', 'التدفق الداخل', 'التدفق الخارج', 'صافي السيولة'];
        keys = ['month_text', 'inflow', 'outflow', 'net_cash_flow'];
        data = await ref.read(cashFlowReportProvider(startDate: dateRange.start, endDate: dateRange.end).future);
      } else if (type == 'trial_balance') {
        title = 'ميزان المراجعة الشامل';
        columns = ['الحساب', 'الكود', 'رصيد سابق', 'مدين', 'دائن', 'الرصيد الحالي'];
        keys = ['name', 'code', 'opening_balance', 'total_debit', 'total_credit', 'current_balance'];
        data = await ref.read(trialBalanceProvider.future);
      }

      if (!mounted) return;
      Navigator.pop(context); // إخفاء الـ Loading

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ReportDetailScreen(
          title: title,
          columns: columns,
          data: data,
          dataKeys: keys,
        ),
      ));
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل تحميل التقرير: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _buildRecentPerformanceTable(List<Map<String, dynamic>> reportData) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('الأداء المالي للأشهر الأخيرة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(height: 1),
          if (reportData.isEmpty)
             const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('لا توجد بيانات لهذه الفترة')))
          else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 40,
              columns: const [
                DataColumn(label: Text('الفترة')),
                DataColumn(label: Text('إجمالي الربح')),
                DataColumn(label: Text('حصة المستثمرين')),
                DataColumn(label: Text('ربح الشركة')),
              ],
              rows: reportData.map((item) => DataRow(cells: [
                DataCell(Text(item['period_text'] ?? '')),
                DataCell(Text('${f.format(item['gross_profit'] ?? 0)} ر.س')),
                DataCell(Text('${f.format(item['investor_share'] ?? 0)} ر.س', style: const TextStyle(color: Colors.orange))),
                DataCell(Text('${f.format(item['company_net_profit'] ?? 0)} ر.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              ])).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primaryNavy)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => dateRange = picked);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primaryNavy)),
        ],
      ),
    );
  }
}

class _ReportCategoryCard extends StatelessWidget {
  final String title, description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportCategoryCard({required this.title, required this.description, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(height: 12),
            Icon(Icons.open_in_new_rounded, size: 18, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
