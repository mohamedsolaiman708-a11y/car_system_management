import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_jobs_repository.dart';
import '../domain/background_job.dart';

part 'jobs_controller.g.dart';

@riverpod
class JobFilter extends _$JobFilter {
  @override
  JobStatus? build() => null;

  void setFilter(JobStatus? status) => state = status;
}

@riverpod
class JobsListController extends _$JobsListController {
  @override
  FutureOr<List<BackgroundJob>> build() {
    final status = ref.watch(jobFilterProvider);
    return ref.watch(jobsRepositoryProvider).getJobs(status: status);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final status = ref.read(jobFilterProvider);
    state = await AsyncValue.guard(
      () => ref.read(jobsRepositoryProvider).getJobs(status: status),
    );
  }

  Future<void> retryJob(String jobId) async {
    state = const AsyncLoading();
    await ref.read(jobsRepositoryProvider).retryJob(jobId);
    ref.invalidateSelf();
  }

  Future<void> cancelJob(String jobId) async {
    state = const AsyncLoading();
    await ref.read(jobsRepositoryProvider).cancelJob(jobId);
    ref.invalidateSelf();
  }

  Future<void> deleteJob(String jobId) async {
    state = const AsyncLoading();
    await ref.read(jobsRepositoryProvider).deleteJob(jobId);
    ref.invalidateSelf();
  }
}

@riverpod
Future<Map<String, int>> jobsStats(JobsStatsRef ref) async {
  // نجلب كافة المهام (بدون فلتر) لحساب الإحصائيات الشاملة
  final jobs = await ref.watch(jobsRepositoryProvider).getJobs();
  return {
    'total': jobs.length,
    'failed': jobs.where((j) => j.status == JobStatus.failed).length,
    'pending': jobs
        .where(
          (j) =>
              j.status == JobStatus.pending || j.status == JobStatus.retrying,
        )
        .length,
    'completed': jobs.where((j) => j.status == JobStatus.completed).length,
  };
}
