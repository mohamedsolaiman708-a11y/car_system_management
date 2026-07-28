import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/utils/error_handler.dart';
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
    final user = _client.auth.currentUser;

    var response = await _client
        .from('investors')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null && user != null && user.email != null) {
      response = await _client
          .from('investors')
          .select()
          .eq('email', user.email!)
          .maybeSingle();
    }

    return response;
  }

  @override
  Future<Map<String, dynamic>> createInvestor(Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data);
    payload.removeWhere((key, value) => value == null);

    try {
      final response = await _client
          .from('investors')
          .insert(payload)
          .select()
          .single();
      return response;
    } catch (e) {
      if (payload.containsKey('phone')) {
        payload.remove('phone');
        final response = await _client
            .from('investors')
            .insert(payload)
            .select()
            .single();
        return response;
      }
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorTransactions(
    String investorId,
  ) async {
    final response = await _client
        .from('investor_transactions')
        .select()
        .eq('investor_id', investorId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorFundedContracts(
    String investorId,
  ) async {
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
  Future<void> processDeposit(
    String investorId,
    double amount,
    String description,
  ) async {
    await _client.rpc(
      'process_investor_deposit',
      params: {
        'p_investor_id': investorId,
        'p_amount': amount,
        'p_description': description,
        'p_idempotency_key': null,
      },
    );
  }

  @override
  Future<void> processWithdrawal(
    String investorId,
    double amount,
    String description,
  ) async {
    await _client.rpc(
      'process_investor_withdrawal',
      params: {
        'p_investor_id': investorId,
        'p_amount': amount,
        'p_description': description,
        'p_idempotency_key': null,
      },
    );
  }

  @override
  Future<void> allocateFunding(
    String contractId,
    String investorId,
    double amount,
  ) async {
    await _client.rpc(
      'allocate_contract_funding',
      params: {
        'p_contract_id': contractId,
        'p_investor_id': investorId,
        'p_amount': amount,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingInvestorRequests() async {
    try {
      final response = await _client.rpc('get_pending_investors');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (_) {}

    try {
      final response = await _client.from('profiles').select('*, roles(slug)');
      if (response == null) return [];
      final List<dynamic> data = response as List;

      return data
          .map((item) {
            final Map<String, dynamic> p = Map<String, dynamic>.from(item);
            final status = (p['status'] ?? '').toString().toLowerCase().trim();
            final roleData = p['roles'];
            String? roleSlug;
            if (roleData is Map) {
              roleSlug = roleData['slug'];
            }
            final isInvestorType = roleSlug == null || roleSlug == 'investor';
            final isPendingStatus = status == 'pending' || status == 'waiting' || status == '';
            return (isInvestorType && isPendingStatus) ? p : null;
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> approveInvestor(String profileId) async {
    await _client.rpc(
      'approve_investor_profile',
      params: {'p_profile_id': profileId},
    );
  }

  @override
  Future<void> rejectInvestor(String profileId, String reason) async {
    try {
      await _client.rpc(
        'reject_investor_profile',
        params: {'p_profile_id': profileId, 'p_reason': reason},
      );
    } catch (_) {
      await _client
          .from('profiles')
          .update({
            'status': 'rejected',
            'rejection_reason': reason,
            'rejected_at': DateTime.now().toIso8601String(),
          })
          .eq('id', profileId);
    }
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
  Future<List<Map<String, dynamic>>> getInvestorDocuments(
    String investorId,
  ) async {
    try {
      // إصلاح سينيور: بما أن جدول contract_documents مربوط بـ contract_id فقط
      // نأتي أولاً بالعقود التي يمولها المستثمر
      final funding = await _client
          .from('contract_funding')
          .select('contract_id')
          .eq('investor_id', investorId);
      
      final contractIds = (funding as List).map((f) => f['contract_id']).toList();
      
      if (contractIds.isEmpty) return [];

      // جلب المستندات المرتبطة بتلك العقود
      final response = await _client
          .from('contract_documents')
          .select()
          .inFilter('contract_id', contractIds);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching documents: $e');
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
  Future<void> distributeProfit(
    String investorId,
    double amount,
    String description,
  ) async {
    await _client.rpc(
      'process_manual_profit_distribution',
      params: {
        'p_investor_id': investorId,
        'p_amount': amount,
        'p_description': description,
        'p_idempotency_key': null,
      },
    );
  }

  @override
  Future<void> requestWithdrawal(double amount, String bankDetails) async {
    await _client.rpc(
      'request_withdrawal',
      params: {'p_amount': amount, 'p_bank_details': bankDetails},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getWithdrawalRequests({
    String? investorId,
    String? status,
  }) async {
    try {
      // تأكدنا من عمل join صحيح مع جدول investors
      var query = _client
          .from('withdrawal_requests')
          .select('*, investors:investor_id(full_name), profiles:investor_id(full_name)');

      if (investorId != null) query = query.eq('investor_id', investorId);
      if (status != null) query = query.eq('status', status);

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Withdrawal Error: $e');
      try {
        var query = _client.from('withdrawal_requests').select();
        if (investorId != null) query = query.eq('investor_id', investorId);
        final response = await query.order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      } catch (e2) {
        throw Failure.fromException(e2);
      }
    }
  }

  @override
  Future<void> approveWithdrawalRequest(String requestId) async {
    await _client.rpc(
      'approve_withdrawal_request',
      params: {'p_request_id': requestId},
    );
  }

  @override
  Future<void> rejectWithdrawalRequest(String requestId, String reason) async {
    await _client
        .from('withdrawal_requests')
        .update({
          'status': 'rejected',
          'rejection_reason': reason,
          'processed_at': DateTime.now().toIso8601String(),
          'processed_by': _client.auth.currentUser?.id,
        })
        .eq('id', requestId);
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorProjections(
    String investorId,
  ) async {
    final response = await _client.rpc(
      'get_investor_expected_cashflow',
      params: {'p_investor_id': investorId},
    );
    return List<Map<String, dynamic>>.from(response as List);
  }
}

@Riverpod(keepAlive: true)
InvestorDataSource investorDataSource(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseInvestorDataSource(client);
}
