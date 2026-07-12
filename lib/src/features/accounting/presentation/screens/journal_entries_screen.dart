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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('دفتر القيود اليومية', 
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('قيد جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: entriesAsync.when(
        data: (entries) => entries.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                itemBuilder: (context, index) => _ClassicJournalEntryCard(entry: entries[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ في تحميل القيود')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('لا توجد قيود مسجلة', style: TextStyle(color: Colors.grey)));
  }
}

class _ClassicJournalEntryCard extends StatelessWidget {
  final dynamic entry;
  const _ClassicJournalEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final date = DateTime.parse(entry.createdAt.toString());
    final lines = entry.lines ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Text('قيد #${entry.id.toString().substring(0, 6).toUpperCase()}', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
                const SizedBox(width: 16),
                Expanded(child: Text(entry.description ?? '-', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                Text(intl.DateFormat('yyyy/MM/dd').format(date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...lines.map((line) {
                  final isDebit = (line.debit ?? 0) > 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(line.accountName ?? '-', style: const TextStyle(fontSize: 12))),
                        Expanded(child: Text(isDebit ? f.format(line.debit) : '', textAlign: TextAlign.end, style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold))),
                        Expanded(child: Text(!isDebit ? f.format(line.credit) : '', textAlign: TextAlign.end, style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
