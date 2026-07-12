import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../../domain/vehicle.dart';
import '../inventory_controller.dart';

class EditVehicleScreen extends ConsumerStatefulWidget {
  final String id;
  const EditVehicleScreen({super.key, required this.id});

  @override
  ConsumerState<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends ConsumerState<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _vinController;
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _colorController;
  late TextEditingController _plateController;
  late TextEditingController _priceController;
  late TextEditingController _marketValueController;

  String _status = 'available';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _vinController = TextEditingController();
    _makeController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    _colorController = TextEditingController();
    _plateController = TextEditingController();
    _priceController = TextEditingController();
    _marketValueController = TextEditingController();
  }

  void _initFields(Vehicle vehicle) {
    if (_initialized) return;
    
    _vinController.text = vehicle.vin;
    _makeController.text = vehicle.make;
    _modelController.text = vehicle.model;
    _yearController.text = vehicle.year.toString();
    _colorController.text = vehicle.color ?? '';
    _plateController.text = vehicle.licensePlate ?? '';
    _priceController.text = vehicle.purchasePrice.toString();
    _marketValueController.text = vehicle.estimatedMarketValue?.toString() ?? '';
    _status = vehicle.status;
    
    _initialized = true;
  }

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

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'vin': _vinController.text.trim().toUpperCase(),
      'make': _makeController.text.trim(),
      'model': _modelController.text.trim(),
      'year': int.tryParse(_yearController.text) ?? 0,
      'color': _colorController.text.trim(),
      'license_plate': _plateController.text.isEmpty ? null : _plateController.text.trim(),
      'purchase_price': double.tryParse(_priceController.text) ?? 0.0,
      'estimated_market_value': double.tryParse(_marketValueController.text),
      'status': _status,
    };

    await ref.read(inventoryControllerProvider.notifier).updateVehicle(widget.id, data);
    
    if (mounted && !ref.read(inventoryControllerProvider).hasError) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث بيانات المركبة بنجاح'), backgroundColor: Colors.green),
      );
      ref.invalidate(vehicleDetailsProvider(widget.id));
      ref.invalidate(vehiclesListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(vehicleDetailsProvider(widget.id));
    final state = ref.watch(inventoryControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('تعديل بيانات المركبة', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: vehicleAsync.when(
        data: (vehicle) {
          if (vehicle == null) return const Center(child: Text('المركبة غير موجودة'));
          _initFields(vehicle);
          
          return state.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildClassicSection('بيانات الهوية والمواصفات', [
                        _buildField(_vinController, 'رقم الهيكل (VIN) *'),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _buildField(_makeController, 'الماركة *')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildField(_modelController, 'الموديل *')),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _buildField(_yearController, 'سنة الصنع *', isNumber: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildField(_colorController, 'اللون')),
                        ]),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _status,
                          style: const TextStyle(fontSize: 13, color: AppColors.primaryNavy),
                          decoration: const InputDecoration(
                            labelText: 'حالة المركبة', labelStyle: TextStyle(fontSize: 12),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'available', child: Text('متوفرة')),
                            DropdownMenuItem(value: 'on_contract', child: Text('تحت عقد')),
                            DropdownMenuItem(value: 'maintenance', child: Text('صيانة')),
                          ],
                          onChanged: (v) => setState(() => _status = v!),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildClassicSection('البيانات المالية واللوحة', [
                        _buildField(_plateController, 'رقم اللوحة'),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _buildField(_priceController, 'سعر الشراء *', isNumber: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildField(_marketValueController, 'القيمة السوقية', isNumber: true)),
                        ]),
                      ]),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _update,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text('حفظ التعديلات النهائية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      ),
    );
  }

  Widget _buildClassicSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const Divider(height: 24),
        ...children,
      ]),
    );
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
      validator: (v) => (v == null || v.isEmpty) && label.contains('*') ? 'مطلوب' : null,
    );
  }
}
