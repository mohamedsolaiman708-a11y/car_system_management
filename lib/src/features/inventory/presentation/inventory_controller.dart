import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/vehicle.dart';
import '../data/supabase_inventory_repository.dart';

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

  Future<void> deleteVehicle(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(inventoryRepositoryProvider).deleteVehicle(id));
  }
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

@riverpod
Future<Map<String, dynamic>> inventoryStats(InventoryStatsRef ref) {
  return ref.watch(inventoryRepositoryProvider).getInventoryStats();
}

@riverpod
Future<List<String>> vehicleMakes(VehicleMakesRef ref) {
  return ref.watch(inventoryRepositoryProvider).getMakes();
}
