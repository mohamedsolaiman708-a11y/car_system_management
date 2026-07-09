import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as developer;
import '../../../core/providers/supabase_provider.dart';

part 'supabase_dashboard_repository.g.dart';

class SupabaseDashboardRepository {
  final SupabaseClient _client;

  SupabaseDashboardRepository(this._client);

  /// جلب الإحصائيات للوحة التحكم عبر RPC (الحل البروفيشنال)
  Future<Map<String, dynamic>> getStaffStats() async {
    try {
      // استدعاء وظيفة واحدة من قاعدة البيانات تجلب كل الإحصائيات
      final response = await _client.rpc('get_dashboard_stats');
      
      // جلب العقود الأخيرة (استعلام منفصل لأنه بيانات متغيرة)
      final recentContracts = await _client
          .from('financing_contracts')
          .select('contract_no, status, total_contract_value, customers(full_name)')
          .order('created_at', ascending: false)
          .limit(6);

      final Map<String, dynamic> stats = Map<String, dynamic>.from(response);
      stats['recent_contracts'] = recentContracts as List;
      
      // إضافة قيم افتراضية للمتأخرات (يمكن إضافتها لاحقاً للـ RPC)
      stats['overdue_under_30'] = 0.0;
      stats['overdue_30_60'] = 0.0;
      stats['overdue_60_90'] = 0.0;
      stats['overdue_over_90'] = 0.0;

      return stats;
    } catch (e) {
      developer.log('Dashboard Stats Error', error: e);
      rethrow;
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
