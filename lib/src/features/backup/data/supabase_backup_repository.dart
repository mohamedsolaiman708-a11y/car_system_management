import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/backup_record.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_backup_repository.g.dart';

class SupabaseBackupRepository {
  final SupabaseClient _client;
  SupabaseBackupRepository(this._client);

  Future<List<BackupRecord>> getBackupHistory() async {
    final response = await _client
        .from('backup_history')
        .select('*, profiles(full_name)')
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => BackupRecord.fromJson(json)).toList();
  }

  Future<void> requestManualBackup() async {
    await _client.rpc('request_manual_backup');
  }

  Future<void> deleteBackupRecord(String id) async {
    await _client.from('backup_history').delete().eq('id', id);
  }
}

@Riverpod(keepAlive: true)
SupabaseBackupRepository backupRepository(BackupRepositoryRef ref) {
  return SupabaseBackupRepository(ref.watch(supabaseClientProvider));
}
