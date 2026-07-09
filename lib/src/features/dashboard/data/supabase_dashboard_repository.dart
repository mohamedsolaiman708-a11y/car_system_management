import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as developer;
import '../../../core/providers/supabase_provider.dart';

part 'supabase_dashboard_repository.g.dart';

class SupabaseDashboardRepository {
  final SupabaseClient _client;

  SupabaseDashboardRepository(this._client);

  /// جلب الإحصائيات المتقدمة للوحة التحكم
  Future<Map<String, dynamic>> getStaffStats() async {
    try {
      final now = DateTime.now();
      final todayStr = now.toIso8601String().split('T')[0];
      final startOfToday = '${todayStr}T00:00:00Z';
      
      final date30 = now.subtract(const Duration(days: 30)).toIso8601String();
      final date60 = now.subtract(const Duration(days: 60)).toIso8601String();
      final date90 = now.subtract(const Duration(days: 90)).toIso8601String();

      final List<dynamic> responses = await Future.wait<dynamic>([
        // الحل: تم تغيير 'sold' إلى 'on_contract' لأنها القيمة الصحيحة في الـ Enum بقاعدة البيانات
        _client.from('inventory_items').select('id').eq('status', 'available').count(CountOption.exact),
        _client.from('inventory_items').select('id').eq('status', 'on_contract').count(CountOption.exact),
        _client.from('investors').select('id').count(CountOption.exact),
        _client.from('customers').select('id').count(CountOption.exact),
        _client.from('payments').select('amount_total.sum()').gte('payment_date', startOfToday),
        _client.from('financing_contracts').select('id').eq('status', 'active').count(CountOption.exact),
        // المتأخرات
        _client.from('installments').select('expected_amount.sum()').eq('status', 'unpaid').lt('due_date', now.toIso8601String()).gt('due_date', date30),
        _client.from('installments').select('expected_amount.sum()').eq('status', 'unpaid').lt('due_date', date30).gt('due_date', date60),
        _client.from('installments').select('expected_amount.sum()').eq('status', 'unpaid').lt('due_date', date60).gt('due_date', date90),
        _client.from('installments').select('expected_amount.sum()').eq('status', 'unpaid').lt('due_date', date90),
        // العقود الأخيرة
        _client.from('financing_contracts').select('contract_no, status, total_contract_value, customers(full_name)').order('created_at', ascending: false).limit(6),
      ]);

      return {
        'available_cars': (responses[0] as PostgrestResponse).count ?? 0,
        'sold_cars': (responses[1] as PostgrestResponse).count ?? 0, 
        'total_investors': (responses[2] as PostgrestResponse).count ?? 0,
        'total_customers': (responses[3] as PostgrestResponse).count ?? 0,
        'today_revenue': _parseSum(responses[4]),
        'active_contracts': (responses[5] as PostgrestResponse).count ?? 0,
        'overdue_under_30': _parseSum(responses[6]),
        'overdue_30_60': _parseSum(responses[7]),
        'overdue_60_90': _parseSum(responses[8]),
        'overdue_over_90': _parseSum(responses[9]),
        'recent_contracts': responses[10] as List,
      };
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

  double _parseSum(dynamic data) {
    try {
      if (data == null || data is! List || data.isEmpty) return 0.0;
      final sum = data.first['sum'];
      return sum != null ? double.parse(sum.toString()) : 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}

@riverpod
SupabaseDashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  return SupabaseDashboardRepository(ref.watch(supabaseClientProvider));
}
