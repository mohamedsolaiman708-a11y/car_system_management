import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/contract.dart';
import '../domain/contract_repository.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_contract_repository.g.dart';

class SupabaseContractRepository implements ContractRepository {
  final SupabaseClient _client;
  SupabaseContractRepository(this._client);

  @override
  Future<List<Contract>> getContracts({
    String? searchQuery,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client.from('financing_contracts').select('*, customers(full_name), inventory_items(make, model, license_plate)');

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('contract_no.ilike.%$searchQuery%');
    }

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => Contract.fromJson(json)).toList();
  }

  @override
  Future<Contract?> getContractById(String id) async {
    final response = await _client
        .from('financing_contracts')
        .select('*, customers(*), inventory_items(*)')
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return Contract.fromJson(response);
  }

  @override
  Future<Contract> createContract(Map<String, dynamic> data) async {
    final response = await _client.from('financing_contracts').insert(data).select().single();
    
    // Audit Log
    try {
      await _client.from('audit_logs').insert({
        'profile_id': _client.auth.currentUser?.id,
        'event_type': 'CONTRACT_CREATED',
        'table_name': 'financing_contracts',
        'record_id': response['id'],
        'new_values': response,
      });
    } catch (_) {}

    return Contract.fromJson(response);
  }

  @override
  Future<Contract> updateContract(String id, Map<String, dynamic> data) async {
    final response = await _client.from('financing_contracts').update(data).eq('id', id).select().single();
    return Contract.fromJson(response);
  }

  @override
  Future<void> activateContract(String id) async {
    // This calls the RPC function 'activate_financing_contract' defined in your SQL schema
    await _client.rpc('activate_financing_contract', params: {'p_contract_id': id});
  }

  @override
  Future<Map<String, dynamic>> getContractStats() async {
    final responses = await Future.wait<dynamic>([
      _client.from('financing_contracts').select('id').count(CountOption.exact),
      _client.from('financing_contracts').select('id').eq('status', 'active').count(CountOption.exact),
      _client.from('financing_contracts').select('id').eq('status', 'draft').count(CountOption.exact),
      _client.from('financing_contracts').select('id').eq('status', 'defaulted').count(CountOption.exact),
    ]);

    final totalRes = responses[0] as PostgrestResponse;
    final activeRes = responses[1] as PostgrestResponse;
    final draftRes = responses[2] as PostgrestResponse;
    final defaultedRes = responses[3] as PostgrestResponse;

    return {
      'total': totalRes.count ?? 0,
      'active': activeRes.count ?? 0,
      'draft': draftRes.count ?? 0,
      'defaulted': defaultedRes.count ?? 0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getContractInstallments(String contractId) async {
    final response = await _client
        .from('installments')
        .select()
        .eq('contract_id', contractId)
        .order('due_date', ascending: true);
    
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getContractPayments(String contractId) async {
    final response = await _client
        .from('payments')
        .select()
        .eq('contract_id', contractId)
        .order('payment_date', ascending: false);
    
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getContractTimeline(String contractId) async {
    final response = await _client
        .from('contract_timeline_view')
        .select()
        .eq('contract_id', contractId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response as List);
  }
}

@Riverpod(keepAlive: true)
SupabaseContractRepository contractRepository(ContractRepositoryRef ref) {
  return SupabaseContractRepository(ref.watch(supabaseClientProvider));
}
