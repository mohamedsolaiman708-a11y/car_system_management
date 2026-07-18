import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/services/export_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportDetailScreen extends ConsumerWidget {
  final String title;
  final List<String> columns;
  final List<Map<String, dynamic>> data;
  final List<String> dataKeys;

  const ReportDetailScreen({
    super.key,
    required this.title,
    required this.columns,
    required this.data,
    required this.dataKeys,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(title, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          actions: [
            _buildExportAction(context, ref),
            const SizedBox(width: 16),
          ],
        ),
        body: Column(
          children: [
            _buildPremiumHeader(f),
            Expanded(
              child: _buildMainTable(f),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(intl.NumberFormat f) {
    double total1 = 0;
    double total2 = 0;
    String label1 = 'إجمالي (أ)';
    String label2 = 'إجمالي (ب)';
    bool showStats = false;

    if (data.isNotEmpty) {
      if (title.contains('ميزان')) {
        total1 = data.fold(0, (sum, item) => sum + (item['total_debit'] as num? ?? 0));
        total2 = data.fold(0, (sum, item) => sum + (item['total_credit'] as num? ?? 0));
        label1 = 'إجمالي المدين';
        label2 = 'إجمالي الدائن';
        showStats = true;
      } else if (title.contains('التدفق')) {
        total1 = data.fold(0, (sum, item) => sum + (item['inflow'] as num? ?? 0));
        total2 = data.fold(0, (sum, item) => sum + (item['outflow'] as num? ?? 0));
        label1 = 'إجمالي الإيداعات';
        label2 = 'إجمالي السحوبات';
        showStats = true;
      } else if (title.contains('الأرباح')) {
        total1 = data.fold(0, (sum, item) => sum + (item['gross_profit'] as num? ?? 0));
        total2 = data.fold(0, (sum, item) => sum + (item['company_net_profit'] as num? ?? 0));
        label1 = 'إجمالي الربح';
        label2 = 'صافي الشركة';
        showStats = true;
      }
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: showStats 
        ? Row(
            children: [
              _buildStatItem(label1, f.format(total1), AppColors.accentGold),
              const SizedBox(width: 48),
              _buildStatItem(label2, f.format(total2), Colors.white),
            ],
          )
        : Text('كشف تفصيلي بالعمليات المالية والحسابات', 
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
        const SizedBox(height: 6),
        Text('$value ر.س', 
          style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildMainTable(intl.NumberFormat f) {
    if (data.isEmpty) return _buildEmptyState();

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 64,
              dataRowMinHeight: 60,
              dataRowMaxHeight: 60,
              horizontalMargin: 24,
              columnSpacing: 40,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              dividerThickness: 0.5,
              columns: columns.map((col) => DataColumn(
                label: Text(col, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 14)),
              )).toList(),
              rows: data.map((row) => DataRow(
                cells: dataKeys.map((key) {
                  final value = _getNestedValue(row, key);
                  final isAmount = value is num;
                  return DataCell(
                    Text(
                      _formatValue(value, f, key),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isAmount ? FontWeight.w700 : FontWeight.normal,
                        color: _getCellColor(value, key),
                        fontFamily: isAmount ? 'monospace' : null,
                      ),
                    ),
                  );
                }).toList(),
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCellColor(dynamic value, String key) {
    if (value is! num) return AppColors.primaryNavy;
    if (value < 0) return Colors.redAccent;
    if (key.contains('profit') || key.contains('inflow') || key.contains('debit')) return AppColors.successGreen;
    return AppColors.primaryNavy;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          const Text('لا توجد بيانات متاحة لهذا التقرير حالياً', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildExportAction(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.ios_share_rounded, color: Colors.white, size: 20),
      ),
      onSelected: (val) => _handleExport(context, ref, val),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, color: Colors.red), SizedBox(width: 12), Text('تصدير PDF')])),
        const PopupMenuItem(value: 'excel', child: Row(children: [Icon(Icons.table_chart, color: Colors.green), SizedBox(width: 12), Text('تصدير Excel')])),
      ],
    );
  }

  dynamic _getNestedValue(Map<String, dynamic> row, String path) {
    if (!path.contains('.')) return row[path];
    final parts = path.split('.');
    dynamic current = row;
    for (var part in parts) {
      if (current is Map) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  String _formatValue(dynamic value, intl.NumberFormat f, String key) {
    if (value == null) return '-';
    if (value is num) return f.format(value);
    if (key.contains('date')) {
      try { return intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(value.toString())); } catch (_) {}
    }
    return value.toString();
  }

  Future<void> _handleExport(BuildContext context, WidgetRef ref, String format) async {
    final exportService = ref.read(exportServiceProvider);
    if (format == 'pdf') {
      final rows = data.map((row) => dataKeys.map((key) => _formatValue(_getNestedValue(row, key), intl.NumberFormat(), key)).toList()).toList();
      await exportService.exportToPdf(title: title, columns: columns, rows: rows);
    } else {
      await exportService.exportToExcel(fileName: title, columns: columns, data: data, dataKeys: dataKeys);
    }
  }
}
