import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/services/export_service.dart';
import '../../../../core/utils/app_theme.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              tooltip: 'تصدير PDF',
              onPressed: () => _exportPdf(ref),
            ),
            IconButton(
              icon: const Icon(Icons.table_view_rounded), // أيقونة إكسل احترافية
              tooltip: 'تصدير Excel',
              onPressed: () => _exportExcel(ref),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: data.isEmpty
            ? const Center(child: Text('لا توجد بيانات متوفرة لهذا التقرير حالياً'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.primaryNavy.withOpacity(0.05)),
                        columns: columns.map((c) => DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                        rows: data.map((item) {
                          return DataRow(
                            cells: dataKeys.map((key) {
                              final val = _getProperty(item, key);
                              return DataCell(Text(val.toString()));
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  dynamic _getProperty(Map<String, dynamic> item, String key) {
    // دعم الوصول للخصائص المتداخلة بذكاء
    if (item == null) return '-';
    if (!key.contains('.')) return item[key] ?? '-';

    final parts = key.split('.');
    dynamic current = item;
    for (var part in parts) {
      if (current is Map) {
        current = current[part];
      } else {
        return '-';
      }
    }
    return current ?? '-';
  }

  void _exportPdf(WidgetRef ref) {
    ref.read(exportServiceProvider).exportToPdf(
      title: title,
      columns: columns,
      rows: data.map((item) => dataKeys.map((key) => _getProperty(item, key).toString()).toList()).toList(),
    );
  }

  void _exportExcel(WidgetRef ref) {
    // تم التحديث ليتوافق مع خدمة التصدير الجديدة التي تعالج الـ Nested Data تلقائياً
    ref.read(exportServiceProvider).exportToExcel(
      fileName: title,
      columns: columns,
      data: data,
      dataKeys: dataKeys,
    );
  }
}
