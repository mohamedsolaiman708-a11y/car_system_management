import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../../../core/providers/supabase_provider.dart';

part 'supabase_dashboard_repository.g.dart';

class SupabaseDashboardRepository {
  final SupabaseClient _client;

  SupabaseDashboardRepository(this._client);

  Future<Map<String, dynamic>> getStaffStats() async {
    try {
      final List<dynamic> responses = await Future.wait<dynamic>([
        // 0. إجمالي المستثمرين
        _client.from('investors').select('id').count(CountOption.exact),

        // 1. العقود النشطة
        _client.from('financing_contracts').select('id').eq('status', 'active').count(CountOption.exact),

        // 2. إجمالي الإيرادات
        _client.from('payments').select('amount_total.sum()'),

        // 3. طلبات الانضمام المعلقة
        _client.from('profiles').select('id').eq('is_active', false).count(CountOption.exact),

        // 4. رأس المال المستثمر
        _client.from('investors').select('deployed_capital.sum()'),

        // 5. إجمالي العملاء
        _client.from('customers').select('id').count(CountOption.exact),
      ]);

      final totalInvestorsRes = responses[0] as PostgrestResponse;
      final activeContractsRes = responses[1] as PostgrestResponse;
      final totalRevenueData = responses[2];
      final pendingApprovalsRes = responses[3] as PostgrestResponse;
      final totalDeployedData = responses[4];
      final totalCustomersRes = responses[5] as PostgrestResponse;

      return {
        'total_investors': totalInvestorsRes.count ?? 0,
        'active_contracts': activeContractsRes.count ?? 0,
        'total_revenue': _parseSum(totalRevenueData),
        'pending_approvals': pendingApprovalsRes.count ?? 0,
        'total_deployed_capital': _parseSum(totalDeployedData),
        'total_customers': totalCustomersRes.count ?? 0,
      };
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching dashboard stats',
        error: e,
        stackTrace: stackTrace,
        name: 'DashboardRepository',
      );
      rethrow;
    }
  }

  double _parseSum(dynamic data) {
    try {
      if (data == null || data is! List || data.isEmpty) return 0.0;
      final firstEntry = data.first as Map<String, dynamic>;
      final sum = firstEntry['sum'];
      if (sum == null) return 0.0;
      return double.tryParse(sum.toString()) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}

@riverpod
SupabaseDashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  return SupabaseDashboardRepository(ref.watch(supabaseClientProvider));
}
