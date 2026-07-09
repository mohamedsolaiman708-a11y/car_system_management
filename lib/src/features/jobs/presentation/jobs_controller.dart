import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_jobs_repository.dart';
import '../domain/background_job.dart';

part 'jobs_controller.g.dart';

@riverpod
class JobsListController extends _$JobsListController {
  @override
  FutureOr<List<BackgroundJob>> build() {
    return ref.watch(jobsRepositoryProvider).getJobs();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(jobsRepositoryProvider).getJobs());
  }

  Future<void> retryJob(String jobId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(jobsRepositoryProvider).retryJob(jobId);
      return ref.read(jobsRepositoryProvider).getJobs();
    });
  }

  Future<void> cancelJob(String jobId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(jobsRepositoryProvider).cancelJob(jobId);
      return ref.read(jobsRepositoryProvider).getJobs();
    });
  }

  Future<void> deleteJob(String jobId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(jobsRepositoryProvider).deleteJob(jobId);
      return ref.read(jobsRepositoryProvider).getJobs();
    });
  }
}
