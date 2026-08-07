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
      if (Failure.isNetworkError(e)) {
        _ref.read(connectionNotifierProvider.notifier).setOffline();
      }
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
      // استبدال maybeSingle بـ limit(1) لمنع تعطل الويب
      final response = await _client.from('inventory_items').select().eq('id', id).limit(1);
      if ((response as List).isEmpty) return null;
      final vehicle = Vehicle.fromJson(response.first);
      _memCache[cacheKey] = vehicle;
      return vehicle;
    } catch (e) {
      if (Failure.isNetworkError(e)) {
        _ref.read(connectionNotifierProvider.notifier).setOffline();
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Vehicle> createVehicle(Map<String, dynamic> data) async {
    try {
      // تجنب .single()
      final response = await _client.from('inventory_items').insert(data).select();
      if ((response as List).isEmpty) throw const Failure(message: 'فشل إضافة المركبة');
      
      final record = response.first;
      _memCache.clear(); 

      try {
        await _client.from('audit_logs').insert({
          'profile_id': _client.auth.currentUser?.id,
          'event_type': 'VEHICLE_CREATED',
          'table_name': 'inventory_items',
          'record_id': record['id'],
          'new_values': record,
        });
      } catch (_) {}

      return Vehicle.fromJson(record);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Vehicle> updateVehicle(String id, Map<String, dynamic> data) async {
    try {
      // تجنب .single()
      final oldDataQuery = await _client.from('inventory_items').select().eq('id', id).limit(1);
      final oldData = (oldDataQuery as List).isNotEmpty ? oldDataQuery.first : null;
      
      final response = await _client.from('inventory_items').update(data).eq('id', id).select();
      if ((response as List).isEmpty) throw const Failure(message: 'فشل تحديث بيانات المركبة');

      final record = response.first;
      _memCache.clear(); 

      try {
        await _client.from('audit_logs').insert({
          'profile_id': _client.auth.currentUser?.id,
          'event_type': 'VEHICLE_UPDATED',
          'table_name': 'inventory_items',
          'record_id': id,
          'old_values': oldData,
          'new_values': record,
        });
      } catch (_) {}

      return Vehicle.fromJson(record);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await _client.from('inventory_items').delete().eq('id', id);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<String>> getMakes() async {
    try {
      final response = await _client.from('inventory_items').select('make');
      final makes = (response as List).map((item) => item['make'] as String).toSet().toList();
      makes.sort();
      return makes;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryStats() async {
    try {
      final responses = await Future.wait<dynamic>([
        _client.from('inventory_items').select('id').count(CountOption.exact),
        _client.from('inventory_items').select('id').eq('status', 'available').count(CountOption.exact),
        _client.from('inventory_items').select('id').eq('status', 'on_contract').count(CountOption.exact),
        _client.from('inventory_items').select('id').eq('status', 'maintenance').count(CountOption.exact),
      ]);

      return {
        'total': (responses[0] as PostgrestResponse).count ?? 0,
        'available': (responses[1] as PostgrestResponse).count ?? 0,
        'on_contract': (responses[2] as PostgrestResponse).count ?? 0,
        'maintenance': (responses[3] as PostgrestResponse).count ?? 0,
      };
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMaintenanceLogs(String vehicleId) async {
    try {
      final response = await _client
          .from('maintenance_logs')
          .select()
          .eq('inventory_item_id', vehicleId)
          .order('performed_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
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
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}

@Riverpod(keepAlive: true)
SupabaseInventoryRepository inventoryRepository(InventoryRepositoryRef ref) {
  return SupabaseInventoryRepository(ref.watch(supabaseClientProvider), ref);
}
