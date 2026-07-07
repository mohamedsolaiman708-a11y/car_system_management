import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../inventory_controller.dart';
import '../domain/vehicle.dart';

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
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/inventory/$id/edit'),
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
                  const SizedBox(height: 32),
                  _buildActionButtons(context, vehicle),
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
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.directions_car, size: 64, color: Colors.grey),
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
                'رقم الهيكل (VIN): ${vehicle.vin}',
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
    if (specs.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      title: 'المواصفات الفنية',
      icon: Icons.settings_applications_outlined,
      children: specs.entries.map((e) => _buildInfoRow(e.key, e.value.toString())).toList(),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue.shade800, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ],
        ),
        const Divider(height: 32),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Vehicle vehicle) {
    return Row(
      children: [
        if (vehicle.status == 'available')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to create contract with this vehicle
              },
              icon: const Icon(Icons.add_assignment),
              label: const Text('إنشاء عقد تمويل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        if (vehicle.status == 'available') const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Register maintenance
            },
            icon: const Icon(Icons.build_circle_outlined),
            label: const Text('تسجيل صيانة'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
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
      case 'available':
        color = Colors.green;
        label = 'متوفرة للبيع';
        break;
      case 'on_contract':
        color = Colors.blue;
        label = 'مرتبطة بعقد نشط';
        break;
      case 'maintenance':
        color = Colors.orange;
        label = 'في الصيانة';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
