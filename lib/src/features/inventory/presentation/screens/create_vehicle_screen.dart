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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('تمت إضافة المركبة بنجاح إلى المخزون المالي'),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      ref.invalidate(vehiclesListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('إدراج أصل جديد للمخزون', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: state.isLoading 
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
                        _buildSectionCard(
                          title: 'بيانات الهوية التقنية للمركبة',
                          icon: Icons.fingerprint_rounded,
                          children: [
                            _buildPremiumTextField(
                              controller: _vinController,
                              label: 'رقم الهيكل (VIN) - 17 خانة',
                              prefixIcon: Icons.qr_code_rounded,
                              validator: (v) => v == null || v.isEmpty ? 'رقم الهيكل مطلوب للتوثيق' : null,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPremiumTextField(
                                    controller: _makeController,
                                    label: 'الماركة (تويوتا، الخ)',
                                    prefixIcon: Icons.branding_watermark_rounded,
                                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildPremiumTextField(
                                    controller: _modelController,
                                    label: 'الموديل (كامري، الخ)',
                                    prefixIcon: Icons.directions_car_rounded,
                                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPremiumTextField(
                                    controller: _yearController,
                                    label: 'سنة الصنع',
                                    prefixIcon: Icons.calendar_today_rounded,
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildPremiumTextField(
                                    controller: _colorController,
                                    label: 'اللون الخارجي',
                                    prefixIcon: Icons.color_lens_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSectionCard(
                          title: 'بيانات التسجيل والقيمة المالية',
                          icon: Icons.account_balance_rounded,
                          children: [
                            _buildPremiumTextField(
                              controller: _plateController,
                              label: 'رقم اللوحة (إن وجد)',
                              prefixIcon: Icons.pin_rounded,
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPremiumTextField(
                                    controller: _priceController,
                                    label: 'سعر الشراء الفعلي',
                                    prefixIcon: Icons.payments_rounded,
                                    suffix: const Text('ر.س', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildPremiumTextField(
                                    controller: _marketValueController,
                                    label: 'القيمة السوقية الحالية',
                                    prefixIcon: Icons.analytics_rounded,
                                    suffix: const Text('ر.س', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 64),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 8,
                            shadowColor: AppColors.primaryNavy.withOpacity(0.4),
                          ),
                          child: const Text('حفظ المركبة في المخزون العام', 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('إلغاء الإدراج والعودة', style: TextStyle(color: Colors.grey)),
                        ),
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
          const Text('نموذج تسجيل أصل', 
            style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          const Text('إضافة مركبة جديدة للنظام المالي', 
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('تأكد من دقة رقم الهيكل (VIN) وسعر الشراء لضمان سلامة العمليات المحاسبية.', 
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.4)),
        ],
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.accentGold.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.accentGold, size: 20),
              ),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            ],
          ),
          const SizedBox(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, size: 20, color: Colors.grey.shade400),
        suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.all(14.0), child: suffix) : null,
        filled: true,
        fillColor: AppColors.bgGrey.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5)),
      ),
    );
  }
}
