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
  
  String? _selectedCustomerId;
  String? _selectedVehicleId;
  final _principalController = TextEditingController();
  final _profitRateController = TextEditingController();
  final _durationController = TextEditingController();
  
  double _totalValue = 0;
  double _monthlyInstallment = 0;

  void _calculateTotals() {
    final principal = double.tryParse(_principalController.text) ?? 0;
    final rate = double.tryParse(_profitRateController.text) ?? 0;
    final months = int.tryParse(_durationController.text) ?? 1;

    setState(() {
      _totalValue = principal + (principal * (rate / 100));
      _monthlyInstallment = months > 0 ? _totalValue / months : 0;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCustomerId == null || _selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار العميل والمركبة وتعبئة كافة الحقول'), backgroundColor: Colors.red),
      );
      return;
    }

    final data = {
      'customer_id': _selectedCustomerId,
      'inventory_item_id': _selectedVehicleId,
      'principal_amount': double.parse(_principalController.text),
      'finance_profit_rate': double.parse(_profitRateController.text),
      'total_contract_value': _totalValue,
      'duration_months': int.parse(_durationController.text),
      'status': 'draft',
    };

    await ref.read(contractControllerProvider.notifier).createContract(data);
    
    if (mounted && !ref.read(contractControllerProvider).hasError) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء العقد بنجاح'), backgroundColor: Colors.green),
      );
      ref.invalidate(contractsListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersListProvider());
    final vehiclesAsync = ref.watch(vehiclesListProvider(status: 'available'));

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء عقد تمويل جديد')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('1. اختيار الأطراف'),
                const SizedBox(height: 16),
                
                // اختيار العميل
                customersAsync.when(
                  data: (list) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'العميل *', border: OutlineInputBorder()),
                    items: list.map((c) => DropdownMenuItem(value: c.id, child: Text(c.fullName))).toList(),
                    onChanged: (val) => setState(() => _selectedCustomerId = val),
                    validator: (v) => v == null ? 'مطلوب' : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('خطأ في تحميل العملاء'),
                ),
                const SizedBox(height: 16),

                // اختيار المركبة
                vehiclesAsync.when(
                  data: (list) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'المركبة المتاحة *', border: OutlineInputBorder()),
                    items: list.map((v) => DropdownMenuItem(value: v.id, child: Text('${v.make} ${v.model} (${v.year}) - ${v.licensePlate ?? ''}'))).toList(),
                    onChanged: (val) => setState(() => _selectedVehicleId = val),
                    validator: (v) => v == null ? 'مطلوب' : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('خطأ في تحميل المخزون'),
                ),
                
                const SizedBox(height: 32),
                _buildSectionTitle('2. البيانات المالية'),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _principalController,
                  decoration: const InputDecoration(labelText: 'المبلغ الأساسي (سعر البيع) *', border: OutlineInputBorder(), suffixText: 'ر.س'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _calculateTotals(),
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _profitRateController,
                        decoration: const InputDecoration(labelText: 'نسبة الربح الإجمالية % *', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotals(),
                        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(labelText: 'مدة التمويل (بالأشهر) *', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotals(),
                        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                _buildSummaryCard(),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                    child: const Text('حفظ العقد كمسودة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final currency = intl.NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          _buildSummaryRow('إجمالي قيمة العقد:', currency.format(_totalValue), isBold: true),
          const Divider(),
          _buildSummaryRow('القسط الشهري التقديري:', currency.format(_monthlyInstallment)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey));
  }
}
