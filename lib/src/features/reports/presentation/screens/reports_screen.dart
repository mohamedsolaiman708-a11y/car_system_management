import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../reports_controller.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مركز التقارير المالية'),
          actions: [
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: _selectDateRange,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateInfo(),
              const SizedBox(height: 20),
              _buildQuickSummary(),
              const SizedBox(height: 32),
              const Text('التقارير التفصيلية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildReportGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo() {
    final fmt = intl.DateFormat('yyyy/MM/dd');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 8),
          Text('البيانات معروضة للفترة من ${fmt.format(dateRange.start)} إلى ${fmt.format(dateRange.end)}'),
        ],
      ),
    );
  }

  Widget _buildQuickSummary() {
    // هنا نستخدم البيانات المجمعة من الـ Controller
    return Row(
      children: [
        Expanded(child: _SummaryCard(title: 'الإيرادات', value: '150,000 ر.س', icon: Icons.trending_up, color: Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(title: 'الأرباح المتوقعة', value: '45,000 ر.س', icon: Icons.pie_chart, color: Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(title: 'المتأخرات', value: '12,400 ر.س', icon: Icons.warning_amber_rounded, color: Colors.red)),
      ],
    );
  }

  Widget _buildReportGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _ReportCategoryCard(
          title: 'تقرير الممولين',
          icon: Icons.groups_outlined,
          description: 'أداء رأس المال الموزع وأرباح المستثمرين',
          onTap: () => _showReportDetails('investors'),
        ),
        _ReportCategoryCard(
          title: 'سجل التحصيل',
          icon: Icons.payments_outlined,
          description: 'متابعة الدفعات المستلمة وجدول الأقساط',
          onTap: () => _showReportDetails('collections'),
        ),
        _ReportCategoryCard(
          title: 'تقرير العقود',
          icon: Icons.description_outlined,
          description: 'إحصائيات العقود النشطة والمتعثرة',
          onTap: () => _showReportDetails('contracts'),
        ),
        _ReportCategoryCard(
          title: 'ميزان المراجعة',
          icon: Icons.account_balance_outlined,
          description: 'التقرير المحاسبي الشامل للأرصدة',
          onTap: () => _showReportDetails('accounting'),
        ),
      ],
    );
  }

  void _showReportDetails(String type) {
    // سيتم استدعاء شاشات التفاصيل لكل تقرير
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('جاري فتح $type...')));
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
    );
    if (picked != null) {
      setState(() => dateRange = picked);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ReportCategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ReportCategoryCard({required this.title, required this.description, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade800),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
