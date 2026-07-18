import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/vehicle.dart';
import '../domain/inventory_repository.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/utils/error_handler.dart';

part 'supabase_inventory_repository.g.dart';

class SupabaseInventoryRepository implements InventoryRepository {
  final SupabaseClient _client;
  final Ref _ref;
  final Map<String, dynamic> _memCache = {};

  SupabaseInventoryRepository(this._client, this._ref);

  @override
  Future<List<Vehicle>> getVehicles({
    String? searchQuery,
    String? status,
    String? make,
    int limit = 20,
    int offset = 0,
  }) async {
    final cacheKey = 'getVehicles_${searchQuery ?? ''}_${status ?? ''}_${make ?? ''}_${limit}_$offset';
    try {
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

      final list = (response as List).map((json) => Vehicle.fromJson(json)).toList();
      _memCache[cacheKey] = list;
      return list;
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      if (_memCache.containsKey(cacheKey)) {
        return _memCache[cacheKey] as List<Vehicle>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Vehicle?> getVehicleById(String id) async {
    final cacheKey = 'getVehicleById_$id';
    try {
      final response = await _client.from('inventory_items').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      final vehicle = Vehicle.fromJson(response);
      _memCache[cacheKey] = vehicle;
      return vehicle;
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      if (_memCache.containsKey(cacheKey)) {
        return _memCache[cacheKey] as Vehicle?;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Vehicle> createVehicle(Map<String, dynamic> data) async {
    try {
      final response = await _client.from('inventory_items').insert(data).select().single();
      _memCache.clear(); // Invalidate cache

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
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Vehicle> updateVehicle(String id, Map<String, dynamic> data) async {
    try {
      final oldData = await _client.from('inventory_items').select().eq('id', id).single();
      final response = await _client.from('inventory_items').update(data).eq('id', id).select().single();
      _memCache.clear(); // Invalidate cache

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
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await _client.from('inventory_items').delete().eq('id', id);
      _memCache.clear(); // Invalidate cache
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<String>> getMakes() async {
    const cacheKey = 'getMakes';
    try {
      final response = await _client.from('inventory_items').select('make');
      final makes = (response as List).map((item) => item['make'] as String).toSet().toList();
      makes.sort();
      _memCache[cacheKey] = makes;
      return makes;
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      if (_memCache.containsKey(cacheKey)) {
        return _memCache[cacheKey] as List<String>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryStats() async {
    const cacheKey = 'getInventoryStats';
    try {
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

      final stats = {
        'total': totalRes.count ?? 0,
        'available': availableRes.count ?? 0,
        'on_contract': onContractRes.count ?? 0,
        'maintenance': maintenanceRes.count ?? 0,
      };
      _memCache[cacheKey] = stats;
      return stats;
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      if (_memCache.containsKey(cacheKey)) {
        return _memCache[cacheKey] as Map<String, dynamic>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMaintenanceLogs(String vehicleId) async {
    final cacheKey = 'getMaintenanceLogs_$vehicleId';
    try {
      final response = await _client
          .from('maintenance_logs')
          .select()
          .eq('inventory_item_id', vehicleId)
          .order('performed_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(response as List);
      _memCache[cacheKey] = list;
      return list;
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      if (_memCache.containsKey(cacheKey)) {
        return _memCache[cacheKey] as List<Map<String, dynamic>>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> addMaintenanceLog({
    required String vehicleId,
    required String description,
    required double cost,
  }) async {
    try {
      await _client.from('maintenance_logs').insert({
        'inventory_item_id': vehicleId,
        'description': description,
        'cost': cost,
        'performed_at': DateTime.now().toIso8601String().split('T')[0],
      });
      _memCache.remove('getMaintenanceLogs_$vehicleId'); // Invalidate specific log cache
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      throw Failure.fromException(e);
    }
  }
}

@Riverpod(keepAlive: true)
SupabaseInventoryRepository inventoryRepository(InventoryRepositoryRef ref) {
  return SupabaseInventoryRepository(ref.watch(supabaseClientProvider), ref);
}
