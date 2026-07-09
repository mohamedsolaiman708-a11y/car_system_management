import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/background_job.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_jobs_repository.g.dart';

class SupabaseJobsRepository {
  final SupabaseClient _client;
  SupabaseJobsRepository(this._client);

  Future<List<BackgroundJob>> getJobs({
    JobStatus? status,
    int limit = 50,
  }) async {
    var query = _client.from('background_jobs').select();

    if (status != null) {
      query = query.eq('status', status.name);
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => BackgroundJob.fromJson(json)).toList();
  }

  Future<void> retryJob(String jobId) async {
    await _client.from('background_jobs').update({
      'status': 'pending',
      'error_message': null,
      'attempts': 0,
    }).eq('id', jobId);
  }

  Future<void> cancelJob(String jobId) async {
    await _client.from('background_jobs').update({
      'status': 'failed',
      'error_message': 'Cancelled by administrator',
    }).eq('id', jobId);
  }

  Future<void> deleteJob(String jobId) async {
    await _client.from('background_jobs').delete().eq('id', jobId);
  }
}

@Riverpod(keepAlive: true)
SupabaseJobsRepository jobsRepository(JobsRepositoryRef ref) {
  return SupabaseJobsRepository(ref.watch(supabaseClientProvider));
}
