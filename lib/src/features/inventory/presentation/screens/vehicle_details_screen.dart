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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => context.pop(),
        ),
        title: const Text('بيانات المركبة الفنية والمالية', 
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
            onPressed: () => context.push('/inventory/$id/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => _confirmDelete(context, ref),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: vehicleAsync.when(
        data: (vehicle) {
          if (vehicle == null) return const Center(child: Text('غير موجود'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(vehicle),
                const SizedBox(height: 16),
                _buildInfoSection('المعلومات الأساسية', [
                  _buildRow('رقم الهيكل (VIN)', vehicle.vin),
                  _buildRow('رقم اللوحة', vehicle.licensePlate ?? '-'),
                  _buildRow('سنة الصنع', vehicle.year.toString()),
                  _buildRow('اللون', vehicle.color ?? '-'),
                ]),
                const SizedBox(height: 16),
                _buildInfoSection('البيانات المالية', [
                  _buildRow('سعر الشراء الفعلي', '${f.format(vehicle.purchasePrice)} ر.س'),
                  _buildRow('القيمة السوقية الحالية', '${f.format(vehicle.estimatedMarketValue ?? 0)} ر.س'),
                ]),
                const SizedBox(height: 24),
                _buildActionButtons(context, ref, vehicle),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }

  Widget _buildHeader(Vehicle vehicle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.directions_car, color: AppColors.primaryNavy),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${vehicle.make} ${vehicle.model}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildStatusChip(vehicle.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Vehicle vehicle) {
    return Row(
      children: [
        if (vehicle.status == 'available')
          Expanded(child: ElevatedButton(
            onPressed: () => context.push('/contracts/new?vehicleId=${vehicle.id}'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            child: const Text('تعميد عقد بيع', style: TextStyle(fontWeight: FontWeight.bold)),
          )),
        if (vehicle.status == 'available') const SizedBox(width: 12),
        Expanded(child: OutlinedButton(
          onPressed: () => _toggleMaintenance(ref, vehicle),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
          child: Text(vehicle.status == 'maintenance' ? 'إنهاء الصيانة' : 'إرسال للصيانة', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        )),
      ],
    );
  }

  void _toggleMaintenance(WidgetRef ref, Vehicle vehicle) async {
    final newStatus = vehicle.status == 'maintenance' ? 'available' : 'maintenance';
    await ref.read(inventoryControllerProvider.notifier).updateVehicle(id, {'status': newStatus});
    ref.invalidate(vehicleDetailsProvider(id));
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
     // منطق الحذف
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.green;
    if (status == 'maintenance') color = Colors.orange;
    if (status == 'on_contract' || status == 'sold') color = AppColors.accentGold;
    return Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold));
  }
}
