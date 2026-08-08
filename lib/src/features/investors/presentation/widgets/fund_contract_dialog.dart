import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../contracts/domain/contract.dart';
import '../../../contracts/presentation/contract_controller.dart';
import '../../domain/investor.dart';
import '../investor_controller.dart';
import '../../../../core/utils/app_theme.dart';

class FundContractDialog extends ConsumerStatefulWidget {
  final Contract contract;
  const FundContractDialog({super.key, required this.contract});

  @override
  ConsumerState<FundContractDialog> createState() => _FundContractDialogState();
}

class _FundContractDialogState extends ConsumerState<FundContractDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedInvestorId;
  Investor? _selectedInvestor;
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final defaultId = widget.contract.investorId ??
        widget.contract.investor?['id'] as String?;
    if (defaultId != null) _selectedInvestorId = defaultId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final investorsAsync = ref.watch(investorListControllerProvider);
    final fundingAsync =
        ref.watch(contractFundingProvider(widget.contract.id));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 520,
          decoration: const BoxDecoration(color: Colors.white),
          child: fundingAsync.when(
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('خطأ في جلب بيانات العقد: $e',
                  style: const TextStyle(color: Colors.red)),
            ),
            data: (fundingList) {
              final totalFunded = fundingList.fold<double>(
                  0, (s, i) => s + (i['amount_allocated'] as num).toDouble());
              final remaining =
                  widget.contract.principalAmount - totalFunded;

              if (_amountController.text.isEmpty && remaining > 0) {
                _amountController.text = remaining.toStringAsFixed(2);
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Header ───
                  Container(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    decoration: const BoxDecoration(
                        color: AppColors.primaryNavy),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                  Icons.account_balance_rounded,
                                  color: AppColors.accentGold,
                                  size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'تمويل العقود — تخصيص رأس المال',
                              style: TextStyle(
                                color: AppColors.accentGold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'تخصيص تمويل للعقد',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 10),
                        // Contract info chips
                        Row(
                          children: [
                            _chip(
                              Icons.receipt_long_rounded,
                              'عقد ${widget.contract.contractNo}',
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white,
                            ),
                            const SizedBox(width: 8),
                            _chip(
                              Icons.account_balance_wallet_rounded,
                              'المتبقي: ${remaining.toStringAsFixed(0)} ر.س',
                              remaining > 0
                                  ? Colors.orange.withValues(alpha: 0.25)
                                  : AppColors.successGreen
                                      .withValues(alpha: 0.25),
                              remaining > 0
                                  ? Colors.orangeAccent
                                  : AppColors.successGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ─── Form Body ───
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Investor Dropdown
                            _label('اختر المستثمر الممول'),
                            const SizedBox(height: 8),
                            investorsAsync.when(
                              loading: () => const LinearProgressIndicator(),
                              error: (_, __) => const Text(
                                  'خطأ في تحميل المستثمرين',
                                  style: TextStyle(color: Colors.red)),
                              data: (investors) {
                                if (_selectedInvestorId != null &&
                                    _selectedInvestor == null) {
                                  final m = investors
                                      .where((i) => i.id == _selectedInvestorId);
                                  if (m.isNotEmpty) {
                                    _selectedInvestor = m.first;
                                  }
                                }
                                return DropdownButtonFormField<String>(
                                  decoration: _dec(
                                    hint: 'اختر المستثمر...',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  initialValue: investors.any(
                                          (i) => i.id == _selectedInvestorId)
                                      ? _selectedInvestorId
                                      : null,
                                  items: investors.map((inv) {
                                    return DropdownMenuItem(
                                      value: inv.id,
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.account_circle_rounded,
                                              size: 18,
                                              color: AppColors.primaryNavy),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              inv.fullName,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.successGreen
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${inv.availableBalance.toStringAsFixed(0)} ر.س',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.successGreen,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _isSubmitting
                                      ? null
                                      : (val) => setState(() {
                                            _selectedInvestorId = val;
                                            _selectedInvestor = investors
                                                .firstWhere((i) => i.id == val);
                                          }),
                                  validator: (val) =>
                                      val == null ? 'مطلوب' : null,
                                );
                              },
                            ),

                            // Selected investor balance card
                            if (_selectedInvestor != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryNavy.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: AppColors.primaryNavy
                                          .withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                        Icons.account_balance_wallet_rounded,
                                        color: AppColors.primaryNavy,
                                        size: 20),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedInvestor!.fullName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: AppColors.primaryNavy),
                                        ),
                                        Text(
                                          'الرصيد المتاح: ${_selectedInvestor!.availableBalance.toStringAsFixed(2)} ر.س',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.successGreen,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Amount
                            _label('المبلغ المخصص للتمويل *'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _amountController,
                              enabled: !_isSubmitting,
                              decoration: _dec(
                                  hint: '0.00',
                                  icon: Icons.attach_money_rounded,
                                  suffix: 'ر.س'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'مطلوب';
                                final amount = double.tryParse(val);
                                if (amount == null || amount <= 0) {
                                  return 'مبلغ غير صحيح';
                                }
                                if (_selectedInvestor != null &&
                                    amount >
                                        _selectedInvestor!.availableBalance) {
                                  return 'رصيد المستثمر غير كافٍ (المتاح: ${_selectedInvestor!.availableBalance})';
                                }
                                if (amount > (remaining + 0.01)) {
                                  return 'المبلغ يتجاوز المطلوب (المتبقي: $remaining)';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── Footer Actions ───
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.04),
                      border: Border(
                          top: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.12))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.3)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('إلغاء',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _submit,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(
                                    Icons.account_balance_rounded,
                                    size: 20),
                            label: Text(
                              _isSubmitting ? 'جاري التخصيص...' : 'تأكيد التخصيص',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 3,
                              shadowColor:
                                  AppColors.primaryNavy.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
          ],
        ),
      );

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryNavy));

  InputDecoration _dec(
          {required String hint, required IconData icon, String? suffix}) =>
      InputDecoration(
        hintText: hint,
        suffixText: suffix,
        hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        prefixIcon: Icon(icon, size: 18, color: AppColors.primaryNavy),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryNavy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      );

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedInvestorId != null) {
      setState(() => _isSubmitting = true);
      try {
        final success = await ref
            .read(investorTransactionsControllerProvider(_selectedInvestorId!)
                .notifier)
            .allocateFunding(
              investorId: _selectedInvestorId!,
              contractId: widget.contract.id,
              amount: double.parse(_amountController.text),
            );
        if (mounted) {
          if (success) {
            Navigator.pop(context);
          } else {
            setState(() => _isSubmitting = false);
          }
        }
      } catch (e) {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }
}
