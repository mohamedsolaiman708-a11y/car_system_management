import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/utils/app_theme.dart';
import '../../../core/utils/snack_bar_helper.dart';
import '../../investors/data/sources/supabase_investor_data_source.dart';
import '../../investors/presentation/investor_controller.dart';
import '../data/sources/supabase_voucher_data_source.dart';
import 'voucher_print_helper.dart';

class VoucherScreen extends ConsumerStatefulWidget {
  final String type; // 'receipt' or 'payment'
  const VoucherScreen({super.key, required this.type});

  @override
  ConsumerState<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends ConsumerState<VoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isCash = true;

  // نوع الجهة: 'general' (جهة أخرى), 'investor' (مستثمر), 'customer' (عميل)
  String _partyType = 'general';

  // بيانات المستثمرين
  List<Map<String, dynamic>> _investorsList = [];
  bool _isLoadingInvestors = false;
  String? _selectedInvestorId;
  double? _selectedInvestorBalance;

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _chequeNoController = TextEditingController();
  final _drawnOnController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool get isReceipt => widget.type == 'receipt';
  String get title => isReceipt ? 'سند قبض' : 'سند صرف';
  String get nameLabel => isReceipt ? 'استُلم من' : 'صُرف إلى';
  String get icon => isReceipt ? '💰' : '📤';

  double get _totalAmount => double.tryParse(_amountController.text) ?? 0;

  @override
  void initState() {
    super.initState();
    _fetchInvestors();
  }

  Future<void> _fetchInvestors() async {
    setState(() => _isLoadingInvestors = true);
    try {
      final investors = await ref.read(investorDataSourceProvider).getInvestors();
      if (mounted) {
        setState(() {
          _investorsList = investors;
          _isLoadingInvestors = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingInvestors = false);
    }
  }

  void _onPartyTypeChanged(String? type) {
    if (type == null) return;
    setState(() {
      _partyType = type;
      if (type != 'investor') {
        _selectedInvestorId = null;
        _selectedInvestorBalance = null;
      }
    });
  }

  void _onInvestorSelected(String? investorId) {
    if (investorId == null) return;
    final selected = _investorsList.firstWhere(
      (inv) => inv['id']?.toString() == investorId,
      orElse: () => {},
    );

    if (selected.isNotEmpty) {
      final rawBal = selected['available_balance'];
      final bal = (rawBal is num) ? rawBal.toDouble() : double.tryParse(rawBal?.toString() ?? '0') ?? 0.0;
      final name = selected['full_name']?.toString() ?? '';

      setState(() {
        _selectedInvestorId = investorId;
        _nameController.text = name;
        _selectedInvestorBalance = bal;
      });
    }
  }

  String _amountInWords(double amount) {
    if (amount <= 0) return '...';
    final intPart = amount.toInt();
    final decimal = ((amount - intPart) * 100).round();
    final words = _numberToArabic(intPart);
    if (decimal > 0) return '$words ريال و$decimal هللة';
    return '$words ر.س فقط لا غير';
  }

  String _numberToArabic(int n) {
    if (n == 0) return 'صفر';
    const ones = ['', 'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة',
      'أحد عشر', 'اثنا عشر', 'ثلاثة عشر', 'أربعة عشر', 'خمسة عشر', 'ستة عشر', 'سبعة عشر', 'ثمانية عشر', 'تسعة عشر'];
    const tens = ['', '', 'عشرون', 'ثلاثون', 'أربعون', 'خمسون', 'ستون', 'سبعون', 'ثمانون', 'تسعون'];
    const hundreds = ['', 'مئة', 'مئتان', 'ثلاثمئة', 'أربعمئة', 'خمسمئة', 'ستمئة', 'سبعمئة', 'ثمانمئة', 'تسعمئة'];

    if (n < 20) return ones[n];
    if (n < 100) {
      final t = tens[n ~/ 10];
      final o = n % 10 > 0 ? '${ones[n % 10]} و' : '';
      return '$o$t';
    }
    if (n < 1000) {
      final h = hundreds[n ~/ 100];
      final r = n % 100;
      return r > 0 ? '$h و${_numberToArabic(r)}' : h;
    }
    if (n < 1000000) {
      final t = n ~/ 1000;
      final r = n % 1000;
      final tWord = t == 1 ? 'ألف' : t == 2 ? 'ألفان' : '${_numberToArabic(t)} آلاف';
      return r > 0 ? '$tWord و${_numberToArabic(r)}' : tWord;
    }
    return n.toString();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveAndPrint() async {
    if (!_formKey.currentState!.validate()) return;

    if (_partyType == 'investor' && _selectedInvestorId == null) {
      SnackBarHelper.showError(context, 'يرجى اختيار المستثمر المعني بالسند');
      return;
    }

    if (!isReceipt && _partyType == 'investor' && _selectedInvestorBalance != null) {
      if (_totalAmount > _selectedInvestorBalance!) {
        SnackBarHelper.showError(
          context,
          'رصيد المستثمر غير كافٍ لصرف هذا المبلغ (المتاح: ${_selectedInvestorBalance!.toStringAsFixed(2)} ر.س)',
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // 1. حفظ السند وتنفيذ الأثر المالي في قاعدة البيانات
      final res = await ref.read(voucherDataSourceProvider).createVoucher(
            type: widget.type,
            partyType: _partyType,
            entityId: _partyType == 'investor' ? _selectedInvestorId : null,
            partyName: _nameController.text.trim(),
            amount: _totalAmount,
            paymentMethod: _isCash ? 'cash' : 'cheque',
            chequeNumber: _isCash ? null : _chequeNoController.text.trim(),
            bankName: _isCash ? null : _drawnOnController.text.trim(),
            purpose: _purposeController.text.trim(),
            voucherDate: _selectedDate,
          );

      final String voucherNumber = res['voucher_number']?.toString() ?? '';

      // تحديث حالة المستثمرين إن وُجد
      if (_partyType == 'investor') {
        ref.invalidate(investorListControllerProvider);
      }

      // 2. طباعة السند في ملف PDF
      if (isReceipt) {
        await VoucherPrintHelper.printReceiptVoucher(
          receivedFrom: _nameController.text.trim(),
          amount: _totalAmount,
          amountText: _amountInWords(_totalAmount),
          purpose: _purposeController.text.trim(),
          isCash: _isCash,
          chequeNo: _isCash ? null : _chequeNoController.text.trim(),
          drawnOn: _isCash ? null : _drawnOnController.text.trim(),
          date: _selectedDate,
          voucherNumber: voucherNumber,
        );
      } else {
        await VoucherPrintHelper.printPaymentVoucher(
          paidTo: _nameController.text.trim(),
          amount: _totalAmount,
          amountText: _amountInWords(_totalAmount),
          purpose: _purposeController.text.trim(),
          isCash: _isCash,
          chequeNo: _isCash ? null : _chequeNoController.text.trim(),
          drawnOn: _isCash ? null : _drawnOnController.text.trim(),
          date: _selectedDate,
          voucherNumber: voucherNumber,
        );
      }

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          _partyType == 'investor'
              ? 'تم حفظ $title برقم ($voucherNumber) وتحديث حساب المستثمر بنجاح'
              : 'تم حفظ $title برقم ($voucherNumber) وإعداده للطباعة',
        );

        // إعادة ضبط الحقول
        _amountController.clear();
        _purposeController.clear();
        _chequeNoController.clear();
        _drawnOnController.clear();
        if (_partyType == 'general') _nameController.clear();
      }
    } catch (e) {
      if (mounted) SnackBarHelper.showError(context, 'فشل حفظ وتجهيز السند: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    _chequeNoController.dispose();
    _drawnOnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final dateStr = intl.DateFormat('dd / MM / yyyy').format(_selectedDate);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: Column(
          children: [
            // ── Header Bar ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: const BoxDecoration(color: AppColors.primaryNavy),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isReceipt ? Icons.arrow_circle_down_rounded : Icons.arrow_circle_up_rounded,
                      color: AppColors.accentGold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(
                        isReceipt ? 'RECEIPT VOUCHER' : 'PAYMENT VOUCHER',
                        style: TextStyle(
                            color: AppColors.accentGold.withValues(alpha: 0.8),
                            fontSize: 12,
                            letterSpacing: 1.5),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Preview card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(dateStr, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          '${f.format(_totalAmount)} ر.س',
                          style: const TextStyle(
                              color: AppColors.accentGold,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ── Section 0: Party Type Selector (جهة التعامل) ───────
                      _buildCard(
                        title: 'جهة التعامل (الجهة الموجه إليها السند)',
                        icon: Icons.account_box_rounded,
                        child: Row(
                          children: [
                            Expanded(
                              child: _partyTypeChoiceTile(
                                label: 'مستثمر (مالي مباشر)',
                                icon: Icons.savings_rounded,
                                value: 'investor',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _partyTypeChoiceTile(
                                label: 'عميل (عقود/أقساط)',
                                icon: Icons.person_pin_rounded,
                                value: 'customer',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _partyTypeChoiceTile(
                                label: 'جهة أخرى / مصاريف',
                                icon: Icons.business_rounded,
                                value: 'general',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── If Investor Selected: Dropdown + Balance Card ────
                      if (_partyType == 'investor') ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildCard(
                                title: 'اختيار المستثمر',
                                icon: Icons.badge_rounded,
                                child: _isLoadingInvestors
                                    ? const Center(child: CircularProgressIndicator())
                                    : DropdownButtonFormField<String>(
                                        initialValue: _selectedInvestorId,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFFF8F9FA),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        ),
                                        hint: const Text('اختر المستثمر من القائمة...'),
                                        items: _investorsList.map((inv) {
                                          final id = inv['id']?.toString() ?? '';
                                          final name = inv['full_name']?.toString() ?? 'مستثمر';
                                          return DropdownMenuItem<String>(
                                            value: id,
                                            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          );
                                        }).toList(),
                                        onChanged: _onInvestorSelected,
                                        validator: (v) => v == null ? 'يرجى اختيار المستثمر' : null,
                                      ),
                              ),
                            ),
                            if (_selectedInvestorBalance != null) ...[
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 2,
                                child: _buildCard(
                                  title: 'رصيد المستثمر المتاح حالياً',
                                  icon: Icons.account_balance_wallet_rounded,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isReceipt
                                          ? Colors.green.withValues(alpha: 0.08)
                                          : AppColors.primaryNavy.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${f.format(_selectedInvestorBalance)} ر.س',
                                          style: TextStyle(
                                            color: isReceipt ? Colors.green.shade800 : AppColors.primaryNavy,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Row 1: Date + Payment Method ─────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date picker card
                          Expanded(
                            child: _buildCard(
                              title: 'التاريخ',
                              icon: Icons.calendar_month_rounded,
                              child: InkWell(
                                onTap: _selectDate,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded,
                                          color: AppColors.primaryNavy, size: 18),
                                      const SizedBox(width: 12),
                                      Text(dateStr,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppColors.primaryNavy)),
                                      const Spacer(),
                                      const Icon(Icons.edit_rounded, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Payment method card
                          Expanded(
                            child: _buildCard(
                              title: 'طريقة السداد',
                              icon: Icons.payments_rounded,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _methodTile(
                                      label: 'نقداً',
                                      icon: Icons.money_rounded,
                                      selected: _isCash,
                                      onTap: () => setState(() => _isCash = true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _methodTile(
                                      label: 'شيك',
                                      icon: Icons.receipt_long_rounded,
                                      selected: !_isCash,
                                      onTap: () => setState(() => _isCash = false),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Row 2: Name + Amount ─────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildCard(
                              title: nameLabel,
                              icon: Icons.person_rounded,
                              child: _buildField(
                                controller: _nameController,
                                hint: isReceipt
                                    ? 'اسم الشخص / الجهة المُسلِّمة...'
                                    : 'اسم الشخص / الجهة المُستلِمة...',
                                required: true,
                                readOnly: _partyType == 'investor',
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: _buildCard(
                              title: 'المبلغ (ريال)',
                              icon: Icons.paid_rounded,
                              child: _buildField(
                                controller: _amountController,
                                hint: '0.00',
                                isNumber: true,
                                required: true,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Amount in words ───────────────────────────
                      if (_totalAmount > 0)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primaryNavy.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.text_fields_rounded,
                                  color: AppColors.primaryNavy, size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _amountInWords(_totalAmount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryNavy,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      // ── Purpose ───────────────────────────────────
                      _buildCard(
                        title: 'وذلك مقابل / الغرض من السند',
                        icon: Icons.description_rounded,
                        child: _buildField(
                          controller: _purposeController,
                          hint: _partyType == 'investor'
                              ? (isReceipt ? 'إيداع رأس مال للمستثمر ...' : 'سحب أرباح / رأس مال ...')
                              : 'مثال: دفعة أولى عقد رقم FIN-000001 ...',
                          required: true,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Cheque info (if cheque) ────────────────────
                      if (!_isCash)
                        Row(
                          children: [
                            Expanded(
                              child: _buildCard(
                                title: 'رقم الشيك',
                                icon: Icons.pin_rounded,
                                child: _buildField(
                                    controller: _chequeNoController,
                                    hint: 'رقم الشيك...'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildCard(
                                title: 'مسحوب على (البنك)',
                                icon: Icons.account_balance_rounded,
                                child: _buildField(
                                    controller: _drawnOnController,
                                    hint: 'اسم البنك...'),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // ── Print & Save Button ──────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveAndPrint,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isReceipt
                                ? const Color(0xFF1A3A6B)
                                : const Color(0xFF8B1A1A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.print_rounded, size: 22),
                          label: Text(
                            _isLoading
                                ? 'جاري التوثيق والطباعة...'
                                : 'حفظ وطباعة $title',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _partyTypeChoiceTile({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final selected = _partyType == value;
    return GestureDetector(
      onTap: () => _onPartyTypeChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryNavy : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryNavy : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? AppColors.accentGold : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentGold, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primaryNavy)),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
    bool required = false,
    bool readOnly = false,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType:
          isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5), fontSize: 13),
        filled: true,
        fillColor: readOnly ? const Color(0xFFEEEEEE) : const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryNavy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _methodTile({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryNavy : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryNavy : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
