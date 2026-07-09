import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_disaster_recovery_repository.g.dart';

class SupabaseDisasterRecoveryRepository {
  final SupabaseClient _client;
  SupabaseDisasterRecoveryRepository(this._client);

  Future<Map<String, dynamic>> performIntegrityCheck() async {
    final response = await _client.rpc('perform_system_integrity_check');
    return Map<String, dynamic>.from(response);
  }

  Future<List<Map<String, dynamic>>> getIntegrityHistory() async {
    final response = await _client
        .from('integrity_checks')
        .select()
        .order('check_date', ascending: false)
        .limit(20);
    
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<Map<String, dynamic>> repairInvestorBalances() async {
    final response = await _client.rpc('repair_investor_balances');
    return Map<String, dynamic>.from(response);
  }

  Future<void> toggleFinancialFreeze(bool isFrozen) async {
    await _client.rpc('toggle_financial_freeze', params: {'p_is_frozen': isFrozen});
  }

  Future<bool> isSystemFrozen() async {
    final response = await _client.rpc('is_financial_system_frozen');
    return response as bool;
  }
}

@Riverpod(keepAlive: true)
SupabaseDisasterRecoveryRepository disasterRecoveryRepository(DisasterRecoveryRepositoryRef ref) {
  return SupabaseDisasterRecoveryRepository(ref.watch(supabaseClientProvider));
}
