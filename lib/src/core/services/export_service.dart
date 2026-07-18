import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
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

  /// تصدير البيانات إلى ملف PDF احترافي يليق بالعملاء (RTL Corrected)
  Future<void> exportToPdf({
    required String title,
    required List<String> columns,
    required List<List<dynamic>> rows,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    // عكس القوائم لضمان ظهور "الاسم" في اليمين و "البريد" في اليسار
    // لأن مكتبة PDF ترتب الـ List من 0 (يسار) إلى N (يمين)
    final reversedColumns = columns.reversed.toList();
    final reversedRows = rows.map((row) => row.reversed.toList()).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(bottom: 15),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blueGrey900, width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 24, color: PdfColors.blueGrey900)),
                  pw.Text('نظام إدارة السيارات المتكامل', style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey600)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('تاريخ التصدير: ${DateTime.now().toString().split(' ')[0]}', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('تقرير CRM المعتمد', style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey600)),
                ],
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerLeft,
          padding: const pw.EdgeInsets.only(top: 15),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('طُبع بواسطة نظام الإدارة الذكي', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              pw.Text('صفحة ${context.pageNumber} من ${context.pagesCount}', style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: reversedColumns,
            data: reversedRows,
            headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white, fontSize: 11),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
            cellAlignment: pw.Alignment.centerRight,
            headerAlignment: pw.Alignment.centerRight,
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerHeight: 35,
            cellPadding: const pw.EdgeInsets.all(8),
            // تعديل النسب لتتوافق مع الترتيب المعكوس
            columnWidths: {
              0: const pw.FlexColumnWidth(3.5), // البريد الإلكتروني (أصبح الأول من اليسار)
              1: const pw.FlexColumnWidth(1.5), // مستوى المخاطر
              2: const pw.FlexColumnWidth(2),   // رقم الهاتف
              3: const pw.FlexColumnWidth(2),   // رقم الهوية
              4: const pw.FlexColumnWidth(3),   // الاسم الكامل (أصبح الأخير من اليسار = الأول من اليمين)
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: '$title.pdf',
    );
  }
}

@Riverpod(keepAlive: true)
ExportService exportService(ExportServiceRef ref) {
  return ExportService();
}
