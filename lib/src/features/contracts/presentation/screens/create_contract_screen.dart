import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../crm/presentation/crm_controller.dart';
import '../../../inventory/presentation/inventory_controller.dart';
import '../../../inventory/domain/vehicle.dart';
import '../../../investors/presentation/investor_controller.dart';
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
  String? _suggestedInvestorName;
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

  @override
  void dispose() {
    _principalController.dispose();
    _profitRateController.dispose();
    _durationController.dispose();
    _moroorFeesController.dispose();
    _tammFeesController.dispose();
    _insuranceFeesController.dispose();
    _vatController.dispose();
    _g1NameController.dispose();
    _g1IdController.dispose();
    _g1PhoneController.dispose();
    _g1WorkController.dispose();
    _witness1NameController.dispose();
    _witness2NameController.dispose();
    super.dispose();
  }

  void _calculateTotals() {
    final principal = double.tryParse(_principalController.text) ?? 0;
    final rate = _contractType == 'installments' ? (double.tryParse(_profitRateController.text) ?? 0) : 0;
    final months = int.tryParse(_durationController.text) ?? 1;

    final moroor = double.tryParse(_moroorFeesController.text) ?? 0;
    final tamm = double.tryParse(_tammFeesController.text) ?? 0;
    final insurance = double.tryParse(_insuranceFeesController.text) ?? 0;
    final vat = double.tryParse(_vatController.text) ?? 0;

    if (mounted) {
      setState(() {
        _totalValue = principal + (principal * (rate / 100)) + moroor + tamm + insurance + vat;
        _monthlyInstallment = (_contractType == 'installments' && months > 0) ? _totalValue / months : 0;
      });
    }
  }

  void _findSmartInvestorSuggestion(double carPrice) {
    final investors = ref.read(investorListControllerProvider).valueOrNull;
    if (investors != null && investors.isNotEmpty) {
      try {
        final suggestion = investors.firstWhere((inv) => inv.availableBalance >= carPrice);
        setState(() => _suggestedInvestorName = suggestion.fullName);
      } catch (e) {
        setState(() => _suggestedInvestorName = 'لا يوجد مستثمر لديه سيولة كافية حالياً');
      }
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate() || _selectedCustomerId == null || _selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إكمال البيانات واختيار العميل والسيارة'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final data = {
      'customer_id': _selectedCustomerId,
      'inventory_item_id': _selectedVehicleId,
      'principal_amount': double.tryParse(_principalController.text) ?? 0.0,
      'finance_profit_rate': _contractType == 'installments' ? (double.tryParse(_profitRateController.text) ?? 0.0) : 0.0,
      'total_contract_value': _totalValue,
      'duration_months': _contractType == 'installments' ? (int.tryParse(_durationController.text) ?? 1) : 1,
      'status': 'draft',
      'type': _contractType,
      'guarantor_1_name': _g1NameController.text.trim(),
      'guarantor_1_id': _g1IdController.text.trim(),
      'guarantor_1_phone': _g1PhoneController.text.trim(),
      'guarantor_1_work': _g1WorkController.text.trim(),
      'witness_1': _witness1NameController.text.trim(),
      'witness_2': _witness2NameController.text.trim(),
      'moroor_fees': double.tryParse(_moroorFeesController.text) ?? 0.0,
      'tamm_fees': double.tryParse(_tammFeesController.text) ?? 0.0,
      'insurance_fees': double.tryParse(_insuranceFeesController.text) ?? 0.0,
      'vat_amount': double.tryParse(_vatController.text) ?? 0.0,
    };

    try {
      await ref.read(contractControllerProvider.notifier).createContract(data);
      
      final controllerState = ref.read(contractControllerProvider);
      
      if (controllerState.hasError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: ${controllerState.error}'), backgroundColor: Colors.red),
          );
        }
      } else {
        if (mounted) {
          ref.invalidate(contractsListProvider);
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إصدار مسودة العقد بنجاح'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ غير متوقع: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersListProvider());
    final vehiclesAsync = ref.watch(vehiclesListProvider(status: 'available'));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        title: const Text('إصدار وثيقة تعاقد ذكية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryNavy),
                SizedBox(height: 16),
                Text('جاري إنشاء العقد وتوليد السجلات...', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
              ],
            ))
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildFormHeader(),
            Padding(
              padding: const EdgeInsets.all(24.0),
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
                        _buildPremiumTextField(_principalController, 'قيمة المركبة (أصل المبلغ) *', Icons.payments_rounded, isNumber: true, isRequired: true),
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
                              Expanded(child: _buildPremiumTextField(_profitRateController, 'نسبة الربح %', Icons.trending_up_rounded, isNumber: true, isRequired: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildPremiumTextField(_durationController, 'مدة التمويل (أشهر)', Icons.timer_rounded, isNumber: true, isRequired: true, minVal: 1)),
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
                        _buildPremiumTextField(_g1WorkController, 'مقر عمل الكفيل', Icons.work_outline_rounded),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildExecutiveSummary(),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: const Text('اعتماد وإصدار العقد للطباعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 100),
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
      padding: const EdgeInsets.all(32),
      color: AppColors.primaryNavy,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تجهيز عقد جديد', style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('أتمتة العملية المالية والقانونية', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildContractTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? AppColors.primaryNavy : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppColors.accentGold, size: 20), const SizedBox(width: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
          const Divider(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPremiumTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isRequired = false, double? minVal}) {
    return TextFormField(
      controller: controller,
      onChanged: (_) => _calculateTotals(),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      validator: (val) {
        if (isRequired && (val == null || val.isEmpty)) return 'هذا الحقل مطلوب';
        if (isNumber && val != null && val.isNotEmpty) {
          final numVal = double.tryParse(val);
          if (numVal == null) return 'يجب إدخال رقم صحيح';
          if (minVal != null && numVal < minVal) return 'يجب أن يكون $minVal على الأقل';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCustomerDropdown(AsyncValue asyncData) {
    return asyncData.when(
      data: (list) => DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: 'العميل المشتري', prefixIcon: const Icon(Icons.person), filled: true, fillColor: const Color(0xFFF8F9FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
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
        decoration: InputDecoration(labelText: 'المركبة المختارة', prefixIcon: const Icon(Icons.directions_car), filled: true, fillColor: const Color(0xFFF8F9FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
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

  Widget _buildExecutiveSummary() {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.primaryNavy, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('إجمالي قيمة مديونية العقد', style: TextStyle(color: Colors.white70)), Text('${f.format(_totalValue)} ر.س', style: const TextStyle(color: AppColors.accentGold, fontSize: 24, fontWeight: FontWeight.bold))]),
          if (_contractType == 'installments') ...[
            const Divider(color: Colors.white10, height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('قيمة القسط الشهري', style: TextStyle(color: Colors.white70)), Text('${f.format(_monthlyInstallment)} ر.س', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
          ],
        ],
      ),
    );
  }
}
