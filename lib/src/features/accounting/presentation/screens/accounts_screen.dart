import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../accounting_controller.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(chartOfAccountsControllerProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // لون خلفية كلاسيكي هادئ
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('دليل الحسابات والأرصدة اللحظية', 
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryNavy),
            onPressed: () => ref.invalidate(chartOfAccountsControllerProvider),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('لا توجد حسابات مالية معرفة في النظام'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildExecutiveFinancialSummary(accounts),
              const SizedBox(height: 24),
              _buildAccountsTableHeader(),
              const SizedBox(height: 8),
              if (isDesktop)
                _buildClassicAccountsTable(accounts)
              else
                _buildClassicAccountsList(accounts),
              const SizedBox(height: 50),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('حدث خطأ في تحميل البيانات المالية: $err')),
      ),
    );
  }

  Widget _buildExecutiveFinancialSummary(List<dynamic> accounts) {
    double assets = 0, liabilities = 0, equity = 0;
    for (var acc in accounts) {
      final b = (acc.currentBalance as num?)?.toDouble() ?? 0;
      if (acc.type.name == 'asset') assets += b;
      if (acc.type.name == 'liability') liabilities += b;
      if (acc.type.name == 'equity') equity += b;
    }
    
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    final bool hasData = (assets != 0 || liabilities != 0 || equity != 0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // الرسم البياني المصغر (Pie Chart) - لا يظهر إلا إذا وجد أرصدة
          if (hasData)
            SizedBox(
              width: 120,
              height: 120,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                  sections: [
                    if (assets != 0) PieChartSectionData(value: assets.abs(), color: Colors.green, title: '', radius: 15),
                    if (liabilities != 0) PieChartSectionData(value: liabilities.abs(), color: Colors.orange, title: '', radius: 15),
                    if (equity != 0) PieChartSectionData(value: equity.abs(), color: Colors.purple, title: '', radius: 15),
                  ],
                ),
              ),
            ),
          if (hasData) const SizedBox(width: 40),
          
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryBox('إجمالي الأصول', f.format(assets), Colors.green),
                _buildDivider(),
                _buildSummaryBox('الالتزامات', f.format(liabilities.abs()), Colors.orange),
                _buildDivider(),
                _buildSummaryBox('حقوق الملكية', f.format(equity.abs()), Colors.purple),
                _buildDivider(),
                _buildSummaryBox('صافي القيمة', f.format(assets - liabilities.abs()), AppColors.primaryNavy),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text('$value ر.س', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 35, color: Colors.grey.shade200);

  Widget _buildAccountsTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('دليل الحسابات التفصيلي', 
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
    );
  }

  Widget _buildClassicAccountsTable(List<dynamic> accounts) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DataTable(
        headingRowHeight: 40,
        dataRowHeight: 50,
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
        columns: const [
          DataColumn(label: Text('كود', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('اسم الحساب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('النوع', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('الرصيد اللحظي', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        ],
        rows: accounts.map((acc) {
          final balance = (acc.currentBalance as num?)?.toDouble() ?? 0.0;
          return DataRow(
            cells: [
              DataCell(Text(acc.code, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold))),
              DataCell(Text(acc.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
              DataCell(_buildTypeBadge(acc.type.name)),
              DataCell(Text(f.format(balance), 
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: balance < 0 ? Colors.red : AppColors.primaryNavy))),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildClassicAccountsList(List<dynamic> accounts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final acc = accounts[index];
        final balance = (acc.currentBalance as num?)?.toDouble() ?? 0.0;
        return Card(
          elevation: 0, margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            dense: true,
            title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('كود: ${acc.code}'),
            trailing: Text('${balance.toStringAsFixed(2)} ر.س', 
              style: TextStyle(fontWeight: FontWeight.bold, color: balance < 0 ? Colors.red : AppColors.primaryNavy)),
          ),
        );
      },
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color = Colors.blue;
    if (type == 'asset') color = Colors.green;
    else if (type == 'liability') color = Colors.orange;
    else if (type == 'equity') color = Colors.purple;
    return Text(type.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold));
  }
}
