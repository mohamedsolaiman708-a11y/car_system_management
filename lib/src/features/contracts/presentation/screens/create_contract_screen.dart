import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../../../crm/presentation/crm_controller.dart';
import '../../../inventory/presentation/inventory_controller.dart';
import '../../../inventory/domain/vehicle.dart';
import '../contract_controller.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../../settings/domain/system_setting.dart';

class CreateContractScreen extends ConsumerStatefulWidget {
  const CreateContractScreen({super.key});

  @override
  ConsumerState<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends ConsumerState<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  String? _selectedCustomerId;
  String? _selectedVehicleId;
  String _contractType = 'installments';

  final _principalController = TextEditingController();
  final _profitRateController = TextEditingController(text: '15');
  final _durationController = TextEditingController(text: '12');

  final _downPaymentController = TextEditingController(text: '0');
  final _moroorFeesController = TextEditingController(text: '250');
  final _tammFeesController = TextEditingController(text: '0');
  final _insuranceFeesController = TextEditingController(text: '900');
  final _inspectionFeesController = TextEditingController(text: '120');
  final _plateFeesController = TextEditingController(text: '500');
  final _violationsFeesController = TextEditingController(text: '350');
  final _otherFeesController = TextEditingController(text: '80');
  final _vatController = TextEditingController(text: '0');

  // الكفلاء والشهود
  final _g1NameController = TextEditingController();
  final _g1IdController = TextEditingController();
  final _g1PhoneController = TextEditingController();
  final _g1WorkController = TextEditingController();
  final _g1AddressController = TextEditingController();

  final _g2NameController = TextEditingController();
  final _g2IdController = TextEditingController();
  final _g2PhoneController = TextEditingController();
  final _g2WorkController = TextEditingController();
  final _g2AddressController = TextEditingController();

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

    final fees = [
      _moroorFeesController, _insuranceFeesController, _inspectionFeesController,
      _plateFeesController, _violationsFeesController, _otherFeesController,
      _tammFeesController, _vatController
    ].fold(0.0, (prev, element) => prev + (double.tryParse(element.text) ?? 0));

    setState(() {
      _totalValue = principal + (principal * (rate / 100)) + fees;
      final downPayment = double.tryParse(_downPaymentController.text) ?? 0;
      final remaining = _totalValue - downPayment;
      _monthlyInstallment = (_contractType == 'installments' && months > 0) 
          ? (remaining > 0 ? remaining / months : 0) 
          : 0;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final data = {
      'customer_id': _selectedCustomerId,
      'inventory_item_id': _selectedVehicleId,
      'principal_amount': double.tryParse(_principalController.text) ?? 0.0,
      'finance_profit_rate': _contractType == 'installments' ? (double.tryParse(_profitRateController.text) ?? 0.0) : 0.0,
      'total_contract_value': _totalValue,
      'duration_months': _contractType == 'installments' ? (int.tryParse(_durationController.text) ?? 1) : 1,
      'down_payment': double.tryParse(_downPaymentController.text) ?? 0.0,
      'status': 'draft',
      'type': _contractType,
      'guarantor_1_name': _g1NameController.text.trim(),
      'guarantor_1_id': _g1IdController.text.trim(),
      'guarantor_1_phone': _g1PhoneController.text.trim(),
      'guarantor_1_work': _g1WorkController.text.trim(),
      'guarantor_1_address': _g1AddressController.text.trim(),
      'guarantor_2_name': _g2NameController.text.trim(),
      'guarantor_2_id': _g2IdController.text.trim(),
      'guarantor_2_phone': _g2PhoneController.text.trim(),
      'guarantor_2_work': _g2WorkController.text.trim(),
      'guarantor_2_address': _g2AddressController.text.trim(),
      'witness_1': _witness1NameController.text.trim(),
      'witness_2': _witness2NameController.text.trim(),
      'moroor_fees': double.tryParse(_moroorFeesController.text) ?? 0.0,
      'tamm_fees': double.tryParse(_tammFeesController.text) ?? 0.0,
      'insurance_fees': double.tryParse(_insuranceFeesController.text) ?? 0.0,
      'inspection_fees': double.tryParse(_inspectionFeesController.text) ?? 0.0,
      'plate_fees': double.tryParse(_plateFeesController.text) ?? 0.0,
      'traffic_violations_fees': double.tryParse(_violationsFeesController.text) ?? 0.0,
      'other_fees': double.tryParse(_otherFeesController.text) ?? 0.0,
      'vat_amount': double.tryParse(_vatController.text) ?? 0.0,
    };

    try {
      await ref.read(contractControllerProvider.notifier).createContract(data);
      if (mounted) {
        ref.invalidate(contractsListProvider);
        context.pop();
        SnackBarHelper.showSuccess(context, 'تم إصدار مسودة العقد بنجاح');
      }
    } catch (e) {
      if (mounted) SnackBarHelper.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          title: const Text('إصدار عقد ذكي'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: Text('خطوة ${_currentStep + 1} من 3', style: const TextStyle(color: AppColors.accentGold))),
            )
          ],
        ),
        body: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(key: _formKey, child: _buildCurrentStepContent()),
                  ),
            ),
            _buildBottomSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      color: AppColors.primaryNavy,
      padding: const EdgeInsets.only(bottom: 16, left: 32, right: 32),
      child: Row(
        children: List.generate(3, (index) => Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index <= _currentStep ? AppColors.accentGold : Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      default: return const SizedBox();
    }
  }

  Widget _buildStep1() {
    final customersAsync = ref.watch(customersListProvider());
    final vehiclesAsync = ref.watch(vehiclesListProvider(status: 'available'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('أطراف التعاقد ونوع البيع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildContractTypeSelector(),
        const SizedBox(height: 24),
        _buildCustomerDropdown(customersAsync),
        const SizedBox(height: 16),
        _buildVehicleDropdown(vehiclesAsync),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('التفاصيل المالية والرسوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildPremiumTextField(_principalController, 'أصل مبلغ المركبة *', Icons.payments, isNumber: true, isRequired: true),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildPremiumTextField(_profitRateController, 'نسبة الربح %', Icons.trending_up, isNumber: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildPremiumTextField(_durationController, 'المدة (أشهر)', Icons.timer, isNumber: true)),
          ],
        ),
        const SizedBox(height: 16),
        _buildPremiumTextField(_downPaymentController, 'الدفعة المقدمة', Icons.account_balance, isNumber: true),
        const Divider(height: 40),
        const Text('رسوم إضافية', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: [
            SizedBox(width: 160, child: _buildPremiumTextField(_moroorFeesController, 'المرور', Icons.assignment, isNumber: true)),
            SizedBox(width: 160, child: _buildPremiumTextField(_insuranceFeesController, 'التأمين', Icons.security, isNumber: true)),
            SizedBox(width: 160, child: _buildPremiumTextField(_vatController, 'الضريبة', Icons.calculate, isNumber: true)),
            SizedBox(width: 160, child: _buildPremiumTextField(_otherFeesController, 'أخرى', Icons.more_horiz, isNumber: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الضمانات والشهود', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildSectionTitle('الكفيل الأول'),
        _buildPremiumTextField(_g1NameController, 'الاسم الكامل', Icons.person),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildPremiumTextField(_g1IdController, 'رقم الهوية', Icons.badge)),
            const SizedBox(width: 12),
            Expanded(child: _buildPremiumTextField(_g1PhoneController, 'رقم الجوال', Icons.phone)),
          ],
        ),
        const Divider(height: 40),
        _buildSectionTitle('الشهود'),
        _buildPremiumTextField(_witness1NameController, 'الشاهد الأول', Icons.people),
        const SizedBox(height: 12),
        _buildPremiumTextField(_witness2NameController, 'الشاهد الثاني', Icons.people_outline),
      ],
    );
  }

  Widget _buildBottomSummary() {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('إجمالي العقد', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('${f.format(_totalValue)} ريال', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                  ],
                ),
                if (_contractType == 'installments') Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('القسط الشهري', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('${f.format(_monthlyInstallment)} ريال', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (_currentStep > 0) Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('السابق'),
                  ),
                ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        _submit();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(_currentStep < 2 ? 'المتابعة' : 'إصدار العقد الآن'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)));

  Widget _buildContractTypeSelector() {
    return Row(
      children: [
        _buildTypeOption('installments', 'أقساط', Icons.calendar_month),
        const SizedBox(width: 12),
        _buildTypeOption('cash', 'كاش', Icons.money),
      ],
    );
  }

  Widget _buildTypeOption(String type, String label, IconData icon) {
    bool isSelected = _contractType == type;
    return Expanded(
      child: InkWell(
        onTap: () { setState(() => _contractType = type); _calculateTotals(); },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryNavy : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primaryNavy : Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown(AsyncValue asyncData) {
    return asyncData.when(
      data: (list) => DropdownButtonFormField<String>(
        value: _selectedCustomerId,
        decoration: InputDecoration(labelText: 'اختر العميل', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        items: (list as List).map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.fullName))).toList(),
        onChanged: (val) => setState(() => _selectedCustomerId = val),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error loading customers'),
    );
  }

  Widget _buildVehicleDropdown(AsyncValue<List<Vehicle>> asyncData) {
    return asyncData.when(
      data: (list) => DropdownButtonFormField<String>(
        value: _selectedVehicleId,
        decoration: InputDecoration(labelText: 'اختر المركبة', prefixIcon: const Icon(Icons.directions_car), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        items: list.map((v) => DropdownMenuItem<String>(value: v.id, child: Text('${v.make} ${v.model}'))).toList(),
        onChanged: (val) {
          if (val != null) {
            final v = list.firstWhere((x) => x.id == val);
            _principalController.text = v.purchasePrice.toString();
            _calculateTotals();
          }
          setState(() => _selectedVehicleId = val);
        },
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error loading vehicles'),
    );
  }

  Widget _buildPremiumTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      onChanged: (_) => _calculateTotals(),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) => isRequired && (val == null || val.isEmpty) ? 'مطلوب' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
