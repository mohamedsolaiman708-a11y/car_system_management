import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../accounting_controller.dart';
import '../../domain/account.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(chartOfAccountsControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('شجرة الحسابات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(chartOfAccountsControllerProvider.notifier).refresh(),
            ),
          ],
        ),
        body: accountsAsync.when(
          data: (accounts) => _buildAccountsList(context, accounts),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('حدث خطأ: $err')),
        ),
      ),
    );
  }

  Widget _buildAccountsList(BuildContext context, List<Account> accounts) {
    if (accounts.isEmpty) {
      return const Center(child: Text('لا توجد حسابات مسجلة'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getAccountTypeColor(account.type).withOpacity(0.1),
              child: Text(
                account.code,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getAccountTypeColor(account.type),
                ),
              ),
            ),
            title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_getAccountTypeLabel(account.type)),
            trailing: Text(
              '${account.currentBalance.toStringAsFixed(2)} ر.س',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: account.currentBalance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getAccountTypeColor(String type) {
    switch (type) {
      case 'asset': return Colors.blue;
      case 'liability': return Colors.red;
      case 'equity': return Colors.purple;
      case 'revenue': return Colors.green;
      case 'expense': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _getAccountTypeLabel(String type) {
    switch (type) {
      case 'asset': return 'أصول';
      case 'liability': return 'خصوم (التزامات)';
      case 'equity': return 'حقوق ملكية';
      case 'revenue': return 'إيرادات';
      case 'expense': return 'مصروفات';
      default: return 'غير معروف';
    }
  }
}
