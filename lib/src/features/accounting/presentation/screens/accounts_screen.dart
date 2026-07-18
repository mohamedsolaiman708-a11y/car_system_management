import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
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
          preferredSize: const Size.fromHeight(120),
          child: Container(
            color: AppColors.primaryNavy,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // زر العودة
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    // الحاوية التي تضمن محاذاة النصوص للبداية (اليمين)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'إدارة الحسابات المالية (Accounting)',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'متابعة الأرصدة اللحظية، هيكلة شجرة الحسابات، والنشاط المالي العام',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: accountsAsync.when(
          data: (accounts) => _buildAccountsGrid(accounts, f),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryNavy),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                Failure.fromException(err).message,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
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
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.push('/accounting/ledger/${acc.id}?name=${Uri.encodeComponent(acc.name)}');
              },
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            acc.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.primaryNavy,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        _buildTypeBadge(acc.type),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      _translateAccountName(acc.name),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'الرصيد المالي',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${f.format(balance)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            color: balance < 0
                                ? Colors.red
                                : AppColors.primaryNavy,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Text(
                          'ر.س',
                          style: TextStyle(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
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
    const translations = {
      // --- حسابات الأصول ---
      'Cash': 'الصندوق الرئيسي',
      'Cash at Bank': 'النقد في البنك',
      'Contracts Receivable': 'ذمم عقود التمويل',
      'Accounts Receivable': 'الذمم المدينة',
      'Prepaid Expenses': 'مصروفات مدفوعة مقدماً',
      'Inventory': 'المخزون',
      'Fixed Assets': 'الأصول الثابتة',
      // --- حسابات الخصوم ---
      'Accounts Payable': 'الذمم الدائنة',
      'Investors Capital': 'رأس مال المستثمرين',
      'Investor Payable - Principal': 'مستحقات المستثمرين - الأصل',
      'Investor Payable - Profit': 'مستحقات المستثمرين - الأرباح',
      'Profit Payable': 'أرباح مستحقة الدفع',
      'Loans Payable': 'قروض مستحقة',
      'Accrued Liabilities': 'التزامات مستحقة',
      // --- حسابات حقوق الملكية ---
      'Equity': 'حقوق الملكية',
      'Share Capital': 'رأس المال المدفوع',
      'Retained Earnings': 'الأرباح المبقاة',
      // --- حسابات الإيرادات ---
      'Revenue': 'الإيرادات',
      'Finance Revenue': 'إيرادات التمويل',
      'Unearned Finance Profit': 'أرباح تمويل غير مكتسبة',
      'Realized Finance Profit': 'أرباح تمويل محققة',
      'Financing Profits': 'أرباح التمويل',
      // --- حسابات المصروفات ---
      'General Expenses': 'مصروفات عامة',
      'Operating Expenses': 'المصروفات التشغيلية',
      'Cost of Revenue': 'تكلفة الإيرادات',
      // --- عربية موجودة ---
      'الصندوق': 'الصندوق الرئيسي',
      'الصندوق / البنك': 'حساب الصندوق والبنك',
    };
    return translations[name] ?? name;
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    String label;
    switch (type.toLowerCase()) {
      case 'asset':
        color = Colors.green;
        label = 'أصل';
        break;
      case 'liability':
        color = Colors.orange;
        label = 'خصم';
        break;
      case 'equity':
        color = Colors.purple;
        label = 'حقوق ملكية';
        break;
      case 'revenue':
        color = Colors.blue;
        label = 'إيراد';
        break;
      case 'expense':
        color = Colors.red;
        label = 'مصروف';
        break;
      default:
        color = Colors.grey;
        label = type;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 80,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد حسابات معرفة حالياً',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
