import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../investor_controller.dart';
import '../../domain/investor_transaction_type.dart';

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

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDeposit = widget.type == InvestorTransactionType.deposit;
    final title = isDeposit ? 'إيداع رأس مال جديد' : 'سحب من الرصيد المتاح';
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(isDeposit ? Icons.add_circle : Icons.remove_circle, 
                 color: isDeposit ? Colors.green : Colors.red),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  suffixText: 'ر.س',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) return 'المبلغ مطلوب';
                  final amount = double.tryParse(val);
                  if (amount == null || amount <= 0) return 'مبلغ غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف / ملاحظات التدقيق',
                  border: OutlineInputBorder(),
                  hintText: 'مثلاً: تحويل بنكي - مصرف الراجحي',
                ),
                maxLines: 2,
                validator: (val) => val == null || val.isEmpty ? 'الوصف مطلوب للرقابة المالية' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final amount = double.parse(_amountController.text);
                final success = await ref.read(investorTransactionsControllerProvider(widget.investorId).notifier).addTransaction(
                  investorId: widget.investorId,
                  amount: amount,
                  type: widget.type,
                  description: _descriptionController.text.trim(),
                );

                if (mounted) {
                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت العملية بنجاح وتحديث القيود المحاسبية'), backgroundColor: Colors.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('فشلت العملية. تأكد من توفر الرصيد الكافي.'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDeposit ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد العملية'),
          ),
        ],
      ),
    );
  }
}
