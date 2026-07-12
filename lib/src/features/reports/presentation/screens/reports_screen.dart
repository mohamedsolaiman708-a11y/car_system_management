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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('مركز التقارير والتحليل المالي', 
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          _buildDateSelector(),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: profitAsync.when(
        data: (reportData) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildExecutiveSummaryRow(reportData),
            const SizedBox(height: 20),
            _buildClassicReportCatalog(),
            const SizedBox(height: 20),
            _buildPerformanceTable(reportData),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ في تحميل التقارير')),
      ),
    );
  }

  Widget _buildDateSelector() {
    return ActionChip(
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade300),
      label: Text(
        '${intl.DateFormat('yyyy/MM/dd').format(dateRange.start)} - ${intl.DateFormat('yyyy/MM/dd').format(dateRange.end)}',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      onPressed: _selectDateRange,
      avatar: const Icon(Icons.calendar_month, size: 14, color: AppColors.primaryNavy),
    );
  }

  Widget _buildExecutiveSummaryRow(List<Map<String, dynamic>> reportData) {
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
        _buildSimpleSummaryBox('إجمالي الأرباح', f.format(totalGross), Colors.blue),
        const SizedBox(width: 12),
        _buildSimpleSummaryBox('حصة المستثمرين', f.format(totalInvestor), Colors.orange),
        const SizedBox(width: 12),
        _buildSimpleSummaryBox('صافي المؤسسة', f.format(totalCompany), Colors.green),
      ],
    );
  }

  Widget _buildSimpleSummaryBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Text('$value ر.س', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildClassicReportCatalog() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('التقارير التفصيلية المتاحة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const Divider(height: 1),
          _ReportListTile('تقرير الأرباح والنمو', 'profit'),
          _ReportListTile('سجل التحصيل المالي', 'collections'),
          _ReportListTile('حركة التدفق النقدي', 'cashflow'),
          _ReportListTile('ميزان المراجعة العام', 'trial_balance'),
        ],
      ),
    );
  }

  Widget _ReportListTile(String title, String type) {
    return ListTile(
      dense: true,
      title: Text(title, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: () => _openReport(type),
    );
  }

  Widget _buildPerformanceTable(List<Map<String, dynamic>> reportData) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('مؤشرات الأداء التاريخية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const Divider(height: 1),
          DataTable(
            headingRowHeight: 40,
            dataRowHeight: 45,
            columns: const [
              DataColumn(label: Text('الفترة', style: TextStyle(fontSize: 12))),
              DataColumn(label: Text('الربح الكلي', style: TextStyle(fontSize: 12))),
              DataColumn(label: Text('صافي المؤسسة', style: TextStyle(fontSize: 12))),
            ],
            rows: reportData.map((item) => DataRow(cells: [
              DataCell(Text(item['period_text'] ?? '-', style: const TextStyle(fontSize: 12))),
              DataCell(Text(f.format(item['gross_profit'] ?? 0), style: const TextStyle(fontSize: 12))),
              DataCell(Text(f.format(item['company_net_profit'] ?? 0), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green))),
            ])).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _openReport(String type) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String title = '';
      List<String> columns = [];
      List<String> keys = [];
      List<Map<String, dynamic>> data = [];

      if (type == 'profit') {
        title = 'تقرير الأرباح والنمو';
        columns = ['الفترة', 'إجمالي الربح', 'حصة المستثمر', 'صافي المؤسسة'];
        keys = ['period_text', 'gross_profit', 'investor_share', 'company_net_profit'];
        data = await ref.read(profitReportProvider(
          startDate: dateRange.start,
          endDate: dateRange.end,
        ).future);
      } else if (type == 'collections') {
        title = 'سجل التحصيل المالي';
        columns = ['التاريخ', 'رقم العقد', 'العميل', 'المبلغ', 'الوسيلة'];
        keys = [
          'payment_date',
          'financing_contracts.contract_no',
          'financing_contracts.customers.full_name',
          'amount_total',
          'payment_method'
        ];
        data = await ref.read(collectionsReportProvider(
          startDate: dateRange.start,
          endDate: dateRange.end,
        ).future);
      } else if (type == 'cashflow') {
        title = 'تقرير التدفق النقدي';
        columns = ['الشهر', 'السيولة الداخلة', 'السيولة الخارجة', 'صافي التدفق'];
        keys = ['month_text', 'inflow', 'outflow', 'net_cash_flow'];
        data = await ref.read(cashFlowReportProvider(
          startDate: dateRange.start,
          endDate: dateRange.end,
        ).future);
      } else if (type == 'trial_balance') {
        title = 'ميزان المراجعة العام';
        columns = ['الحساب', 'الكود', 'مدين', 'دائن', 'الصافي'];
        keys = ['account_name', 'account_code', 'total_debit', 'total_credit', 'net_balance'];
        data = await ref.read(trialBalanceProvider.future);
      }

      if (!mounted) return;
      Navigator.pop(context);

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ReportDetailScreen(
          title: title,
          columns: columns,
          data: data,
          dataKeys: keys,
        ),
      ));
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل التقرير: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
    );
    if (picked != null) setState(() => dateRange = picked);
  }
}
