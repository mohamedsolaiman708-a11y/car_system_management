import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../../data/supabase_contract_repository.dart';
import '../contract_controller.dart';
import '../../domain/contract.dart';

class EditContractScreen extends ConsumerStatefulWidget {
  final String id;
  const EditContractScreen({super.key, required this.id});

  @override
  ConsumerState<EditContractScreen> createState() => _EditContractScreenState();
}

class _EditContractScreenState extends ConsumerState<EditContractScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInitialized = false;

  final _principalController = TextEditingController();
  final _profitRateController = TextEditingController();
  final _durationController = TextEditingController();

  final _moroorFeesController = TextEditingController();
  final _tammFeesController = TextEditingController();
  final _insuranceFeesController = TextEditingController();
  final _vatController = TextEditingController();

  final _g1NameController = TextEditingController();
  final _g1IdController = TextEditingController();
  final _g1PhoneController = TextEditingController();
  final _g1WorkController = TextEditingController();

  double _totalValue = 0;
  double _monthlyInstallment = 0;
  String _contractType = 'installments';

  @override
  void dispose() {
    _principalController.dispose();
    _profitRateController.dispose();
    _durationController.dispose();
    _moroorFeesController.dispose();
    _tammFeesController.dispose();
    _insuranceFeesController.dispose();
    _vatController.dispose();
    _g1NameController.dispose();
    _g1IdController.dispose();
    _g1PhoneController.dispose();
    _g1WorkController.dispose();
    super.dispose();
  }

  void _calculateTotals() {
    final principal = double.tryParse(_principalController.text) ?? 0;
    final rate = _contractType == 'installments' ? (double.tryParse(_profitRateController.text) ?? 0) : 0;
    final months = int.tryParse(_durationController.text) ?? 1;

    final moroor = double.tryParse(_moroorFeesController.text) ?? 0;
    final tamm = double.tryParse(_tammFeesController.text) ?? 0;
    final insurance = double.tryParse(_insuranceFeesController.text) ?? 0;
    final vat = double.tryParse(_vatController.text) ?? 0;

    setState(() {
      _totalValue = principal + (principal * (rate / 100)) + moroor + tamm + insurance + vat;
      _monthlyInstallment = (_contractType == 'installments' && months > 0) ? _totalValue / months : 0;
    });
  }

  void _initFields(Contract contract) {
    if (_isInitialized) return;
    
    _principalController.text = contract.principalAmount.toString();
    _profitRateController.text = contract.financeProfitRate.toString();
    _durationController.text = contract.durationMonths.toString();
    _moroorFeesController.text = contract.moroorFees.toString();
    _tammFeesController.text = contract.tammFees.toString();
    _insuranceFeesController.text = contract.insuranceFees.toString();
    _vatController.text = contract.vatAmount.toString();
    _g1NameController.text = contract.guarantor1Name ?? '';
    _g1IdController.text = contract.guarantor1Id ?? '';
    _g1PhoneController.text = contract.guarantor1Phone ?? '';
    _g1WorkController.text = contract.guarantor1Work ?? '';
    _contractType = contract.type ?? 'installments';
    
    _calculateTotals();
    _isInitialized = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'principal_amount': double.tryParse(_principalController.text) ?? 0.0,
      'finance_profit_rate': double.tryParse(_profitRateController.text) ?? 0.0,
      'total_contract_value': _totalValue,
      'duration_months': int.tryParse(_durationController.text) ?? 1,
      'guarantor_1_name': _g1NameController.text.trim(),
      'guarantor_1_id': _g1IdController.text.trim(),
      'guarantor_1_phone': _g1PhoneController.text.trim(),
      'guarantor_1_work': _g1WorkController.text.trim(),
      'moroor_fees': double.tryParse(_moroorFeesController.text) ?? 0.0,
      'tamm_fees': double.tryParse(_tammFeesController.text) ?? 0.0,
      'insurance_fees': double.tryParse(_insuranceFeesController.text) ?? 0.0,
      'vat_amount': double.tryParse(_vatController.text) ?? 0.0,
    };

    try {
      await ref.read(contractRepositoryProvider).updateContract(widget.id, data);
      ref.invalidate(contractDetailsProvider(widget.id));
      if (mounted) {
        context.pop();
        SnackBarHelper.showSuccess(context, 'تم تحديث بيانات العقد بنجاح');
      }
    } catch (e) {
      if (mounted) SnackBarHelper.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contractAsync = ref.watch(contractDetailsProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('تعديل وثيقة التعاقد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: contractAsync.when(
        data: (contract) {
          if (contract == null) return const Center(child: Text('العقد غير موجود'));
          _initFields(contract);

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  children: [
                    _buildFormHeader(contract.contractNo),
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
                              title: 'القيم المالية الأساسية',
                              icon: Icons.account_balance_wallet_rounded,
                              children: [
                                _buildTextField(_principalController, 'أصل مبلغ التمويل', isNumber: true, icon: Icons.money_rounded),
                                const SizedBox(height: 20),
                                ResponsiveFormRow(
                                  children: [
                                    _buildTextField(_profitRateController, 'نسبة الربح %', isNumber: true, icon: Icons.trending_up_rounded),
                                    _buildTextField(_durationController, 'المدة (أشهر)', isNumber: true, icon: Icons.timer_rounded),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildSectionCard(
                              title: 'الرسوم الإدارية والضرائب',
                              icon: Icons.receipt_long_rounded,
                              children: [
                                ResponsiveFormRow(
                                  children: [
                                    _buildTextField(_moroorFeesController, 'رسوم المرور', isNumber: true, icon: Icons.assignment_rounded),
                                    _buildTextField(_tammFeesController, 'رسوم تم', isNumber: true, icon: Icons.app_registration_rounded),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ResponsiveFormRow(
                                  children: [
                                    _buildTextField(_insuranceFeesController, 'رسوم التأمين', isNumber: true, icon: Icons.security_rounded),
                                    _buildTextField(_vatController, 'ضريبة القيمة المضافة', isNumber: true, icon: Icons.calculate_rounded),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildSectionCard(
                              title: 'بيانات الكفيل الغارم',
                              icon: Icons.person_search_rounded,
                              children: [
                                _buildTextField(_g1NameController, 'اسم الكفيل الكامل', icon: Icons.person_add_rounded),
                                const SizedBox(height: 20),
                                ResponsiveFormRow(
                                  children: [
                                    _buildTextField(_g1IdController, 'هوية الكفيل', icon: Icons.badge_rounded),
                                    _buildTextField(_g1PhoneController, 'جوال الكفيل', icon: Icons.phone_android_rounded),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _buildSummaryCard(),
                            const SizedBox(height: 40),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _submit,
                              icon: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.check_circle_rounded, size: 22),
                              label: Text(_isLoading ? 'جاري التحديث...' : 'حفظ واعتماد التعديلات',
                                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
                              child: const Text('إلغاء التعديل والعودة', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _buildFormHeader(String contractNo) {
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
                child: const Icon(Icons.edit_document, color: AppColors.accentGold, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'عقد رقم: $contractNo',
                style: const TextStyle(color: AppColors.accentGold, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'تعديل القيم المالية والضمانات',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveLayout.isMobile(context) ? 20 : 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'تعديل المبالغ والنسب والرسوم الإدارية وبيانات الكفيل الغارم.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إجمالي قيمة العقد المعدلة', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text('${f.format(_totalValue)} ر.س', style: const TextStyle(color: AppColors.accentGold, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white12, height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('القسط الشهري الجديد', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text('${f.format(_monthlyInstallment)} ر.س', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
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

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, IconData? icon}) {
    return TextFormField(
      controller: controller,
      onChanged: (_) => _calculateTotals(),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.primaryNavy) : null,
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
