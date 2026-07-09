import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:car_system_management/src/features/inventory/domain/vehicle.dart';
import 'package:car_system_management/src/features/inventory/data/supabase_inventory_repository.dart';

part 'inventory_controller.g.dart';

@riverpod
class InventoryController extends _$InventoryController {
  @override
  FutureOr<void> build() {
    // Initial build
  }

  Future<void> createVehicle(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(inventoryRepositoryProvider).createVehicle(data));
  }

  Future<void> updateVehicle(String id, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(inventoryRepositoryProvider).updateVehicle(id, data));
  }

  /// تحديث حالة السيارة - الحل الاحترافي: استخدام الحالة المباشرة بعد تحديث الـ Enum في قاعدة البيانات
  Future<void> updateVehicleStatus(String id, String status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(inventoryRepositoryProvider).updateVehicle(id, {'status': status});
      return null;
    });
    ref.invalidate(vehiclesListProvider);
  }

  Future<void> deleteVehicle(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(inventoryRepositoryProvider).deleteVehicle(id));
  }

  Future<void> addMaintenanceLog(String vehicleId, String description, double cost) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(inventoryRepositoryProvider).addMaintenanceLog(
        vehicleId: vehicleId,
        description: description,
        cost: cost,
      )
    );
    ref.invalidate(vehicleMaintenanceLogsProvider(vehicleId));
  }
}

@riverpod
Future<Map<String, dynamic>> inventoryStats(InventoryStatsRef ref) {
  return ref.watch(inventoryRepositoryProvider).getInventoryStats();
}

@riverpod
Future<List<Map<String, dynamic>>> vehicleMaintenanceLogs(VehicleMaintenanceLogsRef ref, String vehicleId) {
  return ref.watch(inventoryRepositoryProvider).getMaintenanceLogs(vehicleId);
}

@riverpod
Future<List<Vehicle>> vehiclesList(
  VehiclesListRef ref, {
  String? searchQuery,
  String? status,
  String? make,
}) {
  return ref.watch(inventoryRepositoryProvider).getVehicles(
        searchQuery: searchQuery,
        status: status,
        make: make,
      );
}

@riverpod
Future<Vehicle?> vehicleDetails(VehicleDetailsRef ref, String id) {
  return ref.watch(inventoryRepositoryProvider).getVehicleById(id);
}
