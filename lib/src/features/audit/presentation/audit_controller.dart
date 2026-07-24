import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_audit_repository.dart';
import '../domain/audit_log.dart';

part 'audit_controller.g.dart';

@riverpod
class AuditLogController extends _$AuditLogController {
  @override
  FutureOr<List<AuditLog>> build() {
    return ref.watch(auditRepositoryProvider).getAuditLogs();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(auditRepositoryProvider).getAuditLogs(),
    );
  }

  Future<void> filterLogs({
    String? tableName,
    String? eventType,
    String? profileId,
    String? recordId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(auditRepositoryProvider)
          .getAuditLogs(
            tableName: tableName,
            eventType: eventType,
            profileId: profileId,
            recordId: recordId,
            startDate: startDate,
            endDate: endDate,
          ),
    );
  }
}
