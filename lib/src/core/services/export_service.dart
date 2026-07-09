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
  /// تصدير البيانات إلى ملف Excel
  Future<void> exportToExcel({
    required String fileName,
    required List<String> columns,
    required List<List<dynamic>> rows,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // إضافة العناوين
    for (var i = 0; i < columns.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(columns[i]);
    }

    // إضافة البيانات
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1)).value = TextCellValue(rows[r][c].toString());
      }
    }

    final fileBytes = excel.save();
    if (fileBytes == null) return;

    final bytes = Uint8List.fromList(fileBytes);

    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: '$fileName.xlsx');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.xlsx');
      await file.writeAsBytes(bytes);
      await Printing.sharePdf(bytes: bytes, filename: '$fileName.xlsx');
    }
  }

  /// تصدير البيانات إلى ملف PDF
  Future<void> exportToPdf({
    required String title,
    required List<String> columns,
    required List<List<dynamic>> rows,
  }) async {
    final pdf = pw.Document();
    
    // تحميل خط يدعم العربية
    final font = await PdfGoogleFonts.notoKufiArabicRegular();

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font),
        textDirection: pw.TextDirection.rtl,
        orientation: pw.PageOrientation.landscape,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: columns,
            data: rows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerRight,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  /// تصدير البيانات إلى ملف CSV
  Future<void> exportToCsv({
    required String fileName,
    required List<String> columns,
    required List<List<dynamic>> rows,
  }) async {
    String csvData = columns.join(',') + '\n';
    for (var row in rows) {
      csvData += row.map((e) => '"$e"').join(',') + '\n';
    }

    final bytes = utf8.encode(csvData);

    if (kIsWeb) {
       await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: '$fileName.csv');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.csv');
      await file.writeAsBytes(bytes);
      await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: '$fileName.csv');
    }
  }
}

@Riverpod(keepAlive: true)
ExportService exportService(ExportServiceRef ref) {
  return ExportService();
}
