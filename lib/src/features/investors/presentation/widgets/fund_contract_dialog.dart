import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../contracts/domain/contract.dart';
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
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text('تخصيص شركاء التمويل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                color: Colors.grey.shade50,
                child: Text('عقد رقم: ${widget.contract.contractNo}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              investorsAsync.when(
                data: (investors) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'المستثمر الممول', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  value: _selectedInvestorId,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  items: investors.map((inv) => DropdownMenuItem(
                    value: inv.id,
                    child: Text('${inv.fullName} (متاح: ${inv.availableBalance} ر.س)', style: const TextStyle(fontSize: 12)),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedInvestorId = val),
                  validator: (val) => val == null ? 'يرجى اختيار مستثمر' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('خطأ في تحميل المستثمرين'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(labelText: 'مبلغ التمويل المخصص', suffixText: 'ر.س', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontSize: 12, color: Colors.grey))),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            child: _isSubmitting 
              ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('تأكيد الربط بالعقد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedInvestorId == null) return;
    
    setState(() => _isSubmitting = true);
    final success = await ref.read(investorTransactionsControllerProvider(_selectedInvestorId!).notifier).allocateFunding(
      investorId: _selectedInvestorId!,
      contractId: widget.contract.id,
      amount: double.parse(_amountController.text),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تخصيص التمويل بنجاح'), backgroundColor: Colors.green));
        ref.invalidate(investorDetailsControllerProvider(_selectedInvestorId!));
      }
    }
  }
}
