import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/snack_bar_helper.dart';
import '../../../../core/utils/app_theme.dart';
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.folder_open_rounded,
                            size: 40,
                            color: AppColors.primaryNavy),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد مستندات مرفوعة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ارفع الوثائق والمرفقات من خلال زر "رفع ملف"',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }
              return _buildDocumentsList(context, ref, docs);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text('خطأ في تحميل الملفات: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryNavy.withValues(alpha: 0.06),
            AppColors.primaryNavy.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primaryNavy.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.cloud_upload_rounded,
                color: AppColors.primaryNavy, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة المستندات والوثائق',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primaryNavy,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'ارفع صور الهوية، العقود الموقعة، أو الضمانات البنكية.',
                  style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _simulateFileUpload(context, ref),
            icon: const Icon(Icons.upload_file_rounded, size: 16),
            label: const Text('رفع ملف',
                style:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              shadowColor: AppColors.primaryNavy.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(BuildContext context, WidgetRef ref,
      List<Map<String, dynamic>> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final (icon, color, label) = _docMeta(doc['document_type']);
        final dateStr = DateFormat('yyyy/MM/dd').format(
            DateTime.parse(doc['created_at']));

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.grey.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['name'] ?? 'مستند بدون اسم',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(label,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: color)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'تاريخ الرفع: $dateStr',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionButton(
                    icon: Icons.visibility_outlined,
                    color: AppColors.primaryNavy,
                    tooltip: 'معاينة',
                    onTap: () =>
                        _previewDocument(context, doc['document_url']),
                  ),
                  const SizedBox(width: 6),
                  _actionButton(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.errorRed,
                    tooltip: 'حذف',
                    onTap: () => _confirmDelete(context, ref, doc),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) =>
      Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      );

  (IconData, Color, String) _docMeta(String? type) {
    return switch (type) {
      'NATIONAL_ID' => (Icons.badge_rounded, Colors.indigo, 'هوية وطنية'),
      'CONTRACT' => (Icons.assignment_rounded, AppColors.successGreen, 'عقد'),
      'BANK_STATEMENT' =>
        (Icons.account_balance_rounded, Colors.teal, 'كشف بنكي'),
      _ => (Icons.description_rounded, Colors.blueGrey, 'مرفق')
    };
  }

  void _previewDocument(BuildContext context, String? url) {
    if (url == null) return;
    SnackBarHelper.showInfo(context, 'فتح المستند: $url');
  }

  void _confirmDelete(BuildContext context, WidgetRef ref,
      Map<String, dynamic> doc) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: AppColors.primaryNavy),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.amber, size: 22),
                    SizedBox(width: 10),
                    Text('تأكيد الحذف النهائي',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'هل أنت متأكد من حذف "${doc['name']}"؟ لا يمكن التراجع عن هذه العملية.',
                  style: const TextStyle(fontSize: 13, height: 1.6),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.04),
                  border: Border(
                      top: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.12))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('إلغاء',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(crmControllerProvider.notifier)
                              .deleteDocument(
                                documentId: doc['id'],
                                filePath: doc['document_url'],
                                customerId: customerId,
                              );
                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                        },
                        icon: const Icon(Icons.delete_forever_rounded,
                            size: 18),
                        label: const Text('حذف نهائي',
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorRed,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateFileUpload(BuildContext context, WidgetRef ref) async {
    SnackBarHelper.showInfo(context, 'جاري معالجة الملف...');
    await ref.read(crmControllerProvider.notifier).uploadDocument(
          customerId: customerId,
          contractId: contractId,
          documentType: 'OTHER',
          fileName:
              'مرفق_جديد_${DateTime.now().millisecond}.pdf',
          fileBytes: [1, 2, 3],
        );
  }
}
