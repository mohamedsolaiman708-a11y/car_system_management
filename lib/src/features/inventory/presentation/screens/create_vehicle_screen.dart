import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../inventory_controller.dart';

class CreateVehicleScreen extends ConsumerStatefulWidget {
  const CreateVehicleScreen({super.key});

  @override
  ConsumerState<CreateVehicleScreen> createState() => _CreateVehicleScreenState();
}

class _CreateVehicleScreenState extends ConsumerState<CreateVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _vinController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();
  final _priceController = TextEditingController();
  final _marketValueController = TextEditingController();

  @override
  void dispose() {
    _vinController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _priceController.dispose();
    _marketValueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'vin': _vinController.text.trim().toUpperCase(),
      'make': _makeController.text.trim(),
      'model': _modelController.text.trim(),
      'year': int.tryParse(_yearController.text) ?? DateTime.now().year,
      'color': _colorController.text.trim(),
      'license_plate': _plateController.text.isEmpty ? null : _plateController.text.trim(),
      'purchase_price': double.tryParse(_priceController.text) ?? 0.0,
      'estimated_market_value': double.tryParse(_marketValueController.text),
      'status': 'available',
      'technical_specs': {},
    };

    await ref.read(inventoryControllerProvider.notifier).createVehicle(data);
    
    if (mounted && !ref.read(inventoryControllerProvider).hasError) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة المركبة بنجاح')));
      ref.invalidate(vehiclesListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('إدراج مركبة جديدة', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildClassicSection('معلومات المركبة الأساسية', [
                    _buildRow([
                      _buildField(_vinController, 'رقم الهيكل (VIN) *'),
                    ]),
                    const SizedBox(height: 12),
                    _buildRow([
                      _buildField(_makeController, 'الماركة *'),
                      _buildField(_modelController, 'الموديل *'),
                    ]),
                    const SizedBox(height: 12),
                    _buildRow([
                      _buildField(_yearController, 'سنة الصنع *', isNumber: true),
                      _buildField(_colorController, 'اللون الخارجي'),
                    ]),
                  ]),
                  const SizedBox(height: 20),
                  _buildClassicSection('البيانات المالية واللوحة', [
                    _buildRow([
                      _buildField(_plateController, 'رقم اللوحة'),
                      _buildField(_priceController, 'سعر الشراء *', isNumber: true),
                    ]),
                    const SizedBox(height: 12),
                    _buildRow([
                      _buildField(_marketValueController, 'القيمة السوقية التقديرية', isNumber: true),
                      const Spacer(),
                    ]),
                  ]),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                      child: const Text('حفظ المركبة في المخزون', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildClassicSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const Divider(height: 32),
        ...children,
      ]),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c))).toList());
  }

  Widget _buildField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
    );
  }
}
