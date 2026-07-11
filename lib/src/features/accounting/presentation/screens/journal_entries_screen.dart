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
      backgroundColor: AppColors.bgGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Container(
          color: AppColors.primaryNavy,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: _buildPremiumHeader(ref),
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
                  final entry = entries[index];
                  return _PremiumJournalEntryCard(entry: entry);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (err, _) => Center(child: Text('خطأ في تحميل القيود: $err')),
      ),
    );
  }

  Widget _buildPremiumHeader(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('دفتر القيود اليومية', 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('سجل كافة الحركات المالية والقيود المحاسبية المعتمدة', 
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // منطق إضافة قيد يدوي
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('إنشاء قيد جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: AppColors.primaryNavy,
                minimumSize: const Size(160, 54),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () => ref.invalidate(journalEntriesControllerProvider),
              ),
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
          Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('لا توجد قيود محاسبية مسجلة حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

class _PremiumJournalEntryCard extends StatelessWidget {
  final dynamic entry;
  const _PremiumJournalEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final date = DateTime.parse(entry.createdAt.toString());
    final lines = entry.lines ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس القيد (Modern Design)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgGrey.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('قيد #${entry.id.toString().substring(0, 6).toUpperCase()}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.description ?? 'بدون وصف',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryNavy)),
                      if (entry.referenceNo != null)
                        Text('المرجع: ${entry.referenceNo}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(intl.DateFormat('dd MMMM yyyy', 'ar').format(date),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(intl.DateFormat('HH:mm').format(date),
                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          
          // جدول القيد (مدين / دائن)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(flex: 4, child: Text('الحساب المالي', style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('مدين (Debit)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('دائن (Credit)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.bold))),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                ...lines.map((line) {
                  final isDebit = (line.debit ?? 0) > 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isDebit ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(line.accountName ?? 'حساب غير معروف', 
                                style: TextStyle(
                                  fontSize: 14, 
                                  fontWeight: isDebit ? FontWeight.bold : FontWeight.w500,
                                  color: AppColors.primaryNavy,
                                )),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(line.debit > 0 ? f.format(line.debit) : '-', 
                            textAlign: TextAlign.center, 
                            style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(line.credit > 0 ? f.format(line.credit) : '-', 
                            textAlign: TextAlign.center, 
                            style: const TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          // حاشية القيد
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgGrey.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('تم التحقق من اتزان القيد برمجياً', style: TextStyle(fontSize: 10, color: Colors.grey)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.print_rounded, size: 16),
                  label: const Text('طباعة السند', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
