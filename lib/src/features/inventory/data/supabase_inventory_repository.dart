import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/vehicle.dart';
import '../domain/inventory_repository.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_inventory_repository.g.dart';

class SupabaseInventoryRepository implements InventoryRepository {
  final SupabaseClient _client;
  SupabaseInventoryRepository(this._client);

  @override
  Future<List<Vehicle>> getVehicles({
    String? searchQuery,
    String? status,
    String? make,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client.from('inventory_items').select();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('vin.ilike.%$searchQuery%,make.ilike.%$searchQuery%,model.ilike.%$searchQuery%,license_plate.ilike.%$searchQuery%');
    }

    if (status != null) {
      query = query.eq('status', status);
    }

    if (make != null) {
      query = query.eq('make', make);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => Vehicle.fromJson(json)).toList();
  }

  @override
  Future<Vehicle?> getVehicleById(String id) async {
    final response = await _client.from('inventory_items').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return Vehicle.fromJson(response);
  }

  @override
  Future<Vehicle> createVehicle(Map<String, dynamic> data) async {
    final response = await _client.from('inventory_items').insert(data).select().single();
    
    // Audit Log
    try {
      await _client.from('audit_logs').insert({
        'profile_id': _client.auth.currentUser?.id,
        'event_type': 'VEHICLE_CREATED',
        'table_name': 'inventory_items',
        'record_id': response['id'],
        'new_values': response,
      });
    } catch (_) {}

    return Vehicle.fromJson(response);
  }

  @override
  Future<Vehicle> updateVehicle(String id, Map<String, dynamic> data) async {
    final oldData = await _client.from('inventory_items').select().eq('id', id).single();
    final response = await _client.from('inventory_items').update(data).eq('id', id).select().single();
    
    // Audit Log
    try {
      await _client.from('audit_logs').insert({
        'profile_id': _client.auth.currentUser?.id,
        'event_type': 'VEHICLE_UPDATED',
        'table_name': 'inventory_items',
        'record_id': id,
        'old_values': oldData,
        'new_values': response,
      });
    } catch (_) {}

    return Vehicle.fromJson(response);
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await _client.from('inventory_items').delete().eq('id', id);
  }

  @override
  Future<List<String>> getMakes() async {
    final response = await _client.from('inventory_items').select('make');
    final makes = (response as List).map((item) => item['make'] as String).toSet().toList();
    makes.sort();
    return makes;
  }

  @override
  Future<Map<String, dynamic>> getInventoryStats() async {
    final responses = await Future.wait<dynamic>([
      _client.from('inventory_items').select('id').count(CountOption.exact),
      _client.from('inventory_items').select('id').eq('status', 'available').count(CountOption.exact),
      _client.from('inventory_items').select('id').eq('status', 'on_contract').count(CountOption.exact),
      _client.from('inventory_items').select('id').eq('status', 'maintenance').count(CountOption.exact),
    ]);

    final totalRes = responses[0] as PostgrestResponse;
    final availableRes = responses[1] as PostgrestResponse;
    final onContractRes = responses[2] as PostgrestResponse;
    final maintenanceRes = responses[3] as PostgrestResponse;

    return {
      'total': totalRes.count ?? 0,
      'available': availableRes.count ?? 0,
      'on_contract': onContractRes.count ?? 0,
      'maintenance': maintenanceRes.count ?? 0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getMaintenanceLogs(String vehicleId) async {
    final response = await _client
        .from('maintenance_logs')
        .select()
        .eq('inventory_item_id', vehicleId)
        .order('performed_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<void> addMaintenanceLog({
    required String vehicleId,
    required String description,
    required double cost,
  }) async {
    await _client.from('maintenance_logs').insert({
      'inventory_item_id': vehicleId,
      'description': description,
      'cost': cost,
      'performed_at': DateTime.now().toIso8601String().split('T')[0], // format as YYYY-MM-DD
    });
  }
}

@Riverpod(keepAlive: true)
SupabaseInventoryRepository inventoryRepository(InventoryRepositoryRef ref) {
  return SupabaseInventoryRepository(ref.watch(supabaseClientProvider));
}
