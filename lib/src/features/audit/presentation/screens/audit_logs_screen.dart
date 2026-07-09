import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../domain/audit_log.dart';
import '../audit_controller.dart';
import '../../../authentication/presentation/staff_controller.dart';

class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  String? selectedTable;
  String? selectedEvent;
  String? selectedUser;

  final List<String> eventTypes = ['INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT'];
  final List<String> tableNames = [
    'profiles', 
    'financing_contracts', 
    'payments', 
    'installments', 
    'customers', 
    'investors'
  ];

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(auditLogControllerProvider);
    final staffAsync = ref.watch(staffListControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل الرقابة والتدقيق (Audit Logs)'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(auditLogControllerProvider.notifier).refresh(),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterPanel(staffAsync),
            const Divider(height: 1),
            Expanded(
              child: logsAsync.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return const Center(child: Text('لا توجد سجلات تطابق خيارات البحث'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: logs.length,
                    itemBuilder: (context, index) => _AuditLogTile(log: logs[index]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('حدث خطأ أثناء تحميل السجلات: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel(AsyncValue staffAsync) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              // فلتر الجدول
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: selectedTable,
                  decoration: const InputDecoration(labelText: 'الجدول', contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('كل الجداول')),
                    ...tableNames.map((t) => DropdownMenuItem(value: t, child: Text(t))),
                  ],
                  onChanged: (val) {
                    setState(() => selectedTable = val);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              // فلتر العملية
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: selectedEvent,
                  decoration: const InputDecoration(labelText: 'العملية', contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('كل العمليات')),
                    ...eventTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                  ],
                  onChanged: (val) {
                    setState(() => selectedEvent = val);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // فلتر المستخدم
          staffAsync.when(
            data: (staff) => DropdownButtonFormField<String?>(
              value: selectedUser,
              decoration: const InputDecoration(labelText: 'بواسطة الموظف', contentPadding: EdgeInsets.symmetric(horizontal: 8)),
              items: [
                const DropdownMenuItem(value: null, child: Text('كل الموظفين')),
                ...(staff as List).map((s) => DropdownMenuItem(value: s.id, child: Text(s.fullName))),
              ],
              onChanged: (val) {
                setState(() => selectedUser = val);
                _applyFilters();
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('تعذر تحميل قائمة الموظفين'),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    ref.read(auditLogControllerProvider.notifier).filterLogs(
      tableName: selectedTable,
      eventType: selectedEvent,
      profileId: selectedUser,
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  final AuditLog log;
  const _AuditLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final dateStr = intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(log.createdAt);
    final userName = log.profile?['full_name'] ?? 'نظام تلقائي';
    
    // تحديد لون العملية
    Color actionColor = Colors.blue;
    if (log.eventType.contains('INSERT')) actionColor = Colors.green;
    if (log.eventType.contains('DELETE')) actionColor = Colors.red;
    if (log.eventType.contains('UPDATE')) actionColor = Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: actionColor.withOpacity(0.1),
          child: Icon(_getIcon(log.eventType), color: actionColor, size: 20),
        ),
        title: Text(
          '${_translateAction(log.eventType)} في ${log.tableName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text('بواسطة: $userName | $dateStr', style: const TextStyle(fontSize: 12)),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('معرف السجل:', log.recordId),
                if (log.ipAddress != null) _buildInfoRow('عنوان IP:', log.ipAddress!),
                const Divider(),
                if (log.newValues != null && log.newValues!.isNotEmpty) ...[
                  const Text('البيانات الجديدة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                  _buildJsonViewer(log.newValues!),
                ],
                if (log.oldValues != null && log.oldValues!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('البيانات السابقة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                  _buildJsonViewer(log.oldValues!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 8),
          SelectableText(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildJsonViewer(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 11, fontFamily: 'monospace'),
              children: [
                TextSpan(text: '${e.key}: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                TextSpan(text: '${e.value}'),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  IconData _getIcon(String type) {
    if (type.contains('INSERT')) return Icons.add_box_outlined;
    if (type.contains('UPDATE')) return Icons.edit_note_rounded;
    if (type.contains('DELETE')) return Icons.delete_forever_outlined;
    return Icons.history;
  }

  String _translateAction(String action) {
    switch (action) {
      case 'INSERT': return 'إضافة سجل جديد';
      case 'UPDATE': return 'تعديل بيانات';
      case 'DELETE': return 'حذف سجل';
      default: return action;
    }
  }
}
