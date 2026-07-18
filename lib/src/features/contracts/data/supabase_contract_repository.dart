import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/contract.dart';
import '../domain/contract_repository.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/utils/error_handler.dart';

part 'supabase_contract_repository.g.dart';

class SupabaseContractRepository implements ContractRepository {
  final SupabaseClient _client;
  final Ref _ref;
  final Map<String, dynamic> _memCache = {};

  SupabaseContractRepository(this._client, this._ref);

  @override
  Future<List<Contract>> getContracts({
    String? searchQuery,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final cacheKey = 'getContracts_${searchQuery ?? ''}_${status ?? ''}_${limit}_$offset';
    try {
      var query = _client.from('financing_contracts').select(
            'id, contract_no, customer_id, inventory_item_id, principal_amount, finance_profit_rate, total_contract_value, duration_months, start_date, status, created_at, customers(full_name), inventory_items(make, model, license_plate)',
          );
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('contract_no.ilike.%$searchQuery%');
      }
      if (status != null) query = query.eq('status', status);
      
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
          
      final List<dynamic> list = response as List;
      final contracts = list.map((json) {
        final map = Map<String, dynamic>.from(json);
        _sanitizeNumericFields(map);
        return Contract.fromJson(map);
      }).toList();

      _memCache[cacheKey] = contracts;
      return contracts;
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      if (_memCache.containsKey(cacheKey)) {
        return _memCache[cacheKey] as List<Contract>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Contract?> getContractById(String id) async {
    final cleanId = id.trim();
    if (cleanId == 'null' || cleanId.isEmpty) return null;
    
    final cacheKey = 'getContractById_$cleanId';
    try {
      Map<String, dynamic>? data;

      try {
        data = await _client.from('financing_contracts').select().or('id.eq.$cleanId,contract_no.eq.$cleanId').maybeSingle();
      } catch (e) {
        print('DB_LOG: Primary fetch failed (likely type mismatch): $e');
      }

      if (data == null) {
        return null;
      }

      final enrichedData = Map<String, dynamic>.from(data);
      _sanitizeNumericFields(enrichedData);

      try {
        if (data['customer_id'] != null) {
          final customer = await _client.from('customers').select().eq('id', data['customer_id']).maybeSingle();
          enrichedData['customers'] = customer;
        }
        if (data['inventory_item_id'] != null) {
          final vehicle = await _client.from('inventory_items').select().eq('id', data['inventory_item_id']).maybeSingle();
          enrichedData['inventory_items'] = vehicle;
        }
      } catch (e) {
        print('DB_LOG: Relation enrichment warning: $e');
      }

      final contract = Contract.fromJson(enrichedData);
      _memCache[cacheKey] = contract;
      return contract;
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      if (_memCache.containsKey(cacheKey)) {
        return _memCache[cacheKey] as Contract?;
      }
      throw Failure.fromException(e);
    }
  }

  void _sanitizeNumericFields(Map<String, dynamic> json) {
    final numericFields = [
      'principal_amount', 'finance_profit_rate', 'total_contract_value',
      'moroor_fees', 'tamm_fees', 'insurance_fees', 'vat_amount'
    ];
    for (var field in numericFields) {
      if (json[field] != null) {
        json[field] = double.tryParse(json[field].toString()) ?? 0.0;
      } else {
        json[field] = 0.0;
      }
    }
  }

  @override
  Future<Contract> createContract(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('financing_contracts')
          .insert(data)
          .select()
          .single();
      _memCache.clear();
      return Contract.fromJson(response);
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Contract> updateContract(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('financing_contracts')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      _memCache.clear();
      return Contract.fromJson(response);
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> activateContract(String id) async {
    try {
      await _client.rpc(
        'activate_financing_contract',
        params: {'p_contract_id': id},
      );
      _memCache.clear();
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      throw Failure.fromException(e);
    }
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
    try {
      await _client.rpc(
        'process_installment_payment',
        params: {
          'p_contract_id': contractId,
          'p_amount_paid': amount,
          'p_payment_method': method,
          'p_reference_no': reference,
          'p_notes': notes,
          'p_idempotency_key': idempotencyKey,
        },
      );
      _memCache.clear();
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> reversePayment(String paymentId, String reason) async {
    try {
      await _client.rpc(
        'reverse_contract_payment',
        params: {'p_payment_id': paymentId, 'p_reason': reason},
      );
      _memCache.clear();
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getContractStats() async {
    const cacheKey = 'getContractStats';
    try {
      final total = await _client.from('financing_contracts').select('id').count(CountOption.exact);
      final active = await _client.from('financing_contracts').select('id').eq('status', 'active').count(CountOption.exact);
      final draft = await _client.from('financing_contracts').select('id').eq('status', 'draft').count(CountOption.exact);
      final defaulted = await _client.from('financing_contracts').select('id').eq('status', 'defaulted').count(CountOption.exact);

      final today = DateTime.now().toIso8601String().split('T')[0];
      final overdueRes = await _client
          .from('installments')
          .select('expected_amount')
          .lt('due_date', today)
          .neq('status', 'paid');
      
      double totalOverdue = 0.0;
      final overdueList = overdueRes as List<dynamic>;
      for (var row in overdueList) {
        totalOverdue += double.tryParse(row['expected_amount'].toString()) ?? 0.0;
      }

      final stats = {
        'total': total.count,
        'active': active.count,
        'draft': draft.count,
        'defaulted': defaulted.count,
        'total_overdue': totalOverdue,
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
  Future<List<Map<String, dynamic>>> getContractInstallments(String contractId) async {
    if (contractId == 'null' || contractId.isEmpty) return [];
    final cacheKey = 'getContractInstallments_$contractId';
    try {
      final response = await _client
          .from('installments')
          .select()
          .eq('contract_id', contractId)
          .order('due_date', ascending: true);
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
  Future<List<Map<String, dynamic>>> getContractPayments(String contractId) async {
    if (contractId == 'null' || contractId.isEmpty) return [];
    final cacheKey = 'getContractPayments_$contractId';
    try {
      final response = await _client
          .from('payments')
          .select()
          .eq('contract_id', contractId)
          .order('payment_date', ascending: false);
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
  Future<List<Map<String, dynamic>>> getContractTimeline(String contractId) async {
    if (contractId == 'null' || contractId.isEmpty) return [];
    final cacheKey = 'getContractTimeline_$contractId';
    try {
      List<dynamic> response;
      try {
        response = await _client
            .from('contract_timeline_view')
            .select()
            .eq('contract_id', contractId)
            .order('created_at', ascending: false);
      } catch (_) {
        response = await _client
            .from('audit_logs')
            .select()
            .eq('record_id', contractId)
            .order('created_at', ascending: false);
      }
      final list = List<Map<String, dynamic>>.from(response);
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
  Future<List<Map<String, dynamic>>> getContractFunding(String contractId) async {
    if (contractId == 'null' || contractId.isEmpty) return [];
    final cacheKey = 'getContractFunding_$contractId';
    try {
      final response = await _client
          .from('contract_funding')
          .select('*, investors(full_name)')
          .eq('contract_id', contractId);
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
}

@Riverpod(keepAlive: true)
SupabaseContractRepository contractRepository(ContractRepositoryRef ref) {
  return SupabaseContractRepository(ref.watch(supabaseClientProvider), ref);
}
