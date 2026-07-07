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
        _client.from('investors').select('id').count(CountOption.exact),
        _client.from('financing_contracts').select('id').eq('status', 'active').count(CountOption.exact),
        _client.from('payments').select('amount_total.sum()'),
        _client.from('profiles').select('id').eq('is_active', false).count(CountOption.exact),
        _client.from('investors').select('deployed_capital.sum()'),
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
      developer.log('Error fetching dashboard stats', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// وظيفة البحث الشامل (Phase 15) - محدثة لتشمل الموظفين والمدفوعات
  Future<Map<String, List<dynamic>>> globalSearch(String query) async {
    try {
      final results = await Future.wait([
        // 1. البحث في العملاء
        _client.from('customers').select('id, full_name, national_id').or('full_name.ilike.%$query%,national_id.ilike.%$query%').limit(5),
        // 2. البحث في السيارات
        _client.from('inventory_items').select('id, make, model, license_plate, vin').or('make.ilike.%$query%,model.ilike.%$query%,license_plate.ilike.%$query%,vin.ilike.%$query%').limit(5),
        // 3. البحث في العقود
        _client.from('financing_contracts').select('id, contract_no').ilike('contract_no', '%$query%').limit(5),
        // 4. البحث في المستثمرين
        _client.from('investors').select('id, full_name').ilike('full_name', '%$query%').limit(5),
        // 5. البحث في الموظفين (profiles)
        _client.from('profiles').select('id, full_name').ilike('full_name', '%$query%').limit(5),
        // 6. البحث في المدفوعات (برقم المرجع)
        _client.from('payments').select('id, reference_no, amount_total').ilike('reference_no', '%$query%').limit(5),
      ]);

      return {
        'customers': results[0] as List,
        'vehicles': results[1] as List,
        'contracts': results[2] as List,
        'investors': results[3] as List,
        'staff': results[4] as List,
        'payments': results[5] as List,
      };
    } catch (e) {
      developer.log('Global search error', error: e);
      return {
        'customers': [], 
        'vehicles': [], 
        'contracts': [], 
        'investors': [],
        'staff': [],
        'payments': []
      };
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
