import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../contracts/domain/contract.dart';
import '../investor_controller.dart';


class FundContractDialog extends ConsumerStatefulWidget {
  final Contract contract;
  const FundContractDialog({super.key, required this.contract});

  @override
  ConsumerState<FundContractDialog> createState() => _FundContractDialogState();
}

class _FundContractDialogState extends ConsumerState<FundContractDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedInvestorId;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // اقتراح المبلغ المتبقي للتمويل تلقائياً
    _amountController.text = widget.contract.principalAmount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final investorsAsync = ref.watch(investorListControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('تخصيص تمويل للعقد'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('عقد رقم: ${widget.contract.contractNo}'),
              const SizedBox(height: 16),
              investorsAsync.when(
                data: (investors) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'اختر المستثمر',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedInvestorId,
                  items: investors.map((inv) {
                    return DropdownMenuItem(
                      value: inv.id,
                      child: Text('${inv.fullName} (المتاح: ${inv.availableBalance} ر.س)'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedInvestorId = val),
                  validator: (val) => val == null ? 'مطلوب' : null,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('خطأ في تحميل المستثمرين'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'المبلغ المخصص',
                  suffixText: 'ر.س',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'مطلوب';
                  final amount = double.tryParse(val);
                  if (amount == null || amount <= 0) return 'مبلغ غير صحيح';
                  return null;
                },
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
            onPressed: _submit,
            child: const Text('تأكيد التخصيص'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedInvestorId != null) {
      final success = await ref.read(investorTransactionsControllerProvider(_selectedInvestorId!).notifier).allocateFunding(
        investorId: _selectedInvestorId!,
        contractId: widget.contract.id,
        amount: double.parse(_amountController.text),
      );

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تخصيص التمويل بنجاح')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل التخصيص. تأكد من رصيد المستثمر.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
