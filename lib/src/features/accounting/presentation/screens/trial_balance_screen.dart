import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../reports/presentation/reports_controller.dart';

class TrialBalanceScreen extends ConsumerWidget {
  const TrialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trialBalanceAsync = ref.watch(trialBalanceProvider);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
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
                      const Text('ميزان المراجعة الختامي', 
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('التحقق من توازن الأرصدة المدينة والدائنة في الوقت الحقيقي', 
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: () => ref.invalidate(trialBalanceProvider),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: trialBalanceAsync.when(
        data: (data) => _buildPremiumTrialBalance(context, data, f),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (err, _) => Center(child: Text('خطأ في تحميل البيانات: $err')),
      ),
    );
  }

  Widget _buildPremiumTrialBalance(BuildContext context, List<Map<String, dynamic>> data, intl.NumberFormat f) {
    if (data.isEmpty) return const Center(child: Text('لا توجد حركات مالية مسجلة حالياً'));

    double grandTotalDebit = 0;
    double grandTotalCredit = 0;
    for (var row in data) {
      grandTotalDebit += (row['total_debit'] ?? 0);
      grandTotalCredit += (row['total_credit'] ?? 0);
    }

    final isBalanced = (grandTotalDebit - grandTotalCredit).abs() < 0.01;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // كروت الملخص العلوي
        Row(
          children: [
            Expanded(child: _buildSummaryCard('إجمالي الحركات المدينة', f.format(grandTotalDebit), Colors.green)),
            const SizedBox(width: 20),
            Expanded(child: _buildSummaryCard('إجمالي الحركات الدائنة', f.format(grandTotalCredit), Colors.red)),
            const SizedBox(width: 20),
            Expanded(child: _buildStatusCard(isBalanced)),
          ],
        ),
        const SizedBox(height: 32),
        
        // الجدول المالي الفاخر
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.primaryNavy.withOpacity(0.02)),
              dataRowHeight: 70,
              columns: const [
                DataColumn(label: Text('كود الحساب', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('اسم الحساب المالي', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('مدين (Debit)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('دائن (Credit)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('الرصيد الصافي', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                ...data.map((row) => DataRow(cells: [
                  DataCell(Text(row['account_code'] ?? '', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                  DataCell(Text(row['account_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(f.format(row['total_debit'] ?? 0), style: const TextStyle(color: Colors.green))),
                  DataCell(Text(f.format(row['total_credit'] ?? 0), style: const TextStyle(color: Colors.red))),
                  DataCell(Text(f.format(row['net_balance'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold))),
                ])),
                // سطر الإجمالي
                DataRow(
                  color: WidgetStateProperty.all(AppColors.bgGrey),
                  cells: [
                    const DataCell(Text('')),
                    const DataCell(Text('الإجمالي الكلي', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(f.format(grandTotalDebit), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                    DataCell(Text(f.format(grandTotalCredit), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                    const DataCell(Text('')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text('$value ر.س', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isBalanced) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isBalanced ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: (isBalanced ? Colors.green : Colors.red).withOpacity(0.3), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(isBalanced ? Icons.verified_rounded : Icons.warning_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('حالة الميزان', style: TextStyle(color: Colors.white70, fontSize: 11)),
                Text(isBalanced ? 'متوازن تماماً' : 'يوجد خلل!', 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
