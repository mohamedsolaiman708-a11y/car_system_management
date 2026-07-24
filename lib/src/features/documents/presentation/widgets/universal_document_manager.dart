import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart';
import '../document_controller.dart';
import '../../domain/document.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';

class UniversalDocumentManager extends ConsumerStatefulWidget {
  final String? customerId;
  final String? contractId;
  final String? investorId;

  const UniversalDocumentManager({
    super.key,
    this.customerId,
    this.contractId,
    this.investorId,
  });

  @override
  ConsumerState<UniversalDocumentManager> createState() => _UniversalDocumentManagerState();
}

class _UniversalDocumentManagerState extends ConsumerState<UniversalDocumentManager> {
  @override
  Widget build(BuildContext context) {
    AsyncValue<List<AppDocument>> docsAsync;
    try {
      docsAsync = ref.watch(
        documentsListProvider(
          customerId: widget.customerId,
          contractId: widget.contractId,
          investorId: widget.investorId,
        ),
      );
    } catch (e, stack) {
      docsAsync = AsyncValue.error(e, stack);
    }

    try {
      ref.listen<double?>(uploadProgressProvider, (prev, next) {
        if (next != null && prev == null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const _UploadProgressDialog(),
          );
        } else if (next == null && prev != null) {
          if (context.mounted) Navigator.of(context, rootNavigator: true).maybePop();
        }
      });
    } catch (_) {}

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- كرت رفع المستندات ---
            _buildPremiumUploadCard(),

            const SizedBox(height: 24),

            // --- عنوان القائمة ---
            Row(
              children: [
                Container(
                  width: 5,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'قائمة المستندات المرفقة',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- قائمة المستندات / Loading / Error / Empty ---
            docsAsync.when(
              data: (docs) {
                if (docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: _buildEmptyState(),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: docs.length,
                  itemBuilder: (context, index) => _buildDocumentItem(docs[index]),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryNavy),
                ),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: _buildFriendlyErrorState(err),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // هذا هو الكرت الذي يحتوي على زر "إرفاق مستند"
  Widget _buildPremiumUploadCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryNavy, Color(0xFF1B2A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primaryNavy.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.cloud_upload_rounded, size: 36, color: AppColors.accentGold),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مركز المرفقات الرقمي', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white)),
                Text('ارفع الهوية، العقد، أو الصور', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          // الزر الذهبي للرفع
          ElevatedButton(
            onPressed: () => _showUploadDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.primaryNavy,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text('إرفاق مستند', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(AppDocument doc) {
    final nameLower = doc.name.toLowerCase();
    final isImage = nameLower.endsWith('.png') || nameLower.endsWith('.jpg') || nameLower.endsWith('.jpeg');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: isImage ? _buildImageThumbnail(doc.documentUrl) : _buildFileIcon(doc.type),
        title: Text(doc.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryNavy)),
        subtitle: Text('أرشف في: ${intl.DateFormat('yyyy/MM/dd').format(doc.createdAt)}', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue),
              onPressed: () {
                if (isImage) _showImagePreviewDialog(doc);
                else _launchURL(doc.documentUrl);
              },
            ),
            _buildMoreMenu(doc),
          ],
        ),
      ),
    );
  }


  Widget _buildMoreMenu(AppDocument doc) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (val) {
        if (val == 'copy') _copyToClipboard(doc.documentUrl);
        if (val == 'delete') _confirmDelete(doc);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'copy', child: Row(children: [Icon(Icons.link_rounded, size: 20), SizedBox(width: 12), Text('نسخ الرابط')])),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 20), SizedBox(width: 12), Text('حذف نهائي', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold))])),
      ],
    );
  }

  Widget _buildImageThumbnail(String imageUrl) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.grey)),
      ),
    );
  }

  Widget _buildFileIcon(DocumentType type) {
    IconData icon = Icons.description_outlined;
    Color color = Colors.blueGrey;
    if (type == DocumentType.contract) { icon = Icons.assignment_outlined; color = AppColors.successGreen; }
    else if (type == DocumentType.nationalId) { icon = Icons.badge_outlined; color = Colors.indigo; }
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_open_rounded, size: 56, color: AppColors.primaryNavy),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد مستندات مرفوعة حالياً',
            style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'اضغط على زر "إرفاق مستند" أعلاه لإضافة أول مستند لهذا العقد',
            style: TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendlyErrorState(dynamic err) {
    final failure = Failure.fromException(err);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.errorRed),
          const SizedBox(height: 16),
          Text(failure.message, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          TextButton(onPressed: () => ref.invalidate(documentsListProvider), child: const Text('إعادة محاولة المزامنة')),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) SnackBarHelper.showSuccess(context, 'تم نسخ الرابط!');
  }

  void _showImagePreviewDialog(AppDocument doc) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(child: InteractiveViewer(child: Image.network(doc.documentUrl))),
            Positioned(top: 40, right: 20, child: CircleAvatar(backgroundColor: Colors.white24, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)))),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _confirmDelete(AppDocument doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المستند "${doc.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(documentControllerProvider.notifier).deleteDocument(
                documentId: doc.id, filePath: doc.filePath,
                customerId: widget.customerId, contractId: widget.contractId, investorId: widget.investorId,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, foregroundColor: Colors.white),
            child: const Text('تأكيد الحذف'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    DocumentType selectedType = DocumentType.other;
    final nameController = TextEditingController();
    PlatformFile? pickedFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('أرشفة مستند جديد'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<DocumentType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'نوع المستند'),
                    items: DocumentType.values.map((t) => DropdownMenuItem(value: t, child: Text(_getTypeLabel(t)))).toList(),
                    onChanged: (v) => setDialogState(() => selectedType = v!),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم المستند', border: OutlineInputBorder())),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'], withData: true);
                      if (result != null) { 
                        setDialogState(() => pickedFile = result.files.first); 
                        if (nameController.text.isEmpty) nameController.text = pickedFile!.name; 
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: pickedFile != null ? AppColors.successGreen : Colors.grey.shade300), borderRadius: BorderRadius.circular(16), color: pickedFile != null ? AppColors.successGreen.withOpacity(0.05) : Colors.grey.shade50),
                      child: Row(children: [Icon(pickedFile != null ? Icons.check_circle_rounded : Icons.file_present_rounded, color: pickedFile != null ? AppColors.successGreen : AppColors.primaryNavy), const SizedBox(width: 12), Expanded(child: Text(pickedFile != null ? pickedFile!.name : 'اختيار ملف (PDF/صورة)', overflow: TextOverflow.ellipsis))]),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: pickedFile == null ? null : () async {
                  final nav = Navigator.of(context);
                  nav.pop();
                  await ref.read(documentControllerProvider.notifier).uploadDocument(
                    customerId: widget.customerId, contractId: widget.contractId, investorId: widget.investorId,
                    type: selectedType, fileName: nameController.text, fileBytes: pickedFile!.bytes!.toList(),
                  );
                },
                child: const Text('بدء الرفع'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(DocumentType type) {
    switch (type) {
      case DocumentType.nationalId: return 'هوية وطنية';
      case DocumentType.contract: return 'عقد موثق';
      case DocumentType.check: return 'شيك بنكي';
      case DocumentType.guarantee: return 'ضمان / سند';
      default: return 'أخرى';
    }
  }
}

class _UploadProgressDialog extends ConsumerWidget {
  const _UploadProgressDialog();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(uploadProgressProvider) ?? 0.0;
    final isComplete = progress >= 1.0;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(alignment: Alignment.center, children: [SizedBox(width: 90, height: 90, child: CircularProgressIndicator(value: isComplete ? null : progress, strokeWidth: 8, backgroundColor: AppColors.bgGrey, color: AppColors.primaryNavy)), if (isComplete) const Icon(Icons.verified_rounded, color: AppColors.successGreen, size: 44)]),
              const SizedBox(height: 24),
              Text(isComplete ? 'تم الرفع بنجاح!' : 'جاري معالجة المستند...', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
