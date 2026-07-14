// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart' as intl;
// import '../backup_controller.dart';
// import '../../domain/backup_record.dart';
//
// class BackupScreen extends ConsumerWidget {
//   const BackupScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final backupsAsync = ref.watch(backupControllerProvider);
//
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('النسخ الاحتياطي والاستعادة'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: () => ref.read(backupControllerProvider.notifier).refresh(),
//             ),
//           ],
//         ),
//         body: backupsAsync.when(
//           data: (backups) => _buildBackupList(context, ref, backups),
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (err, _) => Center(child: Text('حدث خطأ: $err')),
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: () => _confirmBackupRequest(context, ref),
//           label: const Text('نسخة احتياطية الآن'),
//           icon: const Icon(Icons.backup_rounded),
//           backgroundColor: Colors.blue.shade800,
//           foregroundColor: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBackupList(BuildContext context, WidgetRef ref, List<BackupRecord> backups) {
//     if (backups.isEmpty) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.storage_rounded, size: 64, color: Colors.grey),
//             SizedBox(height: 16),
//             Text('لا توجد سجلات نسخ احتياطي حالياً', style: TextStyle(color: Colors.grey)),
//           ],
//         ),
//       );
//     }
//
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: backups.length,
//       itemBuilder: (context, index) {
//         final backup = backups[index];
//         return _BackupCard(backup: backup);
//       },
//     );
//   }
//
//   void _confirmBackupRequest(BuildContext context, WidgetRef ref) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('طلب نسخة احتياطية'),
//         content: const Text('سيتم إنشاء نسخة احتياطية كاملة لقاعدة البيانات الآن. قد تستغرق هذه العملية بضع دقائق.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//           ElevatedButton(
//             onPressed: () {
//               ref.read(backupControllerProvider.notifier).requestBackup();
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('تم بدء عملية النسخ الاحتياطي في الخلفية')),
//               );
//             },
//             child: const Text('تأكيد الطلب'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _BackupCard extends ConsumerWidget {
//   final BackupRecord backup;
//   const _BackupCard({required this.backup});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final df = intl.DateFormat('yyyy/MM/dd HH:mm');
//     final color = _getStatusColor(backup.status);
//     final sizeStr = backup.sizeBytes != null
//         ? '${(backup.sizeBytes! / (1024 * 1024)).toStringAsFixed(2)} MB'
//         : 'جاري الحساب...';
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: color.withOpacity(0.1),
//           child: Icon(Icons.settings_backup_restore_rounded, color: color),
//         ),
//         title: Text(backup.filename, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('تاريخ الإنشاء: ${df.format(backup.createdAt)}'),
//             Text('الحجم: $sizeStr | النوع: ${backup.backupType == 'manual' ? 'يدوي' : 'تلقائي'}'),
//             const SizedBox(height: 4),
//             _StatusBadge(status: backup.status),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (backup.downloadUrl != null)
//               IconButton(
//                 icon: const Icon(Icons.download_rounded, color: Colors.blue),
//                 onPressed: () {
//                    // Logic to download
//                 },
//               ),
//             IconButton(
//               icon: const Icon(Icons.delete_outline, color: Colors.red),
//               onPressed: () => _confirmDelete(context, ref),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _confirmDelete(BuildContext context, WidgetRef ref) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('حذف سجل النسخ'),
//         content: const Text('هل أنت متأكد من حذف سجل النسخ هذا؟ لن يتم حذف الملف الفعلي من السيرفر إذا كان تلقائياً.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//           TextButton(
//             onPressed: () {
//               ref.read(backupControllerProvider.notifier).deleteRecord(backup.id);
//               Navigator.pop(context);
//             },
//             child: const Text('حذف', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'completed': return Colors.green;
//       case 'failed': return Colors.red;
//       case 'in_progress': return Colors.orange;
//       default: return Colors.grey;
//     }
//   }
// }
//
// class _StatusBadge extends StatelessWidget {
//   final String status;
//   const _StatusBadge({required this.status});
//
//   @override
//   Widget build(BuildContext context) {
//     String label = 'غير معروف';
//     Color color = Colors.grey;
//
//     if (status == 'completed') {
//       label = 'مكتملة';
//       color = Colors.green;
//     } else if (status == 'failed') {
//       label = 'فشلت';
//       color = Colors.red;
//     } else if (status == 'in_progress') {
//       label = 'قيد التنفيذ';
//       color = Colors.orange;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }
