import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/utils/snack_bar_helper.dart';
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
    final state = ref.read(inventoryControllerProvider);

    if (mounted) {
      if (state.hasError) {
        SnackBarHelper.showError(context, state.error);
      } else {
        context.pop();
        SnackBarHelper.showSuccess(context, 'تمت إضافة المركبة بنجاح إلى المخزون المالي');
        ref.invalidate(vehiclesListProvider);
      }
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    children: [
                      _buildFormHeader(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveLayout.isMobile(context) ? 16 : 32,
                          vertical: 24,
                        ),
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
                                  ResponsiveFormRow(
                                    children: [
                                      _buildPremiumTextField(
                                        controller: _makeController,
                                        label: 'الماركة (تويوتا، نيسان، إلخ)',
                                        prefixIcon: Icons.branding_watermark_rounded,
                                        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                      ),
                                      _buildPremiumTextField(
                                        controller: _modelController,
                                        label: 'الموديل (كامري، باترول، إلخ)',
                                        prefixIcon: Icons.directions_car_rounded,
                                        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  ResponsiveFormRow(
                                    children: [
                                      _buildPremiumTextField(
                                        controller: _yearController,
                                        label: 'سنة الصنع',
                                        prefixIcon: Icons.calendar_today_rounded,
                                        keyboardType: TextInputType.number,
                                        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                      ),
                                      _buildPremiumTextField(
                                        controller: _colorController,
                                        label: 'اللون الخارجي',
                                        prefixIcon: Icons.color_lens_rounded,
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
                                  ResponsiveFormRow(
                                    children: [
                                      _buildPremiumTextField(
                                        controller: _priceController,
                                        label: 'سعر الشراء الفعلي',
                                        prefixIcon: Icons.payments_rounded,
                                        suffix: const Text('ر.س', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryNavy)),
                                        keyboardType: TextInputType.number,
                                        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                      ),
                                      _buildPremiumTextField(
                                        controller: _marketValueController,
                                        label: 'القيمة السوقية الحالية',
                                        prefixIcon: Icons.analytics_rounded,
                                        suffix: const Text('ر.س', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryNavy)),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              ElevatedButton.icon(
                                onPressed: _save,
                                icon: const Icon(Icons.check_circle_rounded, size: 22),
                                label: const Text('حفظ المركبة في المخزون العام',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryNavy,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 60),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  elevation: 4,
                                  shadowColor: AppColors.primaryNavy.withValues(alpha: 0.4),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text('إلغاء الإدراج والعودة', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveLayout.isMobile(context) ? 20 : 32),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.time_to_leave_rounded, color: AppColors.accentGold, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'إدارة المخزون — إضافة أصل',
                style: TextStyle(color: AppColors.accentGold, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'إدخال مركبة جديدة في أصول المعرض',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveLayout.isMobile(context) ? 20 : 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'تأكد من دقة رقم الهيكل (VIN) وسعر الشراء لضمان دقة العمليات المحاسبية.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryNavy.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.accentGold, size: 20),
              ),
              const SizedBox(width: 14),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            ],
          ),
          const SizedBox(height: 28),
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
        prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.primaryNavy),
        suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.all(14.0), child: suffix) : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
        ),
      ),
    );
  }
}
