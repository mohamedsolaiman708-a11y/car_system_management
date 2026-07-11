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
      backgroundColor: AppColors.bgGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Container(
          color: AppColors.primaryNavy,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: _buildPremiumHeader(),
            ),
          ),
        ),
      ),
      body: accountsAsync.when(
        data: (accounts) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // قسم الهيكل المالي (Analytics)
            _buildExecutiveAnalytics(accounts),
            const SizedBox(height: 32),
            
            // عنوان القسم
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(Icons.account_tree_rounded, color: AppColors.primaryNavy, size: 24),
                  SizedBox(width: 12),
                  Text('دليل الحسابات التفصيلي', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // قائمة الحسابات بتصميم فاخر
            if (isDesktop)
              _buildPremiumAccountsTable(accounts)
            else
              _buildPremiumAccountsList(accounts),
            
            const SizedBox(height: 40),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('المركز المالي والأرصدة', 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('مراقبة السيولة، الأصول، والالتزامات في الوقت الحقيقي', 
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {}, // refresh logic
          ),
        ),
      ],
    );
  }

  Widget _buildExecutiveAnalytics(List<dynamic> accounts) {
    double assets = 0, liabilities = 0, equity = 0;
    for (var acc in accounts) {
      final b = (acc.currentBalance as num?)?.toDouble() ?? 0;
      if (acc.type.name == 'asset') assets += b;
      if (acc.type.name == 'liability') liabilities += b;
      if (acc.type.name == 'equity') equity += b;
    }
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // كارت الرسم البياني
        Expanded(
          flex: 2,
          child: Container(
            height: 280,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 6,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(value: assets, color: Colors.green, title: '', radius: 25),
                        PieChartSectionData(value: liabilities.abs(), color: Colors.orange, title: '', radius: 25),
                        PieChartSectionData(value: equity.abs(), color: Colors.purple, title: '', radius: 25),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('إجمالي الأصول', f.format(assets), Colors.green),
                    const SizedBox(height: 20),
                    _buildLegendItem('الالتزامات', f.format(liabilities.abs()), Colors.orange),
                    const SizedBox(height: 20),
                    _buildLegendItem('حقوق الملكية', f.format(equity.abs()), Colors.purple),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // كارت ملخص السيولة
        Expanded(
          flex: 1,
          child: Container(
            height: 280,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A294D), AppColors.primaryNavy]),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: AppColors.primaryNavy.withOpacity(0.2), blurRadius: 20)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet_rounded, color: AppColors.accentGold, size: 40),
                const SizedBox(height: 24),
                const Text('صافي القيمة الحالية', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text('${f.format(assets - liabilities.abs())} ر.س', 
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('أداء مالي مستقر', style: TextStyle(color: AppColors.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Text('$value ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryNavy)),
      ],
    );
  }

  Widget _buildPremiumAccountsTable(List<dynamic> accounts) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.primaryNavy.withOpacity(0.02)),
          dataRowHeight: 80,
          columns: const [
            DataColumn(label: Text('اسم الحساب', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
            DataColumn(label: Text('الكود المالي', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
            DataColumn(label: Text('نوع الحساب', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
            DataColumn(label: Text('الرصيد الحالي', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
          ],
          rows: accounts.map((acc) {
            final balance = (acc.currentBalance as num?)?.toDouble() ?? 0.0;
            return DataRow(
              cells: [
                DataCell(Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(6)),
                  child: Text(acc.code, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                )),
                DataCell(_buildTypeBadge(acc.type.name)),
                DataCell(Text('${f.format(balance)} ر.س', 
                  style: TextStyle(fontWeight: FontWeight.w900, color: balance < 0 ? Colors.red : AppColors.primaryNavy))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPremiumAccountsList(List<dynamic> accounts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accounts.length,
      itemBuilder: (context, index) => _PremiumAccountCard(account: accounts[index]),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color = Colors.blue;
    String label = type;
    if (type == 'asset') { color = Colors.green; label = 'أصول'; }
    else if (type == 'liability') { color = Colors.orange; label = 'خصوم'; }
    else if (type == 'equity') { color = Colors.purple; label = 'ملكية'; }
    else if (type == 'revenue') { color = Colors.teal; label = 'إيرادات'; }
    else if (type == 'expense') { color = Colors.red; label = 'مصروفات'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _PremiumAccountCard extends StatelessWidget {
  final dynamic account;
  const _PremiumAccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final balance = (account.currentBalance as num?)?.toDouble() ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('كود: ${account.code}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Text('${f.format(balance)} ر.س', 
          style: TextStyle(fontWeight: FontWeight.bold, color: balance < 0 ? Colors.red : AppColors.primaryNavy)),
      ),
    );
  }
}
