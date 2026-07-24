import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../crm_controller.dart';

class DocumentManagerWidget extends ConsumerWidget {
  final String customerId;
  final String? contractId;

  const DocumentManagerWidget({
    super.key,
    required this.customerId,
    this.contractId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(customerDocumentsProvider(customerId));

    return Column(
      children: [
        _buildUploadHeader(context, ref),
        const SizedBox(height: 16),
        Expanded(
          child: docsAsync.when(
            data: (docs) {
              if (docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('لا توجد مستندات مرفوعة لهذا السجل', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              return _buildDocumentsList(context, ref, docs);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('خطأ في تحميل الملفات: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'يمكنك رفع صور الهوية، العقود الموقعة، أو الضمانات البنكية.',
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _simulateFileUpload(context, ref),
            icon: const Icon(Icons.upload_file),
            label: const Text('رفع ملف'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: _buildFileIcon(doc['document_type']),
            title: Text(doc['name'] ?? 'مستند بدون اسم'),
            subtitle: Text(
              'تاريخ الرفع: ${DateFormat('yyyy/MM/dd').format(DateTime.parse(doc['created_at']))}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, color: Colors.blue),
                  onPressed: () => _previewDocument(context, doc['document_url']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, ref, doc),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileIcon(String? type) {
    IconData icon = Icons.description;
    Color color = Colors.blueGrey;

    if (type == 'NATIONAL_ID') {
      icon = Icons.badge_outlined;
      color = Colors.blue;
    } else if (type == 'CONTRACT') {
      icon = Icons.assignment_outlined;
      color = Colors.green;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color),
    );
  }

  void _previewDocument(BuildContext context, String? url) {
    if (url == null) return;
    SnackBarHelper.showInfo(context, 'فتح المستند: $url');
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Map<String, dynamic> doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستند'),
        content: Text('هل أنت متأكد من حذف "${doc['name']}"؟ لا يمكن التراجع عن هذه العملية.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              await ref.read(crmControllerProvider.notifier).deleteDocument(
                    documentId: doc['id'],
                    filePath: doc['document_url'], // Assuming this stores path or we need path
                    customerId: customerId,
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('حذف نهائي', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _simulateFileUpload(BuildContext context, WidgetRef ref) async {
    SnackBarHelper.showInfo(context, 'جاري معالجة الملف...');
    
    await ref.read(crmControllerProvider.notifier).uploadDocument(
      customerId: customerId,
      contractId: contractId,
      documentType: 'OTHER',
      fileName: 'مرفق_جديد_${DateTime.now().millisecond}.pdf',
      fileBytes: [1, 2, 3], // بيانات وهمية للاختبار
    );
  }
}
