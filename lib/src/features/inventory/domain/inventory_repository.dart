import 'vehicle.dart';

abstract class InventoryRepository {
  Future<List<Vehicle>> getVehicles({
    String? searchQuery,
    String? status,
    String? make,
    int limit = 20,
    int offset = 0,
  });

  Future<Vehicle?> getVehicleById(String id);

  Future<Vehicle> createVehicle(Map<String, dynamic> data);

  Future<Vehicle> updateVehicle(String id, Map<String, dynamic> data);

  Future<void> deleteVehicle(String id);

  Future<List<String>> getMakes();

  Future<Map<String, dynamic>> getInventoryStats();
}
