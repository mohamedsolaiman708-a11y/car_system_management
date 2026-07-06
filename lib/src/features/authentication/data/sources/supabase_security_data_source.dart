import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../domain/security_log.dart';
import 'security_data_source.dart';

part 'supabase_security_data_source.g.dart';

class SupabaseSecurityDataSource implements SecurityDataSource {
  final SupabaseClient _client;

  SupabaseSecurityDataSource(this._client);

  @override
  Future<void> insertLog(SecurityLog log) async {
    await _client.from('security_logs').insert(log.toJson());
  }
}

@Riverpod(keepAlive: true)
SecurityDataSource securityDataSource(SecurityDataSourceRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSecurityDataSource(client);
}
