import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      'vin': _vinController.text,
      'make': _makeController.text,
      'model': _modelController.text,
      'year': int.tryParse(_yearController.text) ?? DateTime.now().year,
      'color': _colorController.text,
      'license_plate': _plateController.text.isEmpty ? null : _plateController.text,
      'purchase_price': double.tryParse(_priceController.text) ?? 0.0,
      'estimated_market_value': double.tryParse(_marketValueController.text),
      'status': 'available',
      'technical_specs': {},
    };

    await ref.read(inventoryControllerProvider.notifier).createVehicle(data);
    
    if (mounted && !ref.read(inventoryControllerProvider).hasError) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة المركبة للمخزون بنجاح'), backgroundColor: Colors.green),
      );
      ref.invalidate(vehiclesListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مركبة جديدة'),
      ),
      body: state.isLoading 
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
                    _buildSectionTitle('بيانات المركبة الأساسية'),
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
                            decoration: const InputDecoration(labelText: 'الماركة (مثلاً: تويوتا) *', border: OutlineInputBorder()),
                            validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _modelController,
                            decoration: const InputDecoration(labelText: 'الموديل (مثلاً: كامري) *', border: OutlineInputBorder()),
                            validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _yearController,
                            decoration: const InputDecoration(labelText: 'سنة الصنع *', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _colorController,
                            decoration: const InputDecoration(labelText: 'اللون', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('اللوحة والبيانات المالية'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(labelText: 'رقم اللوحة (إن وجد)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(labelText: 'سعر الشراء *', border: OutlineInputBorder(), suffixText: 'ر.س'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _marketValueController,
                            decoration: const InputDecoration(labelText: 'القيمة السوقية التقديرية', border: OutlineInputBorder(), suffixText: 'ر.س'),
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
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('حفظ المركبة في المخزون', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
