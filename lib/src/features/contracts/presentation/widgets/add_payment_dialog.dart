import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/contract.dart';
import '../contract_controller.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/app_theme.dart';

class AddPaymentDialog extends ConsumerStatefulWidget {
  final Contract contract;
  const AddPaymentDialog({super.key, required this.contract});

  @override
  ConsumerState<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  final _notesController = TextEditingController();

  String _paymentMethod = 'cash';
  final _idempotencyKey = const Uuid().v4();
  bool _isSubmitting = false;

  static const _methods = [
    ('cash', Icons.payments_rounded, 'نقداً'),
    ('check', Icons.description_rounded, 'شيك مصدق'),
    ('bank_transfer', Icons.account_balance_rounded, 'تحويل بنكي'),
    ('pos', Icons.credit_card_rounded, 'شبكة / مدى'),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final installmentsAsync =
        ref.watch(contractInstallmentsProvider(widget.contract.id));
    double remainingBalance = widget.contract.totalContractValue;

    installmentsAsync.whenData((list) {
      final paid = list
          .where((i) => i['status'] == 'paid')
          .fold(0.0, (sum, i) => sum + (i['expected_amount'] as num).toDouble());
      remainingBalance = widget.contract.totalContractValue - paid;
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 520,
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Header ───
              Container(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                decoration: const BoxDecoration(color: AppColors.primaryNavy),
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
                          child: const Icon(Icons.receipt_long_rounded,
                              color: AppColors.accentGold, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'سند قبض — تسجيل دفعة',
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
                      'إصدار سند قبض جديد',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded,
                              color: Colors.redAccent, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'المتبقي: ${remainingBalance.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
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
                        _label('المبلغ المستلم *'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          enabled: !_isSubmitting,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy),
                          decoration: _dec(
                              hint: '0.00',
                              suffix: 'ر.س',
                              icon: Icons.attach_money_rounded),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'مطلوب';
                            final amount = double.tryParse(val);
                            if (amount == null || amount <= 0) {
                              return 'مبلغ غير صحيح';
                            }
                            if (amount > remainingBalance) {
                              return 'المبلغ يتجاوز المديونية المتبقية';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _label('طريقة السداد'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _methods.map((m) {
                            final sel = _paymentMethod == m.$1;
                            return GestureDetector(
                              onTap: _isSubmitting
                                  ? null
                                  : () => setState(() => _paymentMethod = m.$1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppColors.primaryNavy
                                      : Colors.grey.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: sel
                                        ? AppColors.primaryNavy
                                        : Colors.grey.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(m.$2,
                                        size: 15,
                                        color: sel
                                            ? AppColors.accentGold
                                            : Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Text(m.$3,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: sel
                                                ? Colors.white
                                                : Colors.grey.shade700)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        _label(_paymentMethod == 'check'
                            ? 'رقم الشيك *'
                            : 'رقم المرجع / العملية'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _refController,
                          enabled: !_isSubmitting,
                          decoration:
                              _dec(hint: 'اختياري', icon: Icons.tag_rounded),
                          validator: (v) =>
                              (_paymentMethod == 'check' &&
                                      (v == null || v.isEmpty))
                                  ? 'مطلوب للشيكات'
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        _label('ملاحظات إضافية'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          enabled: !_isSubmitting,
                          maxLines: 2,
                          decoration: _dec(
                              hint: 'ملاحظات اختيارية...',
                              icon: Icons.notes_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Footer Actions ───
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                            : const Icon(Icons.check_circle_rounded, size: 20),
                        label: Text(
                          _isSubmitting ? 'جاري الحفظ...' : 'تسجيل وإصدار السند',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                          shadowColor:
                              AppColors.successGreen.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
    if (_isSubmitting) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final success =
            await ref.read(contractControllerProvider.notifier).processPayment(
                  contractId: widget.contract.id,
                  amount: double.parse(_amountController.text),
                  method: _paymentMethod,
                  reference:
                      '${_refController.text} | ${_notesController.text}'.trim(),
                  idempotencyKey: _idempotencyKey,
                );
        if (mounted) {
          if (success) {
            Navigator.of(context).pop();
            SnackBarHelper.showSuccess(context, 'تم تسجيل السداد بنجاح');
          } else {
            setState(() => _isSubmitting = false);
            final errorState = ref.read(contractControllerProvider);
            if (errorState.hasError) {
              SnackBarHelper.showError(
                  context, Failure.fromException(errorState.error).message);
            }
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          SnackBarHelper.showError(context,
              'فشل تسجيل السداد: ${Failure.fromException(e).message}');
        }
      }
    }
  }
}
