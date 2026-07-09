import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart';
import '../document_controller.dart';
import '../../domain/document.dart';

class UniversalDocumentManager extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsListProvider(
      customerId: customerId,
      contractId: contractId,
      investorId: investorId,
    ));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          _buildUploadCard(context, ref),
          const SizedBox(height: 16),
          Expanded(
            child: docsAsync.when(
              data: (docs) => docs.isEmpty 
                ? _buildEmptyState() 
                : _buildDocumentsList(context, ref, docs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('خطأ في تحميل الملفات: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مركز المرفقات الآمن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('يمكنك رفع صور الهوية، العقود، أو الشيكات بصيغة PDF أو صور.', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showUploadDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('رفع مستند'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList(BuildContext context, WidgetRef ref, List<AppDocument> docs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: _buildFileIcon(doc.type),
            title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('تاريخ الرفع: ${intl.DateFormat('yyyy/MM/dd').format(doc.createdAt)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // زر المعاينة/التحميل
                IconButton(
                  tooltip: 'معاينة / تحميل',
                  icon: const Icon(Icons.open_in_new, color: Colors.blue),
                  onPressed: () => _launchURL(doc.documentUrl),
                ),
                // زر الاستبدال
                IconButton(
                  tooltip: 'استبدال الملف',
                  icon: const Icon(Icons.published_with_changes_rounded, color: Colors.orange),
                  onPressed: () => _showUploadDialog(context, ref, replaceDoc: doc),
                ),
                // زر الحذف
                IconButton(
                  tooltip: 'حذف',
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

  Widget _buildFileIcon(DocumentType type) {
    IconData icon;
    Color color;
    switch (type) {
      case DocumentType.nationalId: icon = Icons.badge_outlined; color = Colors.indigo; break;
      case DocumentType.contract: icon = Icons.assignment_outlined; color = Colors.green; break;
      case DocumentType.check: icon = Icons.payments_outlined; color = Colors.amber.shade900; break;
      case DocumentType.guarantee: icon = Icons.gavel_outlined; color = Colors.purple; break;
      case DocumentType.image: icon = Icons.image_outlined; color = Colors.blue; break;
      default: icon = Icons.description_outlined; color = Colors.grey;
    }
    return CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color));
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('لا توجد مستندات مرفوعة حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppDocument doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستند'),
        content: Text('هل أنت متأكد من حذف "${doc.name}"؟\nلا يمكن التراجع عن هذه العملية.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(documentControllerProvider.notifier).deleteDocument(
                documentId: doc.id,
                filePath: doc.filePath,
                customerId: customerId,
                contractId: contractId,
                investorId: investorId,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context, WidgetRef ref, {AppDocument? replaceDoc}) {
    DocumentType selectedType = replaceDoc?.type ?? DocumentType.other;
    final nameController = TextEditingController(text: replaceDoc?.name);
    PlatformFile? pickedFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(replaceDoc == null ? 'رفع مستند جديد' : 'استبدال المستند'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (replaceDoc == null) // نوع المستند لا يتغير عند الاستبدال غالباً
                    DropdownButtonFormField<DocumentType>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'نوع المستند'),
                      items: DocumentType.values.map((t) => DropdownMenuItem(value: t, child: Text(_getTypeLabel(t)))).toList(),
                      onChanged: (v) => setDialogState(() => selectedType = v!),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'اسم المستند', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  // منطقة اختيار الملف
                  InkWell(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                        withData: true,
                      );
                      if (result != null) {
                        setDialogState(() => pickedFile = result.files.first);
                        if (nameController.text.isEmpty) {
                          nameController.text = pickedFile!.name;
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: pickedFile != null ? Colors.green : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: pickedFile != null ? Colors.green.shade50 : Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(pickedFile != null ? Icons.check_circle : Icons.file_present_rounded, 
                               color: pickedFile != null ? Colors.green : Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pickedFile != null ? pickedFile!.name : 'اضغط لاختيار ملف (PDF أو صورة)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: pickedFile == null ? null : () async {
                  final navigator = Navigator.of(context);
                  
                  // إذا كان استبدال، نحذف القديم أولاً
                  if (replaceDoc != null) {
                    await ref.read(documentControllerProvider.notifier).deleteDocument(
                      documentId: replaceDoc.id,
                      filePath: replaceDoc.filePath,
                    );
                  }

                  await ref.read(documentControllerProvider.notifier).uploadDocument(
                    customerId: customerId,
                    contractId: contractId,
                    investorId: investorId,
                    type: selectedType,
                    fileName: nameController.text,
                    fileBytes: pickedFile!.bytes!.toList(),
                  );
                  
                  navigator.pop();
                },
                child: Text(replaceDoc == null ? 'بدء الرفع' : 'تأكيد الاستبدال'),
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
      case DocumentType.guarantee: return 'سند لأمر / ضمان';
      case DocumentType.image: return 'صورة توضيحية';
      case DocumentType.pdf: return 'ملف PDF';
      default: return 'أخرى';
    }
  }
}
