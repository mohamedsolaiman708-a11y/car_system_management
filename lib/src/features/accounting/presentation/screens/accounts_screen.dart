import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../domain/account.dart';
import '../accounting_controller.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(chartOfAccountsControllerProvider);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(200), // زيادة الارتفاع لضمان ظهور العنوان بوضوح
          child: Container(
            color: AppColors.primaryNavy,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: _buildHeader(context, accountsAsync),
              ),
            ),
          ),
        ),
        body: accountsAsync.when(
          data: (accounts) => _buildAccountsGrid(accounts, f),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
          error: (err, _) => Center(child: Text('خطأ: $err')),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<List<Account>> accountsAsync) {
    int count = 0;
    accountsAsync.whenData((list) => count = list.length);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'شجرة الحسابات المالية', // العنوان الرئيسي بارز وواضح
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickStat('إجمالي الحسابات المعرفة', count.toString()),
                const SizedBox(width: 40),
                _buildQuickStat('حالة شجرة الحسابات', 'نشطة ومعتمدة'),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('خاصية إضافة حساب ستتوفر قريباً')),
            );
          },
          icon: const Icon(Icons.add_chart_rounded, size: 20),
          label: const Text('إضافة حساب جديد'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGold,
            foregroundColor: AppColors.primaryNavy,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildAccountsGrid(List<Account> accounts, intl.NumberFormat f) {
    if (accounts.isEmpty) return _buildEmptyState();

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 200,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final acc = accounts[index];
        final balance = acc.currentBalance;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () { /* تفاصيل الحساب */ },
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(acc.code, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy, fontFamily: 'monospace')),
                        ),
                        _buildTypeBadge(acc.type),
                      ],
                    ),
                    const Spacer(),
                    Text(_translateAccountName(acc.name), 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryNavy)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('الرصيد المالي', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('${f.format(balance)} ر.س', 
                          style: TextStyle(
                            fontWeight: FontWeight.w900, 
                            fontSize: 20, 
                            color: balance < 0 ? Colors.red : AppColors.primaryNavy,
                            letterSpacing: 0.5
                          )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _translateAccountName(String name) {
    final translations = {
      'Contracts Receivable': 'ذمم عقود التمويل',
      'Cash at Bank': 'النقد في البنك',
      'Investors Capital': 'رأس مال المستثمرين',
      'Investor Payable - Principal': 'مستحقات المستثمرين - الأصل',
      'Investor Payable - Profit': 'مستحقات المستثمرين - الأرباح',
      'Unearned Finance Profit': 'أرباح تمويل غير مكتسبة',
      'Realized Finance Profit': 'أرباح تمويل محققة',
      'Cash': 'الصندوق',
      'Finance Revenue': 'إيرادات التمويل',
      'General Expenses': 'مصروفات عامة',
      'Equity': 'حقوق الملكية',
      'Retained Earnings': 'الأرباح المبقاة',
      'الصندوق': 'الصندوق الرئيسي',
      'الصندوق / البنك': 'حساب الصندوق والبنك',
    };
    return translations[name] ?? name;
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    String label;
    switch (type.toLowerCase()) {
      case 'asset': color = Colors.blue; label = 'أصل'; break;
      case 'liability': color = Colors.orange; label = 'خصم'; break;
      case 'equity': color = Colors.purple; label = 'حقوق ملكية'; break;
      case 'revenue': color = Colors.green; label = 'إيراد'; break;
      case 'expense': color = Colors.red; label = 'مصروف'; break;
      default: color = Colors.grey; label = type;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          const Text('لا توجد حسابات معرفة حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
