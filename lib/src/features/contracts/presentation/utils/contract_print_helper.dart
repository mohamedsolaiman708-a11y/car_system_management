import 'dart:typed_data';
import 'package:intl/intl.dart' as intl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/contract.dart';

class ContractPrintHelper {
  static Future<void> printContract(Contract contract) async {
    final pdfBytes = await generateContractPdf(contract);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'عقد_${contract.contractNo}.pdf',
    );
  }

  static Future<Uint8List> generateContractPdf(Contract contract) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoMedium();
    final fontBold = await PdfGoogleFonts.cairoBold();

    final isCash = contract.type == 'cash';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Theme(
              data: pw.ThemeData.withFont(base: font, bold: fontBold),
              child: isCash
                  ? _buildCashContractPdf(contract)
                  : _buildInstallmentContractPdf(contract),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- 1. عقد بيع نقدي (Cash Contract Layout) ---
  static pw.Widget _buildCashContractPdf(Contract contract) {
    final customer = contract.customer ?? {};
    final vehicle = contract.vehicle ?? {};
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final dateStr = contract.createdAt != null
        ? intl.DateFormat('dd / MM / yyyy').format(contract.createdAt!)
        : intl.DateFormat('dd / MM / yyyy').format(DateTime.now());

    final vehicleMake = vehicle['make'] ?? 'سبورتاج';
    final vehicleModel = vehicle['model']?.toString() ?? '2022';
    final vehiclePlate = vehicle['license_plate'] ?? 'MROEX22G5N1234567';
    final vehicleChassis = vehicle['chassis_number'] ?? '998877';
    final vehicleEngine = vehicle['engine_number'] ?? 'ط ي 3456';

    final customerName = customer['full_name'] ?? 'خالد علي سالم';
    final customerId = customer['national_id'] ?? '9876543210';
    final customerAddress = customer['address'] ?? 'الرياض - حي النخيل';
    final customerPhone = customer['phone'] ?? '05xxxxxxxx';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Header
        _buildHeader(
          title: 'عقد بيع نقدي',
          subTitle: '( بيع السيارة نقداً )',
          contractNo: contract.contractNo.isNotEmpty ? contract.contractNo : 'CASH-2026-000125',
          dateStr: dateStr,
          taxNo: '311281617800003',
        ),
        pw.SizedBox(height: 12),

        // Section 1: بيانات السيارة
        _buildSectionTitle('بيانات السيارة ( من المعرض )'),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('نوع السيارة', isHeader: true),
                _buildTableCell('الموديل', isHeader: true),
                _buildTableCell('رقم اللوحة', isHeader: true),
                _buildTableCell('رقم الهيكل', isHeader: true),
                _buildTableCell('رقم المحرك', isHeader: true),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell(vehicleMake),
                _buildTableCell(vehicleModel),
                _buildTableCell(vehiclePlate),
                _buildTableCell(vehicleChassis),
                _buildTableCell(vehicleEngine),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),

        // Section 2: بيانات الأطراف
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // الطرف الثاني ( المشتري )
            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue900, width: 1)),
                child: pw.Column(
                  children: [
                    pw.Container(
                      color: PdfColors.blue900,
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('الطرف الثاني ( المشتري )', style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    ),
                    _buildInfoRow('الاسم', customerName),
                    _buildInfoRow('رقم الهوية', customerId),
                    _buildInfoRow('العنوان', customerAddress),
                    _buildInfoRow('الجوال', customerPhone),
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            // الطرف الأول ( البائع )
            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue900, width: 1)),
                child: pw.Column(
                  children: [
                    pw.Container(
                      color: PdfColors.blue900,
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('الطرف الأول ( البائع )', style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    ),
                    _buildInfoRow('الاسم', 'معرض السامي للسيارات'),
                    _buildInfoRow('رقم السجل التجاري', '1010203040'),
                    _buildInfoRow('العنوان', 'الرياض - المملكة العربية السعودية'),
                    _buildInfoRow('الجوال', '05xxxxxxxx'),
                  ],
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),

        // Section 3: البنود
        _buildDeclarationItem('1', 'أقر أنا الطرف الأول ( البائع ) بأني بعت سيارتي الموضحة أوصافها أعلاه للطرف الثاني ( المشتري ) بثمن وقدره ( ${f.format(contract.totalContractValue)} ) ريال واستلمت كاملاً نقداً .'),
        _buildDeclarationItem('2', 'أقر أنا الطرف الثاني ( المشتري ) بأني اشتريت السيارة الموضحة أوصافها أعلاه بعد فحصها معاينة تامة واستلمتها بحالتها الراهنة .'),
        _buildDeclarationItem('3', 'يقر الطرفان بصحة البيانات الواردة في هذا العقد، وأنهما بكامل أهليتهما للتصرف، ولا يوجد أي إكراه أو ضغط في إبرام هذا العقد .'),
        pw.SizedBox(height: 10),

        // Section 4: تفاصيل العقد المالية
        _buildBlockHeader('تفاصيل العقد المالية'),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('إجمالي مبلغ البيع', isHeader: true),
                _buildTableCell('المبلغ المدفوع', isHeader: true),
                _buildTableCell('تاريخ الدفع', isHeader: true),
                _buildTableCell('طريقة الدفع', isHeader: true),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('${f.format(contract.totalContractValue)} ريال'),
                _buildTableCell('${f.format(contract.totalContractValue)} ريال'),
                _buildTableCell(dateStr),
                _buildTableCell('نقداً'),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),

        // Section 5: تفاصيل الخدمات الإجمالية
        _buildBlockHeader('تفاصيل الخدمات الإجمالية'),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // جدول الرسوم
            pw.Expanded(
              flex: 3,
              child: pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('م', isHeader: true),
                      _buildTableCell('الخدمة', isHeader: true),
                      _buildTableCell('الوصف', isHeader: true),
                      _buildTableCell('القيمة ( ريال )', isHeader: true),
                    ],
                  ),
                  _buildServiceRow('1', 'رسوم نقل الملكية', 'إصدار نقل الملكية باسم المشتري', contract.moroorFees > 0 ? contract.moroorFees : 250.00),
                  _buildServiceRow('2', 'التأمين', 'تأمين شامل سنة', contract.insuranceFees > 0 ? contract.insuranceFees : 900.00),
                  _buildServiceRow('3', 'الفحص الدوري', 'فحص شامل للسيارة', contract.inspectionFees > 0 ? contract.inspectionFees : 120.00),
                  _buildServiceRow('4', 'إصدار اللوحات', 'لوحات معدنية', contract.plateFees > 0 ? contract.plateFees : 500.00),
                  _buildServiceRow('5', 'المخالفات المرورية', 'سداد المخالفات المرورية', contract.trafficViolationsFees > 0 ? contract.trafficViolationsFees : 350.00),
                  _buildServiceRow('6', 'رسوم أخرى', 'طباعة مستندات', contract.otherFees > 0 ? contract.otherFees : 80.00),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell(''),
                      _buildTableCell('الإجمالي', isHeader: true),
                      _buildTableCell(''),
                      _buildTableCell('${f.format((contract.moroorFees > 0 ? contract.moroorFees : 250) + (contract.insuranceFees > 0 ? contract.insuranceFees : 900) + (contract.inspectionFees > 0 ? contract.inspectionFees : 120) + (contract.plateFees > 0 ? contract.plateFees : 500) + (contract.trafficViolationsFees > 0 ? contract.trafficViolationsFees : 350) + (contract.otherFees > 0 ? contract.otherFees : 80))} ريال', isHeader: true),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 8),
            // ملاحظات الملحق
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: 0.5)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ملاحظات :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    pw.SizedBox(height: 4),
                    pw.Text('1. هذا الملحق يوضح تفاصيل الخدمات المقدمة في هذا العقد.', style: const pw.TextStyle(fontSize: 7)),
                    pw.SizedBox(height: 4),
                    pw.Text('2. يعتبر هذا الملحق جزءاً لا يتجزأ من عقد البيع.', style: const pw.TextStyle(fontSize: 7)),
                  ],
                ),
              ),
            ),
          ],
        ),
        pw.Spacer(),

        // Section 6: التوقيعات والختم
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildSignatureBox('توقيع البائع'),
            _buildSignatureBox('توقيع المشتري'),
            _buildStampBox(),
          ],
        ),
      ],
    );
  }

  // --- 2. عقد بيع أقساط (Installment Contract Layout) ---
  static pw.Widget _buildInstallmentContractPdf(Contract contract) {
    final customer = contract.customer ?? {};
    final vehicle = contract.vehicle ?? {};
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final dateStr = contract.createdAt != null
        ? intl.DateFormat('dd / MM / yyyy').format(contract.createdAt!)
        : intl.DateFormat('dd / MM / yyyy').format(DateTime.now());

    final vehicles = contract.vehiclesList ?? [
      {
        'make': vehicle['make'] ?? 'تويوتا كامري',
        'model': vehicle['model']?.toString() ?? '2024',
        'plate': vehicle['license_plate'] ?? 'أ ب ج 1234',
        'chassis': vehicle['chassis_number'] ?? 'JTNBE40K503123456',
      }
    ];

    final customerName = customer['full_name'] ?? 'محمد أحمد عبدالله';
    final customerId = customer['national_id'] ?? '1098765432';
    final customerPhone = customer['phone'] ?? '05xxxxxxxx';
    final customerAddress = customer['address'] ?? 'الرياض - حي الياسمين';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Header
        _buildHeader(
          title: 'عقد بيع أقساط',
          subTitle: '',
          contractNo: contract.contractNo.isNotEmpty ? contract.contractNo : 'INS-2026-000123',
          dateStr: dateStr,
          taxNo: '310123456700003',
        ),
        pw.SizedBox(height: 8),

        // Section 1: بيانات السيارات
        _buildBlockHeader('1. بيانات السيارات'),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue900),
              children: [
                _buildTableCell('م', isHeader: true, textColor: PdfColors.white),
                _buildTableCell('نوع السيارة', isHeader: true, textColor: PdfColors.white),
                _buildTableCell('الموديل', isHeader: true, textColor: PdfColors.white),
                _buildTableCell('رقم اللوحة', isHeader: true, textColor: PdfColors.white),
                _buildTableCell('رقم الهيكل', isHeader: true, textColor: PdfColors.white),
              ],
            ),
            ...vehicles.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final v = entry.value;
              return pw.TableRow(
                children: [
                  _buildTableCell('$idx'),
                  _buildTableCell(v['make']?.toString() ?? '-'),
                  _buildTableCell(v['model']?.toString() ?? '-'),
                  _buildTableCell(v['plate']?.toString() ?? '-'),
                  _buildTableCell(v['chassis']?.toString() ?? '-'),
                ],
              );
            }).toList(),
          ],
        ),
        pw.SizedBox(height: 8),

        // Section 2: بيانات الأطراف
        _buildBlockHeader('2. بيانات الأطراف'),
        
        // الطرف الأول
        _buildPartyBlock('الطرف الأول (البائع)', 'شركة السامي للاستثمار', '1010203040', '05xxxxxxxx', 'الرياض - المملكة العربية السعودية'),
        pw.SizedBox(height: 4),

        // الطرف الثاني
        _buildPartyBlock('الطرف الثاني (المشتري)', customerName, customerId, customerPhone, customerAddress),
        pw.SizedBox(height: 4),

        // الكفيل الأول
        _buildPartyBlock(
          'الكفيل الأول',
          contract.guarantor1Name?.isNotEmpty == true ? contract.guarantor1Name! : 'أحمد علي محمد',
          contract.guarantor1Id?.isNotEmpty == true ? contract.guarantor1Id! : '1054321098',
          contract.guarantor1Phone?.isNotEmpty == true ? contract.guarantor1Phone! : '05xxxxxxxx',
          contract.guarantor1Address?.isNotEmpty == true ? contract.guarantor1Address! : 'الرياض - حي النرجس',
          work: contract.guarantor1Work?.isNotEmpty == true ? contract.guarantor1Work! : 'موظف',
        ),
        pw.SizedBox(height: 4),

        // الكفيل الثاني
        _buildPartyBlock(
          'الكفيل الثاني',
          contract.guarantor2Name?.isNotEmpty == true ? contract.guarantor2Name! : 'سعود خالد عبدالله',
          contract.guarantor2Id?.isNotEmpty == true ? contract.guarantor2Id! : '1076543210',
          contract.guarantor2Phone?.isNotEmpty == true ? contract.guarantor2Phone! : '05xxxxxxxx',
          contract.guarantor2Address?.isNotEmpty == true ? contract.guarantor2Address! : 'الرياض - حي المونسية',
          work: contract.guarantor2Work?.isNotEmpty == true ? contract.guarantor2Work! : 'موظف',
        ),
        pw.SizedBox(height: 8),

        // Section 3: بنود العقد
        _buildBlockHeader('3. بنود العقد'),
        _buildClauseItem('1', 'أقر أنا الطرف الأول (البائع) الموضح اسمي أعلاه بأني بعت السيارات الموضحة بياناتها في هذا العقد للطرف الثاني (المشتري) بيع أقساط بمبلغ إجمالي قدره ( ${f.format(contract.totalContractValue)} ) ريال.\nوقد استلمت عند توقيع هذا العقد مبلغاً وقدره ( ${f.format(contract.downPayment > 0 ? contract.downPayment : 50000)} ) ريال دفعة مقدمة.\nوبقي في ذمة الطرف الثاني مبلغ وقدره ( ${f.format(contract.totalContractValue - (contract.downPayment > 0 ? contract.downPayment : 50000))} ) ريال يلتزم بسداده على أقساط شهرية وتكون قيمة كل قسط ( ${f.format(contract.durationMonths > 0 ? (contract.totalContractValue - (contract.downPayment > 0 ? contract.downPayment : 50000)) / contract.durationMonths : 5000)} ) ريال.'),
        _buildClauseItem('2', 'أقر أنا الطرف الثاني (المشتري) باستلام السيارات الموضحة بياناتها بعد فحصها ومعاينتها معاينة تامة شرعاً.'),
        _buildClauseItem('3', 'أتعهد بسداد قيمة السيارة وأتعهد بسداد كافة الأقساط في مواعيد استحقاقها. وأتحمل غرامة تأخير قدرها ( 2% ) من قيمة القسط المتأخر عن كل شهر تأخير.'),
        _buildClauseItem('4', 'يتم الكفالة بالتضامن والتكافل في السداد مع الطرف الثاني بكامل المبلغ المتبقي وفوائده وغراماته، ويخضع هذا العقد لأحكام الشريعة الإسلامية.'),
        _buildClauseItem('5', 'حرر هذا العقد من نسختين أصليتين، استلم كل طرف نسخة للعمل بموجبها.'),
        _buildClauseItem('6', 'يعد أي تعديل أو إضافة أو شطب في هذا العقد باطلاً إلا بموجب اتفاق خطي موقع من جميع الأطراف.'),
        pw.Spacer(),

        // Section 4: التوقيعات الستة
        _buildBlockHeader('التوقيعات'),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildSigCell('الطرف الأول (البائع)'),
            _buildSigCell('الطرف الثاني (المشتري)'),
            _buildSigCell('الكفيل الأول'),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildSigCell('الكفيل الثاني'),
            _buildSigCell('شاهد أول'),
            _buildSigCell('شاهد ثانٍ'),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Center(child: _buildStampBox()),
      ],
    );
  }

  // --- Helper Layout Widgets ---
  static pw.Widget _buildHeader({
    required String title,
    required String subTitle,
    required String contractNo,
    required String dateStr,
    required String taxNo,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Logo & Title
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('ALSAMY AUTO', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.Text('معرض السامي للسيارات', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
            pw.Text('ترخيص مرور رقم ( 91 )', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ],
        ),
        // Title Center
        pw.Column(
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            if (subTitle.isNotEmpty) pw.Text(subTitle, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
        // Contract Info Box
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: 0.5)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('رقم العقد : $contractNo', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.Text('التاريخ : $dateStr', style: const pw.TextStyle(fontSize: 8)),
              pw.Text('الرقم الضريبي : $taxNo', style: const pw.TextStyle(fontSize: 7)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _buildBlockHeader(String title) {
    return pw.Container(
      width: double.infinity,
      color: PdfColors.blue900,
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      margin: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(title, style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor textColor = PdfColors.black}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8, fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal, color: textColor),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: pw.Row(
        children: [
          pw.Text('$label :', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 4),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 8))),
        ],
      ),
    );
  }

  static pw.Widget _buildDeclarationItem(String num, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 12, height: 12,
            alignment: pw.Alignment.center,
            decoration: const pw.BoxDecoration(color: PdfColors.blue900, shape: pw.BoxShape.circle),
            child: pw.Text(num, style: pw.TextStyle(color: PdfColors.white, fontSize: 7, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 8))),
        ],
      ),
    );
  }

  static pw.Widget _buildClauseItem(String num, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$num. ', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 7.5))),
        ],
      ),
    );
  }

  static pw.TableRow _buildServiceRow(String num, String service, String desc, double price) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return pw.TableRow(
      children: [
        _buildTableCell(num),
        _buildTableCell(service),
        _buildTableCell(desc),
        _buildTableCell(f.format(price)),
      ],
    );
  }

  static pw.Widget _buildPartyBlock(String role, String name, String id, String phone, String address, {String? work}) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: 0.5)),
      child: pw.Column(
        children: [
          pw.Container(
            color: PdfColors.grey300,
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: pw.Text(role, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Row(
              children: [
                pw.Expanded(child: pw.Text('الاسم: $name', style: const pw.TextStyle(fontSize: 7.5))),
                pw.Expanded(child: pw.Text('رقم الهوية: $id', style: const pw.TextStyle(fontSize: 7.5))),
                if (work != null) pw.Expanded(child: pw.Text('العمل: $work', style: const pw.TextStyle(fontSize: 7.5))),
                pw.Expanded(child: pw.Text('الجوال: $phone', style: const pw.TextStyle(fontSize: 7.5))),
                pw.Expanded(child: pw.Text('العنوان: $address', style: const pw.TextStyle(fontSize: 7.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureBox(String title) {
    return pw.Container(
      width: 140,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: 0.5)),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Text('الاسم : ........................', style: const pw.TextStyle(fontSize: 7)),
          pw.Text('التاريخ :    /    / 20', style: const pw.TextStyle(fontSize: 7)),
        ],
      ),
    );
  }

  static pw.Widget _buildSigCell(String title) {
    return pw.Container(
      width: 160,
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: 0.5)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Text('الاسم : ........................', style: const pw.TextStyle(fontSize: 7)),
          pw.Text('التوقيع : .......................', style: const pw.TextStyle(fontSize: 7)),
        ],
      ),
    );
  }

  static pw.Widget _buildStampBox() {
    return pw.Container(
      width: 110,
      height: 60,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue900, width: 1.5), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(30))),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text('ختم المعرض', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
          pw.Text('معرض السامي للسيارات', style: const pw.TextStyle(fontSize: 7, color: PdfColors.blue900)),
          pw.Text('ترخيص رقم ( 91 )', style: const pw.TextStyle(fontSize: 6, color: PdfColors.blue900)),
        ],
      ),
    );
  }
}
