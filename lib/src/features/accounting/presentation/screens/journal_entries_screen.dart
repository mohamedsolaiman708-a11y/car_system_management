import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../accounting_controller.dart';

class JournalEntriesScreen extends ConsumerWidget {
  const JournalEntriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesControllerProvider);

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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: _buildHeader(ref),
              ),
            ),
          ),
        ),
        body: entriesAsync.when(
          data: (entries) => entries.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return _JournalEntryCard(entry: entries[index]);
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
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

  Widget _buildHeader(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('سجل قيود اليومية',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 4),
            Text('متابعة كافة العمليات المالية والقيود المحاسبية',
                style: TextStyle(color: Colors.white60, fontSize: 13)),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () { /* إضافة قيد */ },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('إضافة قيد يدوي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: AppColors.primaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => ref.invalidate(journalEntriesControllerProvider),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.white10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          const Text('لا توجد قيود محاسبية مسجلة', style: TextStyle(color: Colors.grey)),
        ],
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // Header of the card
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryNavy, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.description ?? 'بدون وصف', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                      Text('مرجع: ${entry.id.toString().substring(0, 8).toUpperCase()}', 
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(intl.DateFormat('yyyy/MM/dd').format(date), 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(intl.DateFormat('HH:mm').format(date), 
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Entry Lines
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...lines.map((line) {
                  final isDebit = (line.debit ?? 0) > 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(line.accountName ?? '', 
                            style: TextStyle(
                              color: isDebit ? AppColors.primaryNavy : AppColors.primaryNavy.withValues(alpha: 0.7),
                              fontWeight: isDebit ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13
                            )),
                        ),
                        Expanded(
                          child: Text(isDebit ? f.format(line.debit) : '', 
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        Expanded(
                          child: Text(!isDebit ? f.format(line.credit) : '', 
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgGrey.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الحالة: مكتمل ومعتمد', style: TextStyle(fontSize: 10, color: AppColors.successGreen, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.print_rounded, size: 14),
                  label: const Text('طباعة السند', style: TextStyle(fontSize: 11)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
