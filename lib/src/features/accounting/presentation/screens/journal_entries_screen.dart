import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../accounting_controller.dart';
import '../../domain/journal_entry.dart';

class JournalEntriesScreen extends ConsumerWidget {
  const JournalEntriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('القيود اليومية والعمليات المالية'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(journalEntriesControllerProvider.notifier).refresh(),
            ),
          ],
        ),
        body: entriesAsync.when(
          data: (entries) => _buildEntriesList(context, entries),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('حدث خطأ: $err')),
        ),
      ),
    );
  }

  Widget _buildEntriesList(BuildContext context, List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return const Center(child: Text('لا توجد قيود مسجلة حالياً'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _JournalEntryCard(entry: entry);
      },
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  const _JournalEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final df = intl.DateFormat('yyyy/MM/dd HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: const Icon(Icons.article_outlined, color: Colors.blue),
        ),
        title: Text(entry.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('مرجع: ${entry.referenceNo ?? "N/A"} | ${df.format(entry.createdAt)}'),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                _buildHeaderRow(),
                const Divider(),
                ...entry.lines.map((line) => _buildLineRow(line)),
                const Divider(),
                _buildFooterRow(entry),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return const Row(
      children: [
        Expanded(flex: 3, child: Text('الحساب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        Expanded(child: Text('مدين (Debit)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
        Expanded(child: Text('دائن (Credit)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
      ],
    );
  }

  Widget _buildLineRow(JournalEntryLine line) {
    final accountName = line.accounts?['name'] ?? 'حساب غير معروف';
    final accountCode = line.accounts?['code'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(accountName, style: const TextStyle(fontSize: 13)),
                Text(accountCode, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: Text(
              line.debit > 0 ? line.debit.toStringAsFixed(2) : '-',
              textAlign: TextAlign.center,
              style: TextStyle(color: line.debit > 0 ? Colors.green : Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              line.credit > 0 ? line.credit.toStringAsFixed(2) : '-',
              textAlign: TextAlign.center,
              style: TextStyle(color: line.credit > 0 ? Colors.red : Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterRow(JournalEntry entry) {
    double totalDebit = 0;
    for (var l in entry.lines) {
      totalDebit += l.debit;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          const Expanded(flex: 3, child: Text('الإجمالي', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: Text(
              totalDebit.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          Expanded(
            child: Text(
              totalDebit.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
