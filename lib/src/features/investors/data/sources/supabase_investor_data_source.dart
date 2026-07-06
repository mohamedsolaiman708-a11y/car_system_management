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
  Future<void> insertTransaction(Map<String, dynamic> transactionData) async {
    await _client.from('investor_transactions').insert(transactionData);
  }

  @override
  Stream<Map<String, dynamic>?> watchInvestor(String id) {
    return _client
        .from('investors')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) => data.isNotEmpty ? data.first : null);
  }
}

@Riverpod(keepAlive: true)
InvestorDataSource investorDataSource(InvestorDataSourceRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseInvestorDataSource(client);
}
