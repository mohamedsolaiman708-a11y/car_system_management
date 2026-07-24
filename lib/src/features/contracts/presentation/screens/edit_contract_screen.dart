import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('تعديل وثيقة التعاقد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: contractAsync.when(
        data: (contract) {
          if (contract == null) return const Center(child: Text('العقد غير موجود'));
          _initFields(contract);

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: AppColors.primaryNavy,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('عقد رقم: ${contract.contractNo}', style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('تعديل القيم المالية وبيانات الضمانات', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildSectionCard(
                          title: 'القيم المالية الأساسية',
                          icon: Icons.account_balance_wallet_rounded,
                          children: [
                            _buildTextField(_principalController, 'أصل مبلغ التمويل', isNumber: true, icon: Icons.money_rounded),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildTextField(_profitRateController, 'نسبة الربح %', isNumber: true, icon: Icons.trending_up_rounded)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField(_durationController, 'المدة (أشهر)', isNumber: true, icon: Icons.timer_rounded)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSectionCard(
                          title: 'الرسوم الإدارية والضرائب',
                          icon: Icons.receipt_long_rounded,
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildTextField(_moroorFeesController, 'رسوم المرور', isNumber: true, icon: Icons.assignment_rounded)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField(_tammFeesController, 'رسوم تم', isNumber: true, icon: Icons.app_registration_rounded)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildTextField(_insuranceFeesController, 'رسوم التأمين', isNumber: true, icon: Icons.security_rounded)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField(_vatController, 'ضريبة القيمة المضافة', isNumber: true, icon: Icons.calculate_rounded)),
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
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildTextField(_g1IdController, 'هوية الكفيل', icon: Icons.badge_rounded)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField(_g1PhoneController, 'جوال الكفيل', icon: Icons.phone_android_rounded)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildSummaryCard(),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            minimumSize: const Size(double.infinity, 64),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('حفظ واعتماد التعديلات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.primaryNavy, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              const Text('إجمالي قيمة العقد الجديدة', style: TextStyle(color: Colors.white70)), 
              Text('${f.format(_totalValue)} ر.س', style: const TextStyle(color: AppColors.accentGold, fontSize: 20, fontWeight: FontWeight.bold))
            ]
          ),
          const Divider(color: Colors.white10, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              const Text('القسط الشهري التقريبي', style: TextStyle(color: Colors.white70)), 
              Text('${f.format(_monthlyInstallment)} ر.س', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
            ]
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppColors.accentGold, size: 20), const SizedBox(width: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
          const Divider(height: 32),
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
        prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
