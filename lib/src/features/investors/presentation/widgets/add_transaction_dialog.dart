import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../investor_controller.dart';
import '../../domain/investor_transaction_type.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/snack_bar_helper.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  final String investorId;
  final InvestorTransactionType type;

  const AddTransactionDialog({
    super.key,
    required this.investorId,
    required this.type,
  });

  @override
  ConsumerState<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDeposit = widget.type == InvestorTransactionType.deposit;
    final themeColor =
        isDeposit ? AppColors.successGreen : AppColors.errorRed;
    final title = isDeposit ? 'إيداع رأس مال' : 'سحب من الرصيد';
    final subtitle = isDeposit
        ? 'تسجيل إيداع مالي جديد في حساب المستثمر'
        : 'تسجيل سحب من الرصيد المتاح للمستثمر';
    final icon =
        isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 460,
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Header ───
              Container(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDeposit
                        ? [
                            const Color(0xFF1B5E20),
                            const Color(0xFF2E7D32),
                          ]
                        : [
                            const Color(0xFFB71C1C),
                            const Color(0xFFC62828),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isDeposit
                              ? 'المحفظة الاستثمارية — إيداع'
                              : 'المحفظة الاستثمارية — سحب',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),

              // ─── Form Body ───
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount - big centered input
                      Container(
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: themeColor.withValues(alpha: 0.2)),
                        ),
                        child: TextFormField(
                          controller: _amountController,
                          enabled: !_isSubmitting,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: themeColor),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            suffixText: 'ر.س',
                            hintStyle: TextStyle(
                                color: themeColor.withValues(alpha: 0.3),
                                fontSize: 32,
                                fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          validator: (val) =>
                              (double.tryParse(val ?? '') ?? 0) <= 0
                                  ? 'مبلغ غير صحيح'
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text('البيان / الوصف *',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        enabled: !_isSubmitting,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'أدخل وصفاً للعملية...',
                          hintStyle: TextStyle(
                              color: Colors.grey.withValues(alpha: 0.5),
                              fontSize: 13),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          prefixIcon: const Icon(Icons.notes_rounded,
                              size: 18, color: AppColors.primaryNavy),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: themeColor, width: 1.5),
                          ),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'مطلوب' : null,
                      ),
                    ],
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
                            : Icon(icon, size: 20),
                        label: Text(
                          _isSubmitting
                              ? 'جاري التسجيل...'
                              : 'تأكيد ${isDeposit ? 'الإيداع' : 'السحب'}',
                          style:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                          shadowColor: themeColor.withValues(alpha: 0.4),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final amount = double.parse(_amountController.text);
      final success = await ref
          .read(investorTransactionsControllerProvider(widget.investorId)
              .notifier)
          .addTransaction(
            investorId: widget.investorId,
            amount: amount,
            type: widget.type,
            description: _descriptionController.text.trim(),
          );

      if (mounted && success) {
        Navigator.pop(context);
        SnackBarHelper.showSuccess(context, 'تمت العملية بنجاح');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        SnackBarHelper.showError(context, 'خطأ: $e');
      }
    }
  }
}
