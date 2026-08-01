import 'dart:typed_data';
import 'package:intl/intl.dart' as intl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ألوان ثابتة
const _navy = PdfColor.fromInt(0xFF0D1B4B);
const _gold = PdfColor.fromInt(0xFFB8960C);
const _lightBg = PdfColor.fromInt(0xFFF5F5F5);
const _cardBg = PdfColor.fromInt(0xFFFAFAFA);

class VoucherPrintHelper {
  // -----------------------------------------------------------
  // سند القبض (Receipt Voucher)
  // -----------------------------------------------------------
  static Future<void> printReceiptVoucher({
    required String receivedFrom,
    required double amount,
    required String amountText,
    required String purpose,
    required bool isCash,
    String? chequeNo,
    String? drawnOn,
    DateTime? date,
    String? voucherNumber,
  }) async {
    final pdfBytes = await _buildVoucherPdf(
      type: 'receipt',
      partyName: receivedFrom,
      amount: amount,
      amountText: amountText,
      purpose: purpose,
      isCash: isCash,
      chequeNo: chequeNo,
      drawnOn: drawnOn,
      date: date ?? DateTime.now(),
      voucherNumber: voucherNumber,
    );
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
      name: 'سند_قبض_${voucherNumber ?? intl.DateFormat('yyyyMMdd').format(date ?? DateTime.now())}.pdf',
    );
  }

  // -----------------------------------------------------------
  // سند الصرف (Payment Voucher)
  // -----------------------------------------------------------
  static Future<void> printPaymentVoucher({
    required String paidTo,
    required double amount,
    required String amountText,
    required String purpose,
    required bool isCash,
    String? chequeNo,
    String? drawnOn,
    DateTime? date,
    String? voucherNumber,
  }) async {
    final pdfBytes = await _buildVoucherPdf(
      type: 'payment',
      partyName: paidTo,
      amount: amount,
      amountText: amountText,
      purpose: purpose,
      isCash: isCash,
      chequeNo: chequeNo,
      drawnOn: drawnOn,
      date: date ?? DateTime.now(),
      voucherNumber: voucherNumber,
    );
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
      name: 'سند_صرف_${voucherNumber ?? intl.DateFormat('yyyyMMdd').format(date ?? DateTime.now())}.pdf',
    );
  }

  // -----------------------------------------------------------
  // مولّد PDF مشترك
  // -----------------------------------------------------------
  static Future<Uint8List> _buildVoucherPdf({
    required String type,
    required String partyName,
    required double amount,
    required String amountText,
    required String purpose,
    required bool isCash,
    String? chequeNo,
    String? drawnOn,
    required DateTime date,
    String? voucherNumber,
  }) async {
    final font = await PdfGoogleFonts.cairoMedium();
    final fontBold = await PdfGoogleFonts.cairoBold();
    final pdf = pw.Document();

    final isReceipt = type == 'receipt';
    final title = isReceipt ? 'سند قبض' : 'سند صرف';
    final titleEn = isReceipt ? 'RECEIPT VOUCHER' : 'PAYMENT VOUCHER';
    final fromLabel = isReceipt ? 'استلمنا من' : 'صرفنا لـ';
    final fromLabelEn = isReceipt ? 'Paid To. From' : 'Paid To';
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final dateStr = intl.DateFormat('dd / MM / yyyy').format(date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Theme(
            data: pw.ThemeData.withFont(base: font, bold: fontBold),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // ── Header ──────────────────────────────────────────
                pw.Container(
                  color: _navy,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // شعار المعرض
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('معرض السامي للسيارات',
                              style: pw.TextStyle(
                                  color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('al Sami For Auto Show',
                              style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 10)),
                          pw.SizedBox(height: 4),
                          pw.Text('الرقم الضريبي: ٣١٩٢٩٣٥٨٥٠٠٥٠٩',
                              style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 8)),
                          pw.Text('ترخيص رقم: ٩١٠',
                              style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 8)),
                        ],
                      ),
                      // العنوان ورقم السند
                      pw.Column(
                        children: [
                          pw.Text(title,
                              style: pw.TextStyle(
                                  color: PdfColors.white, fontSize: 28, fontWeight: pw.FontWeight.bold)),
                          pw.Container(
                            margin: const pw.EdgeInsets.only(top: 4),
                            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: const pw.BoxDecoration(color: _gold),
                            child: pw.Text(titleEn,
                                style: pw.TextStyle(
                                    color: PdfColors.white, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          ),
                          if (voucherNumber != null && voucherNumber.isNotEmpty)
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 4),
                              child: pw.Text('رقم السند: $voucherNumber',
                                  style: pw.TextStyle(color: PdfColors.grey300, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                            ),
                        ],
                      ),
                      // التاريخ والمبلغ
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('الموافق : $dateStr',
                              style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                          pw.SizedBox(height: 4),
                          pw.Text('التاريخ : $dateStr',
                              style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                          pw.SizedBox(height: 12),
                          pw.Row(
                            children: [
                              _amountBox('ريال S.R.', f.format(amount)),
                              pw.SizedBox(width: 8),
                              _amountBox('هـ H', ''),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── شريط طريقة السداد ────────────────────────────
                pw.Container(
                  color: _lightBg,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  child: pw.Row(
                    children: [
                      pw.Text('طريقة السداد',
                          style: pw.TextStyle(
                              color: _navy, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 24),
                      _checkBox(isCash, 'نقداً'),
                      pw.SizedBox(width: 24),
                      _checkBox(!isCash, 'شيك'),
                    ],
                  ),
                ),

                // ── الجسم الرئيسي ──────────────────────────────────
                pw.Expanded(
                  child: pw.Container(
                    color: PdfColors.white,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        _infoRow(fromLabelEn, fromLabel, partyName),
                        pw.SizedBox(height: 16),
                        _infoRow('The Sum Of', 'مبلغاً وقدره', '${f.format(amount)} ريال سعودي'),
                        pw.SizedBox(height: 8),
                        // المبلغ كتابةً
                        pw.Container(
                          margin: const pw.EdgeInsets.only(right: 106),
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: _cardBg,
                            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text('( $amountText )',
                              style: pw.TextStyle(fontSize: 9, color: _navy, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.SizedBox(height: 16),
                        _infoRow('This Compares', 'وذلك مقابل', purpose),
                        pw.SizedBox(height: 16),

                        // معلومات الشيك
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                            color: _cardBg,
                          ),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              _checkBox(isCash, 'Cash نقداً'),
                              pw.SizedBox(width: 8),
                              _checkBox(!isCash, 'شيك'),
                              pw.SizedBox(width: 12),
                              pw.Text('شيك رقم : ${chequeNo ?? '......................'}',
                                  style: const pw.TextStyle(fontSize: 8)),
                              pw.SizedBox(width: 12),
                              pw.Text('التاريخ : $dateStr',
                                  style: const pw.TextStyle(fontSize: 8)),
                              pw.SizedBox(width: 12),
                              pw.Text('مسحوب على : ${drawnOn ?? '................'}',
                                  style: const pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        pw.Spacer(),

                        // التوقيعات
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                          children: [
                            _sigBox('توقيع المستلم', 'Receiver Signature'),
                            _sigBox('توقيع المحاسب', 'Accountant Signature'),
                            _sigBox('الختم', 'Stamp'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer ──────────────────────────────────────────
                pw.Container(
                  color: _navy,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _footerItem('+966 14 6620909', 'فاكس: +966 14 6693888'),
                      _footerItem('+966 14 6693999', 'جوال: +966 558288787'),
                      pw.Text('منطقة الحدود الشمالية - عرعر',
                          style: const pw.TextStyle(color: PdfColors.white, fontSize: 8)),
                      pw.Text('alsamy.car@gmail.com\ninfo@alsamy.com.sa',
                          style: const pw.TextStyle(color: PdfColors.white, fontSize: 8)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _amountBox(String label, String value) {
    return pw.Container(
      width: 80,
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: const pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
          pw.SizedBox(height: 2),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _checkBox(bool checked, String label) {
    return pw.Row(
      children: [
        pw.Container(
          width: 12,
          height: 12,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _navy, width: 1),
          ),
          child: checked
              ? pw.Center(
              child: pw.Text('✓',
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold, color: _navy)))
              : null,
        ),
        pw.SizedBox(width: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }

  static pw.Widget _infoRow(String labelEn, String labelAr, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 110,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(labelAr,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: _navy)),
              pw.Text(labelEn, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
            ],
          ),
        ),
        pw.Text(' : ', style: const pw.TextStyle(fontSize: 9)),
        pw.Expanded(
          child: pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5))),
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
          ),
        ),
      ],
    );
  }

  static pw.Widget _sigBox(String titleAr, String titleEn) {
    return pw.Column(
      children: [
        pw.Container(
          width: 110,
          height: 44,
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300, width: 0.5)),
        ),
        pw.SizedBox(height: 4),
        pw.Text(titleAr,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _navy)),
        pw.Text(titleEn, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
      ],
    );
  }

  static pw.Widget _footerItem(String line1, String line2) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(line1, style: const pw.TextStyle(color: PdfColors.white, fontSize: 8)),
        pw.Text(line2, style: const pw.TextStyle(color: PdfColors.white, fontSize: 8)),
      ],
    );
  }
}
