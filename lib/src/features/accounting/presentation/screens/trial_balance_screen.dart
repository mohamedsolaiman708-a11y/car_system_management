import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
// استخدام Package Import لضمان التعرف على المزودات بشكل صحيح
import 'package:car_system_management/src/features/reports/presentation/reports_controller.dart';

class TrialBalanceScreen extends ConsumerWidget {
  const TrialBalanceScreen({super.key});

  // الألوان الرسمية المعتمدة في النظام (كحلي وذهبي)
  static const Color primaryNavy = Color(0xFF0D1B3E);
  static const Color accentGold = Color(0xFFC5A35E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // جلب البيانات من المزود (تأكد من تشغيل build_runner لتوليد هذا المزود)
    final trialBalanceAsync = ref.watch(trialBalanceProvider);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          title: const Text('ميزان المراجعة المحاسبي', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.invalidate(trialBalanceProvider),
              tooltip: 'تحديث البيانات',
            ),
          ],
        ),
        body: trialBalanceAsync.when(
          data: (data) => _buildTrialBalanceTable(context, data, f),
          loading: () => const Center(child: CircularProgressIndicator(color: primaryNavy)),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('حدث خطأ أثناء جلب البيانات: $err'),
                TextButton(
                  onPressed: () => ref.invalidate(trialBalanceProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrialBalanceTable(BuildContext context, List<Map<String, dynamic>> data, intl.NumberFormat f) {
    if (data.isEmpty) {
      return const Center(child: Text('لا توجد قيود محاسبية مسجلة في هذه الفترة'));
    }

    double grandTotalDebit = 0;
    double grandTotalCredit = 0;

    for (var row in data) {
      grandTotalDebit += (row['total_debit'] ?? 0);
      grandTotalCredit += (row['total_credit'] ?? 0);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ملخص سريع علوي (Executive Summary)
          _buildQuickSummary(grandTotalDebit, grandTotalCredit, f),
          const SizedBox(height: 24),
          
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(primaryNavy.withOpacity(0.05)),
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: primaryNavy),
                  columnSpacing: 40,
                  columns: const [
                    DataColumn(label: Text('كود الحساب')),
                    DataColumn(label: Text('اسم الحساب')),
                    DataColumn(label: Text('مدين (Debit)')),
                    DataColumn(label: Text('دائن (Credit)')),
                    DataColumn(label: Text('الرصيد الصافي')),
                  ],
                  rows: [
                    ...data.map((row) => DataRow(cells: [
                      DataCell(Text(row['account_code'] ?? '', style: const TextStyle(fontFamily: 'monospace'))),
                      DataCell(Text(row['account_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(f.format(row['total_debit'] ?? 0))),
                      DataCell(Text(f.format(row['total_credit'] ?? 0))),
                      DataCell(Text(
                        f.format(row['net_balance'] ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: primaryNavy),
                      )),
                    ])),
                    // سطر الإجمالي الختامي
                    DataRow(
                      color: WidgetStateProperty.all(primaryNavy.withOpacity(0.02)),
                      cells: [
                        const DataCell(Text('')),
                        const DataCell(Text('الإجمالي الكلي', style: TextStyle(fontWeight: FontWeight.bold, color: primaryNavy))),
                        DataCell(Text(f.format(grandTotalDebit), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                        DataCell(Text(f.format(grandTotalCredit), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                        const DataCell(Text('')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildIntegrityStatus(grandTotalDebit, grandTotalCredit, f),
        ],
      ),
    );
  }

  Widget _buildQuickSummary(double debit, double credit, intl.NumberFormat f) {
    return Row(
      children: [
        _buildSummaryBox('إجمالي الحركات المدينة', f.format(debit), Colors.green),
        const SizedBox(width: 16),
        _buildSummaryBox('إجمالي الحركات الدائنة', f.format(credit), Colors.red),
      ],
    );
  }

  Widget _buildSummaryBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrityStatus(double debit, double credit, intl.NumberFormat f) {
    final diff = (debit - credit).abs();
    final isBalanced = diff < 0.01;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isBalanced ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isBalanced ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isBalanced ? Icons.verified_rounded : Icons.warning_amber_rounded, color: isBalanced ? Colors.green : Colors.red, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isBalanced 
                ? 'ميزان المراجعة متزن: كافة العمليات المالية والقيود اليومية مطابقة تماماً.' 
                : 'تنبيه: يوجد خلل في اتزان الميزان! هناك فرق محاسبي قدره: ${f.format(diff)} ر.س. يرجى مراجعة القيود الأخيرة.',
              style: TextStyle(color: isBalanced ? Colors.green.shade900 : Colors.red.shade900, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
