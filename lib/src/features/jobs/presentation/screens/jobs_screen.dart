import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../jobs_controller.dart';
import '../../domain/background_job.dart';
import '../../../../core/utils/arabic_translator.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../../../../core/utils/app_theme.dart';

class BackgroundJobsScreen extends ConsumerWidget {
  const BackgroundJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsListControllerProvider);
    final statsAsync = ref.watch(jobsStatsProvider);
    final currentFilter = ref.watch(jobFilterProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          elevation: 0,
          toolbarHeight: 80,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مراقبة المهام الخلفية',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('إدارة طابور العمليات المجدولة والإشعارات',
                  style: TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () {
                ref.read(jobsListControllerProvider.notifier).refresh();
                ref.invalidate(jobsStatsProvider);
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Column(
          children: [
            // لوحة الإحصائيات
            _buildStatsHeader(statsAsync),
            
            // شريط الفلترة
            _buildFilterBar(ref, currentFilter),

            Expanded(
              child: jobsAsync.when(
                data: (jobs) => _buildJobsList(context, ref, jobs),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      Failure.fromException(err).message,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(AsyncValue<Map<String, int>> statsAsync) {
    return statsAsync.maybeWhen(
      data: (stats) => Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _buildStatCard('الإجمالي', stats['total']?.toString() ?? '0', Colors.blue),
            const SizedBox(width: 12),
            _buildStatCard('فاشلة', stats['failed']?.toString() ?? '0', Colors.red),
            const SizedBox(width: 12),
            _buildStatCard('معلقة', stats['pending']?.toString() ?? '0', Colors.orange),
            const SizedBox(width: 12),
            _buildStatCard('مكتملة', stats['completed']?.toString() ?? '0', Colors.green),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(bottom: BorderSide(color: color, width: 3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(WidgetRef ref, JobStatus? currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('الكل'),
            selected: currentFilter == null,
            onSelected: (_) => ref.read(jobFilterProvider.notifier).setFilter(null),
          ),
          const SizedBox(width: 8),
          ...JobStatus.values.map((status) => Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: FilterChip(
              label: Text(_getStatusLabel(status)),
              selected: currentFilter == status,
              onSelected: (_) => ref.read(jobFilterProvider.notifier).setFilter(status),
              selectedColor: _getStatusColor(status).withOpacity(0.2),
              checkmarkColor: _getStatusColor(status),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildJobsList(BuildContext context, WidgetRef ref, List<BackgroundJob> jobs) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt_rounded, size: 64, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('لا توجد مهام في هذا التصنيف حالياً', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _JobCard(job: job);
      },
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
}

class _JobCard extends ConsumerWidget {
  final BackgroundJob job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final df = intl.DateFormat('yyyy/MM/dd HH:mm');
    final color = _getStatusColor(job.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(_getJobIcon(job.jobType), color: color, size: 20),
        ),
        title: Text(ArabicTranslator.jobType(job.jobType), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('${_getStatusLabel(job.status)} | ${df.format(job.createdAt)}', style: const TextStyle(fontSize: 11)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _buildInfoRow('معرف المهمة:', job.id),
                _buildInfoRow('المحاولات:', '${job.attempts} من أصل ${job.maxAttempts}'),
                if (job.startedAt != null) _buildInfoRow('بدأت في:', df.format(job.startedAt!)),
                if (job.completedAt != null) _buildInfoRow('انتهت في:', df.format(job.completedAt!)),
                
                if (job.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  const Text('تفاصيل الفشل:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 12)),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(job.errorMessage!, style: const TextStyle(fontSize: 11, color: Colors.red, fontFamily: 'monospace')),
                  ),
                ],
                
                const SizedBox(height: 12),
                const Text('بيانات العملية (Payload):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(job.payload.toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.blueGrey)),
                ),
                
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (job.status == JobStatus.failed)
                      ElevatedButton.icon(
                        onPressed: () => ref.read(jobsListControllerProvider.notifier).retryJob(job.id),
                        icon: const Icon(Icons.replay_rounded, size: 16),
                        label: const Text('إعادة محاولة'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(context, ref),
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text('حذف السجل'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
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
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف سجل المهمة'),
        content: const Text('هل أنت متأكد من حذف هذا السجل؟ لن يؤثر هذا على عمل النظام ولكنه سيمسح سجل التتبع.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              ref.read(jobsListControllerProvider.notifier).deleteJob(job.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('تأكيد الحذف'),
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
    if (type.contains('EMAIL')) return Icons.email_rounded;
    if (type.contains('REPORT')) return Icons.assessment_rounded;
    if (type.contains('SYNC')) return Icons.sync_rounded;
    return Icons.settings_backup_restore_rounded;
  }
}
