import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/supabase_provider.dart';
import '../domain/audit_log.dart';

part 'supabase_audit_repository.g.dart';

class SupabaseAuditRepository {
  final SupabaseClient _client;
  SupabaseAuditRepository(this._client);

  Future<List<AuditLog>> getAuditLogs({
    String? eventType,
    String? tableName,
    String? profileId,
    int limit = 50,
  }) async {
    var query = _client
        .from('audit_logs')
        .select('*, profiles(full_name)');

    // تطبيق الفلاتر
    if (eventType != null) query = query.eq('event_type', eventType);
    if (tableName != null) query = query.eq('table_name', tableName);
    if (profileId != null) query = query.eq('profile_id', profileId);

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    // تحويل البيانات من Map إلى AuditLog
    return (response as List).map((json) => AuditLog.fromJson(json)).toList();
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
