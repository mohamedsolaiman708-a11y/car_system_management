import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../accounting_controller.dart';

class JournalEntriesScreen extends ConsumerWidget {
  const JournalEntriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('دفتر القيود اليومية'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.invalidate(journalEntriesControllerProvider),
            ),
          ],
        ),
        body: entriesAsync.when(
          data: (entries) => entries.isEmpty
              ? const Center(child: Text('لا توجد قيود مسجلة حالياً'))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _JournalEntryCard(entry: entry);
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ في تحميل القيود: $err')),
        ),
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final dynamic entry;
  const _JournalEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final date = DateTime.parse(entry.createdAt.toString());
    final lines = entry.lines ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس القيد
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryNavy, borderRadius: BorderRadius.circular(8)),
                  child: Text('قيد رقم: ${entry.id.toString().substring(0, 8)}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(entry.description ?? 'بدون وصف',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Text(intl.DateFormat('yyyy/MM/dd').format(date),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          
          // تفاصيل القيد (مدين / دائن)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  children: [
                    Padding(padding: EdgeInsets.only(bottom: 8), child: Text('الحساب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                    Text('مدين', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    Text('دائن', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  ],
                ),
                ...lines.map((line) {
                  final isDebit = (line.debit ?? 0) > 0;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(line.accountName ?? 'حساب غير معروف', style: TextStyle(fontSize: 13, fontWeight: isDebit ? FontWeight.bold : FontWeight.normal)),
                      ),
                      Text(line.debit > 0 ? f.format(line.debit) : '-', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
                      Text(line.credit > 0 ? f.format(line.credit) : '-', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
          
          // حقل المرجع
          if (entry.referenceNo != null)
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: Text('المرجع: ${entry.referenceNo}', style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }
}
