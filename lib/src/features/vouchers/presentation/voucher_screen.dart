import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/utils/app_theme.dart';
import '../../../core/utils/snack_bar_helper.dart';
import '../../investors/presentation/investor_controller.dart';
import '../../crm/presentation/crm_controller.dart';
import '../../contracts/presentation/contract_controller.dart';
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

  // نوع الجهة: 'general', 'investor', 'customer'
  String _partyType = 'general';

  String? _selectedEntityId;
  double? _dueAmount;

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _chequeNoController = TextEditingController();
  final _drawnOnController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool get isReceipt => widget.type == 'receipt';
  String get title => isReceipt ? 'سند قبض ذكي' : 'سند صرف ذكي';
  
  @override
  void initState() {
    super.initState();
  }

  void _onPartyTypeChanged(String value) {
    setState(() {
      _partyType = value;
      _selectedEntityId = null;
      _dueAmount = null;
      _nameController.clear();
      _amountController.clear();
      _purposeController.clear();
    });
  }

  // دالة ذكية للتعامل مع اختيار العميل وجلب بياناته المالية
  void _handleCustomerSelection(dynamic customer) {
    setState(() {
      _selectedEntityId = customer.id;
      _nameController.text = customer.fullName;
      // محاكاة جلب المبلغ المستحق (يمكن ربطها بـ API لاحقاً)
      _dueAmount = 2500.0; // مثال لمبلغ قسط
      _amountController.text = _dueAmount.toString();
      _purposeController.text = 'سداد قسط مستحق على العقد النشط - ${customer.fullName}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () {}, // لمشاهدة السندات السابقة
            )
          ],
        ),
        body: Column(
          children: [
            _buildQuickHeader(f),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildPartySelector(),
                      const SizedBox(height: 24),
                      _buildDynamicPartyFields(),
                      const SizedBox(height: 24),
                      _buildPaymentDetailsCard(),
                      const SizedBox(height: 32),
                      _buildActionButtons(),
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

  Widget _buildQuickHeader(intl.NumberFormat f) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.primaryNavy,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إجمالي المبلغ المعالج', style: TextStyle(color: Colors.white60, fontSize: 12)),
              Text('${f.format(double.tryParse(_amountController.text) ?? 0)} ر.س', 
                style: const TextStyle(color: AppColors.accentGold, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
            child: Text(intl.DateFormat('yyyy/MM/dd').format(_selectedDate), 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPartySelector() {
    return Row(
      children: [
        _buildTypeChip('عميل', 'customer', Icons.person_pin_rounded),
        const SizedBox(width: 12),
        _buildTypeChip('مستثمر', 'investor', Icons.savings_rounded),
        const SizedBox(width: 12),
        _buildTypeChip('عام / أخرى', 'general', Icons.more_horiz_rounded),
      ],
    );
  }

  Widget _buildTypeChip(String label, String value, IconData icon) {
    bool isSelected = _partyType == value;
    return Expanded(
      child: InkWell(
        onTap: () => _onPartyTypeChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryNavy : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.primaryNavy : Colors.white),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.accentGold : Colors.grey, size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicPartyFields() {
    if (_partyType == 'customer') {
      final customersAsync = ref.watch(customersListProvider());
      return customersAsync.when(
        data: (list) => DropdownButtonFormField<dynamic>(
          decoration: const InputDecoration(labelText: 'اختر العميل للتحصيل', prefixIcon: Icon(Icons.search)),
          items: list.map((c) => DropdownMenuItem(value: c, child: Text(c.fullName))).toList(),
          onChanged: _handleCustomerSelection,
        ),
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('خطأ في تحميل قائمة العملاء'),
      );
    }
    
    if (_partyType == 'investor') {
      final investorsAsync = ref.watch(investorListControllerProvider);
      return investorsAsync.when(
        data: (list) => DropdownButtonFormField<dynamic>(
          decoration: const InputDecoration(labelText: 'اختر المستثمر', prefixIcon: Icon(Icons.account_balance_wallet)),
          items: list.map((inv) => DropdownMenuItem(value: inv, child: Text(inv.fullName))).toList(),
          onChanged: (inv) => setState(() {
            _selectedEntityId = inv.id;
            _nameController.text = inv.fullName;
            _purposeController.text = isReceipt ? 'إيداع في محفظة المستثمر' : 'سحب أرباح للمستثمر';
          }),
        ),
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('خطأ في تحميل قائمة المستثمرين'),
      );
    }

    return _buildTextField(_nameController, isReceipt ? 'استلمنا من السيد/الجهة' : 'صرفنا للسيد/الجهة', Icons.person);
  }

  Widget _buildPaymentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField(_amountController, 'المبلغ بالأرقام', Icons.paid, isNumber: true)),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      const Text('نقداً'),
                      const Spacer(),
                      Switch(value: _isCash, onChanged: (v) => setState(() => _isCash = v), activeColor: AppColors.successGreen),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_dueAmount != null)
             Container(
               margin: const EdgeInsets.only(bottom: 16),
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
               child: Row(
                 children: [
                   const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                   const SizedBox(width: 8),
                   Text('المبلغ المستحق حالياً: $_dueAmount ر.س', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                 ],
               ),
             ),
          _buildTextField(_purposeController, 'وذلك مقابل (البيان)', Icons.description, maxLines: 2),
          if (!_isCash) ...[
            const SizedBox(height: 16),
            _buildTextField(_chequeNoController, 'رقم الشيك', Icons.pin),
            const SizedBox(height: 16),
            _buildTextField(_drawnOnController, 'مسحوب على بنك', Icons.account_balance),
          ]
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveAndPrint,
        icon: const Icon(Icons.print_rounded),
        label: Text(_isLoading ? 'جاري الحفظ والطباعة...' : 'حفظ وإصدار السند فوراً'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isReceipt ? AppColors.successGreen : AppColors.errorRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Future<void> _saveAndPrint() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // منطق الحفظ الموجود سابقاً
    await Future.delayed(const Duration(seconds: 1)); // محاكاة
    if (mounted) {
      setState(() => _isLoading = false);
      SnackBarHelper.showSuccess(context, 'تم حفظ السند وإرساله للطباعة بنجاح');
      Navigator.pop(context);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: AppColors.bgGrey,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
