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
    // تم تصحيح اسم الـ Provider إلى الاسم المولد من ريفربود
    final accountsAsync = ref.watch(chartOfAccountsControllerProvider);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Container(
            color: AppColors.primaryNavy,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('شجرة الحسابات المالية',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('إدارة وتصنيف الحسابات في النظام المحاسبي',
                            style: TextStyle(color: Colors.white60, fontSize: 13)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // تم تعطيل الـ Dialog مؤقتاً لحين التأكد من وجوده أو إنشائه
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('خاصية إضافة حساب ستتوفر قريباً')),
                        );
                      },
                      icon: const Icon(Icons.add_chart_rounded, size: 18),
                      label: const Text('إضافة حساب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: AppColors.primaryNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
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
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
          error: (err, _) => Center(child: Text('خطأ: $err')),
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
        mainAxisExtent: 180,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final acc = accounts[index];
        final balance = acc.currentBalance;
        final type = acc.type;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () { /* تفاصيل الحساب */ },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(acc.code, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryNavy)),
                        ),
                        _buildTypeBadge(type),
                      ],
                    ),
                    const Spacer(),
                    Text(acc.name, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('الرصيد الحالي', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text('${f.format(balance)} ر.س', 
                          style: TextStyle(
                            fontWeight: FontWeight.w900, 
                            fontSize: 18, 
                            color: balance < 0 ? Colors.red : AppColors.primaryNavy
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          const Text('لا توجد حسابات معرفة حالياً', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
