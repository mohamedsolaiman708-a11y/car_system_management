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
  Future<List<Contract>> getContracts({String? searchQuery, String? status, int limit = 20, int offset = 0}) async {
    var query = _client.from('financing_contracts').select('*, customers(full_name), inventory_items(make, model, license_plate)');
    if (searchQuery != null && searchQuery.isNotEmpty) query = query.or('contract_no.ilike.%$searchQuery%');
    if (status != null) query = query.eq('status', status);
    final response = await query.order('created_at', ascending: false).range(offset, offset + limit - 1);
    return (response as List).map((json) => Contract.fromJson(json)).toList();
  }

  @override
  Future<Contract?> getContractById(String id) async {
    final response = await _client.from('financing_contracts').select('*, customers(*), inventory_items(*)').eq('id', id).maybeSingle();
    return response != null ? Contract.fromJson(response) : null;
  }

  @override
  Future<Contract> createContract(Map<String, dynamic> data) async {
    final response = await _client.from('financing_contracts').insert(data).select().single();
    return Contract.fromJson(response);
  }

  @override
  Future<Contract> updateContract(String id, Map<String, dynamic> data) async {
    final response = await _client.from('financing_contracts').update(data).eq('id', id).select().single();
    return Contract.fromJson(response);
  }

  @override
  Future<void> activateContract(String id) async {
    await _client.rpc('activate_financing_contract', params: {'p_contract_id': id});
  }

  @override
  Future<void> processPayment({
    required String contractId,
    required double amount,
    required String method,
    String? reference,
    String? idempotencyKey,
    String? notes,
  }) async {
    // إرسال البارامترات كاملة بما فيها Idempotency Key لمنع السحب المزدوج
    await _client.rpc('process_installment_payment', params: {
      'p_contract_id': contractId,
      'p_amount_paid': amount,
      'p_payment_method': method,
      'p_reference_no': reference,
      'p_notes': notes,
      'p_idempotency_key': idempotencyKey,
    });
  }

  @override
  Future<void> reversePayment(String paymentId, String reason) async {
    await _client.rpc('reverse_contract_payment', params: {'p_payment_id': paymentId, 'p_reason': reason});
  }

  @override
  Future<Map<String, dynamic>> getContractStats() async {
    // استعادة الإحصائيات التفصيلية للوحة التحكم (Dashboard)
    final responses = await Future.wait([
      _client.from('financing_contracts').select('id', const FetchOptions(count: CountOption.exact)),
      _client.from('financing_contracts').select('id', const FetchOptions(count: CountOption.exact)).eq('status', 'active'),
      _client.from('financing_contracts').select('id', const FetchOptions(count: CountOption.exact)).eq('status', 'draft'),
      _client.from('financing_contracts').select('id', const FetchOptions(count: CountOption.exact)).eq('status', 'defaulted'),
    ]);

    return {
      'total': responses[0].count ?? 0,
      'active': responses[1].count ?? 0,
      'draft': responses[2].count ?? 0,
      'defaulted': responses[3].count ?? 0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getContractInstallments(String contractId) async {
    final response = await _client.from('installments').select().eq('contract_id', contractId).order('due_date', ascending: true);
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getContractPayments(String contractId) async {
    final response = await _client.from('payments').select().eq('contract_id', contractId).order('payment_date', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getContractTimeline(String contractId) async {
    // استخدام View إذا كانت موجودة، أو العودة لـ audit_logs
    try {
      final response = await _client.from('contract_timeline_view').select().eq('contract_id', contractId).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (_) {
      final response = await _client.from('audit_logs').select().eq('record_id', contractId).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getContractFunding(String contractId) async {
    final response = await _client.from('contract_funding').select('*, investors(full_name)').eq('contract_id', contractId);
    return List<Map<String, dynamic>>.from(response as List);
  }
}

@Riverpod(keepAlive: true)
SupabaseContractRepository contractRepository(ContractRepositoryRef ref) {
  return SupabaseContractRepository(ref.watch(supabaseClientProvider));
}
