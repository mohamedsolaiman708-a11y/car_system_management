import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // مراقبة تقدم الرفع وعرض الـ Dialog تلقائياً
    ref.listen<double?>(uploadProgressProvider, (prev, next) {
      if (next != null && prev == null) {
        // ابدأ الرفع → افتح الـ dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _UploadProgressDialog(
            customerId: customerId,
            contractId: contractId,
            investorId: investorId,
          ),
        );
      } else if (next == null && prev != null) {
        // انتهى الرفع → أغلق الـ dialog
        if (context.mounted) Navigator.of(context, rootNavigator: true).maybePop();
      }
    });

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
              error: (err, _) =>
                  Center(child: Text('خطأ في تحميل الملفات: $err')),
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
            const Icon(Icons.cloud_upload_outlined,
                size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مركز المرفقات الآمن',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                      'يمكنك رفع صور الهوية، العقود، أو الشيكات بصيغة PDF أو صور.',
                      style:
                          TextStyle(fontSize: 12, color: Colors.blueGrey)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showUploadDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('رفع مستند'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList(
      BuildContext context, WidgetRef ref, List<AppDocument> docs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final isImage = doc.type == DocumentType.image ||
            doc.name.toLowerCase().endsWith('.png') ||
            doc.name.toLowerCase().endsWith('.jpg') ||
            doc.name.toLowerCase().endsWith('.jpeg');

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: isImage
                ? _buildImageThumbnail(context, doc.documentUrl)
                : _buildFileIcon(doc.type),
            title: Text(doc.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0D1B3E))),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'تاريخ الرفع: ${intl.DateFormat('yyyy/MM/dd').format(doc.createdAt)}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // زر نسخ الرابط
                IconButton(
                  tooltip: 'نسخ رابط المستند',
                  icon: const Icon(Icons.copy_rounded,
                      color: Colors.blueGrey, size: 20),
                  onPressed: () =>
                      _copyToClipboard(context, doc.documentUrl),
                ),
                // زر المعاينة/التحميل
                IconButton(
                  tooltip: isImage ? 'معاينة سريعة' : 'تحميل المستند',
                  icon: Icon(
                      isImage
                          ? Icons.visibility_outlined
                          : Icons.download_outlined,
                      color: Colors.blue,
                      size: 22),
                  onPressed: () {
                    if (isImage) {
                      _showImagePreviewDialog(context, doc);
                    } else {
                      _launchURL(doc.documentUrl);
                    }
                  },
                ),
                // زر الاستبدال
                IconButton(
                  tooltip: 'استبدال الملف',
                  icon: const Icon(Icons.published_with_changes_rounded,
                      color: Colors.orange, size: 20),
                  onPressed: () =>
                      _showUploadDialog(context, ref, replaceDoc: doc),
                ),
                // زر الحذف
                IconButton(
                  tooltip: 'حذف',
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: () => _confirmDelete(context, ref, doc),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageThumbnail(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () =>
          _showImagePreviewDialog(context, null, overrideUrl: imageUrl),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('تم نسخ رابط المستند إلى الحافظة!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showImagePreviewDialog(BuildContext context, AppDocument? doc,
      {String? overrideUrl}) {
    final url = overrideUrl ?? doc?.documentUrl ?? '';
    final name = doc?.name ?? 'معاينة الصورة';
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon:
                          const Icon(Icons.open_in_new, color: Colors.white),
                      onPressed: () => _launchURL(url),
                    )
                  ],
                ),
                Expanded(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white));
                      },
                      errorBuilder: (context, err, stack) => const Center(
                        child: Text(
                            'عذراً، تعذر تحميل الصورة المرفوعة.',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIcon(DocumentType type) {
    IconData icon;
    Color color;
    switch (type) {
      case DocumentType.nationalId:
        icon = Icons.badge_outlined;
        color = Colors.indigo;
        break;
      case DocumentType.contract:
        icon = Icons.assignment_outlined;
        color = Colors.green;
        break;
      case DocumentType.check:
        icon = Icons.payments_outlined;
        color = Colors.amber.shade900;
        break;
      case DocumentType.guarantee:
        icon = Icons.gavel_outlined;
        color = Colors.purple;
        break;
      case DocumentType.image:
        icon = Icons.image_outlined;
        color = Colors.blue;
        break;
      default:
        icon = Icons.description_outlined;
        color = Colors.grey;
    }
    return CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        radius: 22,
        child: Icon(icon, color: color, size: 20));
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('لا توجد مستندات مرفوعة حالياً',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
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
        content: Text(
            'هل أنت متأكد من حذف "${doc.name}"؟\nلا يمكن التراجع عن هذه العملية.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
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
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context, WidgetRef ref,
      {AppDocument? replaceDoc}) {
    DocumentType selectedType =
        replaceDoc?.type ?? DocumentType.other;
    final nameController =
        TextEditingController(text: replaceDoc?.name);
    PlatformFile? pickedFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(replaceDoc == null
                ? 'رفع مستند جديد'
                : 'استبدال المستند'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (replaceDoc == null)
                    DropdownButtonFormField<DocumentType>(
                      initialValue: selectedType,
                      decoration:
                          const InputDecoration(labelText: 'نوع المستند'),
                      items: DocumentType.values
                          .map((t) => DropdownMenuItem(
                              value: t, child: Text(_getTypeLabel(t))))
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedType = v!),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'اسم المستند',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  // منطقة اختيار الملف
                  InkWell(
                    onTap: () async {
                      final result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: [
                          'pdf',
                          'jpg',
                          'jpeg',
                          'png'
                        ],
                        withData: true,
                      );
                      if (result != null) {
                        setDialogState(
                            () => pickedFile = result.files.first);
                        if (nameController.text.isEmpty) {
                          nameController.text = pickedFile!.name;
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: pickedFile != null
                                ? Colors.green
                                : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: pickedFile != null
                            ? Colors.green.shade50
                            : Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(
                              pickedFile != null
                                  ? Icons.check_circle
                                  : Icons.file_present_rounded,
                              color: pickedFile != null
                                  ? Colors.green
                                  : Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pickedFile != null
                                  ? pickedFile!.name
                                  : 'اضغط لاختيار ملف (PDF أو صورة)',
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
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: pickedFile == null
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);

                        // إذا كان استبدال، نحذف القديم أولاً
                        if (replaceDoc != null) {
                          await ref
                              .read(documentControllerProvider.notifier)
                              .deleteDocument(
                                documentId: replaceDoc.id,
                                filePath: replaceDoc.filePath,
                              );
                        }

                        navigator.pop(); // أغلق dialog الرفع

                        await ref
                            .read(documentControllerProvider.notifier)
                            .uploadDocument(
                              customerId: customerId,
                              contractId: contractId,
                              investorId: investorId,
                              type: selectedType,
                              fileName: nameController.text,
                              fileBytes: pickedFile!.bytes!.toList(),
                            );
                      },
                child: Text(replaceDoc == null
                    ? 'بدء الرفع'
                    : 'تأكيد الاستبدال'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(DocumentType type) {
    switch (type) {
      case DocumentType.nationalId:
        return 'هوية وطنية';
      case DocumentType.contract:
        return 'عقد موثق';
      case DocumentType.check:
        return 'شيك بنكي';
      case DocumentType.guarantee:
        return 'سند لأمر / ضمان';
      case DocumentType.image:
        return 'صورة توضيحية';
      case DocumentType.pdf:
        return 'ملف PDF';
      default:
        return 'أخرى';
    }
  }
}

// ─────────────────────────────────────────────
// Upload Progress Dialog (مستقل ومراقب للـ provider)
// ─────────────────────────────────────────────
class _UploadProgressDialog extends ConsumerWidget {
  final String? customerId;
  final String? contractId;
  final String? investorId;

  const _UploadProgressDialog({
    this.customerId,
    this.contractId,
    this.investorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(uploadProgressProvider) ?? 0.0;
    final isComplete = progress >= 1.0;

    String statusText;
    if (progress < 0.1) {
      statusText = 'جاري تحضير الملف...';
    } else if (progress < 0.75) {
      statusText = 'جاري الرفع إلى الخادم...';
    } else if (progress < 0.9) {
      statusText = 'جاري معالجة الملف...';
    } else if (!isComplete) {
      statusText = 'جاري حفظ البيانات...';
    } else {
      statusText = 'تم الرفع بنجاح! ✓';
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة متحركة
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: isComplete
                    ? Container(
                        key: const ValueKey('done'),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 44),
                      )
                    : Container(
                        key: const ValueKey('loading'),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _AnimatedUploadIcon(),
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // العنوان
              Text(
                isComplete ? 'تم بنجاح!' : 'جاري رفع المستند',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isComplete ? Colors.green.shade700 : const Color(0xFF0D1B3E),
                ),
              ),
              const SizedBox(height: 8),

              // النص التوضيحي
              Text(
                statusText,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // شريط التقدم
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.green : Colors.blue.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // نسبة التقدم
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isComplete ? Colors.green : Colors.blue.shade700,
                    ),
                  ),
                  if (!isComplete)
                    Text(
                      'الرجاء الانتظار...',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// أيقونة رفع متحركة باستخدام CustomPainter
class _AnimatedUploadIcon extends StatefulWidget {
  @override
  State<_AnimatedUploadIcon> createState() => _AnimatedUploadIconState();
}

class _AnimatedUploadIconState extends State<_AnimatedUploadIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _UploadArrowPainter(_animation.value),
        );
      },
    );
  }
}

class _UploadArrowPainter extends CustomPainter {
  final double progress;
  _UploadArrowPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade700.withValues(alpha: 0.6 + 0.4 * progress)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final offset = -4.0 * progress; // يتحرك للأعلى

    // رسم السهم للأعلى
    final path = Path()
      ..moveTo(cx, cy + 6 + offset)
      ..lineTo(cx, cy - 6 + offset)
      ..moveTo(cx - 5, cy - 1 + offset)
      ..lineTo(cx, cy - 6 + offset)
      ..lineTo(cx + 5, cy - 1 + offset);

    canvas.drawPath(path, paint);

    // رسم الخط السفلي (القاعدة)
    canvas.drawLine(
      Offset(cx - 7, cy + 8),
      Offset(cx + 7, cy + 8),
      paint,
    );
  }

  @override
  bool shouldRepaint(_UploadArrowPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
