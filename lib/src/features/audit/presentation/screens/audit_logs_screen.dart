import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../data/supabase_audit_repository.dart';
import '../../domain/audit_log.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsListProvider);

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Container(
          color: AppColors.primaryNavy,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('سجل الرقابة والنشاط',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('تتبع كافة العمليات، التعديلات، والوصول إلى البيانات الحساسة',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: () => ref.invalidate(auditLogsListProvider),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: logsAsync.when(
        data: (logs) => logs.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            return _PremiumAuditLogCard(log: logs[index]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (err, _) => Center(child: Text('خطأ في تحميل السجلات: $err')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('لا توجد سجلات نشاط مسجلة حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

class _PremiumAuditLogCard extends StatelessWidget {
  final AuditLog log;
  const _PremiumAuditLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final eventType = log.eventType;
    final staffName = log.profile?['full_name'] ?? 'نظام آلي';

    // استخراج اسم المستثمر بأسلوب "بريميوم"
    final String? investorName = log.newValues?['المستثمر'] ??
        log.newValues?['investor'] ??
        log.newValues?['للمستثمر'] ??
        log.newValues?['investor_name'];

    Color eventColor;
    IconData eventIcon;

    if (eventType.contains('CREATED') || eventType.contains('DEPOSIT')) {
      eventColor = Colors.green;
      eventIcon = Icons.add_circle_outline_rounded;
    } else if (eventType.contains('UPDATED')) {
      eventColor = Colors.blue;
      eventIcon = Icons.edit_note_rounded;
    } else if (eventType.contains('DELETED') || eventType.contains('WITHDRAWAL')) {
      eventColor = Colors.red;
      eventIcon = Icons.delete_forever_rounded;
    } else {
      eventColor = AppColors.primaryNavy;
      eventIcon = Icons.info_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogDetails(context, log),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: eventColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(eventIcon, color: eventColor, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نوع العملية بلون مميز
                      Text(_formatEventType(eventType),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: eventColor)),

                      const SizedBox(height: 6),

                      // اسم المستثمر - يظهر بشكل بارز جداً
                      if (investorName != null)
                        Row(
                          children: [
                            const Icon(Icons.account_balance_rounded, size: 14, color: AppColors.primaryNavy),
                            const SizedBox(width: 6),
                            Text(investorName,
                                style: const TextStyle(fontSize: 15, color: AppColors.primaryNavy, fontWeight: FontWeight.w900)),
                          ],
                        )
                      else
                        const Text('عملية نظام عامة', style: TextStyle(fontSize: 12, color: Colors.grey)),

                      const SizedBox(height: 8),

                      // الموظف المنفذ
                      Row(
                        children: [
                          Icon(Icons.person_pin_rounded, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text('المنفذ: $staffName', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(intl.DateFormat('dd/MM/yyyy').format(log.createdAt),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(intl.DateFormat('HH:mm:ss').format(log.createdAt),
                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatEventType(String type) {
    return type
        .replaceAll('_', ' ')
        .replaceAll('CREATED', 'إضافة')
        .replaceAll('UPDATED', 'تحديث')
        .replaceAll('DELETED', 'حذف')
        .replaceAll('CONTRACT', 'عقد')
        .replaceAll('CUSTOMER', 'عميل')
        .replaceAll('VEHICLE', 'سيارة')
        .replaceAll('PAYMENT', 'عملية دفع')
        .replaceAll('INVESTOR DEPOSIT', 'إيداع مالي')
        .replaceAll('INVESTOR WITHDRAWAL', 'سحب مالي')
        .replaceAll('PROFIT DISTRIBUTION', 'توزيع أرباح');
  }

  void _showLogDetails(BuildContext context, AuditLog log) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics_outlined, color: AppColors.primaryNavy),
                    const SizedBox(width: 12),
                    const Text('تفاصيل العملية الرقابية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 32),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (log.oldValues != null && log.oldValues!.isNotEmpty) ...[
                          _buildValueBox('القيم السابقة', log.oldValues!),
                          const SizedBox(height: 20),
                        ],
                        _buildValueBox('بيانات الحركة الحالية', log.newValues ?? {}, isNew: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق السجل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueBox(String label, Map<String, dynamic> values, {bool isNew = false}) {
    // تصفية الحقول التقنية الزائدة إذا كان الاسم موجوداً
    final hasProperName = values.containsKey('المستثمر') || values.containsKey('investor') || values.containsKey('للمستثمر');

    final filteredEntries = values.entries.where((e) {
      if (e.key == 'investor_id' && hasProperName) return false;
      if (e.key == 'recorded_by_name' || e.key == 'performed_by') return false;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isNew ? Colors.green.withValues(alpha: 0.05) : AppColors.bgGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isNew ? Colors.green.withValues(alpha: 0.1) : Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: filteredEntries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_translateKey(e.key), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('${e.value}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: isNew ? Colors.green.shade900 : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace'
                        )
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  String _translateKey(String key) {
    switch (key) {
      case 'amount': return 'المبلغ';
      case 'المبلغ': return 'المبلغ';
      case 'description': return 'البيان';
      case 'البيان': return 'البيان';
      case 'investor': return 'المستثمر';
      case 'المستثمر': return 'المستثمر';
      case 'للمستثمر': return 'المستثمر';
      case 'investor_id': return 'رقم المستثمر التقني';
      case 'transaction_id': return 'رقم المعاملة';
      case 'status': return 'الحالة';
      case 'balance_after': return 'الرصيد بعد الحركة';
      default: return key;
    }
  }
}