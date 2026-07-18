import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/customer.dart';
import '../domain/crm_repository.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/utils/error_handler.dart';

part 'supabase_crm_repository.g.dart';

class SupabaseCrmRepository implements CrmRepository {
  final SupabaseClient _client;
  final Ref _ref;
  final Map<String, dynamic> _memCache = {};

  SupabaseCrmRepository(this._client, this._ref);

  @override
  Future<List<Customer>> getCustomers({
    String? searchQuery,
    String? status,
    String? city,
    int limit = 20,
    int offset = 0,
  }) async {
    final cacheKey = 'getCustomers_${searchQuery ?? ''}_${status ?? ''}_${city ?? ''}_${limit}_$offset';
    try {
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

      // تأكد من أن الرد قائمة وليس null
      final data = response as List? ?? [];
      return data.map((json) {
        try {
          return Customer.fromJson(json);
        } catch (e) {
          // لو فيه سجل واحد فيه مشكلة ميبوظش القائمة كلها
          print('Error mapping customer: $e');
          return null;
        }
      }).whereType<Customer>().toList();

    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      if (_memCache.containsKey(cacheKey)) {
        return _memCache[cacheKey] as List<Customer>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    try {
      final response = await _client.from('customers').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return Customer.fromJson(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Customer> createCustomer(Map<String, dynamic> data) async {
    try {
      final response = await _client.from('customers').insert(data).select().single();
      _memCache.clear();
      return Customer.fromJson(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Customer> updateCustomer(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client.from('customers').update(data).eq('id', id).select().single();
      _memCache.clear();
      return Customer.fromJson(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _client.from('customers').delete().eq('id', id);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getCustomerFinancialSummary(String id) async {
    try {
      final contracts = await _client
          .from('financing_contracts')
          .select('id, status, total_contract_value')
          .eq('customer_id', id);

      final contractsList = contracts as List;
      double totalValue = 0;
      for (var c in contractsList) {
        totalValue += (c['total_contract_value'] as num?)?.toDouble() ?? 0.0;
      }

      double totalPaid = 0;
      if (contractsList.isNotEmpty) {
        final contractIds = contractsList.map((c) => c['id']).toList();
        final payments = await _client
            .from('payments')
            .select('amount_total')
            .inFilter('contract_id', contractIds);

        for (var p in (payments as List)) {
          totalPaid += (p['amount_total'] as num?)?.toDouble() ?? 0.0;
        }
      }

      return {
        'total_contracts': contractsList.length,
        'total_paid': totalPaid,
        'outstanding_balance': totalValue - totalPaid,
        'delayed_installments': 0,
      };
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerTimeline(String id) async {
    try {
      final response = await _client
          .from('audit_logs')
          .select()
          .eq('record_id', id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerContracts(String customerId) async {
    try {
      final response = await _client
          .from('financing_contracts')
          .select('*, inventory_items(make, model, year, license_plate)')
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerPayments(String customerId) async {
    try {
      final contracts = await _client.from('financing_contracts').select('id').eq('customer_id', customerId);
      final contractIds = (contracts as List).map((c) => c['id']).toList();
      if (contractIds.isEmpty) return [];
      final response = await _client.from('payments').select('*, financing_contracts(contract_no)').inFilter('contract_id', contractIds).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerInstallments(String customerId) async {
    try {
      final contracts = await _client.from('financing_contracts').select('id').eq('customer_id', customerId);
      final contractIds = (contracts as List).map((c) => c['id']).toList();
      if (contractIds.isEmpty) return [];
      final response = await _client.from('installments').select('*, financing_contracts(contract_no)').inFilter('contract_id', contractIds).order('due_date', ascending: true);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerDocuments(String customerId) async {
    try {
      final response = await _client
          .from('contract_documents')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> uploadDocument({
    required String customerId,
    required String? contractId,
    required String documentType,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.split('.').last;
      final storagePath = 'customers/$customerId/${documentType}_$timestamp.$extension';

      await _client.storage.from('documents').uploadBinary(storagePath, fileBytes as dynamic);
      final fileUrl = _client.storage.from('documents').getPublicUrl(storagePath);

      await _client.from('contract_documents').insert({
        'customer_id': customerId,
        'contract_id': contractId,
        'name': fileName,
        'document_url': fileUrl,
        'document_type': documentType,
      });
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> deleteDocument(String documentId, String filePath) async {
    try {
      await _client.storage.from('documents').remove([filePath]);
      await _client.from('contract_documents').delete().eq('id', documentId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}

@Riverpod(keepAlive: true)
SupabaseCrmRepository crmRepository(CrmRepositoryRef ref) {
  return SupabaseCrmRepository(ref.watch(supabaseClientProvider), ref);
}
