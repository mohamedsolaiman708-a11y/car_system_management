import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/utils/error_handler.dart';
import '../domain/audit_log.dart';

part 'supabase_audit_repository.g.dart';

class SupabaseAuditRepository {
  final SupabaseClient _client;

  SupabaseAuditRepository(this._client);

  Future<List<AuditLog>> getAuditLogs({
    String? eventType,
    String? tableName,
    String? profileId,
    String? recordId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      var query = _client
          .from('audit_logs')
          .select('*, profiles(full_name)');

      if (eventType != null && eventType.isNotEmpty) {
        query = query.eq('event_type', eventType);
      }
      if (tableName != null && tableName.isNotEmpty) {
        query = query.eq('table_name', tableName);
      }
      if (profileId != null && profileId.isNotEmpty) {
        query = query.eq('profile_id', profileId);
      }
      if (recordId != null && recordId.isNotEmpty) {
        query = query.ilike('record_id', '%$recordId%');
      }
      
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        // إضافة يوم واحد لنهاية النطاق ليشمل اليوم المختار بالكامل
        final nextDay = endDate.add(const Duration(days: 1));
        query = query.lt('created_at', nextDay.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => AuditLog.fromJson(json)).toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}

@riverpod
SupabaseAuditRepository auditRepository(AuditRepositoryRef ref) {
  return SupabaseAuditRepository(ref.watch(supabaseClientProvider));
}
