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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          _buildExportButton(context, ref),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: data.isEmpty
          ? const Center(child: Text('لا توجد بيانات لعرضها في هذا التقرير'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 45,
                    dataRowHeight: 45,
                    headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                    columns: columns.map((col) => DataColumn(
                      label: Text(col, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    )).toList(),
                    rows: data.map((row) => DataRow(
                      cells: dataKeys.map((key) {
                        final value = _getNestedValue(row, key);
                        return DataCell(
                          Text(_formatValue(value, f), style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                    )).toList(),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildExportButton(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.print_rounded, color: AppColors.primaryNavy, size: 20),
      tooltip: 'تصدير وطباعة',
      onSelected: (val) => _handleExport(context, ref, val),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'pdf', child: Text('تصدير بصيغة PDF')),
        const PopupMenuItem(value: 'excel', child: Text('تصدير بصيغة Excel')),
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

  String _formatValue(dynamic value, intl.NumberFormat f) {
    if (value == null) return '-';
    if (value is num) return f.format(value);
    return value.toString();
  }

  Future<void> _handleExport(BuildContext context, WidgetRef ref, String format) async {
    final exportService = ref.read(exportServiceProvider);
    if (format == 'pdf') {
      final rows = data.map((row) => dataKeys.map((key) => _formatValue(_getNestedValue(row, key), intl.NumberFormat())).toList()).toList();
      await exportService.exportToPdf(title: title, columns: columns, rows: rows);
    } else {
      await exportService.exportToExcel(fileName: title, columns: columns, data: data, dataKeys: dataKeys);
    }
  }
}
