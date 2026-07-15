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
        appBar: AppBar(
          toolbarHeight: 140,
          backgroundColor: AppColors.primaryNavy,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0,
          flexibleSpace: SafeArea(
            child: _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'إدارة الحسابات المالية',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'متابعة الأرصدة اللحظية، هيكلة شجرة الحسابات، والنشاط المالي',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsGrid(List<Account> accounts, intl.NumberFormat f) {
    if (accounts.isEmpty) return _buildEmptyState();

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 220,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), 
                blurRadius: 15, 
                offset: const Offset(0, 8)
              )
            ],
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(acc.code, 
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 12, 
                              color: AppColors.primaryNavy,
                              fontFamily: 'monospace'
                            )),
                        ),
                        _buildTypeBadge(acc.type),
                      ],
                    ),
                    const Spacer(),
                    Text(_translateAccountName(acc.name), 
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 19, 
                        color: AppColors.primaryNavy
                      )),
                    const SizedBox(height: 12),
                    const Text('الرصيد المالي', 
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${f.format(balance)}', 
                          style: TextStyle(
                            fontWeight: FontWeight.w900, 
                            fontSize: 22, 
                            color: balance < 0 ? Colors.red : AppColors.primaryNavy,
                            letterSpacing: 0.5
                          )),
                        const Text('ر.س', 
                          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 14)),
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
      'Cash': 'الصندوق الرئيسي',
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
      case 'asset': color = Colors.green; label = 'أصل'; break;
      case 'liability': color = Colors.orange; label = 'خصم'; break;
      case 'equity': color = Colors.purple; label = 'حقوق ملكية'; break;
      case 'revenue': color = Colors.blue; label = 'إيراد'; break;
      case 'expense': color = Colors.red; label = 'مصروف'; break;
      default: color = Colors.grey; label = type;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
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
