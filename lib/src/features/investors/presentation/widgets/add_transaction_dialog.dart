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
    final title = widget.type == InvestorTransactionType.deposit ? 'Capital Deposit' : 'Capital Withdrawal';
    
    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                final amount = double.tryParse(val);
                if (amount == null || amount <= 0) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description / Reference',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (val) => val == null || val.isEmpty ? 'Required for audit trail' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
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
                  // Refresh investor details to show updated balance
                  ref.read(investorDetailsControllerProvider(widget.investorId).notifier).refresh();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction failed. Possibly insufficient funds.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
