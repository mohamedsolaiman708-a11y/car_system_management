import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      'vin': _vinController.text,
      'make': _makeController.text,
      'model': _modelController.text,
      'year': int.tryParse(_yearController.text) ?? 0,
      'color': _colorController.text,
      'license_plate': _plateController.text.isEmpty ? null : _plateController.text,
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
      appBar: AppBar(
        title: const Text('تعديل بيانات المركبة'),
      ),
      body: vehicleAsync.when(
        data: (vehicle) {
          if (vehicle == null) return const Center(child: Text('المركبة غير موجودة'));
          _initFields(vehicle);
          
          return state.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Directionality(
                textDirection: TextDirection.rtl,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('بيانات المركبة'),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _vinController,
                          decoration: const InputDecoration(labelText: 'رقم الهيكل (VIN) *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _makeController,
                                decoration: const InputDecoration(labelText: 'الماركة *', border: OutlineInputBorder()),
                                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _modelController,
                                decoration: const InputDecoration(labelText: 'الموديل *', border: OutlineInputBorder()),
                                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: const InputDecoration(labelText: 'حالة المركبة', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'available', child: Text('متوفرة')),
                            DropdownMenuItem(value: 'on_contract', child: Text('في عقد')),
                            DropdownMenuItem(value: 'maintenance', child: Text('صيانة')),
                          ],
                          onChanged: (v) => setState(() => _status = v!),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('البيانات المالية واللوحة'),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _plateController,
                          decoration: const InputDecoration(labelText: 'رقم اللوحة', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                decoration: const InputDecoration(labelText: 'سعر الشراء *', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _marketValueController,
                                decoration: const InputDecoration(labelText: 'القيمة السوقية', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _update,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade800,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('تحديث بيانات المركبة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
    );
  }
}
