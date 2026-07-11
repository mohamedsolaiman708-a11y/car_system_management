import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../../domain/vehicle.dart';
import '../inventory_controller.dart';
import '../../../../core/utils/app_theme.dart';

class VehicleDetailsScreen extends ConsumerWidget {
  final String id;
  const VehicleDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleDetailsProvider(id));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('بطاقة الأصول الرأسمالية', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.accentGold),
            onPressed: () => context.push('/inventory/$id/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: vehicleAsync.when(
        data: (vehicle) {
          if (vehicle == null) return const Center(child: Text('المركبة غير موجودة'));

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildPremiumHeader(vehicle, f),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildFinancialSnapshot(vehicle, f),
                      const SizedBox(height: 24),
                      _buildSpecsGrid(vehicle),
                      const SizedBox(height: 24),
                      _buildActionPanel(context, ref, vehicle),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (err, _) => Center(child: Text('حدث خطأ: $err')),
      ),
    );
  }

  Widget _buildPremiumHeader(Vehicle vehicle, intl.NumberFormat f) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Row(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.directions_car_filled_rounded, size: 80, color: AppColors.accentGold),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBadgeLarge(status: vehicle.status),
                const SizedBox(height: 16),
                Text('${vehicle.make} ${vehicle.model}', 
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.fingerprint_rounded, color: Colors.white54, size: 14),
                    const SizedBox(width: 8),
                    Text('رقم الهيكل: ${vehicle.vin}', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(width: 24),
                    const Icon(Icons.calendar_today_rounded, color: Colors.white54, size: 14),
                    const SizedBox(width: 8),
                    Text('سنة الصنع: ${vehicle.year}', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSnapshot(Vehicle vehicle, intl.NumberFormat f) {
    return Row(
      children: [
        _buildFinCard('تكلفة الشراء', f.format(vehicle.purchasePrice), Colors.blue),
        const SizedBox(width: 20),
        _buildFinCard('القيمة السوقية', f.format(vehicle.estimatedMarketValue ?? 0), Colors.green),
        const SizedBox(width: 20),
        _buildFinCard('رقم اللوحة', vehicle.licensePlate ?? 'N/A', AppColors.accentGold, isCurrency: false),
      ],
    );
  }

  Widget _buildFinCard(String label, String value, Color color, {bool isCurrency = true}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(isCurrency ? '$value ر.س' : value, 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecsGrid(Vehicle vehicle) {
    final specs = vehicle.technicalSpecs;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings_applications_rounded, color: AppColors.primaryNavy, size: 24),
              SizedBox(width: 12),
              Text('المواصفات الفنية والتقنية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            ],
          ),
          const Divider(height: 48),
          if (specs.isEmpty)
            const Center(child: Text('لا توجد مواصفات إضافية مسجلة'))
          else
            Wrap(
              spacing: 40,
              runSpacing: 24,
              children: specs.entries.map((e) => SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActionPanel(BuildContext context, WidgetRef ref, Vehicle vehicle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryNavy.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          if (vehicle.status == 'available')
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/contracts/new?vehicleId=${vehicle.id}'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, foregroundColor: Colors.white),
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('تعميد عقد تمويل جديد'),
              ),
            ),
          if (vehicle.status == 'available') const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _toggleMaintenance(context, ref, vehicle),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: vehicle.status == 'maintenance' ? Colors.green : Colors.orange),
                foregroundColor: vehicle.status == 'maintenance' ? Colors.green : Colors.orange.shade800,
              ),
              icon: Icon(vehicle.status == 'maintenance' ? Icons.check_circle_outline : Icons.build_circle_outlined),
              label: Text(vehicle.status == 'maintenance' ? 'إنهاء الصيانة وإتاحة المركبة' : 'إصدار أمر صيانة'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تأكيد شطب الأصل'),
          content: const Text('هل أنت متأكد من حذف هذه المركبة نهائياً من سجلات الأصول؟'),
          actions: [
            TextButton(onPressed: () => context.pop(), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                await ref.read(inventoryControllerProvider.notifier).deleteVehicle(id);
                if (context.mounted) {
                  context.pop(); context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف المركبة بنجاح')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('تأكيد الحذف'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMaintenance(BuildContext context, WidgetRef ref, Vehicle vehicle) async {
    final newStatus = vehicle.status == 'maintenance' ? 'available' : 'maintenance';
    await ref.read(inventoryControllerProvider.notifier).updateVehicle(id, {'status': newStatus});
    ref.invalidate(vehicleDetailsProvider(id));
  }
}

class _StatusBadgeLarge extends StatelessWidget {
  final String status;
  const _StatusBadgeLarge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color; String label;
    switch (status) {
      case 'available': color = Colors.green; label = 'متوفرة للاستثمار'; break;
      case 'on_contract': color = Colors.blue; label = 'نشطة بعقد تمويل'; break;
      case 'maintenance': color = Colors.orange; label = 'خارج الخدمة - صيانة'; break;
      default: color = Colors.grey; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
    );
  }
}
