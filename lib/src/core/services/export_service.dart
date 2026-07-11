import 'dart:io';
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_service.g.dart';

class ExportService {
  /// دالة مساعدة لجلب القيمة حتى لو كانت متداخلة (Nested)
  String _getDeepValue(dynamic item, String key) {
    if (item == null) return '-';
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
    await Printing.sharePdf(bytes: bytes, filename: '$fileName.xlsx');
  }

  /// تصدير البيانات إلى ملف PDF
  Future<void> exportToPdf({
    required String title,
    required List<String> columns,
    required List<List<dynamic>> rows,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoKufiArabicRegular();

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font),
        textDirection: pw.TextDirection.rtl,
        orientation: pw.PageOrientation.landscape,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: columns,
            data: rows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
            cellAlignment: pw.Alignment.centerRight,
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}

@Riverpod(keepAlive: true)
ExportService exportService(ExportServiceRef ref) {
  return ExportService();
}
