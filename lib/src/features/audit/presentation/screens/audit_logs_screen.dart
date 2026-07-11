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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('سجلات الرقابة والنشاط'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.invalidate(auditLogsListProvider),
            ),
          ],
        ),
        body: logsAsync.when(
          data: (logs) => logs.isEmpty
              ? const Center(child: Text('لا توجد سجلات نشاط حالياً'))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return _AuditLogCard(log: log);
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ في تحميل السجلات: $err')),
        ),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final AuditLog log; // تم تغيير النوع هنا من Map إلى AuditLog
  const _AuditLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final eventType = log.eventType;
    final createdAt = log.createdAt;
    final fullName = log.profile?['full_name'] ?? 'نظام آلي';
    
    Color eventColor;
    IconData eventIcon;

    if (eventType.contains('CREATED')) {
      eventColor = Colors.green;
      eventIcon = Icons.add_circle_outline_rounded;
    } else if (eventType.contains('UPDATED')) {
      eventColor = Colors.blue;
      eventIcon = Icons.edit_note_rounded;
    } else if (eventType.contains('DELETED')) {
      eventColor = Colors.red;
      eventIcon = Icons.delete_forever_rounded;
    } else {
      eventColor = AppColors.primaryNavy;
      eventIcon = Icons.info_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: eventColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(eventIcon, color: eventColor),
        ),
        title: Row(
          children: [
            Text(
              _formatEventType(eventType),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Spacer(),
            Text(
              intl.DateFormat('yyyy/MM/dd HH:mm').format(createdAt),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('القائم بالعملية: $fullName', style: const TextStyle(fontSize: 12, color: AppColors.primaryNavy)),
            const SizedBox(height: 4),
            Text('الجدول المتأثر: ${log.tableName}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        onTap: () => _showLogDetails(context, log),
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
        .replaceAll('PAYMENT', 'عملية دفع');
  }

  void _showLogDetails(BuildContext context, AuditLog log) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تفاصيل العملية'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailItem('القيم القديمة', log.oldValues?.toString() ?? 'لا يوجد'),
                const Divider(),
                _detailItem('القيم الجديدة', log.newValues?.toString() ?? 'لا يوجد'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
