import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import 'investor_data_source.dart';

part 'supabase_investor_data_source.g.dart';

class SupabaseInvestorDataSource implements InvestorDataSource {
  final SupabaseClient _client;

  SupabaseInvestorDataSource(this._client);

  @override
  Future<List<Map<String, dynamic>>> getInvestors() async {
    final response = await _client
        .from('investors')
        .select()
        .order('full_name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>?> getInvestorById(String id) async {
    return await _client
        .from('investors')
        .select()
        .eq('id', id)
        .maybeSingle();
  }

  @override
  Future<Map<String, dynamic>> createInvestor(Map<String, dynamic> data) async {
    final response = await _client
        .from('investors')
        .insert(data)
        .select()
        .single();
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorTransactions(String investorId) async {
    final response = await _client
        .from('investor_transactions')
        .select()
        .eq('investor_id', investorId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorFundedContracts(String investorId) async {
    final response = await _client
        .from('contract_funding')
        .select('*, financing_contracts(*, customers(full_name))')
        .eq('investor_id', investorId);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> insertTransaction(Map<String, dynamic> transactionData) async {
    await _client.from('investor_transactions').insert(transactionData);
  }

  @override
  Future<void> processDeposit(String investorId, double amount, String description) async {
    await _client.rpc('process_investor_deposit', params: {
      'p_investor_id': investorId,
      'p_amount': amount,
      'p_description': description,
    });
  }

  @override
  Future<void> processWithdrawal(String investorId, double amount, String description) async {
    await _client.rpc('process_investor_withdrawal', params: {
      'p_investor_id': investorId,
      'p_amount': amount,
      'p_description': description,
    });
  }

  @override
  Future<void> allocateFunding(String contractId, String investorId, double amount) async {
    await _client.rpc('allocate_contract_funding', params: {
      'p_contract_id': contractId,
      'p_investor_id': investorId,
      'p_amount': amount,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingInvestorRequests() async {
    final response = await _client
        .from('profiles')
        .select('*, roles!inner(*)')
        .eq('roles.slug', 'investor')
        .eq('status', 'pending');
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> approveInvestor(String profileId) async {
    await _client.rpc('approve_investor_profile', params: {
      'p_profile_id': profileId,
    });
  }

  @override
  Future<void> rejectInvestor(String profileId, String reason) async {
    await _client.from('profiles').update({
      'status': 'rejected',
      'rejection_reason': reason,
      'rejected_at': DateTime.now().toIso8601String(),
    }).eq('id', profileId);
  }

  @override
  Stream<Map<String, dynamic>?> watchInvestor(String id) {
    return _client
        .from('investors')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) => data.isNotEmpty ? data.first : null);
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorDocuments(String investorId) async {
    try {
      final response = await _client
          .from('contract_documents')
          .select()
          .eq('investor_id', investorId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> uploadInvestorDocument(Map<String, dynamic> documentData) async {
    await _client.from('contract_documents').insert(documentData);
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    await _client.from('contract_documents').delete().eq('id', documentId);
  }

  @override
  Future<void> distributeProfit(String investorId, double amount, String description) async {
    await _client.rpc('process_manual_profit_distribution', params: {
      'p_investor_id': investorId,
      'p_amount': amount,
      'p_description': description,
    });
  }

  @override
  Future<void> requestWithdrawal(double amount, String bankDetails) async {
    await _client.rpc('request_withdrawal', params: {
      'p_amount': amount,
      'p_bank_details': bankDetails,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getWithdrawalRequests({String? investorId, String? status}) async {
    var query = _client.from('withdrawal_requests').select('*, investors(full_name)');
    
    if (investorId != null) {
      query = query.eq('investor_id', investorId);
    }
    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> approveWithdrawalRequest(String requestId) async {
    await _client.rpc('approve_withdrawal_request', params: {
      'p_request_id': requestId,
    });
  }

  @override
  Future<void> rejectWithdrawalRequest(String requestId, String reason) async {
    await _client.from('withdrawal_requests').update({
      'status': 'rejected',
      'rejection_reason': reason,
      'processed_at': DateTime.now().toIso8601String(),
      'processed_by': _client.auth.currentUser?.id,
    }).eq('id', requestId);
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorProjections(String investorId) async {
    final response = await _client.rpc('get_investor_expected_cashflow', params: {
      'p_investor_id': investorId,
    });
    return List<Map<String, dynamic>>.from(response as List);
  }
}

@Riverpod(keepAlive: true)
InvestorDataSource investorDataSource(InvestorDataSourceRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseInvestorDataSource(client);
}
