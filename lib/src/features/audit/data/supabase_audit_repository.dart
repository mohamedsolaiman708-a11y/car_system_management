import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/audit_log.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_audit_repository.g.dart';

class SupabaseAuditRepository {
  final SupabaseClient _client;
  SupabaseAuditRepository(this._client);

  Future<List<AuditLog>> getAuditLogs({
    String? tableName,
    String? eventType,
    String? profileId,
    int limit = 50,
  }) async {
    var query = _client
        .from('audit_logs')
        .select('*, profiles(full_name)');

    if (tableName != null) {
      query = query.eq('table_name', tableName);
    }
    if (eventType != null) {
      query = query.eq('event_type', eventType);
    }
    if (profileId != null) {
      query = query.eq('profile_id', profileId);
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => AuditLog.fromJson(json)).toList();
  }
}

@Riverpod(keepAlive: true)
SupabaseAuditRepository auditRepository(AuditRepositoryRef ref) {
  return SupabaseAuditRepository(ref.watch(supabaseClientProvider));
}
