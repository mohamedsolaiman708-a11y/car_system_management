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
  final _bankNameController = TextEditingController(); // للـ PDF
  final _checkDateController = TextEditingController(); // للـ PDF
  
  String _paymentMethod = 'cash';
  final _idempotencyKey = const Uuid().v4();

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _bankNameController.dispose();
    _checkDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
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
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'المبلغ المستلم *',
                    suffixText: 'ر.س',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) => (val == null || double.tryParse(val) == null) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _paymentMethod,
                  decoration: const InputDecoration(labelText: 'طريقة السداد', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('نقداً')),
                    DropdownMenuItem(value: 'check', child: Text('شيك')),
                    DropdownMenuItem(value: 'bank_transfer', child: Text('تحويل بنكي')),
                    DropdownMenuItem(value: 'pos', child: Text('شبكة / مدى')),
                  ],
                  onChanged: (val) => setState(() => _paymentMethod = val!),
                ),
                if (_paymentMethod == 'check') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _refController,
                    decoration: const InputDecoration(labelText: 'رقم الشيك *', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'مطلوب للشيكات' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bankNameController,
                    decoration: const InputDecoration(labelText: 'مسحوب على (البنك) *', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                ],
                if (_paymentMethod != 'cash' && _paymentMethod != 'check') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _refController,
                    decoration: const InputDecoration(labelText: 'رقم المرجع / العملية', border: OutlineInputBorder()),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.print_rounded),
            label: const Text('تسجيل وطباعة السند'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D1B3E), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // 1. تسجيل العملية في قاعدة البيانات
      final success = await ref.read(contractControllerProvider.notifier).processPayment(
        contractId: widget.contract.id,
        amount: double.parse(_amountController.text),
        method: _paymentMethod,
        reference: _refController.text,
        idempotencyKey: _idempotencyKey,
      );

      if (mounted && success) {
        Navigator.pop(context);
        // سنقوم هنا باستدعاء محرك الـ PDF لطباعة السند فوراً
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الدفعة بنجاح، جاري تجهيز السند للطباعة...')));
      }
    }
  }
}
