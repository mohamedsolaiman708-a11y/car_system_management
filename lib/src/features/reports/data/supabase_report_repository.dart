import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/report_repository.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_report_repository.g.dart';

class SupabaseReportRepository implements ReportRepository {
  final SupabaseClient _client;
  SupabaseReportRepository(this._client);

  @override
  Future<List<Map<String, dynamic>>> getRevenueReport({
    required DateTime startDate,
    required DateTime endDate,
    String? investorId,
  }) async {
    final response = await _client.rpc('get_revenue_report', params: {
      'p_start_date': startDate.toIso8601String().split('T')[0],
      'p_end_date': endDate.toIso8601String().split('T')[0],
      'p_investor_id': investorId, // نرسلها دائماً حتى لو كانت null لحل مشكلة الـ Overloading
    });
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getProfitReport({
    required DateTime startDate,
    required DateTime endDate,
    String? investorId,
    String? customerId,
  }) async {
    final response = await _client.rpc('get_profit_report', params: {
      'p_start_date': startDate.toIso8601String().split('T')[0],
      'p_end_date': endDate.toIso8601String().split('T')[0],
      'p_investor_id': investorId, // نرسلها دائماً
      'p_customer_id': customerId, // نرسلها دائماً
    });
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getCashFlowReport({
    required DateTime startDate,
    required DateTime endDate,
    String? investorId,
  }) async {
    final response = await _client.rpc('get_cash_flow_report', params: {
      'p_start_date': startDate.toIso8601String().split('T')[0],
      'p_end_date': endDate.toIso8601String().split('T')[0],
      'p_investor_id': investorId, // نرسلها دائماً
    });
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getOverdueReport() async {
    final response = await _client.rpc('get_overdue_report');
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorsPerformance() async {
    final response = await _client.rpc('get_investors_performance');
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getCollectionsReport({
    required DateTime startDate,
    required DateTime endDate,
    String? customerId,
  }) async {
    var query = _client
        .from('payments')
        .select('*, financing_contracts(contract_no, customers(full_name))')
        .gte('payment_date', startDate.toIso8601String())
        .lte('payment_date', endDate.toIso8601String());

    if (customerId != null) {
      query = query.eq('contract_id.customer_id', customerId);
    }
    
    final response = await query.order('payment_date', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getContractsSummary() async {
    final response = await _client.rpc('get_contracts_summary_report');
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getTrialBalance() async {
    final response = await _client.rpc('get_trial_balance');
    return List<Map<String, dynamic>>.from(response as List);
  }
}

@Riverpod(keepAlive: true)
ReportRepository reportRepository(ReportRepositoryRef ref) {
  return SupabaseReportRepository(ref.watch(supabaseClientProvider));
}
