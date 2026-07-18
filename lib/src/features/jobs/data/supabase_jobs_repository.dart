import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/background_job.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/utils/error_handler.dart';

part 'supabase_jobs_repository.g.dart';

class SupabaseJobsRepository {
  final SupabaseClient _client;
  final Map<String, dynamic> _memCache = {};

  SupabaseJobsRepository(this._client);

  Future<List<BackgroundJob>> getJobs({
    JobStatus? status,
    int limit = 50,
  }) async {
    final key = 'jobs_${status?.name}_$limit';
    try {
      var query = _client.from('background_jobs').select();

      if (status != null) {
        query = query.eq('status', status.name);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final list = (response as List).map((json) => BackgroundJob.fromJson(json)).toList();
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<BackgroundJob>;
      }
      throw Failure.fromException(e);
    }
  }

  Future<void> retryJob(String jobId) async {
    try {
      await _client.from('background_jobs').update({
        'status': 'pending',
        'error_message': null,
        'attempts': 0,
      }).eq('id', jobId);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> cancelJob(String jobId) async {
    try {
      await _client.from('background_jobs').update({
        'status': 'failed',
        'error_message': 'Cancelled by administrator',
      }).eq('id', jobId);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await _client.from('background_jobs').delete().eq('id', jobId);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}

@Riverpod(keepAlive: true)
SupabaseJobsRepository jobsRepository(JobsRepositoryRef ref) {
  return SupabaseJobsRepository(ref.watch(supabaseClientProvider));
}
