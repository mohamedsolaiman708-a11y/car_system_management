import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/utils/error_handler.dart';
import '../domain/audit_log.dart';

part 'supabase_audit_repository.g.dart';

class SupabaseAuditRepository {
  final SupabaseClient _client;
  final Map<String, dynamic> _memCache = {};

  SupabaseAuditRepository(this._client);

  Future<List<AuditLog>> getAuditLogs({
    String? eventType,
    String? tableName,
    String? profileId,
    int limit = 50,
  }) async {
    final key = 'audit_logs_${eventType}_${tableName}_${profileId}_$limit';
    try {
      var query = _client
          .from('audit_logs')
          .select('*, profiles(full_name)');

      if (eventType != null) query = query.eq('event_type', eventType);
      if (tableName != null) query = query.eq('table_name', tableName);
      if (profileId != null) query = query.eq('profile_id', profileId);

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final list = (response as List).map((json) => AuditLog.fromJson(json)).toList();
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<AuditLog>;
      }
      throw Failure.fromException(e);
    }
  }
}

@riverpod
SupabaseAuditRepository auditRepository(AuditRepositoryRef ref) {
  return SupabaseAuditRepository(ref.watch(supabaseClientProvider));
}

@riverpod
Future<List<AuditLog>> auditLogsList(AuditLogsListRef ref) {
  return ref.watch(auditRepositoryProvider).getAuditLogs();
}
