import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../jobs_controller.dart';
import '../../domain/background_job.dart';
import '../../../../core/utils/arabic_translator.dart';

class BackgroundJobsScreen extends ConsumerWidget {
  const BackgroundJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsListControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المهام الخلفية'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(jobsListControllerProvider.notifier).refresh(),
            ),
          ],
        ),
        body: jobsAsync.when(
          data: (jobs) => _buildJobsList(context, ref, jobs),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('حدث خطأ: $err')),
        ),
      ),
    );
  }

  Widget _buildJobsList(BuildContext context, WidgetRef ref, List<BackgroundJob> jobs) {
    if (jobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد مهام مسجلة حالياً', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _JobCard(job: job);
      },
    );
  }
}

class _JobCard extends ConsumerWidget {
  final BackgroundJob job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final df = intl.DateFormat('yyyy/MM/dd HH:mm');
    final color = _getStatusColor(job.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(_getJobIcon(job.jobType), color: color),
        title: Text(ArabicTranslator.jobType(job.jobType), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('الحالة: ${_getStatusLabel(job.status)} | ${df.format(job.createdAt)}'),
        trailing: _buildTrailingActions(context, ref),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('معرف المهمة:', job.id),
                _buildInfoRow('عدد المحاولات:', '${job.attempts} / ${job.maxAttempts}'),
                if (job.startedAt != null) _buildInfoRow('وقت البدء:', df.format(job.startedAt!)),
                if (job.completedAt != null) _buildInfoRow('وقت الانتهاء:', df.format(job.completedAt!)),
                if (job.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  const Text('رسالة الخطأ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                    child: Text(job.errorMessage!, style: const TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                ],
                const SizedBox(height: 12),
                const Text('بيانات المهمة (Payload):', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                  child: Text(job.payload.toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTrailingActions(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (job.status == JobStatus.failed)
          IconButton(
            icon: const Icon(Icons.replay, color: Colors.blue),
            tooltip: 'إعادة المحاولة',
            onPressed: () => ref.read(jobsListControllerProvider.notifier).retryJob(job.id),
          ),
        if (job.status == JobStatus.pending || job.status == JobStatus.retrying)
          IconButton(
            icon: const Icon(Icons.cancel_outlined, color: Colors.orange),
            tooltip: 'إلغاء المهمة',
            onPressed: () => ref.read(jobsListControllerProvider.notifier).cancelJob(job.id),
          ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'حذف السجل',
          onPressed: () => _confirmDelete(context, ref),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف سجل المهمة'),
        content: const Text('هل أنت متأكد من حذف سجل هذه المهمة نهائياً؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              ref.read(jobsListControllerProvider.notifier).deleteJob(job.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.pending: return Colors.orange;
      case JobStatus.running: return Colors.blue;
      case JobStatus.completed: return Colors.green;
      case JobStatus.failed: return Colors.red;
      case JobStatus.retrying: return Colors.purple;
    }
  }

  String _getStatusLabel(JobStatus status) {
    switch (status) {
      case JobStatus.pending: return 'قيد الانتظار';
      case JobStatus.running: return 'قيد التنفيذ';
      case JobStatus.completed: return 'مكتملة';
      case JobStatus.failed: return 'فشلت';
      case JobStatus.retrying: return 'إعادة محاولة';
    }
  }

  IconData _getJobIcon(String type) {
    if (type.contains('EMAIL')) return Icons.email_outlined;
    if (type.contains('REPORT')) return Icons.assessment_outlined;
    if (type.contains('SYNC')) return Icons.sync;
    return Icons.settings_backup_restore;
  }
}
