import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/contract.dart';
import '../contract_controller.dart';

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

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // جلب بيانات الأقساط لحساب المتبقي الفعلي ومنع الدفع الزائد
    final installmentsAsync = ref.watch(contractInstallmentsProvider(widget.contract.id));
    double remainingBalance = widget.contract.totalContractValue;
    
    installmentsAsync.whenData((list) {
      final paid = list.where((i) => i['status'] == 'paid').fold(0.0, (sum, i) => sum + (i['expected_amount'] as num).toDouble());
      remainingBalance = widget.contract.totalContractValue - paid;
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: Color(0xFF0D1B3E)),
            SizedBox(width: 12),
            Text('إصدار سند قبض جديد'),
          ],
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المتبقي على العقد: ${remainingBalance.toStringAsFixed(2)} ر.س', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'المبلغ المستلم *',
                    suffixText: 'ر.س',
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'مطلب';
                    final amount = double.tryParse(val);
                    if (amount == null || amount <= 0) return 'مبلغ غير صحيح';
                    if (amount > remainingBalance) return 'المبلغ يتجاوز المديونية المتبقية';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _paymentMethod,
                  decoration: const InputDecoration(labelText: 'طريقة السداد', border: OutlineInputBorder(), filled: true),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('نقداً')),
                    DropdownMenuItem(value: 'check', child: Text('شيك مصدق')),
                    DropdownMenuItem(value: 'bank_transfer', child: Text('تحويل بنكي')),
                    DropdownMenuItem(value: 'pos', child: Text('شبكة / مدى')),
                  ],
                  onChanged: (val) => setState(() => _paymentMethod = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _refController,
                  decoration: InputDecoration(
                    labelText: _paymentMethod == 'check' ? 'رقم الشيك *' : 'رقم المرجع / العملية', 
                    border: const OutlineInputBorder()
                  ),
                  validator: (v) => (_paymentMethod == 'check' && v!.isEmpty) ? 'مطلوب للشيكات' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'ملاحظات إضافية', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('تسجيل وسداد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32), 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(contractControllerProvider.notifier).processPayment(
        contractId: widget.contract.id,
        amount: double.parse(_amountController.text),
        method: _paymentMethod,
        reference: '${_refController.text} | ${_notesController.text}'.trim(),
        idempotencyKey: _idempotencyKey,
      );

      if (mounted && success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل السداد بنجاح')));
      }
    }
  }
}
