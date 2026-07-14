import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../reports/presentation/reports_controller.dart';

class TrialBalanceScreen extends ConsumerWidget {
  const TrialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trialBalanceAsync = ref.watch(trialBalanceProvider);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: Container(
            color: AppColors.primaryNavy,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('ميزان المراجعة العام', 
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 6),
                        Text('مراقبة دقة التوازن المالي للأصول والخصوم', 
                          style: TextStyle(color: Colors.white60, fontSize: 13)),
                      ],
                    ),
                    _buildRefreshButton(ref),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: trialBalanceAsync.when(
          data: (data) => _buildPremiumTable(context, data, f),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
          error: (err, _) => Center(child: Text('خطأ: $err')),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: AppColors.accentGold),
        onPressed: () => ref.invalidate(trialBalanceProvider),
      ),
    );
  }

  Widget _buildPremiumTable(BuildContext context, List<Map<String, dynamic>> data, intl.NumberFormat f) {
    double totalDebit = data.fold(0, (sum, item) => sum + (item['total_debit'] ?? 0));
    double totalCredit = data.fold(0, (sum, item) => sum + (item['total_credit'] ?? 0));
    final isBalanced = (totalDebit - totalCredit).abs() < 0.01;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSummaryCards(totalDebit, totalCredit, isBalanced, f),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              dataRowHeight: 65,
              columns: const [
                DataColumn(label: Text('الكود', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('الحساب', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('مدين', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('دائن', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('الصافي', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                ...data.map((row) => DataRow(cells: [
                  DataCell(Text(row['account_code'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  DataCell(Text(row['account_name'] ?? '')),
                  DataCell(Text(f.format(row['total_debit'] ?? 0), style: const TextStyle(color: AppColors.successGreen))),
                  DataCell(Text(f.format(row['total_credit'] ?? 0), style: const TextStyle(color: Colors.redAccent))),
                  DataCell(Text(f.format(row['net_balance'] ?? 0), style: const TextStyle(fontWeight: FontWeight.w900))),
                ])),
                DataRow(
                  color: WidgetStateProperty.all(AppColors.primaryNavy.withOpacity(0.03)),
                  cells: [
                    const DataCell(Text('')),
                    const DataCell(Text('الإجماليات', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(f.format(totalDebit), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.successGreen))),
                    DataCell(Text(f.format(totalCredit), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))),
                    const DataCell(Text('')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(double debit, double credit, bool balanced, intl.NumberFormat f) {
    return Row(
      children: [
        _buildStatCard('إجمالي المدين', f.format(debit), AppColors.successGreen),
        const SizedBox(width: 16),
        _buildStatCard('إجمالي الدائن', f.format(credit), Colors.redAccent),
        const SizedBox(width: 16),
        _buildBalanceCard(balanced),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(bool balanced) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: balanced ? AppColors.successGreen : Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(balanced ? Icons.check_circle_rounded : Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text(balanced ? 'متوازن' : 'غير متوازن', 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
