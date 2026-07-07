import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../../domain/vehicle.dart';
import '../inventory_controller.dart';

class VehicleDetailsScreen extends ConsumerWidget {
  final String id;
  const VehicleDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleDetailsProvider(id));
    final currencyFormat = intl.NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المركبة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'تعديل البيانات',
            onPressed: () => context.push('/inventory/$id/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'حذف من المخزون',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: vehicleAsync.when(
        data: (vehicle) {
          if (vehicle == null) return const Center(child: Text('المركبة غير موجودة'));

          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(vehicle),
                  const SizedBox(height: 32),
                  _buildMainInfo(vehicle, currencyFormat),
                  const SizedBox(height: 32),
                  _buildTechnicalSpecs(vehicle),
                  const SizedBox(height: 40),
                  _buildActionButtons(context, ref, vehicle),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      ),
    );
  }

  Widget _buildHeader(Vehicle vehicle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Icon(Icons.directions_car_filled, size: 64, color: Colors.blue.shade900),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${vehicle.make} ${vehicle.model}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'رقم الهيكل: ${vehicle.vin}',
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 12),
              _StatusBadge(status: vehicle.status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainInfo(Vehicle vehicle, intl.NumberFormat currencyFormat) {
    return _buildSection(
      title: 'المعلومات الأساسية',
      icon: Icons.info_outline,
      children: [
        _buildInfoRow('سنة الصنع', vehicle.year.toString()),
        _buildInfoRow('اللون', vehicle.color ?? 'غير محدد'),
        _buildInfoRow('رقم اللوحة', vehicle.licensePlate ?? 'بدون لوحة'),
        _buildInfoRow('سعر الشراء', currencyFormat.format(vehicle.purchasePrice)),
        _buildInfoRow('القيمة السوقية التقديرية', vehicle.estimatedMarketValue != null ? currencyFormat.format(vehicle.estimatedMarketValue) : 'غير محدد'),
        _buildInfoRow('تاريخ الإضافة', intl.DateFormat('yyyy/MM/dd').format(vehicle.createdAt)),
      ],
    );
  }

  Widget _buildTechnicalSpecs(Vehicle vehicle) {
    final specs = vehicle.technicalSpecs;
    return _buildSection(
      title: 'المواصفات الفنية',
      icon: Icons.settings_applications_outlined,
      children: specs.isEmpty 
        ? [const Text('لا توجد مواصفات فنية مسجلة', style: TextStyle(color: Colors.grey))]
        : specs.entries.map((e) => _buildInfoRow(e.key, e.value.toString())).toList(),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade800, size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Vehicle vehicle) {
    return Row(
      children: [
        if (vehicle.status == 'available')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/contracts/new?vehicleId=${vehicle.id}'),
              icon: const Icon(Icons.add_task),
              label: const Text('بدء عقد تمويل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (vehicle.status == 'available') const SizedBox(width: 16),
        
        // زر الصيانة
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _toggleMaintenance(context, ref, vehicle),
            icon: Icon(vehicle.status == 'maintenance' ? Icons.check_circle_outline : Icons.build_circle_outlined),
            label: Text(vehicle.status == 'maintenance' ? 'إعادة للمخزون' : 'إرسال للصيانة'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: vehicle.status == 'maintenance' ? Colors.green : Colors.orange),
              foregroundColor: vehicle.status == 'maintenance' ? Colors.green : Colors.orange.shade900,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه المركبة نهائياً من المخزون؟'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              await ref.read(inventoryControllerProvider.notifier).deleteVehicle(id);
              if (context.mounted) {
                context.pop(); // Close dialog
                context.pop(); // Back to list
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف المركبة')));
                ref.invalidate(vehiclesListProvider);
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleMaintenance(BuildContext context, WidgetRef ref, Vehicle vehicle) async {
    final newStatus = vehicle.status == 'maintenance' ? 'available' : 'maintenance';
    await ref.read(inventoryControllerProvider.notifier).updateVehicle(id, {'status': newStatus});
    ref.invalidate(vehicleDetailsProvider(id));
    ref.invalidate(vehiclesListProvider);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'available': color = Colors.green; label = 'متوفرة'; break;
      case 'on_contract': color = Colors.blue; label = 'مباعة / عقد'; break;
      case 'maintenance': color = Colors.orange; label = 'في الصيانة'; break;
      default: color = Colors.grey; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
