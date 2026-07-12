import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/contract.dart';
import '../contract_controller.dart';
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
  
  String _paymentMethod = 'cash';
  bool _isSubmitting = false;
  final _idempotencyKey = const Uuid().v4();

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text('إصدار سند قبض ائتماني', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                color: Colors.grey.shade50,
                child: Text('عقد رقم: ${widget.contract.contractNo}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                decoration: const InputDecoration(
                  labelText: 'المبلغ المستلم نقداً',
                  suffixText: 'ر.س',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                keyboardType: TextInputType.number,
                validator: (val) => (val == null || double.tryParse(val) == null) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                decoration: const InputDecoration(labelText: 'قناة السداد', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('نقدي / كاش')),
                  DropdownMenuItem(value: 'bank_transfer', child: Text('تحويل بنكي')),
                  DropdownMenuItem(value: 'pos', child: Text('مدى / شبكة')),
                ],
                onChanged: (val) => setState(() => _paymentMethod = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _refController,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(labelText: 'رقم المرجع (اختياري)', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontSize: 12, color: Colors.grey))),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: const Icon(Icons.print_rounded, size: 16),
            label: Text(_isSubmitting ? 'جاري التسجيل...' : 'تسجيل وطباعة السند', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    final success = await ref.read(contractControllerProvider.notifier).processPayment(
      contractId: widget.contract.id,
      amount: double.parse(_amountController.text),
      method: _paymentMethod,
      reference: _refController.text.trim(),
      idempotencyKey: _idempotencyKey,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الدفعة بنجاح'), backgroundColor: Colors.green));
      }
    }
  }
}
