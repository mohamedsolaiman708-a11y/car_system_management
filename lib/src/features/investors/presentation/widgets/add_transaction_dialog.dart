import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  ConsumerState<AddTransactionDialog> createState() => _AddTransactionDialogState();
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
    final themeColor = isDeposit ? AppColors.successGreen : AppColors.errorRed;
    final title = isDeposit ? 'إيداع رأس مال جديد' : 'سحب من الرصيد المتاح';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _amountController,
                  enabled: !_isSubmitting,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeColor),
                  decoration: const InputDecoration(hintText: '0.00', suffixText: 'ر.س', filled: true),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) => (double.tryParse(val ?? '') ?? 0) <= 0 ? 'مبلغ غير صحيح' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(labelText: 'البيان / ملاحظات', filled: true),
                  validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تأكيد العملية الآن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
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
      // استدعاء الـ Controller والانتظار حتى ينتهي تماماً من قاعدة البيانات
      final success = await ref.read(investorTransactionsControllerProvider(widget.investorId).notifier).addTransaction(
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
