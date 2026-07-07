import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../domain/vehicle.dart';
import '../inventory_controller.dart';

class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  String _searchQuery = '';
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesListProvider(
      searchQuery: _searchQuery,
      status: _selectedStatus,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المخزون والسيارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(vehiclesListProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: vehiclesAsync.when(
              data: (vehicles) {
                if (vehicles.isEmpty) {
                  return const Center(child: Text('لا توجد سيارات في المخزون حالياً'));
                }
                return _buildVehiclesGrid(vehicles);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/new'),
        label: const Text('إضافة سيارة جديدة'),
        icon: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'بحث برقم الهيكل، الماركة، أو اللوحة...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              hint: const Text('الحالة'),
              items: const [
                DropdownMenuItem(value: null, child: Text('الكل')),
                DropdownMenuItem(value: 'available', child: Text('متوفرة')),
                DropdownMenuItem(value: 'on_contract', child: Text('مباعة/عقد')),
                DropdownMenuItem(value: 'maintenance', child: Text('صيانة')),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesGrid(List<Vehicle> vehicles) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 800 ? 3 : 1),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _VehicleCard(vehicle: vehicle);
      },
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = intl.NumberFormat.currency(symbol: 'ر.س', decimalDigits: 0);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/inventory/${vehicle.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Image Placeholder
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: const Icon(Icons.directions_car, size: 64, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      _StatusBadge(status: vehicle.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'سنة الصنع: ${vehicle.year}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('سعر الشراء:', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      Text(
                        currencyFormat.format(vehicle.purchasePrice),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('رقم اللوحة:', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      Text(
                        vehicle.licensePlate ?? 'بدون',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        label = 'متوفرة';
        break;
      case 'on_contract':
        color = Colors.blue;
        label = 'في عقد';
        break;
      case 'maintenance':
        color = Colors.orange;
        label = 'صيانة';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
