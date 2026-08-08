import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../../../crm/presentation/crm_controller.dart';
import '../../../inventory/presentation/inventory_controller.dart';
import '../../../inventory/domain/vehicle.dart';
import '../../../investors/presentation/investor_controller.dart';
import '../../../investors/domain/investor.dart';
import '../contract_controller.dart';

class CreateCashContractScreen extends ConsumerStatefulWidget {
  final String? initialVehicleId;
  final String? initialCustomerId;

  const CreateCashContractScreen({
    super.key,
    this.initialVehicleId,
    this.initialCustomerId,
  });

  @override
  ConsumerState<CreateCashContractScreen> createState() =>
      _CreateCashContractScreenState();
}

class _CreateCashContractScreenState
    extends ConsumerState<CreateCashContractScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _selectedVehicleId;
  String? _selectedInvestorId;
  String? _selectedCustomerId;

  final _cashPriceController = TextEditingController();
  final _servicesCollectedController = TextEditingController();
  final _servicesCostController = TextEditingController();
  final _witness1NameController = TextEditingController();
  final _witness2NameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _contractDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.initialVehicleId;
    _selectedCustomerId = widget.initialCustomerId;
  }

  @override
  void dispose() {
    _cashPriceController.dispose();
    _servicesCollectedController.dispose();
    _servicesCostController.dispose();
    _witness1NameController.dispose();
    _witness2NameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate() ||
        _selectedVehicleId == null ||
        _selectedInvestorId == null ||
        _selectedCustomerId == null) {
      SnackBarHelper.showWarning(
        context,
        'يرجى اختيار السيارة والمستثمر والعميل المشتري لاستكمال العقد النقدي',
      );
      return;
    }

    setState(() => _isLoading = true);

    final cashPrice = double.tryParse(_cashPriceController.text) ?? 0.0;

    final data = {
      'type': 'cash',
      'inventory_item_id': _selectedVehicleId,
      'investor_id': _selectedInvestorId,
      'customer_id': _selectedCustomerId,
      'principal_amount': cashPrice,
      'finance_profit_rate': 0.0,
      'total_contract_value': cashPrice,
      'down_payment': cashPrice,
      'duration_months': 1,
      'start_date': _contractDate.toIso8601String(),
      'status': 'draft',
      'notes': _notesController.text.trim(),
      'witness_1': _witness1NameController.text.trim(),
      'witness_2': _witness2NameController.text.trim(),
    };

    try {
      await ref.read(contractControllerProvider.notifier).createContract(data);
      final controllerState = ref.read(contractControllerProvider);

      if (controllerState.hasError) {
        if (mounted) {
          SnackBarHelper.showError(context, controllerState.error);
        }
      } else {
        if (mounted) {
          ref.invalidate(contractsListProvider);
          context.pop();
          SnackBarHelper.showSuccess(
            context,
            'تم إنشاء مسودة عقد البيع النقدي المباشر بنجاح',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesListProvider(status: 'available'));
    final investorsAsync = ref.watch(investorListControllerProvider);
    final customersAsync = ref.watch(customersListProvider());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        // إضافة أيقونة الرجوع يدوياً لضمان ظهورها دائماً
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'إنشاء عقد بيع نقدي مباشر',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryNavy),
                  SizedBox(height: 16),
                  Text(
                    'جاري إنشاء عقد البيع النقدي وتوليد السجلات...',
                    style: TextStyle(
                      color: AppColors.primaryNavy, // تعديل اللون ليصبح مرئياً
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    children: [
                      _buildFormHeader(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveLayout.isMobile(context) ? 16 : 24,
                          vertical: 24,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // 1. السيارة من المخزون
                              _buildSectionCard(
                                stepNumber: '١',
                                title: 'اختيار السيارة (من المخزون)',
                                icon: Icons.directions_car_rounded,
                                children: [_buildVehicleDropdown(vehiclesAsync)],
                              ),
                              const SizedBox(height: 24),

                              // 2. المستثمر (الطرف الأول - البائع)
                              _buildSectionCard(
                                stepNumber: '٢',
                                title: 'الطرف الأول: المستثمر (البائع الممول)',
                                icon: Icons.account_balance_wallet_rounded,
                                children: [_buildInvestorDropdown(investorsAsync)],
                              ),
                              const SizedBox(height: 24),

                              // 3. المشتري (الطرف الثاني)
                              _buildSectionCard(
                                stepNumber: '٣',
                                title: 'الطرف الثاني: المشتري',
                                icon: Icons.person_rounded,
                                children: [_buildCustomerDropdown(customersAsync)],
                              ),
                              const SizedBox(height: 24),

                              // 4. سعر البيع النقدي المباشر وتاريخ البيع
                              _buildSectionCard(
                                stepNumber: '٤',
                                title: 'سعر البيع النقدي وتاريخ العقد',
                                icon: Icons.payments_rounded,
                                children: [
                                  _buildTextField(
                                    _cashPriceController,
                                    'سعر البيع النقدي المباشر (ريال سعودي) *',
                                    Icons.payments_rounded,
                                    isNumber: true,
                                    isRequired: true,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDatePickerField(
                                    label: 'تاريخ عقد البيع النقدي',
                                    date: _contractDate,
                                    onSelect: (d) =>
                                        setState(() => _contractDate = d),
                                  ),
                                ],
                              ),
                              // 5. خدمات نقل الملكية والإصدار الاختيارية
                              _buildOptionalServicesCard(),
                              const SizedBox(height: 24),

                              // 6. الشهود وملاحظات العقد
                              _buildSectionCard(
                                stepNumber: '٦',
                                title: 'ملاحظات العقد النقدي',
                                icon: Icons.assignment_rounded,
                                children: [
                                  _buildTextField(
                                    _notesController,
                                    'شروط أو ملاحظات إضافية على البيع النقدي',
                                    Icons.notes_rounded,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              _buildCashSummaryCard(),
                              const SizedBox(height: 40),

                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _submit,
                                icon: const Icon(Icons.check_circle_rounded, size: 22),
                                label: const Text(
                                  'اعتماد وإنشاء عقد البيع النقدي المباشر',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryNavy,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 4,
                                  shadowColor: AppColors.primaryNavy.withValues(alpha: 0.4),
                                ),
                              ),
                              const SizedBox(height: 60),
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
                child: const Icon(
                  Icons.payments_rounded,
                  color: AppColors.accentGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'قسم عقود البيع النقدي المباشر',
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'إصدار عقد بيع نقدي مباشر وتسليم السيارة',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveLayout.isMobile(context) ? 20 : 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'تعبئة أطراف العقد والقيمة النقدية لاعتماد الفاتورة والسندات تلقائياً',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String stepNumber,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primaryNavy,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.accentGold, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          ...children,
        ],
      ),
    );
  }

  Widget _buildVehicleDropdown(AsyncValue<List<Vehicle>> asyncData) {
    return asyncData.when(
      data: (list) => DropdownButtonFormField<String>(
        initialValue: _selectedVehicleId,
        decoration: InputDecoration(
          labelText: 'اختر السيارة من قائمة السيارات المتاحة بالمخزون *',
          prefixIcon: const Icon(
            Icons.directions_car,
            color: AppColors.primaryNavy,
          ),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: list.map((v) {
          final title =
              '${v.make} ${v.model} (${v.year}) - لوحة: ${v.licensePlate ?? "بدون"}';
          return DropdownMenuItem<String>(
            value: v.id,
            child: Text(title, style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            final vehicle = list.firstWhere((x) => x.id == val);
            _cashPriceController.text = vehicle.purchasePrice.toString();
          }
          setState(() => _selectedVehicleId = val);
        },
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('حدث خطأ أثناء تحميل سيارات المخزون'),
    );
  }

  Widget _buildInvestorDropdown(AsyncValue<List<Investor>> asyncData) {
    return asyncData.when(
      data: (list) => DropdownButtonFormField<String>(
        initialValue: _selectedInvestorId,
        decoration: InputDecoration(
          labelText: 'اختر المستثمر (الطرف الأول - البائع) *',
          prefixIcon: const Icon(
            Icons.account_balance_wallet,
            color: AppColors.primaryNavy,
          ),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: list.map((inv) {
          return DropdownMenuItem<String>(
            value: inv.id,
            child: Text(inv.fullName, style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedInvestorId = val),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('حدث خطأ أثناء تحميل قائمة المستثمرين'),
    );
  }

  Widget _buildCustomerDropdown(AsyncValue asyncData) {
    return asyncData.when(
      data: (list) => DropdownButtonFormField<String>(
        initialValue: _selectedCustomerId,
        decoration: InputDecoration(
          labelText: 'اختر المشتري (الطرف الثاني) *',
          prefixIcon: const Icon(Icons.person, color: AppColors.primaryNavy),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: (list as List).map((c) {
          return DropdownMenuItem<String>(
            value: c.id,
            child: Text(c.fullName, style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedCustomerId = val),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('حدث خطأ أثناء تحميل قائمة العملاء'),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: (val) {
        if (isRequired && (val == null || val.isEmpty)) {
          return 'هذا الحقل مطلوب';
        }
        if (isNumber && val != null && val.isNotEmpty) {
          final numVal = double.tryParse(val);
          if (numVal == null) return 'يرجى إدخال رقم صحيح';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.primaryNavy),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onSelect,
  }) {
    final formatted = intl.DateFormat('dd / MM / yyyy').format(date);
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2040),
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: AppColors.primaryNavy,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  formatted,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalServicesCard() {
    return _buildSectionCard(
      stepNumber: '٥',
      title: 'خدمات نقل الملكية والإصدار (اختيارية)',
      icon: Icons.design_services_rounded,
      children: [
        const Text(
          'تشمل خدمات نقل الملكية، تجديد الرخصة، سداد المخالفات، تغيير اللوحات، التأمين، ومنصة تم.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          _servicesCollectedController,
          'إجمالي المبلغ المستلم من العميل مقابل الخدمات (ريال)',
          Icons.payments_outlined,
          isNumber: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          _servicesCostController,
          'إجمالي التكلفة الحكومية الفعلية المسددة (ريال)',
          Icons.account_balance_wallet_outlined,
          isNumber: true,
        ),
      ],
    );
  }

  Widget _buildCashSummaryCard() {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final vehiclePrice = double.tryParse(_cashPriceController.text) ?? 0.0;
    final collectedServices = double.tryParse(_servicesCollectedController.text) ?? 0.0;
    final costServices = double.tryParse(_servicesCostController.text) ?? 0.0;

    final grossRevenue = (collectedServices - costServices) > 0 ? (collectedServices - costServices) : 0.0;
    final netProfit = grossRevenue / 1.15;
    final vatAmount = grossRevenue - netProfit;
    final grandTotal = vehiclePrice + collectedServices;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.task_alt_rounded, color: AppColors.accentGold),
              SizedBox(width: 10),
              Text(
                'ملخص العمليات المالية والمحاسبية للمبيعات النقدية',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          _summaryRow('سعر المركبة الاتفاقي النقدي', '${f.format(vehiclePrice)} ر.س', isGold: true),
          if (collectedServices > 0) ...[
            const SizedBox(height: 8),
            _summaryRow('إجمالي المقبوض للخدمات', '${f.format(collectedServices)} ر.س'),
            _summaryRow('التكلفة الحكومية المسددة', '${f.format(costServices)} ر.س'),
            _summaryRow('الإيراد الخاضع للضريبة', '${f.format(grossRevenue)} ر.س'),
            _summaryRow('الصافي المعترف به كإيراد', '${f.format(netProfit)} ر.س'),
            _summaryRow('ضريبة القيمة المضافة المستحقة (15%)', '${f.format(vatAmount)} ر.س'),
          ],
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إجمالي الدفعة المستلمة من المشتري', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${f.format(grandTotal)} ر.س', style: const TextStyle(color: AppColors.accentGold, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isGold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: isGold ? AppColors.accentGold : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
