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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('سجلات الرقابة والنشاط التقني', 
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: logsAsync.when(
        data: (logs) => logs.isEmpty
            ? const Center(child: Text('لا توجد سجلات'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, index) => _ClassicAuditLogTile(log: logs[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ في تحميل السجلات')),
      ),
    );
  }
}

class _ClassicAuditLogTile extends StatelessWidget {
  final AuditLog log;
  const _ClassicAuditLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final eventType = log.eventType;
    final fullName = log.profile?['full_name'] ?? 'نظام آلي';
    
    Color eventColor = Colors.blue;
    if (eventType.contains('CREATED')) eventColor = Colors.green;
    else if (eventType.contains('DELETED')) eventColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(Icons.history_toggle_off_rounded, color: eventColor, size: 18),
        title: Row(
          children: [
            Text(_formatType(eventType), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(2)),
              child: Text(log.tableName, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ],
        ),
        subtitle: Text('بواسطة: $fullName', style: const TextStyle(fontSize: 11)),
        trailing: Text(intl.DateFormat('HH:mm:ss').format(log.createdAt), 
          style: const TextStyle(fontSize: 11, color: Colors.grey)),
        onTap: () => _showDetails(context, log),
      ),
    );
  }

  String _formatType(String type) => type.replaceAll('_', ' ').toLowerCase();

  void _showDetails(BuildContext context, AuditLog log) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: const Text('تفاصيل العملية', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Text(log.newValues.toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          ],
        ),
      ),
    );
  }
}
