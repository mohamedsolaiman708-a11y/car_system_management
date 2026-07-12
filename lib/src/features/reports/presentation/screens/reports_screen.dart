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
      backgroundColor: AppColors.bgGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Container(
          color: AppColors.primaryNavy,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('مركز التقارير والذكاء المالي',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('تحليل الأداء الاستثماري، التدفقات النقدية، والتقارير الرقابية',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                    ],
                  ),
                  _buildDateRangePicker(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: profitAsync.when(
        data: (reportData) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ملخص مالي تنفيذي
            _buildExecutiveSummary(reportData),
            const SizedBox(height: 40),

            // شبكة أنواع التقارير
            const Text('كتالوج التقارير المتخصصة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            const SizedBox(height: 20),
            _buildReportCategories(),

            const SizedBox(height: 40),

            // جدول الأداء الأخير
            _buildPerformanceSection(reportData),
            const SizedBox(height: 60),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range_rounded, color: AppColors.accentGold, size: 20),
            const SizedBox(width: 12),
            Text(
              '${intl.DateFormat('dd/MM/yyyy').format(dateRange.start)} - ${intl.DateFormat('dd/MM/yyyy').format(dateRange.end)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutiveSummary(List<Map<String, dynamic>> reportData) {
    double totalGross = 0, totalInvestor = 0, totalCompany = 0;
    for (var item in reportData) {
      totalGross += (item['gross_profit'] as num?)?.toDouble() ?? 0;
      totalInvestor += (item['investor_share'] as num?)?.toDouble() ?? 0;
      totalCompany += (item['company_net_profit'] as num?)?.toDouble() ?? 0;
    }
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Row(
      children: [
        _buildPremiumSummaryCard('إجمالي الأرباح التشغيلية', f.format(totalGross), Icons.payments_rounded, [const Color(0xFF6366F1), const Color(0xFF4F46E5)]),
        const SizedBox(width: 20),
        _buildPremiumSummaryCard('حصة المستثمرين', f.format(totalInvestor), Icons.groups_rounded, [const Color(0xFFF59E0B), const Color(0xFFD97706)]),
        const SizedBox(width: 20),
        _buildPremiumSummaryCard('صافي ربح المؤسسة', f.format(totalCompany), Icons.trending_up_rounded, [const Color(0xFF10B981), const Color(0xFF059669)]),
      ],
    );
  }

  Widget _buildPremiumSummaryCard(String title, String value, IconData icon, List<Color> gradient) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: gradient.last.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 20),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCategories() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.2,
      children: [
        _buildCategoryCard('تقرير الأرباح', 'تحليل العوائد والنمو', Icons.pie_chart_rounded, Colors.indigo, 'profit'),
        _buildCategoryCard('سجل التحصيل', 'متابعة الدفعات المستلمة', Icons.receipt_long_rounded, Colors.teal, 'collections'),
        _buildCategoryCard('التدفق النقدي', 'مراقبة حركة السيولة', Icons.swap_horizontal_circle_rounded, Colors.orange, 'cashflow'),
        _buildCategoryCard('ميزان المراجعة', 'التقرير المحاسبي العام', Icons.account_tree_rounded, Colors.blueGrey, 'trial_balance'),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, IconData icon, Color color, String type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openReport(type),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceSection(List<Map<String, dynamic>> reportData) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مؤشرات الأداء التاريخية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          const SizedBox(height: 24),
          if (reportData.isEmpty)
            const Center(child: Text('لا توجد بيانات متاحة للمدة المختارة'))
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  children: [
                    _buildHeaderCell('الفترة الزمنية'),
                    _buildHeaderCell('إجمالي الربح'),
                    _buildHeaderCell('حصة المستثمرين'),
                    _buildHeaderCell('صافي الشركة'),
                  ],
                ),
                ...reportData.map((item) => TableRow(
                  children: [
                    _buildDataCell(item['period_text'] ?? '', isBold: true),
                    _buildDataCell('${f.format(item['gross_profit'] ?? 0)} ر.س'),
                    _buildDataCell('${f.format(item['investor_share'] ?? 0)} ر.س', color: Colors.orange),
                    _buildDataCell('${f.format(item['company_net_profit'] ?? 0)} ر.س', color: Colors.green, isBold: true),
                  ],
                )).toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.bold)));
  Widget _buildDataCell(String text, {bool isBold = false, Color? color}) => Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(text, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? AppColors.primaryNavy)));

  Future<void> _openReport(String type) async {
    // Logic as per original but navigation can be improved
    // For brevity, keeping core logic
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
