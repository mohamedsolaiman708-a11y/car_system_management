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
    // جلب القائمة الأساسية
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
    return list.map((json) {
      final map = Map<String, dynamic>.from(json);
      _sanitizeNumericFields(map);
      return Contract.fromJson(map);
    }).toList();
  }

  @override
  Future<Contract?> getContractById(String id) async {
    final cleanId = id.trim();
    if (cleanId == 'null' || cleanId.isEmpty) return null;
    
    print('DB_LOG: Attempting to fetch contract: $cleanId');
    
    try {
      Map<String, dynamic>? data;

      // 1. محاولة جلب العقد الأساسي فقط (بدون Joins) لتخطي مشاكل الـ RLS في الجداول الأخرى
      try {
        data = await _client.from('financing_contracts').select().or('id.eq.$cleanId,contract_no.eq.$cleanId').maybeSingle();
      } catch (e) {
        print('DB_LOG: Primary fetch failed (likely type mismatch): $e');
      }

      if (data == null) {
        print('DB_LOG: Record not found in financing_contracts for key: $cleanId');
        return null;
      }

      // 2. محاولة إثراء البيانات بالجداول المرتبطة بشكل مستقل
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

      return Contract.fromJson(enrichedData);
    } catch (e, stack) {
      print('DB_LOG: Error in getContractById: $e');
      print(stack);
      rethrow;
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
    final response = await _client
        .from('financing_contracts')
        .insert(data)
        .select()
        .single();
    return Contract.fromJson(response);
  }

  @override
  Future<Contract> updateContract(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('financing_contracts')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return Contract.fromJson(response);
  }

  @override
  Future<void> activateContract(String id) async {
    await _client.rpc(
      'activate_financing_contract',
      params: {'p_contract_id': id},
    );
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
  }

  @override
  Future<void> reversePayment(String paymentId, String reason) async {
    await _client.rpc(
      'reverse_contract_payment',
      params: {'p_payment_id': paymentId, 'p_reason': reason},
    );
  }

  @override
  Future<Map<String, dynamic>> getContractStats() async {
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

    return {
      'total': total.count ?? 0,
      'active': active.count ?? 0,
      'draft': draft.count ?? 0,
      'defaulted': defaulted.count ?? 0,
      'total_overdue': totalOverdue,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getContractInstallments(String contractId) async {
    if (contractId == 'null' || contractId.isEmpty) return [];
    final response = await _client
        .from('installments')
        .select()
        .eq('contract_id', contractId)
        .order('due_date', ascending: true);
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getContractPayments(String contractId) async {
    if (contractId == 'null' || contractId.isEmpty) return [];
    final response = await _client
        .from('payments')
        .select()
        .eq('contract_id', contractId)
        .order('payment_date', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getContractTimeline(String contractId) async {
    if (contractId == 'null' || contractId.isEmpty) return [];
    try {
      final response = await _client
          .from('contract_timeline_view')
          .select()
          .eq('contract_id', contractId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (_) {
      final response = await _client
          .from('audit_logs')
          .select()
          .eq('record_id', contractId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getContractFunding(String contractId) async {
    if (contractId == 'null' || contractId.isEmpty) return [];
    final response = await _client
        .from('contract_funding')
        .select('*, investors(full_name)')
        .eq('contract_id', contractId);
    return List<Map<String, dynamic>>.from(response as List);
  }
}

@Riverpod(keepAlive: true)
SupabaseContractRepository contractRepository(ContractRepositoryRef ref) {
  return SupabaseContractRepository(ref.watch(supabaseClientProvider));
}
