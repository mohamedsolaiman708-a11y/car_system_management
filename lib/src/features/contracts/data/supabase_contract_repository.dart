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

  void clearCache() {
    _memCache.clear();
  }

  @override
  Future<List<Contract>> getContracts({
    String? searchQuery,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final cacheKey =
        'getContracts_${searchQuery ?? ''}_${status ?? ''}_${limit}_$offset';
    try {
      var query = _client.from('financing_contracts').select(
            '*, customers(full_name), inventory_items(make, model, license_plate), investors(full_name)',
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
      if (_memCache.containsKey(cacheKey)) {
        return _memCache[cacheKey] as Contract?;
      }

      Map<String, dynamic>? data;

      try {
        data = await _client
            .from('financing_contracts')
            .select()
            .or('id.eq.$cleanId,contract_no.eq.$cleanId')
            .maybeSingle();
      } catch (e) {
        print('DB_LOG: Primary fetch failed: $e');
      }

      if (data == null) return null;

      final enrichedData = Map<String, dynamic>.from(data);
      _sanitizeNumericFields(enrichedData);

      try {
        if (data['customer_id'] != null) {
          final customer = await _client
              .from('customers')
              .select()
              .eq('id', data['customer_id'])
              .maybeSingle();
          enrichedData['customers'] = customer;
        }
        if (data['inventory_item_id'] != null) {
          final vehicle = await _client
              .from('inventory_items')
              .select()
              .eq('id', data['inventory_item_id'])
              .maybeSingle();
          enrichedData['inventory_items'] = vehicle;
        }
        if (data['investor_id'] != null) {
          final investor = await _client
              .from('investors')
              .select()
              .eq('id', data['investor_id'])
              .maybeSingle();
          enrichedData['investors'] = investor;
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
      'principal_amount',
      'finance_profit_rate',
      'total_contract_value',
      'down_payment',
      'moroor_fees',
      'tamm_fees',
      'insurance_fees',
      'inspection_fees',
      'plate_fees',
      'traffic_violations_fees',
      'other_fees',
      'vat_amount',
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
      clearCache();
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
      clearCache();
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
      clearCache();
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
    final effectiveRef = [reference, notes].where((s) => s != null && s.trim().isNotEmpty).join(' | ');
    try {
      await _client.rpc(
        'process_contract_payment',
        params: {
          'p_contract_id': contractId,
          'p_amount': amount,
          'p_payment_method': method,
          'p_reference_no': effectiveRef.isNotEmpty ? effectiveRef : 'سداد قسط',
          'p_idempotency_key': idempotencyKey,
        },
      );
      clearCache();
    } catch (e) {
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
        clearCache();
        return;
      } catch (_) {}

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
      clearCache();
    } catch (e) {
      _ref.read(connectionNotifierProvider.notifier).setOffline();
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getContractStats() async {
    const cacheKey = 'getContractStats';
    try {
      // الحل الأكثر استقراراً للحصول على العدد في كل الإصدارات
      final allResponse = await _client.from('financing_contracts').select('id');
      final activeResponse = await _client.from('financing_contracts').select('id').eq('status', 'active');
      
      final stats = {
        'total': (allResponse as List).length, 
        'active': (activeResponse as List).length
      };
      _memCache[cacheKey] = stats;
      return stats;
    } catch (e) {
      if (_memCache.containsKey(cacheKey)) return _memCache[cacheKey] as Map<String, dynamic>;
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getContractInstallments(
    String contractId,
  ) async {
    final effectiveId = await _getEffectiveId(contractId);
    final response = await _client
        .from('installments')
        .select()
        .eq('contract_id', effectiveId)
        .order('due_date', ascending: true);
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getContractPayments(
    String contractId,
  ) async {
    final effectiveId = await _getEffectiveId(contractId);
    final response = await _client
        .from('payments')
        .select()
        .eq('contract_id', effectiveId)
        .order('payment_date', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getContractTimeline(
    String contractId,
  ) async {
    final effectiveId = await _getEffectiveId(contractId);
    final response = await _client
        .from('audit_logs')
        .select()
        .eq('record_id', effectiveId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<void> addContractLog({
    required String contractId,
    required String eventType,
    Map<String, dynamic>? metadata,
  }) async {
    final effectiveId = await _getEffectiveId(contractId);
    await _client.from('audit_logs').insert({
      'record_id': effectiveId,
      'table_name': 'financing_contracts',
      'event_type': eventType.toUpperCase(),
      'new_values': metadata ?? {},
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getContractFunding(
    String contractId,
  ) async {
    final effectiveId = await _getEffectiveId(contractId);
    final cacheKey = 'getContractFunding_$effectiveId';

    try {
      final response = await _client
          .from('contract_funding')
          .select('amount_allocated, investor_id, investors(full_name)')
          .eq('contract_id', effectiveId);

      final list = (response as List)
          .map(
            (item) => {
              'amount_allocated':
                  double.tryParse(item['amount_allocated'].toString()) ?? 0.0,
              'investor_id': item['investor_id'],
              'investors': item['investors'],
            },
          )
          .toList();

      _memCache[cacheKey] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(cacheKey)) return _memCache[cacheKey];
      return [];
    }
  }

  Future<String> _getEffectiveId(String inputId) async {
    if (inputId.contains('-') && inputId.length > 30) return inputId;
    final contract = await getContractById(inputId);
    return contract?.id ?? inputId;
  }
}

@Riverpod(keepAlive: true)
SupabaseContractRepository contractRepository(ContractRepositoryRef ref) {
  return SupabaseContractRepository(ref.watch(supabaseClientProvider), ref);
}
