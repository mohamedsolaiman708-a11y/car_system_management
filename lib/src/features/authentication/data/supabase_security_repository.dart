import 'package:car_system_management/src/features/authentication/data/sources/supabase_security_data_source.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/security_log.dart';
import '../domain/security_repository.dart';
import 'sources/security_data_source.dart';

part 'supabase_security_repository.g.dart';

class SupabaseSecurityRepository implements SecurityRepository {
  final SecurityDataSource _dataSource;

  SupabaseSecurityRepository(this._dataSource);

  @override
  Future<void> logEvent(SecurityLog log) async {
    await _dataSource.insertLog(log);
  }
}

@Riverpod(keepAlive: true)
SecurityRepository securityRepository(SecurityRepositoryRef ref) {
  final dataSource = ref.watch(securityDataSourceProvider);
  return SupabaseSecurityRepository(dataSource);
}
