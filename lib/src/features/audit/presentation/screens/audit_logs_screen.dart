import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/arabic_translator.dart';
import '../../../../core/services/export_service.dart';
import '../audit_controller.dart';
import '../../domain/audit_log.dart';

class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  final TextEditingController _recordIdController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  String? _selectedTable;
  String? _selectedAction;

  final List<String> _tables = [
    'contracts',
    'payments',
    'investors',
    'customers',
    'profiles',
    'journal_entries',
    'vehicles',
  ];

  final List<String> _actions = [
    'INSERT',
    'UPDATE',
    'DELETE',
    'CONTRACT_CREATED',
    'PAYMENT_RECEIVED',
    'INVESTOR_DEPOSIT',
    'INVESTOR_WITHDRAWAL',
  ];

  @override
  void dispose() {
    _recordIdController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(auditLogControllerProvider.notifier).filterLogs(
          recordId: _recordIdController.text,
          startDate: _selectedDateRange?.start,
          endDate: _selectedDateRange?.end,
          tableName: _selectedTable,
          eventType: _selectedAction,
        );
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(auditLogControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          elevation: 0,
          toolbarHeight: 80,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مركز الرقابة والتدقيق',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('سجل كامل لكافة العمليات والتحركات الإدارية',
                  style: TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
          actions: [
            if (logsAsync.hasValue && logsAsync.value!.isNotEmpty)
              _buildExportButton(logsAsync.value!),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
              onPressed: () => ref.read(auditLogControllerProvider.notifier).refresh(),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Column(
          children: [
            _buildFilterPanel(),
            Expanded(
              child: logsAsync.when(
                data: (logs) => logs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          return _EliteAuditLogCard(log: logs[index]);
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
                // تم استبدال النص الأحمر بواجهة فخمة وودية تمنع الأكواد التقنية
                error: (err, _) => _buildFriendlyErrorState(err),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendlyErrorState(dynamic err) {
    final failure = Failure.fromException(err);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.errorRed.withOpacity(0.05), shape: BoxShape.circle),
              child: const Icon(Icons.security_update_warning_rounded, size: 64, color: AppColors.errorRed),
            ),
            const SizedBox(height: 24),
            Text(
              failure.message, 
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryNavy),
            ),
            const SizedBox(height: 8),
            const Text(
              'تعذر تحميل سجل النشاطات حالياً. يرجى التأكد من الاتصال والمحاولة مرة أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(auditLogControllerProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة محاولة المزامنة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(List<AuditLog> data) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
      ),
      tooltip: 'تصدير السجل',
      onSelected: (type) => _handleExport(type, data),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, color: Colors.red), SizedBox(width: 8), Text('تصدير PDF')])),
        const PopupMenuItem(value: 'excel', child: Row(children: [Icon(Icons.table_view, color: Colors.green), SizedBox(width: 8), Text('تصدير Excel')])),
      ],
    );
  }

  Future<void> _handleExport(String type, List<AuditLog> data) async {
    final exportService = ref.read(exportServiceProvider);
    final columns = ['التاريخ', 'نوع العملية', 'الجدول', 'رقم السجل', 'المنفذ'];
    
    final rows = data.map((log) => [
      intl.DateFormat('yyyy/MM/dd HH:mm').format(log.createdAt),
      ArabicTranslator.actionType(log.eventType),
      ArabicTranslator.actionType(log.tableName),
      log.recordId,
      log.profile?['full_name'] ?? 'نظام آلي',
    ]).toList();

    if (type == 'excel') {
      await exportService.exportToExcel(
        fileName: 'audit_logs_report',
        columns: columns,
        data: data.map((l) => {
          'date': intl.DateFormat('yyyy/MM/dd HH:mm').format(l.createdAt),
          'event': ArabicTranslator.actionType(l.eventType),
          'table': ArabicTranslator.actionType(l.tableName),
          'id': l.recordId,
          'user': l.profile?['full_name'] ?? 'نظام آلي',
        }).toList(),
        dataKeys: ['date', 'event', 'table', 'id', 'user'],
      );
    } else {
      await exportService.exportToPdf(title: 'تقرير سجل الرقابة والنشاط', columns: columns, rows: rows);
    }
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _recordIdController,
                  onSubmitted: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'البحث برقم السجل (ID)...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primaryNavy),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropdown(
                  hint: 'الجدول',
                  value: _selectedTable,
                  items: _tables,
                  onChanged: (val) {
                    setState(() => _selectedTable = val);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  hint: 'نوع العملية',
                  value: _selectedAction,
                  items: _actions,
                  onChanged: (val) {
                    setState(() => _selectedAction = val);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: AppColors.primaryNavy),
                        ),
                        child: Directionality(textDirection: TextDirection.rtl, child: child!),
                      ),
                    );
                    if (range != null) {
                      setState(() => _selectedDateRange = range);
                      _applyFilters();
                    }
                  },
                  icon: const Icon(Icons.date_range_rounded, size: 18),
                  label: Text(
                    _selectedDateRange == null
                        ? 'تاريخ العملية'
                        : '${intl.DateFormat('MM/dd').format(_selectedDateRange!.start)} - ${intl.DateFormat('MM/dd').format(_selectedDateRange!.end)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              if (_selectedDateRange != null || _selectedTable != null || _selectedAction != null || _recordIdController.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDateRange = null;
                      _selectedTable = null;
                      _selectedAction = null;
                      _recordIdController.clear();
                    });
                    _applyFilters();
                  },
                  icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(ArabicTranslator.actionType(e), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          const Text('لا توجد سجلات مطابقة لمعايير البحث', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}

class _EliteAuditLogCard extends StatelessWidget {
  final AuditLog log;
  const _EliteAuditLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final eventType = log.eventType;
    final staffName = log.profile?['full_name'] ?? 'نظام آلي';

    Color statusColor;
    IconData icon;

    if (eventType.contains('INSERT') || eventType.contains('CREATED') || eventType.contains('DEPOSIT')) {
      statusColor = const Color(0xFF4CAF50);
      icon = Icons.add_circle_rounded;
    } else if (eventType.contains('UPDATE') || eventType.contains('UPDATED')) {
      statusColor = const Color(0xFF2196F3);
      icon = Icons.edit_rounded;
    } else if (eventType.contains('DELETE') || eventType.contains('WITHDRAWAL')) {
      statusColor = const Color(0xFFF44336);
      icon = Icons.remove_circle_rounded;
    } else {
      statusColor = AppColors.primaryNavy;
      icon = Icons.info_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: () => _showLogDetails(context, log),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: statusColor, size: 24),
        ),
        title: Row(
          children: [
            Text(
              ArabicTranslator.actionType(eventType),
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primaryNavy),
            ),
            const Spacer(),
            Text(
              intl.DateFormat('HH:mm').format(log.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'الجدول: ${ArabicTranslator.actionType(log.tableName)} | المنفذ: $staffName',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'سجل: ${log.recordId.split("-").first}...',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontFamily: 'monospace'),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Colors.grey),
      ),
    );
  }

  void _showLogDetails(BuildContext context, AuditLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AuditDetailsSheet(log: log),
    );
  }
}

class _AuditDetailsSheet extends StatelessWidget {
  final AuditLog log;
  const _AuditDetailsSheet({required this.log});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.analytics_rounded, color: AppColors.primaryNavy, size: 28),
                  const SizedBox(width: 16),
                  const Text('تفاصيل السجل الرقابي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildDetailGroup('المعلومات الأساسية', [
                    _buildInfoRow('تاريخ العملية', intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(log.createdAt)),
                    _buildInfoRow('نوع الإجراء', ArabicTranslator.actionType(log.eventType)),
                    _buildInfoRow('الجدول المستهدف', ArabicTranslator.actionType(log.tableName)),
                    _buildInfoRow('المستخدم المسؤول', log.profile?['full_name'] ?? 'نظام آلي'),
                  ]),
                  const SizedBox(height: 24),
                  _buildDetailGroup('المعلومات التقنية', [
                    _buildInfoRow('رقم السجل (ID)', log.recordId),
                    if (log.ipAddress != null) _buildInfoRow('عنوان الـ IP', log.ipAddress!),
                  ]),
                  const SizedBox(height: 24),
                  const Text('البيانات المفصلة (Payload):', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildValuesSection(log.newValues ?? log.oldValues ?? {}),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentGold, fontSize: 12)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primaryNavy))),
        ],
      ),
    );
  }

  Widget _buildValuesSection(Map<String, dynamic> values) {
    if (values.isEmpty) return const Text('لا توجد بيانات تفصيلية مسجلة', style: TextStyle(fontSize: 13, color: Colors.grey));
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: values.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              const SizedBox(width: 24),
              Expanded(child: Text('${e.value}', textAlign: TextAlign.left, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primaryNavy, fontFamily: 'monospace'))),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
