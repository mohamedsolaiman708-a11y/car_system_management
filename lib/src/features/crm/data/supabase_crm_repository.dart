import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/customer.dart';
import '../domain/crm_repository.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_crm_repository.g.dart';

class SupabaseCrmRepository implements CrmRepository {
  final SupabaseClient _client;
  SupabaseCrmRepository(this._client);

  @override
  Future<List<Customer>> getCustomers({
    String? searchQuery,
    String? status,
    String? city,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client.from('customers').select();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('full_name.ilike.%$searchQuery%,national_id.ilike.%$searchQuery%,phone.ilike.%$searchQuery%');
    }

    if (status != null) {
      query = query.eq('risk_rating', status);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => Customer.fromJson(json)).toList();
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    final response = await _client.from('customers').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return Customer.fromJson(response);
  }

  @override
  Future<Customer> createCustomer(Map<String, dynamic> data) async {
    final response = await _client.from('customers').insert(data).select().single();
    
    // Audit Log using RPC if defined, or direct insert
    try {
      await _client.from('audit_logs').insert({
        'profile_id': _client.auth.currentUser?.id,
        'event_type': 'CUSTOMER_CREATED',
        'table_name': 'customers',
        'record_id': response['id'],
        'new_values': response,
      });
    } catch (_) {
      // Fallback or ignore if audit_logs fails
    }

    return Customer.fromJson(response);
  }

  @override
  Future<Customer> updateCustomer(String id, Map<String, dynamic> data) async {
    // Get old data for audit
    final oldData = await _client.from('customers').select().eq('id', id).single();
    
    final response = await _client.from('customers').update(data).eq('id', id).select().single();
    
    // Audit Log
    try {
      await _client.from('audit_logs').insert({
        'profile_id': _client.auth.currentUser?.id,
        'event_type': 'CUSTOMER_UPDATED',
        'table_name': 'customers',
        'record_id': id,
        'old_values': oldData,
        'new_values': response,
      });
    } catch (_) {}

    return Customer.fromJson(response);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _client.from('customers').delete().eq('id', id);
  }

  @override
  Future<Map<String, dynamic>> getCustomerFinancialSummary(String id) async {
    final contracts = await _client
        .from('financing_contracts')
        .select('id, status, total_contract_value')
        .eq('customer_id', id);
    
    final contractsList = contracts as List;
    final activeContracts = contractsList.where((c) => c['status'] == 'active').length;
    final closedContracts = contractsList.where((c) => c['status'] == 'closed').length;
    
    double totalContractsValue = 0;
    for (var c in contractsList) {
      totalContractsValue += (c['total_contract_value'] as num).toDouble();
    }

    double totalPaid = 0;
    if (contractsList.isNotEmpty) {
      final contractIds = contractsList.map((c) => c['id']).toList();
      final payments = await _client
          .from('payments')
          .select('amount_total')
          .inFilter('contract_id', contractIds);
      
      for (var p in (payments as List)) {
        totalPaid += (p['amount_total'] as num).toDouble();
      }
    }

    int lateInstallments = 0;
    if (contractsList.isNotEmpty) {
      final contractIds = contractsList.map((c) => c['id']).toList();
      // Fixed: Removed FetchOptions and used .count() for Supabase 2.x compatibility
      final lateResponse = await _client
          .from('installments')
          .select('id')
          .inFilter('contract_id', contractIds)
          .lt('due_date', DateTime.now().toIso8601String())
          .neq('status', 'paid');
      
      // If the above still fails in your specific environment, try the count() chain:
      // final lateResponse = await _client.from('installments').select('id').inFilter(...).count(CountOption.exact);

      lateInstallments = (lateResponse as PostgrestResponse).count ?? 0;
    }

    return {
      'total_contracts': contractsList.length,
      'active_contracts': activeContracts,
      'closed_contracts': closedContracts,
      'total_paid': totalPaid,
      'outstanding_balance': totalContractsValue - totalPaid,
      'delayed_installments': lateInstallments, 
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerTimeline(String id) async {
    // Querying direct audit_logs table from your schema
    final response = await _client
        .from('audit_logs')
        .select()
        .eq('record_id', id)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response as List);
  }
  
  @override
  Future<List<Map<String, dynamic>>> getCustomerContracts(String customerId) async {
    final response = await _client
        .from('financing_contracts')
        .select('*, inventory_items(make, model, year, license_plate)')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerPayments(String customerId) async {
    final contracts = await _client
        .from('financing_contracts')
        .select('id')
        .eq('customer_id', customerId);
    
    final contractIds = (contracts as List).map((c) => c['id']).toList();
    if (contractIds.isEmpty) return [];

    final response = await _client
        .from('payments')
        .select('*, financing_contracts(contract_no)')
        .inFilter('contract_id', contractIds)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerInstallments(String customerId) async {
    final contracts = await _client
        .from('financing_contracts')
        .select('id')
        .eq('customer_id', customerId);
    
    final contractIds = (contracts as List).map((c) => c['id']).toList();
    if (contractIds.isEmpty) return [];

    final response = await _client
        .from('installments')
        .select('*, financing_contracts(contract_no)')
        .inFilter('contract_id', contractIds)
        .order('due_date', ascending: true);
    
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerDocuments(String customerId) async {
    final response = await _client
        .from('contract_documents')
        .select('*, financing_contracts(contract_no)')
        // Note: filtered by contract's customer_id since contract_documents doesn't have it directly in your schema
        .eq('financing_contracts.customer_id', customerId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<void> uploadDocument({
    required String customerId,
    required String? contractId,
    required String documentType,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.split('.').last;
    final storagePath = 'customers/$customerId/${documentType}_$timestamp.$extension';

    await _client.storage.from('documents').uploadBinary(storagePath, fileBytes as dynamic);

    final response = await _client.from('contract_documents').insert({
      'contract_id': contractId,
      'name': fileName,
      'document_url': storagePath,
    }).select().single();

    // Audit
    try {
      await _client.from('audit_logs').insert({
        'profile_id': _client.auth.currentUser?.id,
        'event_type': 'DOCUMENT_UPLOADED',
        'table_name': 'contract_documents',
        'record_id': response['id'],
        'new_values': response,
      });
    } catch (_) {}
  }

  @override
  Future<void> deleteDocument(String documentId, String filePath) async {
    await _client.storage.from('documents').remove([filePath]);
    await _client.from('contract_documents').delete().eq('id', documentId);
  }
}

@Riverpod(keepAlive: true)
SupabaseCrmRepository crmRepository(CrmRepositoryRef ref) {
  return SupabaseCrmRepository(ref.watch(supabaseClientProvider));
}
