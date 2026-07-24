import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/pdf_service.dart';
import '../../features/settings/presentation/settings_controller.dart';

part 'export_service.g.dart';

class ExportService {
  final Ref _ref;
  ExportService(this._ref);

  /// دالة مساعدة لجلب القيمة حتى لو كانت متداخلة (Nested)
  String _getDeepValue(dynamic item, String key) {
    if (item == null) return '-';
    if (item is! Map) return item.toString();
    if (!key.contains('.')) return item[key]?.toString() ?? '-';

    final parts = key.split('.');
    dynamic current = item;
    for (var part in parts) {
      if (current is Map) {
        current = current[part];
      } else {
        return '-';
      }
    }
    return current?.toString() ?? '-';
  }

  /// تصدير البيانات إلى ملف CSV
  Future<void> exportToCsv({
    required String fileName,
    required List<String> columns,
    required List<List<dynamic>> rows,
  }) async {
    String csvData = columns.map((h) => '"$h"').join(',') + '\n';
    
    for (var row in rows) {
      csvData += row.map((e) {
        final value = e?.toString() ?? '';
        return '"${value.replaceAll('"', '""')}"';
      }).join(',') + '\n';
    }

    if (kIsWeb) {
      await Printing.sharePdf(bytes: Uint8List.fromList(csvData.codeUnits), filename: '$fileName.csv');
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.csv');
      await file.writeAsString(csvData);
      await Share.shareXFiles([XFile(file.path)], subject: 'تصدير $fileName');
    }
  }

  /// تصدير البيانات إلى ملف Excel
  Future<void> exportToExcel({
    required String fileName,
    required List<String> columns,
    required List<Map<String, dynamic>> data,
    required List<String> dataKeys,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // إضافة العناوين
    for (var i = 0; i < columns.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(columns[i]);
    }

    // إضافة البيانات
    for (var r = 0; r < data.length; r++) {
      for (var c = 0; c < dataKeys.length; c++) {
        final val = _getDeepValue(data[r], dataKeys[c]);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1)).value = TextCellValue(val);
      }
    }

    final fileBytes = excel.save();
    if (fileBytes == null) return;

    final bytes = Uint8List.fromList(fileBytes);
    
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: '$fileName.xlsx');
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.xlsx');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], subject: 'تصدير $fileName');
    }
  }

  /// تصدير البيانات إلى ملف PDF احترافي (RTL Support) مع هوية الشركة
  Future<void> exportToPdf({
    required String title,
    required List<String> columns,
    required List<List<dynamic>> rows,
  }) async {
    // جلب بيانات الشركة من الـ Provider
    final companySettingsAsync = await _ref.read(companySettingsProvider.future);
    final companyInfo = {
      'companyName': companySettingsAsync.companyName,
      'tax_number': companySettingsAsync.taxNumber,
      'phone': companySettingsAsync.phone,
    };

    final pdfBytes = await PdfService.generateTablePdf(
      title: title,
      headers: columns,
      rows: rows,
      companyInfo: companyInfo,
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdfBytes,
      name: '$title.pdf',
    );
  }
}

@Riverpod(keepAlive: true)
ExportService exportService(ExportServiceRef ref) {
  return ExportService(ref);
}
