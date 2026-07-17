import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/services/export_service.dart';
import '../../../../core/utils/app_theme.dart';
import '../accounting_controller.dart';

class AccountLedgerScreen extends ConsumerWidget {
  final String accountId;
  final String accountName;

  const AccountLedgerScreen({super.key, required this.accountId, required this.accountName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text('كشف حركات: ${_translateAccountName(accountName)}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              onPressed: () => _exportPdf(ref, entriesAsync.value ?? []),
              tooltip: 'تصدير كشف حساب PDF',
            ),
          ],
        ),
        body: entriesAsync.when(
          data: (entries) {
            final ledgerLines = <Map<String, dynamic>>[];

            for (var entry in entries) {
              for (var line in (entry.lines ?? <dynamic>[])) {
                if (line.accountId == accountId) {
                  ledgerLines.add({
                    'date': entry.createdAt,
                    'description': entry.description,
                    'debit': line.debit,
                    'credit': line.credit,
                    'ref': entry.referenceNo,
                  });
                }
              }
            }

            if (ledgerLines.isEmpty) {
              return const Center(child: Text('لا توجد حركات مسجلة لهذا الحساب حالياً'));
            }

            final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

            return Column(
              children: [
                _buildLedgerHeader(_translateAccountName(accountName), ledgerLines.length),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: ledgerLines.length,
                    itemBuilder: (context, index) {
                      final line = ledgerLines[index];
                      final isDebit = (line['debit'] as num) > 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isDebit ? Colors.green.shade50 : Colors.red.shade50,
                            child: Icon(
                              isDebit ? Icons.south_west_rounded : Icons.north_east_rounded,
                              color: isDebit ? Colors.green : Colors.red,
                              size: 18,
                            ),
                          ),
                          title: Text(_translateDescription(line['description'] ?? ''),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(
                            intl.DateFormat('yyyy/MM/dd HH:mm').format(line['date']),
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${f.format(isDebit ? line['debit'] : line['credit'])} ر.س',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDebit ? Colors.green : Colors.red,
                                ),
                              ),
                              if (line['ref'] != null)
                                Text('مرجع: ${line['ref']}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ في تحميل الحركات: $err')),
        ),
      ),
    );
  }

  Widget _buildLedgerHeader(String name, int count) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryNavy),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('إجمالي عدد الحركات: $count قيد', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(WidgetRef ref, List<dynamic> entries) async {
    final ledgerLines = <List<String>>[];
    for (var entry in entries) {
      for (var line in (entry.lines ?? [])) {
        if (line.accountId == accountId) {
          ledgerLines.add([
            intl.DateFormat('yyyy/MM/dd').format(entry.createdAt),
            _translateDescription(entry.description ?? ''),
            line.debit > 0 ? line.debit.toString() : '-',
            line.credit > 0 ? line.credit.toString() : '-',
            entry.referenceNo ?? '-',
          ]);
        }
      }
    }

    await ref.read(exportServiceProvider).exportToPdf(
      title: 'كشف حساب: ${_translateAccountName(accountName)}',
      columns: ['التاريخ', 'البيان', 'مدين', 'دائن', 'المرجع'],
      rows: ledgerLines,
    );
  }

  String _translateAccountName(String name) {
    const map = {
      'Cash': 'الصندوق الرئيسي',
      'Cash at Bank': 'النقد في البنك',
      'Contracts Receivable': 'ذمم عقود التمويل',
      'Accounts Receivable': 'الذمم المدينة',
      'Investors Capital': 'رأس مال المستثمرين',
      'Investor Payable - Principal': 'مستحقات المستثمرين - الأصل',
      'Investor Payable - Profit': 'مستحقات المستثمرين - الأرباح',
      'Profit Payable': 'أرباح مستحقة الدفع',
      'Unearned Finance Profit': 'أرباح تمويل غير مكتسبة',
      'Realized Finance Profit': 'أرباح تمويل محققة',
      'Finance Revenue': 'إيرادات التمويل',
      'Financing Profits': 'أرباح التمويل',
      'General Expenses': 'مصروفات عامة',
      'Operating Expenses': 'المصروفات التشغيلية',
      'Equity': 'حقوق الملكية',
      'Retained Earnings': 'الأرباح المبقاة',
    };
    return map[name] ?? name;
  }

  String _translateDescription(String text) {
    if (text.isEmpty) return text;
    const prefixes = {
      'Investor Deposit (': 'إيداع مستثمر (',
      'Investor Withdrawal (': 'سحب مستثمر (',
      'Investor Deposit': 'إيداع مستثمر',
      'Investor Withdrawal': 'سحب مستثمر',
      'Activation of Contract:': 'تفعيل عقد:',
      'Payment for Contract:': 'دفعة للعقد:',
      'Withdrawal Request Approved:': 'تمت الموافقة على طلب السحب:',
    };
    for (final entry in prefixes.entries) {
      if (text.startsWith(entry.key)) {
        return text.replaceFirst(entry.key, entry.value);
      }
    }
    return text;
  }
}
