import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as developer;
import '../../../core/providers/supabase_provider.dart';

part 'supabase_dashboard_repository.g.dart';

class SupabaseDashboardRepository {
  final SupabaseClient _client;

  SupabaseDashboardRepository(this._client);

  /// جلب الإحصائيات العامة للوحة التحكم
  Future<Map<String, dynamic>> getStaffStats() async {
    try {
      final response = await _client.rpc('get_dashboard_stats');
      
      final recentContracts = await _client
          .from('financing_contracts')
          .select('contract_no, status, total_contract_value, customers(full_name)')
          .order('created_at', ascending: false)
          .limit(6);

      final Map<String, dynamic> stats = Map<String, dynamic>.from(response);
      stats['recent_contracts'] = recentContracts as List;
      
      return stats;
    } catch (e) {
      developer.log('Dashboard Stats Error', error: e);
      rethrow;
    }
  }

  /// جلب بيانات الرسوم البيانية (نمو الأرباح والمبيعات)
  Future<List<Map<String, dynamic>>> getMonthlyGrowthData() async {
    try {
      // نستخدم دالة التقرير المالي المتاحة في قاعدة البيانات لجلب بيانات آخر 6 أشهر
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 5, 1);
      
      final response = await _client.rpc('get_profit_report', params: {
        'p_start_date': startDate.toIso8601String(),
        'p_end_date': now.toIso8601String(),
      });
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log('Growth Data Error', error: e);
      return [];
    }
  }

  Future<Map<String, List<dynamic>>> globalSearch(String query) async {
    try {
      final results = await Future.wait([
        _client.from('customers').select('id, full_name, national_id').or('full_name.ilike.%$query%,national_id.ilike.%$query%').limit(5),
        _client.from('inventory_items').select('id, make, model, license_plate, vin').or('make.ilike.%$query%,model.ilike.%$query%,license_plate.ilike.%$query%,vin.ilike.%$query%').limit(5),
        _client.from('financing_contracts').select('id, contract_no').ilike('contract_no', '%$query%').limit(5),
        _client.from('investors').select('id, full_name').ilike('full_name', '%$query%').limit(5),
      ]);

      return {
        'customers': results[0] as List,
        'vehicles': results[1] as List,
        'contracts': results[2] as List,
        'investors': results[3] as List,
      };
    } catch (e) {
      return {'customers': [], 'vehicles': [], 'contracts': [], 'investors': []};
    }
  }
}

@riverpod
SupabaseDashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  return SupabaseDashboardRepository(ref.watch(supabaseClientProvider));
}
