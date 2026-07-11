import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/app_theme.dart';
import '../accounting_controller.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(chartOfAccountsControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('دليل الحسابات والأرصدة'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.invalidate(chartOfAccountsControllerProvider),
            ),
          ],
        ),
        body: accountsAsync.when(
          data: (accounts) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFinancialStructureChart(accounts),
                const SizedBox(height: 32),
                const Text('الأرصدة التفصيلية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return _AccountBalanceCard(account: account);
                  },
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ في تحميل الحسابات: $err')),
        ),
      ),
    );
  }

  Widget _buildFinancialStructureChart(List<dynamic> accounts) {
    // تجميع الأرصدة حسب النوع للرسم البياني
    double assets = 0, liabilities = 0, equity = 0;
    for (var acc in accounts) {
      final b = (acc.currentBalance as num?)?.toDouble() ?? 0;
      if (acc.type.name == 'asset') assets += b;
      if (acc.type.name == 'liability') liabilities += b;
      if (acc.type.name == 'equity') equity += b;
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(value: assets, color: Colors.green, title: 'الأصول', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                  PieChartSectionData(value: liabilities.abs(), color: Colors.orange, title: 'الالتزامات', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                  PieChartSectionData(value: equity.abs(), color: Colors.purple, title: 'الملكية', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ChartLegend(color: Colors.green, label: 'إجمالي الأصول', value: assets),
                _ChartLegend(color: Colors.orange, label: 'الالتزامات', value: liabilities),
                _ChartLegend(color: Colors.purple, label: 'رأس المال', value: equity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  final double value;
  const _ChartLegend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text('${f.format(value.abs())} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _AccountBalanceCard extends StatelessWidget {
  final dynamic account;
  const _AccountBalanceCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final balance = (account.currentBalance as num?)?.toDouble() ?? 0.0;
    
    Color typeColor = Colors.blue;
    IconData typeIcon = Icons.account_balance_wallet_rounded;

    if (account.type.name == 'asset') {
      typeColor = Colors.green;
      typeIcon = Icons.account_balance_rounded;
    } else if (account.type.name == 'liability') {
      typeColor = Colors.orange;
      typeIcon = Icons.pending_actions_rounded;
    } else if (account.type.name == 'equity') {
      typeColor = Colors.purple;
      typeIcon = Icons.pie_chart_rounded;
    } else if (account.type.name == 'revenue') {
      typeColor = Colors.teal;
      typeIcon = Icons.trending_up_rounded;
    } else {
      typeColor = Colors.red;
      typeIcon = Icons.trending_down_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('كود الحساب: ${account.code}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${f.format(balance)} ر.س', 
              style: TextStyle(
                fontWeight: FontWeight.w900, 
                fontSize: 18, 
                color: balance >= 0 ? AppColors.primaryNavy : Colors.red
              )),
            Text(balance >= 0 ? 'رصيد مدين' : 'رصيد دائن', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
