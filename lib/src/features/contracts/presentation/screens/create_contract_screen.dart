import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

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
  
  // الأطراف والمركبة
  String? _selectedCustomerId;
  String? _selectedVehicleId;
  String _contractType = 'installments'; 

  // المبالغ الأساسية
  final _principalController = TextEditingController();
  final _profitRateController = TextEditingController(text: '15'); 
  final _durationController = TextEditingController(text: '12');

  // رسوم الخدمات (مطابقة للصورة 9)
  final _moroorFeesController = TextEditingController(text: '0');
  final _tammFeesController = TextEditingController(text: '0');
  final _insuranceFeesController = TextEditingController(text: '0');
  final _vatController = TextEditingController(text: '0');

  // بيانات الكفيل (مطابقة للصورة 8)
  final _g1NameController = TextEditingController();
  final _g1IdController = TextEditingController();
  final _g1PhoneController = TextEditingController();
  final _g1WorkController = TextEditingController();

  // الشهود (مطابقة للصورة 8)
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

    final data = {
      'customer_id': _selectedCustomerId,
      'inventory_item_id': _selectedVehicleId,
      'principal_amount': double.parse(_principalController.text),
      'finance_profit_rate': _contractType == 'installments' ? double.parse(_profitRateController.text) : 0,
      'total_contract_value': _totalValue,
      'duration_months': _contractType == 'installments' ? int.parse(_durationController.text) : 0,
      'status': 'draft',
      'type': _contractType,
      // بيانات الكفلاء
      'guarantor_1_name': _g1NameController.text,
      'guarantor_1_id': _g1IdController.text,
      'guarantor_1_phone': _g1PhoneController.text,
      'guarantor_1_work': _g1WorkController.text,
      // الشهود
      'witness_1': _witness1NameController.text,
      'witness_2': _witness2NameController.text,
      // الرسوم
      'moroor_fees': double.parse(_moroorFeesController.text),
      'tamm_fees': double.parse(_tammFeesController.text),
      'insurance_fees': double.parse(_insuranceFeesController.text),
      'vat_amount': double.parse(_vatController.text),
    };

    await ref.read(contractControllerProvider.notifier).createContract(data);
    
    if (mounted && !ref.read(contractControllerProvider).hasError) {
      // تم تغيير 'sold' إلى 'on_contract' لتجنب خطأ الـ Enum في قاعدة البيانات
      await ref.read(inventoryControllerProvider.notifier).updateVehicleStatus(_selectedVehicleId!, 'on_contract');
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إصدار الوثيقة وحفظها كمسودة بنجاح'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersListProvider());
    final vehiclesAsync = ref.watch(vehiclesListProvider(status: 'available'));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FE),
        appBar: AppBar(
          title: const Text('إصدار وثيقة مبايعة سيارة'),
          centerTitle: true,
          backgroundColor: const Color(0xFF0D1B3E),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildContractTypeToggle(),
                const SizedBox(height: 24),
                
                _buildSectionCard(
                  title: 'أطراف العقد والمركبة',
                  icon: Icons.handshake_rounded,
                  children: [
                    _buildCustomerDropdown(customersAsync),
                    const SizedBox(height: 16),
                    _buildVehicleDropdown(vehiclesAsync),
                  ],
                ),

                if (_contractType == 'installments') ...[
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'بيانات الكفيل الغارم',
                    icon: Icons.security_rounded,
                    children: [
                      _buildTextField(_g1NameController, 'اسم الكفيل الكامل *'),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_g1IdController, 'رقم الهوية')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(_g1PhoneController, 'رقم الجوال')),
                        ],
                      ),
                      _buildTextField(_g1WorkController, 'جهة العمل'),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'الشهود',
                  icon: Icons.people_alt_rounded,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_witness1NameController, 'اسم الشاهد الأول')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(_witness2NameController, 'اسم الشاهد الثاني')),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'التكاليف والرسوم (مطابقة للصورة 9)',
                  icon: Icons.account_balance_wallet_rounded,
                  children: [
                    _buildTextField(_principalController, 'قيمة السيارة الأساسية *', isNumber: true, prefix: 'ر.س'),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_moroorFeesController, 'نقل ملكية', isNumber: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField(_tammFeesController, 'رسوم تم', isNumber: true)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_insuranceFeesController, 'تأمين', isNumber: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField(_vatController, 'الضريبة (VAT)', isNumber: true)),
                      ],
                    ),
                  ],
                ),

                if (_contractType == 'installments') ...[
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'شروط الأقساط',
                    icon: Icons.calendar_month_rounded,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_profitRateController, 'نسبة الربح %', isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(_durationController, 'المدة (أشهر)', isNumber: true)),
                        ],
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),
                _buildSummaryPanel(),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('حفظ واصدار الوثيقة للطباعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D1B3E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContractTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          _buildToggleBtn('installments', 'بيع بالأجل (أقساط)', Icons.history_edu_rounded),
          _buildToggleBtn('cash', 'بيع نقداً', Icons.payments_rounded),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String type, String label, IconData icon) {
    final isSelected = _contractType == type;
    return Expanded(
      child: InkWell(
        onTap: () { setState(() => _contractType = type); _calculateTotals(); },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: isSelected ? const Color(0xFF0D1B3E) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
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

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: const Color(0xFFC5A35E), size: 22), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)))]),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, String? prefix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        onChanged: (_) => _calculateTotals(),
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          suffixText: prefix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown(AsyncValue asyncData) {
    return asyncData.when(
      data: (list) => DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'اختر المشتري *', border: OutlineInputBorder()),
        items: list.map((c) => DropdownMenuItem(value: c.id, child: Text(c.fullName))).toList(),
        onChanged: (val) => setState(() => _selectedCustomerId = val),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('خطأ في تحميل العملاء'),
    );
  }

  Widget _buildVehicleDropdown(AsyncValue asyncData) {
    return asyncData.when(
      data: (list) => DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'اختر المركبة *', border: OutlineInputBorder()),
        items: list.map((v) => DropdownMenuItem(value: v.id, child: Text('${v.make} ${v.model} - لوحة: ${v.licensePlate}'))).toList(),
        onChanged: (val) => setState(() => _selectedVehicleId = val),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('خطأ في تحميل المركبات'),
    );
  }

  Widget _buildSummaryPanel() {
    final f = intl.NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF0D1B3E), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('إجمالي قيمة الوثيقة:', style: TextStyle(color: Colors.white70)), Text(f.format(_totalValue), style: const TextStyle(color: Color(0xFFC5A35E), fontSize: 24, fontWeight: FontWeight.bold))]),
          if (_contractType == 'installments') ...[
            const Divider(color: Colors.white24, height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('القسط الشهري:', style: TextStyle(color: Colors.white70)), Text(f.format(_monthlyInstallment), style: const TextStyle(color: Colors.white, fontSize: 18))]),
          ],
        ],
      ),
    );
  }
}
