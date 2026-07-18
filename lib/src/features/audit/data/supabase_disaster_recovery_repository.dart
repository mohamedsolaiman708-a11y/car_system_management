import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/utils/error_handler.dart';

part 'supabase_disaster_recovery_repository.g.dart';

class SupabaseDisasterRecoveryRepository {
  final SupabaseClient _client;
  final Map<String, dynamic> _memCache = {};

  SupabaseDisasterRecoveryRepository(this._client);

  Future<Map<String, dynamic>> performIntegrityCheck() async {
    try {
      final response = await _client.rpc('perform_system_integrity_check');
      final data = Map<String, dynamic>.from(response);
      _memCache['integrity_status'] = data;
      return data;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<Map<String, dynamic>>> getIntegrityHistory() async {
    const key = 'integrity_history';
    try {
      final response = await _client
          .from('integrity_checks')
          .select()
          .order('check_date', ascending: false)
          .limit(20);
      
      final list = List<Map<String, dynamic>>.from(response as List);
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<Map<String, dynamic>>;
      }
      throw Failure.fromException(e);
    }
  }

  Future<Map<String, dynamic>> repairInvestorBalances() async {
    try {
      final response = await _client.rpc('repair_investor_balances');
      _memCache.clear();
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> toggleFinancialFreeze(bool isFrozen) async {
    try {
      await _client.rpc('toggle_financial_freeze', params: {'p_is_frozen': isFrozen});
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<bool> isSystemFrozen() async {
    const key = 'system_frozen';
    try {
      final response = await _client.rpc('is_financial_system_frozen');
      final val = response as bool;
      _memCache[key] = val;
      return val;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as bool;
      }
      throw Failure.fromException(e);
    }
  }
}

@Riverpod(keepAlive: true)
SupabaseDisasterRecoveryRepository disasterRecoveryRepository(DisasterRecoveryRepositoryRef ref) {
  return SupabaseDisasterRecoveryRepository(ref.watch(supabaseClientProvider));
}
