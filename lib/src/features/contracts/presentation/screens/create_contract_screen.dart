import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../crm/presentation/crm_controller.dart';
import '../../../inventory/presentation/inventory_controller.dart';
import '../contract_controller.dart';

class CreateContractScreen extends ConsumerStatefulWidget {
  const CreateContractScreen({super.key});

  @override
  ConsumerState<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends ConsumerState<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _selectedCustomerId;
  String? _selectedVehicleId;
  String _contractType = 'installments';

  final _principalController = TextEditingController();
  final _profitRateController = TextEditingController(text: '15');
  final _durationController = TextEditingController(text: '12');

  final _moroorFeesController = TextEditingController(text: '0');
  final _tammFeesController = TextEditingController(text: '0');
  final _insuranceFeesController = TextEditingController(text: '0');
  final _vatController = TextEditingController(text: '0');

  final _g1NameController = TextEditingController();
  final _g1IdController = TextEditingController();
  final _g1PhoneController = TextEditingController();
  final _g1WorkController = TextEditingController();

  final _witness1NameController = TextEditingController();
  final _witness2NameController = TextEditingController();

  double _totalValue = 0;
  double _monthlyInstallment = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _calculateTotals() {
    final principal = double.tryParse(_principalController.text) ?? 0;
    final rate = _contractType == 'installments' ? (double.tryParse(_profitRateController.text) ?? 0) : 0;
    final months = int.tryParse(_durationController.text) ?? 1;

    final moroor = double.tryParse(_moroorFeesController.text) ?? 0;
    final tamm = double.tryParse(_tammFeesController.text) ?? 0;
    final insurance = double.tryParse(_insuranceFeesController.text) ?? 0;
    final vat = double.tryParse(_vatController.text) ?? 0;

    setState(() {
      _totalValue = principal + (principal * (rate / 100)) + moroor + tamm + insurance + vat;
      _monthlyInstallment = (_contractType == 'installments' && months > 0) ? _totalValue / months : 0;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCustomerId == null || _selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إكمال البيانات الأساسية واختيار العميل والسيارة'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final data = {
      'customer_id': _selectedCustomerId,
      'inventory_item_id': _selectedVehicleId,
      'principal_amount': double.parse(_principalController.text),
      'finance_profit_rate': _contractType == 'installments' ? double.parse(_profitRateController.text) : 0,
      'total_contract_value': _totalValue,
      'duration_months': _contractType == 'installments' ? int.parse(_durationController.text) : 0,
      'status': 'draft',
      'type': _contractType,
      'guarantor_1_name': _g1NameController.text.trim(),
      'guarantor_1_id': _g1IdController.text.trim(),
      'guarantor_1_phone': _g1PhoneController.text.trim(),
      'guarantor_1_work': _g1WorkController.text.trim(),
      'witness_1': _witness1NameController.text.trim(),
      'witness_2': _witness2NameController.text.trim(),
      'moroor_fees': double.parse(_moroorFeesController.text),
      'tamm_fees': double.parse(_tammFeesController.text),
      'insurance_fees': double.parse(_insuranceFeesController.text),
      'vat_amount': double.parse(_vatController.text),
    };

    try {
      await ref.read(contractControllerProvider.notifier).createContract(data);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم إصدار مسودة العقد وتحديث حالة المركبة بنجاح'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersListProvider());
    final vehiclesAsync = ref.watch(vehiclesListProvider(status: 'available'));

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('إصدار وثيقة تعاقد جديدة',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy))
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildFormHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildContractTypeSelector(),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      title: 'أطراف التعاقد والأصل الممول',
                      icon: Icons.handshake_rounded,
                      children: [
                        _buildCustomerDropdown(customersAsync),
                        const SizedBox(height: 20),
                        _buildVehicleDropdown(vehiclesAsync),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      title: 'القيم المالية والرسوم الإدارية',
                      icon: Icons.account_balance_wallet_rounded,
                      children: [
                        _buildPremiumTextField(_principalController, 'قيمة المركبة (أصل المبلغ) *', Icons.payments_rounded, isNumber: true),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _buildPremiumTextField(_moroorFeesController, 'رسوم النقل', Icons.assignment_turned_in_rounded, isNumber: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPremiumTextField(_tammFeesController, 'رسوم تم', Icons.app_registration_rounded, isNumber: true)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _buildPremiumTextField(_insuranceFeesController, 'رسوم التأمين', Icons.security_rounded, isNumber: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPremiumTextField(_vatController, 'ضريبة القيمة (VAT)', Icons.calculate_rounded, isNumber: true)),
                          ],
                        ),
                      ],
                    ),
                    if (_contractType == 'installments') ...[
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        title: 'شروط السداد والأرباح',
                        icon: Icons.calendar_month_rounded,
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildPremiumTextField(_profitRateController, 'نسبة الربح %', Icons.trending_up_rounded, isNumber: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildPremiumTextField(_durationController, 'مدة التمويل (أشهر)', Icons.timer_rounded, isNumber: true)),
                            ],
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      title: 'بيانات الكفيل الغارم والشهود',
                      icon: Icons.gpp_good_rounded,
                      children: [
                        _buildPremiumTextField(_g1NameController, 'اسم الكفيل الكامل', Icons.person_add_rounded),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _buildPremiumTextField(_g1IdController, 'هوية الكفيل', Icons.badge_rounded)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPremiumTextField(_g1PhoneController, 'جوال الكفيل', Icons.phone_android_rounded)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _buildPremiumTextField(_witness1NameController, 'الشاهد الأول', Icons.people_outline_rounded)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPremiumTextField(_witness2NameController, 'الشاهد الثاني', Icons.people_outline_rounded)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildExecutiveSummary(),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                      ),
                      child: const Text('اعتماد وإصدار العقد للطباعة',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('نظام إصدار الوثائق التمويلية',
              style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          const Text('عقد مبايعة سيارة بنظام التقسيط',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('يرجى مراجعة كافة الشروط المالية قبل الاعتماد النهائي.',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildContractTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          _buildTypeOption('installments', 'بيع بالأجل (أقساط)', Icons.history_edu_rounded),
          _buildTypeOption('cash', 'بيع نقدي مباشر', Icons.payments_rounded),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String type, String label, IconData icon) {
    final bool isSelected = _contractType == type;
    return Expanded(
      child: InkWell(
        onTap: () { setState(() => _contractType = type); _calculateTotals(); },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentGold, size: 22),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            ],
          ),
          const Divider(height: 48),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPremiumTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      onChanged: (_) => _calculateTotals(),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
        filled: true,
        fillColor: AppColors.bgGrey.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCustomerDropdown(AsyncValue asyncData) {
    return asyncData.when(
      data: (list) => DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'العميل المشتري',
          prefixIcon: const Icon(Icons.person_search_rounded),
          filled: true,
          fillColor: AppColors.bgGrey.withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        items: list.map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.fullName))).toList(),
        onChanged: (val) => setState(() => _selectedCustomerId = val),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error loading customers'),
    );
  }

  Widget _buildVehicleDropdown(AsyncValue asyncData) {
    return asyncData.when(
      data: (list) => DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'المركبة المختارة من المخزون',
          prefixIcon: const Icon(Icons.directions_car_rounded),
          filled: true,
          fillColor: AppColors.bgGrey.withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        items: list.map((v) => DropdownMenuItem<String>(value: v.id, child: Text('${v.make} ${v.model} - لوحة: ${v.licensePlate ?? "-"}'))).toList(),
        onChanged: (val) => setState(() => _selectedVehicleId = val),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error loading vehicles'),
    );
  }

  Widget _buildExecutiveSummary() {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A294D), AppColors.primaryNavy]),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: AppColors.primaryNavy.withOpacity(0.3), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إجمالي قيمة مديونية العقد', style: TextStyle(color: Colors.white70, fontSize: 16)),
              Text('${f.format(_totalValue)} ر.س',
                  style: const TextStyle(color: AppColors.accentGold, fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          ),
          if (_contractType == 'installments') ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('قيمة القسط الشهري المتوقعة', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text('${f.format(_monthlyInstallment)} ر.س',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
