import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../crm/presentation/crm_controller.dart';
import '../../../inventory/presentation/inventory_controller.dart';
import '../contract_controller.dart';

class CreateContractScreen extends ConsumerStatefulWidget {
  final String? initialVehicleId;
  final String? initialCustomerId;
  
  const CreateContractScreen({super.key, this.initialVehicleId, this.initialCustomerId});

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
  final _witness1NameController = TextEditingController();
  final _witness2NameController = TextEditingController();

  double _totalValue = 0;
  double _monthlyInstallment = 0;

  @override
  void initState() {
    super.initState();
    // ميزة ذكية: الربط التلقائي بالبيانات القادمة من شاشات أخرى
    _selectedVehicleId = widget.initialVehicleId;
    _selectedCustomerId = widget.initialCustomerId;
    _calculateTotals();
  }

  void _calculateTotals() {
    final principal = double.tryParse(_principalController.text) ?? 0;
    final rate = _contractType == 'installments' ? (double.tryParse(_profitRateController.text) ?? 0) : 0;
    final months = int.tryParse(_durationController.text) ?? 1;
    final otherFees = (double.tryParse(_moroorFeesController.text) ?? 0) +
                      (double.tryParse(_tammFeesController.text) ?? 0) +
                      (double.tryParse(_insuranceFeesController.text) ?? 0) +
                      (double.tryParse(_vatController.text) ?? 0);

    setState(() {
      _totalValue = principal + (principal * (rate / 100)) + otherFees;
      _monthlyInstallment = (_contractType == 'installments' && months > 0) ? _totalValue / months : 0;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCustomerId == null || _selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار العميل والسيارة وإكمال البيانات')));
      return;
    }

    setState(() => _isLoading = true);
    try {
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
        'witness_1': _witness1NameController.text.trim(),
        'witness_2': _witness2NameController.text.trim(),
        'moroor_fees': double.parse(_moroorFeesController.text),
        'tamm_fees': double.parse(_tammFeesController.text),
        'insurance_fees': double.parse(_insuranceFeesController.text),
        'vat_amount': double.parse(_vatController.text),
      };

      await ref.read(contractControllerProvider.notifier).createContract(data);
      // ميزة ذكية: تحديث حالة السيارة فوراً إلى Sold
      await ref.read(inventoryControllerProvider.notifier).updateVehicleStatus(_selectedVehicleId!, 'sold');

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إصدار الوثيقة وتحديث حالة السيارة'), backgroundColor: Colors.green));
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('إصدار عقد بيع جديد', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTypeToggle(),
              const SizedBox(height: 20),
              _buildClassicSection('الأطراف والمركبة', [
                _buildCustomerDropdown(customersAsync),
                const SizedBox(height: 12),
                _buildVehicleDropdown(vehiclesAsync),
              ]),
              const SizedBox(height: 16),
              _buildClassicSection('التكاليف المالية والرسوم', [
                _buildSimpleField(_principalController, 'قيمة السيارة الأساسية', isNumber: true),
                Row(children: [
                  Expanded(child: _buildSimpleField(_moroorFeesController, 'رسوم النقل', isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSimpleField(_tammFeesController, 'رسوم تم', isNumber: true)),
                ]),
              ]),
              const SizedBox(height: 16),
              if (_contractType == 'installments')
                _buildClassicSection('شروط الأقساط', [
                  Row(children: [
                    Expanded(child: _buildSimpleField(_profitRateController, 'نسبة الربح %', isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSimpleField(_durationController, 'المدة (أشهر)', isNumber: true)),
                  ]),
                ]),
              const SizedBox(height: 24),
              _buildClassicSummary(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  child: const Text('حفظ واصدار العقد النهائي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Row(
      children: [
        _buildToggleItem('installments', 'بيع بالأجل'),
        const SizedBox(width: 8),
        _buildToggleItem('cash', 'بيع نقدي'),
      ],
    );
  }

  Widget _buildToggleItem(String type, String label) {
    final sel = _contractType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() { _contractType = type; _calculateTotals(); }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: sel ? AppColors.primaryNavy : Colors.white, border: Border.all(color: sel ? AppColors.primaryNavy : Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
          child: Center(child: Text(label, style: TextStyle(color: sel ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))),
        ),
      ),
    );
  }

  Widget _buildClassicSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const Divider(height: 24),
        ...children,
      ]),
    );
  }

  Widget _buildSimpleField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        onChanged: (_) => _calculateTotals(),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown(AsyncValue asyncData) {
    return asyncData.when(
      data: (list) => DropdownButtonFormField<String>(
        value: _selectedCustomerId,
        decoration: const InputDecoration(labelText: 'المشتري', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
        items: list.map<DropdownMenuItem<String>>((c) => DropdownMenuItem(value: c.id, child: Text(c.fullName, style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: (val) => setState(() => _selectedCustomerId = val),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error'),
    );
  }

  Widget _buildVehicleDropdown(AsyncValue asyncData) {
    return asyncData.when(
      data: (list) => DropdownButtonFormField<String>(
        value: _selectedVehicleId,
        decoration: const InputDecoration(labelText: 'المركبة', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
        items: list.map<DropdownMenuItem<String>>((v) => DropdownMenuItem(value: v.id, child: Text('${v.make} ${v.model}', style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: (val) => setState(() => _selectedVehicleId = val),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error'),
    );
  }

  Widget _buildClassicSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primaryNavy.withOpacity(0.05), border: Border.all(color: AppColors.primaryNavy.withOpacity(0.1)), borderRadius: BorderRadius.circular(4)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('إجمالي العقد:', style: TextStyle(fontSize: 13)), Text('${_totalValue.toStringAsFixed(2)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
        if (_contractType == 'installments') ...[
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('القسط الشهري:', style: TextStyle(fontSize: 12, color: Colors.grey)), Text('${_monthlyInstallment.toStringAsFixed(2)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]),
        ]
      ]),
    );
  }
}
