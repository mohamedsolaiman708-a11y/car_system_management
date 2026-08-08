import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../../../crm/presentation/crm_controller.dart';
import '../../../crm/domain/customer.dart';
import '../../../inventory/presentation/inventory_controller.dart';
import '../../../inventory/domain/vehicle.dart';
import '../../../investors/presentation/investor_controller.dart';
import '../../../investors/domain/investor.dart';
import '../contract_controller.dart';

class CreateInstallmentContractScreen extends ConsumerStatefulWidget {
  final String? initialVehicleId;
  final String? initialCustomerId;

  const CreateInstallmentContractScreen({
    super.key,
    this.initialVehicleId,
    this.initialCustomerId,
  });

  @override
  ConsumerState<CreateInstallmentContractScreen> createState() =>
      _CreateInstallmentContractScreenState();
}

class _CreateInstallmentContractScreenState
    extends ConsumerState<CreateInstallmentContractScreen> {
  int _currentStep = 0;

  // نوع عقد الأجل: أقساط أو وعدة (دفع مؤجل)
  String _installmentSubtype = 'installments'; // 'installments' | 'waada'

  // البيانات الأساسية
  final List<Vehicle> _selectedVehicles = [];
  Investor? _selectedInvestor;
  Customer? _selectedCustomer;
  
  // بيانات الكفيل
  bool _hasGuarantor = false;
  int _guarantorCount = 1; // 1 or 2
  final _g1NameController = TextEditingController();
  final _g1IdController = TextEditingController();
  final _g1PhoneController = TextEditingController();
  final _g1WorkController = TextEditingController();

  final _g2NameController = TextEditingController();
  final _g2IdController = TextEditingController();
  final _g2PhoneController = TextEditingController();
  final _g2WorkController = TextEditingController();

  // الحقول المالية
  final _totalSalePriceController = TextEditingController();
  final _installmentAmountController = TextEditingController();
  final DateTime _contractDate = DateTime.now();
  DateTime _firstInstallmentDate = DateTime.now().add(const Duration(days: 30));
  DateTime _waadaDueDate = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _totalSalePriceController.dispose();
    _installmentAmountController.dispose();
    _g1NameController.dispose();
    _g1IdController.dispose();
    _g1PhoneController.dispose();
    _g1WorkController.dispose();
    _g2NameController.dispose();
    _g2IdController.dispose();
    _g2PhoneController.dispose();
    _g2WorkController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_currentStep == 0 && _selectedVehicles.isEmpty) {
        SnackBarHelper.showWarning(context, 'يرجى اختيار سيارة واحدة على الأقل من المخزون');
        return;
      }
      if (_currentStep == 1 && (_selectedInvestor == null || _selectedCustomer == null)) {
        SnackBarHelper.showWarning(context, 'يرجى تحديد أطراف العقد (البائع والمشتري)');
        return;
      }
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _submit() async {
    final double totalValue = double.tryParse(_totalSalePriceController.text) ?? 0;

    if (totalValue <= 0) {
      SnackBarHelper.showError(context, 'يرجى إدخال سعر بيع صحيح');
      return;
    }

    int duration = 1;

    if (_installmentSubtype == 'installments') {
      final double instValue = double.tryParse(_installmentAmountController.text) ?? 0;
      if (instValue <= 0) {
        SnackBarHelper.showError(context, 'يرجى إدخال قيمة قسط صحيحة');
        return;
      }
      duration = (totalValue / instValue).ceil();
    } else {
      // وعدة
      final daysDiff = _waadaDueDate.difference(_contractDate).inDays;
      duration = (daysDiff / 30).ceil();
      if (duration < 1) duration = 1;
    }

    final data = {
      'type': 'installments',
      'inventory_item_id': _selectedVehicles.isNotEmpty ? _selectedVehicles.first.id : null,
      'investor_id': _selectedInvestor?.id,
      'customer_id': _selectedCustomer?.id,
      'principal_amount': totalValue,
      'total_contract_value': totalValue,
      'finance_profit_rate': 0.0,
      'duration_months': duration,
      'start_date': _contractDate.toIso8601String(),
      'status': 'draft',
      'notes': _installmentSubtype == 'waada' ? 'عقد بيع بالأجل (وعدة - سداد دفعة واحدة)' : 'عقد بيع بالأجل (أقساط)',
      'vehicles_list': _selectedVehicles.map((v) => {
        'id': v.id,
        'make': v.make,
        'model': v.model,
        'year': v.year,
        'license_plate': v.licensePlate,
      }).toList(),
      if (_hasGuarantor) ...{
        'guarantor_1_name': _g1NameController.text.trim(),
        'guarantor_1_id': _g1IdController.text.trim(),
        'guarantor_1_phone': _g1PhoneController.text.trim(),
        'guarantor_1_work': _g1WorkController.text.trim(),
        if (_guarantorCount == 2) ...{
          'guarantor_2_name': _g2NameController.text.trim(),
          'guarantor_2_id': _g2IdController.text.trim(),
          'guarantor_2_phone': _g2PhoneController.text.trim(),
          'guarantor_2_work': _g2WorkController.text.trim(),
        },
      },
    };

    final success = await ref.read(contractControllerProvider.notifier).createContract(data);

    if (success && mounted) {
      SnackBarHelper.showSuccess(context, 'تم إنشاء مسودة عقد البيع بالأجل بنجاح');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final contractState = ref.watch(contractControllerProvider);
    final isLoading = contractState.isLoading;

    if (widget.initialCustomerId != null && _selectedCustomer == null) {
      final customers = ref.watch(customersListProvider()).valueOrNull;
      if (customers != null) {
        try {
          _selectedCustomer = customers.firstWhere((c) => c.id == widget.initialCustomerId);
        } catch (_) {}
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryNavy,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: const Text('إصدار عقد بيع بالأجل (أقساط / وعدة)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('خطوة ${_currentStep + 1} من 3', style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy))
                  : SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 860),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveLayout.isMobile(context) ? 16 : 32,
                              vertical: 24,
                            ),
                            child: _buildCurrentStep(),
                          ),
                        ),
                      ),
                    ),
            ),
            _buildControlButtons(isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final steps = [
      {'title': 'اختيار السيارات', 'icon': Icons.directions_car_rounded},
      {'title': 'أطراف العقد', 'icon': Icons.people_alt_rounded},
      {'title': 'الحسابات والجدولة', 'icon': Icons.calculate_rounded},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.isMobile(context) ? 16 : 32,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (index) {
              final isCurrent = index == _currentStep;
              final isPassed = index < _currentStep;
              final stepData = steps[index];

              return Expanded(
                child: GestureDetector(
                  onTap: isPassed ? () => setState(() => _currentStep = index) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.accentGold.withValues(alpha: 0.15)
                          : isPassed
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.accentGold
                            : isPassed
                                ? Colors.white24
                                : Colors.white10,
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? AppColors.accentGold
                                : isPassed
                                    ? Colors.white24
                                    : Colors.white10,
                          ),
                          child: Center(
                            child: isPassed
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isCurrent ? AppColors.primaryNavy : Colors.white54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                          ),
                        ),
                        if (!ResponsiveLayout.isMobile(context)) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              stepData['title'] as String,
                              style: TextStyle(
                                color: isCurrent ? AppColors.accentGold : Colors.white70,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: Colors.white10,
              color: AppColors.accentGold,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _stepVehicle();
      case 1: return _stepParties();
      case 2: return _stepFinancial();
      default: return const SizedBox();
    }
  }

  Widget _stepVehicle() {
    final vehiclesAsync = ref.watch(vehiclesListProvider(status: 'available'));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return _buildStepLayout(
      title: 'اختيار السيارات من المخزون',
      subtitle: 'اختر المركبات المتاحة بالمخزون المالي لإدراجها في العقد التعاقدي الحالي',
      icon: Icons.directions_car_filled_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          vehiclesAsync.when(
            data: (list) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        )
                      ],
                      border: Border.all(color: AppColors.primaryNavy.withValues(alpha: 0.1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'إضافة سيارة من المخزون المتاح',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 14),
                          prefixIcon: Icon(Icons.add_road_rounded, color: AppColors.accentGold, size: 24),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        items: list.map((v) => DropdownMenuItem(
                          value: v.id, 
                          child: Text(
                            '${v.make} ${v.model} (${v.year}) - لوحة: ${v.licensePlate ?? "بدون"}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final v = list.firstWhere((x) => x.id == val);
                            if (!_selectedVehicles.any((element) => element.id == v.id)) {
                              setState(() {
                                _selectedVehicles.add(v);
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_selectedVehicles.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.amber, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'لم يتم اختيار أي سيارة بعد. يرجى التحديد من القائمة أعلاه لبدء إجراءات العقد.',
                              style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: _selectedVehicles.map((v) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                          border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primaryNavy, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${v.make} ${v.model}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primaryNavy),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryNavy.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.primaryNavy.withValues(alpha: 0.1)),
                                        ),
                                        child: Text(
                                          'لوحة: ${v.licensePlate ?? "بدون"}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'الشراء: ${f.format(v.purchasePrice)} ر.س',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentGold.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'سنة ${v.year}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                              ),
                              onPressed: () => setState(() => _selectedVehicles.removeWhere((x) => x.id == v.id)),
                              tooltip: 'إزالة المركبة',
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('حدث خطأ في تحميل بيانات المخزون'),
          ),
        ],
      ),
    );
  }

  Widget _stepParties() {
    return _buildStepLayout(
      title: 'أطراف العقد والضمانات',
      subtitle: 'تحديد المستثمر الممول (البائع)، العميل (المشتري)، وبيانات الكفيل الغارم إن وجد',
      icon: Icons.people_alt_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchSelectionTile(
            label: 'المستثمر (الطرف الأول - البائع)',
            hint: 'انقر لاختيار المستثمر الممول...',
            icon: Icons.account_balance_rounded,
            selectedName: _selectedInvestor?.fullName,
            onTap: () => _showInvestorSearch(),
          ),
          const SizedBox(height: 20),
          _buildSearchSelectionTile(
            label: 'المشتري (الطرف الثاني - العميل)',
            hint: 'انقر لاختيار العميل المشتري...',
            icon: Icons.person_rounded,
            selectedName: _selectedCustomer?.fullName,
            onTap: () => _showCustomerSearch(),
          ),
          const SizedBox(height: 32),
          const Divider(height: 1),
          const SizedBox(height: 24),
          _buildGuarantorSection(),
        ],
      ),
    );
  }

  Widget _buildSearchSelectionTile({
    required String label,
    required String hint,
    required IconData icon,
    String? selectedName,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedName != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.primaryNavy, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryNavy.withValues(alpha: 0.03) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.accentGold : Colors.grey.shade300,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentGold.withValues(alpha: 0.15) : AppColors.bgGrey,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? AppColors.primaryNavy : Colors.grey,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSelected ? selectedName : hint,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryNavy : Colors.grey.shade600,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: isSelected ? 15 : 13,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 2),
                        const Text(
                          'طرف معتمد بالعقد',
                          style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryNavy : AppColors.bgGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isSelected ? 'تغيير' : 'اختيار',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primaryNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showInvestorSearch() {
    final investors = ref.read(investorListControllerProvider).valueOrNull ?? [];
    _showSearchPicker<Investor>(
      title: 'البحث عن مستثمر',
      items: investors,
      itemLabel: (i) => i.fullName,
      onSelect: (i) => setState(() => _selectedInvestor = i),
    );
  }

  void _showCustomerSearch() {
    final customers = ref.read(customersListProvider()).valueOrNull ?? [];
    _showSearchPicker<Customer>(
      title: 'البحث عن عميل',
      items: customers,
      itemLabel: (c) => '${c.fullName} - ${c.nationalId}',
      onSelect: (c) => setState(() => _selectedCustomer = c),
    );
  }

  void _showSearchPicker<T>({
    required String title,
    required List<T> items,
    required String Function(T) itemLabel,
    required Function(T) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchPickerSheet<T>(
        title: title,
        items: items,
        itemLabel: itemLabel,
        onSelect: (item) {
          onSelect(item);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildGuarantorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.security, color: AppColors.accentGold),
            const SizedBox(width: 8),
            const Text('بيانات الكفيل الغارم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            Switch(
              value: _hasGuarantor,
              onChanged: (v) => setState(() => _hasGuarantor = v),
              activeThumbColor: AppColors.accentGold,
              activeTrackColor: AppColors.accentGold.withValues(alpha: 0.4),
            ),
          ],
        ),
        if (_hasGuarantor) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text('كفيل واحد'),
                selected: _guarantorCount == 1,
                onSelected: (_) => setState(() => _guarantorCount = 1),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('كفيلان'),
                selected: _guarantorCount == 2,
                onSelected: (_) => setState(() => _guarantorCount = 2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('بيانات الكفيل الأول:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy)),
          const SizedBox(height: 8),
          _buildTextField(_g1NameController, 'اسم الكفيل الأول الكامل', Icons.person_outline),
          const SizedBox(height: 12),
          ResponsiveFormRow(
            children: [
              _buildTextField(_g1IdController, 'رقم الهوية', Icons.badge_outlined),
              _buildTextField(_g1PhoneController, 'رقم الجوال', Icons.phone_android),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(_g1WorkController, 'جهة العمل / المهنة', Icons.work_outline),
          if (_guarantorCount == 2) ...[
            const SizedBox(height: 24),
            const Text('بيانات الكفيل الثاني:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy)),
            const SizedBox(height: 8),
            _buildTextField(_g2NameController, 'اسم الكفيل الثاني الكامل', Icons.person_outline),
            const SizedBox(height: 12),
            ResponsiveFormRow(
              children: [
                _buildTextField(_g2IdController, 'رقم الهوية', Icons.badge_outlined),
                _buildTextField(_g2PhoneController, 'رقم الجوال', Icons.phone_android),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(_g2WorkController, 'جهة العمل / المهنة', Icons.work_outline),
          ],
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('لا يوجد كفيل مسجل لهذا العقد حالياً', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _stepFinancial() {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
    return _buildStepLayout(
      title: 'الحسابات والجدولة المالية',
      subtitle: 'تحديد نوع البيع بالأجل (أقساط شهرية أو وعدة) والقيمة الاتفاقية المعتمدة',
      icon: Icons.calculate_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اختيار نوع عقد الأجل
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15)
              ],
              border: Border.all(color: AppColors.primaryNavy.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('صيغة البيع بالأجل المعتمدة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy)),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'installments',
                      label: Text('بيع أقساط شهرية'),
                      icon: Icon(Icons.view_list_rounded, size: 18),
                    ),
                    ButtonSegment(
                      value: 'waada',
                      label: Text('بيع وعدة (سداد مؤجل)'),
                      icon: Icon(Icons.event_rounded, size: 18),
                    ),
                  ],
                  selected: {_installmentSubtype},
                  onSelectionChanged: (val) => setState(() => _installmentSubtype = val.first),
                  style: ButtonStyle(
                    textStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            _totalSalePriceController,
            _installmentSubtype == 'waada' ? 'سعر البيع الأجل (وعدة) *' : 'إجمالي قيمة العقد بالأقساط *',
            Icons.money,
            isNumber: true,
          ),
          const SizedBox(height: 16),
          if (_installmentSubtype == 'installments') ...[
            _buildTextField(_installmentAmountController, 'قيمة القسط الشهري *', Icons.payments, isNumber: true),
            const SizedBox(height: 16),
            _buildDatePicker('تاريخ استحقاق أول قسط', _firstInstallmentDate, (d) => setState(() => _firstInstallmentDate = d)),
          ] else
            _buildDatePicker('تاريخ سداد الوعدة', _waadaDueDate, (d) => setState(() => _waadaDueDate = d)),
          const SizedBox(height: 32),
          _buildCalculatedSummary(f),
        ],
      ),
    );
  }

  Widget _buildCalculatedSummary(intl.NumberFormat f) {
    final total = double.tryParse(_totalSalePriceController.text) ?? 0;

    if (_installmentSubtype == 'waada') {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.primaryNavy.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('مبلغ الوعدة الإجمالي', style: TextStyle(color: Colors.white70)),
                Text('${f.format(total)} ر.س', style: const TextStyle(color: AppColors.accentGold, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
            const Divider(color: Colors.white10, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryItem('نوع العقد', 'بيع وعدة (دفعة واحدة)'),
                _summaryItem('تاريخ السداد', intl.DateFormat('yyyy/MM/dd').format(_waadaDueDate)),
              ],
            ),
          ],
        ),
      );
    }

    final inst = double.tryParse(_installmentAmountController.text) ?? 0;
    final int count = inst > 0 ? (total / inst).ceil() : 0;
    final endDate = _firstInstallmentDate.add(Duration(days: (count - 1) * 30));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primaryNavy.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إجمالي مبلغ المديونية', style: TextStyle(color: Colors.white70)),
              Text('${f.format(total)} ر.س', style: const TextStyle(color: AppColors.accentGold, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const Divider(color: Colors.white10, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem('عدد الأقساط', '$count قسطاً'),
              _summaryItem('تاريخ الانتهاء', intl.DateFormat('yyyy/MM/dd').format(endDate)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildControlButtons(bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.bgGrey)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _prevStep,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('السابق'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    foregroundColor: AppColors.primaryNavy,
                    side: const BorderSide(color: AppColors.primaryNavy),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _nextStep,
                icon: Icon(
                  _currentStep < 2 ? Icons.arrow_forward_rounded : Icons.check_circle_rounded,
                  size: 20,
                ),
                label: Text(
                  _currentStep < 2 ? 'الخطوة التالية' : 'اعتماد وإصدار العقد الآن',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: AppColors.primaryNavy.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepLayout({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.accentGold, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryNavy),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        child,
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2045));
        if (d != null) onSelect(d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: AppColors.primaryNavy, size: 22),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(intl.DateFormat('yyyy/MM/dd').format(date), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final Function(T) onSelect;

  const _SearchPickerSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.onSelect,
  });

  @override
  State<_SearchPickerSheet<T>> createState() => _SearchPickerSheetState<T>();
}

class _SearchPickerSheetState<T> extends State<_SearchPickerSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) => 
      widget.itemLabel(item).toLowerCase().contains(_query.toLowerCase())
    ).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'اكتب للبحث...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onChanged: (val) => setState(() => _query = val),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return ListTile(
                  title: Text(widget.itemLabel(item), style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => widget.onSelect(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
