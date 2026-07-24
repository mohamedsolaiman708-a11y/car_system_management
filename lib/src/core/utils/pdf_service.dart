import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart' as intl;
import 'tafqit_helper.dart';

class PdfService {
  /// توليد ملف PDF يحتوي على جدول بيانات (للتصدير العام) مع ترويسة الشركة
  static Future<Uint8List> generateTablePdf({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
    Map<String, dynamic>? companyInfo,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (context) => _buildReportHeader(companyInfo, title, fontBold),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerLeft,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text('صفحة ${context.pageNumber} من ${context.pagesCount}', style: const pw.TextStyle(fontSize: 9)),
        ),
        build: (context) => [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.TableHelper.fromTextArray(
              headers: headers.reversed.toList(),
              data: rows.map((row) => row.reversed.toList()).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellAlignment: pw.Alignment.center,
              cellStyle: const pw.TextStyle(fontSize: 9),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildReportHeader(Map? company, String title, pw.Font boldFont) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blueGrey, width: 2))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(company?['companyName'] ?? 'نظام إدارة السيارات', style: pw.TextStyle(font: boldFont, fontSize: 16)),
              pw.Text('الرقم الضريبي: ${company?['tax_number'] ?? '-'}', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('الهاتف: ${company?['phone'] ?? '-'}', style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.blueGrey900)),
              pw.Text('تاريخ التقرير: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  // --- السندات والعقود (تستخدم للنظام المالي المباشر) ---

  static Future<Uint8List> generateReceiptVoucher({
    required Map<String, dynamic> companyInfo,
    required String voucherNo,
    required String customerName,
    required double amount,
    required String paymentMethod,
    required String reason,
    String? checkNo,
    String? bankName,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.amiriRegular();
    final fontBold = await PdfGoogleFonts.amiriBold();
    final dateStr = intl.DateFormat('yyyy/MM/dd').format(DateTime.now());
    final amountWords = TafqitHelper.convert(amount);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5.landscape,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
              child: pw.Column(
                children: [
                  _buildHeader(companyInfo, voucherNo, dateStr, "سند قبض"),
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 10),
                  _buildBody(customerName, amount, amountWords, reason),
                  pw.SizedBox(height: 10),
                  _buildPaymentMethod(paymentMethod, checkNo, bankName),
                  pw.Spacer(),
                  _buildSignatures(),
                ],
              ),
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  static pw.Widget _buildHeader(Map company, String no, String date, String title) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(company['companyName'] ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('الرقم الضريبي: ${company['tax_number'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
        ]),
        pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text('الرقم: $no', style: pw.TextStyle(color: PdfColors.red900, fontWeight: pw.FontWeight.bold)),
          pw.Text('التاريخ: $date', style: const pw.TextStyle(fontSize: 8)),
        ]),
      ],
    );
  }

  static pw.Widget _buildBody(String name, double amt, String words, String reason) {
    return pw.Column(children: [
      _row("استلمنا من السيد/ة: ", name),
      _row("مبلغاً وقدره: ", words, trailing: "${amt.toStringAsFixed(2)} ر.س"),
      _row("وذلك مقابل: ", reason),
    ]);
  }

  static pw.Widget _row(String label, String val, {String? trailing}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Expanded(child: pw.Container(decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))), child: pw.Text(val))),
        if (trailing != null) pw.Container(padding: const pw.EdgeInsets.all(4), color: PdfColors.grey200, child: pw.Text(trailing, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      ]),
    );
  }

  static pw.Widget _buildPaymentMethod(String method, String? chk, String? bank) {
    return pw.Row(children: [
      pw.Text('طريقة السداد: '),
      pw.Text(method == 'cash' ? '[X] نقداً ' : '[ ] نقداً '),
      pw.Text(method == 'check' ? '[X] شيك رقم: ${chk ?? ""} بنك: ${bank ?? ""}' : '[ ] شيك '),
    ]);
  }

  static pw.Widget _buildSignatures() {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Column(children: [pw.Text('ختم المعرض'), pw.SizedBox(height: 30), pw.Text('................')]),
      pw.Column(children: [pw.Text('المحاسب'), pw.SizedBox(height: 30), pw.Text('................')]),
      pw.Column(children: [pw.Text('المستلم/المشتري'), pw.SizedBox(height: 30), pw.Text('................')]),
    ]);
  }
}
