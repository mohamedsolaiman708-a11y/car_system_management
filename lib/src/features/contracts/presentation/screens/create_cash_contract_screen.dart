import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
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
        title: const Text(
          'إنشاء عقد بيع نقدي مباشر',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.white),
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildFormHeader(),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
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
                          const SizedBox(height: 24),

                          // الشهود وملاحظات العقد
                          _buildSectionCard(
                            stepNumber: '٥',
                            title: 'الشهود وملاحظات العقد النقدي',
                            icon: Icons.assignment_rounded,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      _witness1NameController,
                                      'اسم الشاهد الأول',
                                      Icons.people_outline_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      _witness2NameController,
                                      'اسم الشاهد الثاني',
                                      Icons.people_outline_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
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

                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'اعتماد وإنشاء عقد البيع النقدي المباشر',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
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
      padding: const EdgeInsets.all(28),
      color: AppColors.primaryNavy,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payments_rounded,
                color: AppColors.accentGold,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'قسم عقود البيع النقدي المباشر',
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'إصدار عقد بيع نقدي مباشر وتسليم السيارة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primaryNavy,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: AppColors.accentGold, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primaryNavy,
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
        value: _selectedVehicleId,
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
        value: _selectedInvestorId,
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
        value: _selectedCustomerId,
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
        if (isRequired && (val == null || val.isEmpty))
          return 'هذا الحقل مطلوب';
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

  Widget _buildCashSummaryCard() {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    final price = double.tryParse(_cashPriceController.text) ?? 0.0;

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
                'إجمالي قيمة العقد النقدي المباشر',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'سعر المركبة النقدي صافي',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '${f.format(price)} ر.س',
                style: const TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
