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
          .select('id, contract_no, status, total_contract_value, customers(full_name)')
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
      final now = DateTime.now();
      final List<Map<String, dynamic>> last6Months = [];
      
      // إنشاء قائمة الـ 6 أشهر الماضية بالترتيب الزمني
      for (int i = 5; i >= 0; i--) {
        final d = DateTime(now.year, now.month - i, 1);
        final mStr = '${d.year}-${d.month.toString().padLeft(2, '0')}';
        last6Months.add({
          'period_text': mStr,
          'year': d.year,
          'month': d.month,
          'gross_profit': 0.0,
          'company_net_profit': 0.0,
        });
      }

      final startDate = DateTime(now.year, now.month - 5, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      List<dynamic> response = [];
      try {
        response = await _client.rpc('get_profit_report', params: {
          'p_start_date': startDate.toIso8601String().split('T')[0],
          'p_end_date': endDate.toIso8601String().split('T')[0],
          'p_investor_id': null,
          'p_customer_id': null,
        });
      } catch (_) {
        // في حالة عدم وجود دالة RPC، نحاول جلب المدفوعات كبديل
        final payments = await _client
            .from('payments')
            .select('payment_date, amount_total')
            .gte('payment_date', startDate.toIso8601String());
        
        if (payments is List) {
          final Map<String, double> sums = {};
          for (final p in payments) {
            final dateStr = p['payment_date'] as String?;
            if (dateStr != null) {
              final dt = DateTime.parse(dateStr).toLocal();
              final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
              sums[key] = (sums[key] ?? 0.0) + ((p['amount_total'] as num?)?.toDouble() ?? 0.0);
            }
          }
          response = sums.entries.map((e) => {
            'period_text': e.key,
            'gross_profit': e.value,
          }).toList();
        }
      }

      // دمج البيانات المسترجعة مع أشهر الجدول الزمني
      if (response is List && response.isNotEmpty) {
        final dataMap = <String, Map<String, dynamic>>{};
        for (final row in response) {
          if (row is Map && row['period_text'] != null) {
            dataMap[row['period_text'].toString()] = Map<String, dynamic>.from(row);
          }
        }
        for (final item in last6Months) {
          final key = item['period_text'] as String;
          if (dataMap.containsKey(key)) {
            final match = dataMap[key]!;
            item['gross_profit'] = (match['gross_profit'] as num?)?.toDouble() ?? 
                (match['amount'] as num?)?.toDouble() ?? 0.0;
            item['company_net_profit'] = (match['company_net_profit'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }

      return last6Months;
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


