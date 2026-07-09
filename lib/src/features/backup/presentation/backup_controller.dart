import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_backup_repository.dart';
import '../domain/backup_record.dart';

part 'backup_controller.g.dart';

@riverpod
class BackupController extends _$BackupController {
  @override
  FutureOr<List<BackupRecord>> build() {
    return ref.watch(backupRepositoryProvider).getBackupHistory();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(backupRepositoryProvider).getBackupHistory());
  }

  Future<void> requestBackup() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(backupRepositoryProvider).requestManualBackup();
      return ref.read(backupRepositoryProvider).getBackupHistory();
    });
  }

  Future<void> deleteRecord(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(backupRepositoryProvider).deleteBackupRecord(id);
      return ref.read(backupRepositoryProvider).getBackupHistory();
    });
  }
}
