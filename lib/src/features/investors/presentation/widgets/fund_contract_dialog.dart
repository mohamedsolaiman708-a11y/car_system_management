import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../contracts/domain/contract.dart';
import '../../../contracts/presentation/contract_controller.dart';
import '../../domain/investor.dart';
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
  Investor? _selectedInvestor;
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final investorsAsync = ref.watch(investorListControllerProvider);
    final fundingAsync = ref.watch(contractFundingProvider(widget.contract.id));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('تخصيص تمويل للعقد'),
        content: fundingAsync.when(
          data: (fundingList) {
            double totalFunded = fundingList.fold(0, (sum, item) => sum + (item['amount_allocated'] as num).toDouble());
            double remainingToFund = widget.contract.principalAmount - totalFunded;
            
            if (_amountController.text.isEmpty && remainingToFund > 0) {
              _amountController.text = remainingToFund.toString();
            }

            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('عقد رقم: ${widget.contract.contractNo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('المبلغ المطلوب المتبقي: $remainingToFund ر.س', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                  const SizedBox(height: 16),
                  investorsAsync.when(
                    data: (investors) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'اختر المستثمر',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      value: _selectedInvestorId,
                      items: investors.map((inv) {
                        return DropdownMenuItem(
                          value: inv.id,
                          child: Text('${inv.fullName} (المتاح: ${inv.availableBalance} ر.س)'),
                        );
                      }).toList(),
                      onChanged: _isSubmitting ? null : (val) {
                        setState(() {
                          _selectedInvestorId = val;
                          _selectedInvestor = investors.firstWhere((i) => i.id == val);
                        });
                      },
                      validator: (val) => val == null ? 'مطلوب' : null,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('خطأ في تحميل المستثمرين', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    enabled: !_isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'المبلغ المخصص',
                      suffixText: 'ر.س',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'مطلوب';
                      final amount = double.tryParse(val);
                      if (amount == null || amount <= 0) return 'مبلغ غير صحيح';
                      
                      if (_selectedInvestor != null && amount > _selectedInvestor!.availableBalance) {
                        return 'رصيد المستثمر غير كافٍ (المتاح: ${_selectedInvestor!.availableBalance})';
                      }
                      
                      if (amount > (remainingToFund + 0.01)) {
                        return 'المبلغ يتجاوز المطلوب للعقد (المتبقي: $remainingToFund)';
                      }
                      
                      return null;
                    },
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('خطأ في جلب بيانات العقد: $e'),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            child: _isSubmitting 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('تأكيد التخصيص'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedInvestorId != null) {
      setState(() => _isSubmitting = true);
      
      try {
        final success = await ref.read(investorTransactionsControllerProvider(_selectedInvestorId!).notifier).allocateFunding(
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
