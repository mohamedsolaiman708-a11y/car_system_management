import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';
import 'pdf_service.dart';

class ExportHelper {
  /// تصدير البيانات إلى ملف CSV
  static Future<void> exportToCsv({
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    // بناء محتوى الـ CSV مع معالجة الفواصل والهروب من الرموز
    String csvData = headers.map((h) => '"$h"').join(',') + '\n';

    for (var row in rows) {
      csvData += row.map((e) {
        final value = e?.toString() ?? '';
        return '"${value.replaceAll('"', '""')}"';
      }).join(',') + '\n';
    }

    if (kIsWeb) {
      // للويب، نستخدم Printing لتقديم خيار الحفظ أو الطباعة (كمحاكاة للتصدير)
      await Printing.sharePdf(bytes: Uint8List.fromList(csvData.codeUnits), filename: '$fileName.csv');
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.csv');
      await file.writeAsString(csvData);
      await Share.shareXFiles([XFile(file.path)], subject: 'تصدير $fileName');
    }
  }

  /// تصدير البيانات إلى ملف Excel
  static Future<void> exportToExcel({
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // إضافة العناوين
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // إضافة البيانات
    for (var row in rows) {
      sheet.appendRow(row.map((e) => TextCellValue(e?.toString() ?? '')).toList());
    }

    final bytes = excel.save();
    if (bytes == null) return;

    final uint8Bytes = Uint8List.fromList(bytes);

    if (kIsWeb) {
      await Printing.sharePdf(bytes: uint8Bytes, filename: '$fileName.xlsx');
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.xlsx');
      await file.writeAsBytes(uint8Bytes);
      await Share.shareXFiles([XFile(file.path)], subject: 'تصدير $fileName');
    }
  }

  /// تصدير البيانات إلى ملف PDF (على شكل جدول)
  static Future<void> exportToPdfTable({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final pdfBytes = await PdfService.generateTablePdf(
      title: title,
      headers: headers,
      rows: rows,
    );

    await Printing.layoutPdf(onLayout: (format) => pdfBytes);
  }
}
