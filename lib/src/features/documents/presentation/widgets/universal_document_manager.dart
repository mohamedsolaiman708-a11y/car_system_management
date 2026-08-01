import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart';
import '../document_controller.dart';
import '../../domain/document.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/snack_bar_helper.dart';

// ── ألوان ثابتة للتصميم الجديد ──────────────────────────────────
const _navy  = AppColors.primaryNavy;
const _gold  = AppColors.accentGold;
const _bg    = Color(0xFFF5F6FA);

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
  ConsumerState<UniversalDocumentManager> createState() =>
      _UniversalDocumentManagerState();
}

class _UniversalDocumentManagerState
    extends ConsumerState<UniversalDocumentManager>
    with SingleTickerProviderStateMixin {

  String _selectedFilter = 'all';
  final _searchCtrl = TextEditingController();
  String _searchText = '';

  final _filters = const [
    ('all',        'الكل',       Icons.layers_rounded),
    ('NATIONAL_ID','هوية',       Icons.badge_outlined),
    ('CONTRACT',   'عقود',       Icons.assignment_outlined),
    ('CHECK',      'شيكات',      Icons.money_outlined),
    ('GUARANTEE',  'ضمانات',     Icons.verified_outlined),
    ('OTHER',      'أخرى',       Icons.folder_outlined),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<AppDocument>> docsAsync;
    try {
      docsAsync = ref.watch(documentsListProvider(
        customerId: widget.customerId,
        contractId: widget.contractId,
        investorId: widget.investorId,
      ));
    } catch (e, s) {
      docsAsync = AsyncValue.error(e, s);
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
      child: docsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _navy, strokeWidth: 2)),
        error: (err, _) => _ErrorState(onRetry: () => ref.invalidate(documentsListProvider)),
        data: (allDocs) {
          // ── فلترة ──
          final filtered = allDocs.where((d) {
            final matchType = _selectedFilter == 'all' || d.type.name.toUpperCase() == _selectedFilter;
            final matchSearch = _searchText.isEmpty ||
                d.name.toLowerCase().contains(_searchText.toLowerCase());
            return matchType && matchSearch;
          }).toList();

          return Column(
            children: [
              // ── شريط البحث والفلتر ──────────────────────────
              _buildTopBar(allDocs),

              // ── بطاقات الإحصاء ──────────────────────────────
              _buildStatsRow(allDocs),

              const SizedBox(height: 4),

              // ── تابات الفلتر ─────────────────────────────────
              _buildFilterChips(allDocs),

              const SizedBox(height: 12),

              // ── قائمة المستندات ──────────────────────────────
              Expanded(child: _buildDocumentList(filtered)),
            ],
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  TOP BAR  (بحث + زر رفع)
  // ════════════════════════════════════════════════════════════════
  Widget _buildTopBar(List<AppDocument> docs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: Row(
        children: [
          // ── حقل البحث ──
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchText = v),
                decoration: InputDecoration(
                  hintText: 'ابحث عن مستند...',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                          onPressed: () => setState(() { _searchCtrl.clear(); _searchText = ''; }),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── زر رفع جديد ──
          ElevatedButton.icon(
            onPressed: _showUploadDialog,
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: const Text('رفع مستند'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  STATS ROW
  // ════════════════════════════════════════════════════════════════
  Widget _buildStatsRow(List<AppDocument> docs) {
    final total    = docs.length;
    final pdfs     = docs.where((d) => d.name.toLowerCase().endsWith('.pdf')).length;
    final images   = docs.where((d) {
      final n = d.name.toLowerCase();
      return n.endsWith('.jpg') || n.endsWith('.jpeg') || n.endsWith('.png');
    }).length;
    final contracts = docs.where((d) => d.type == DocumentType.contract).length;

    return Row(
      children: [
        _StatCard(label: 'إجمالي الملفات', value: '$total', icon: Icons.folder_zip_outlined, color: _navy),
        const SizedBox(width: 10),
        _StatCard(label: 'PDF', value: '$pdfs', icon: Icons.picture_as_pdf_rounded, color: const Color(0xFFE53935)),
        const SizedBox(width: 10),
        _StatCard(label: 'صور', value: '$images', icon: Icons.image_outlined, color: const Color(0xFF1E88E5)),
        const SizedBox(width: 10),
        _StatCard(label: 'عقود', value: '$contracts', icon: Icons.assignment_outlined, color: const Color(0xFF43A047)),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  FILTER CHIPS
  // ════════════════════════════════════════════════════════════════
  Widget _buildFilterChips(List<AppDocument> docs) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (key, label, icon) = _filters[i];
          final count = key == 'all'
              ? docs.length
              : docs.where((d) => d.type.name.toUpperCase() == key).length;
          final isSelected = _selectedFilter == key;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _navy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? _navy : Colors.grey.shade200,
                  width: isSelected ? 0 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: _navy.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: isSelected ? _gold : Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? _gold.withValues(alpha: 0.25) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? _gold : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  DOCUMENT LIST
  // ════════════════════════════════════════════════════════════════
  Widget _buildDocumentList(List<AppDocument> docs) {
    if (docs.isEmpty) return _buildEmptyState();

    return ListView.separated(
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _DocCard(
        doc: docs[i],
        onView: _viewDocument,
        onCopy: (url) {
          Clipboard.setData(ClipboardData(text: url));
          SnackBarHelper.showSuccess(context, 'تم نسخ الرابط!');
        },
        onDelete: _confirmDelete,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  EMPTY STATE
  // ════════════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_navy.withValues(alpha: 0.08), _navy.withValues(alpha: 0.03)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.folder_open_rounded, size: 52, color: _navy),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد مستندات بعد',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _navy),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all'
                ? 'اضغط على زر "رفع مستند" لإضافة أول مستند'
                : 'لا توجد مستندات من هذا النوع',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          if (_selectedFilter == 'all') ...[
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _showUploadDialog,
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('رفع أول مستند'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  ACTIONS
  // ════════════════════════════════════════════════════════════════
  void _viewDocument(AppDocument doc) {
    final nameLower = doc.name.toLowerCase();
    final isImage = nameLower.endsWith('.png') || nameLower.endsWith('.jpg') || nameLower.endsWith('.jpeg');
    if (isImage) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(children: [
            Center(child: InteractiveViewer(child: Image.network(doc.documentUrl))),
            Positioned(
              top: 40, right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ]),
        ),
      );
    } else {
      _launchURL(doc.documentUrl);
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _confirmDelete(AppDocument doc) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            SizedBox(width: 8),
            Text('تأكيد الحذف', style: TextStyle(fontSize: 16)),
          ]),
          content: Text('هل أنت متأكد من حذف "${doc.name}"؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(documentControllerProvider.notifier).deleteDocument(
                  documentId: doc.id, filePath: doc.filePath,
                  customerId: widget.customerId,
                  contractId: widget.contractId,
                  investorId: widget.investorId,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, foregroundColor: Colors.white),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadDialog() {
    DocumentType selectedType = DocumentType.other;
    final nameCtrl = TextEditingController();
    PlatformFile? picked;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── عنوان ──
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: _navy.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.upload_file_rounded, color: _navy, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text('أرشفة مستند جديد', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _navy)),
                  ]),
                  const SizedBox(height: 24),

                  // ── نوع المستند ──
                  const Text('نوع المستند', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _navy)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DocumentType>(
                        value: selectedType,
                        isExpanded: true,
                        items: DocumentType.values.map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(_typeLabel(t), style: const TextStyle(fontSize: 13)),
                        )).toList(),
                        onChanged: (v) => setState(() => selectedType = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── اسم المستند ──
                  const Text('اسم المستند', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _navy)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'مثال: هوية محمد أحمد',
                      hintStyle: const TextStyle(fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── منطقة رفع الملف ──
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                        withData: true,
                      );
                      if (result != null) {
                        setState(() => picked = result.files.first);
                        if (nameCtrl.text.isEmpty) nameCtrl.text = picked!.name;
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: picked != null ? AppColors.successGreen.withValues(alpha: 0.05) : _bg,
                        border: Border.all(
                          color: picked != null ? AppColors.successGreen : Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            picked != null ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                            size: 36,
                            color: picked != null ? AppColors.successGreen : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            picked != null ? picked!.name : 'اضغط لاختيار ملف (PDF أو صورة)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: picked != null ? AppColors.successGreen : Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── أزرار ──
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: picked == null ? null : () async {
                          final nav = Navigator.of(ctx);
                          nav.pop();
                          await ref.read(documentControllerProvider.notifier).uploadDocument(
                            customerId: widget.customerId,
                            contractId: widget.contractId,
                            investorId: widget.investorId,
                            type: selectedType,
                            fileName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : picked!.name,
                            fileBytes: picked!.bytes!.toList(),
                          );
                        },
                        icon: const Icon(Icons.upload_rounded, size: 18),
                        label: const Text('بدء الرفع'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          textStyle: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _typeLabel(DocumentType t) {
    switch (t) {
      case DocumentType.nationalId: return 'هوية وطنية';
      case DocumentType.contract:   return 'عقد موثق';
      case DocumentType.check:      return 'شيك بنكي';
      case DocumentType.guarantee:  return 'ضمان / سند';
      case DocumentType.pdf:        return 'ملف PDF';
      case DocumentType.image:      return 'صورة';
      default:                      return 'أخرى';
    }
  }
}

// ════════════════════════════════════════════════════════════════════
//  STAT CARD  (بطاقة إحصاء)
// ════════════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  DOC CARD  (بطاقة مستند واحد)
// ════════════════════════════════════════════════════════════════════
class _DocCard extends StatelessWidget {
  final AppDocument doc;
  final void Function(AppDocument) onView;
  final void Function(String) onCopy;
  final void Function(AppDocument) onDelete;

  const _DocCard({required this.doc, required this.onView, required this.onCopy, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final nameLower = doc.name.toLowerCase();
    final isImage = nameLower.endsWith('.png') || nameLower.endsWith('.jpg') || nameLower.endsWith('.jpeg');
    final isPdf   = nameLower.endsWith('.pdf');

    Color typeColor;
    IconData typeIcon;
    if (isImage) { typeColor = const Color(0xFF1E88E5); typeIcon = Icons.image_rounded; }
    else if (isPdf) { typeColor = const Color(0xFFE53935); typeIcon = Icons.picture_as_pdf_rounded; }
    else if (doc.type == DocumentType.nationalId) { typeColor = Colors.indigo; typeIcon = Icons.badge_outlined; }
    else if (doc.type == DocumentType.contract)   { typeColor = const Color(0xFF43A047); typeIcon = Icons.assignment_outlined; }
    else if (doc.type == DocumentType.check)      { typeColor = const Color(0xFFF57C00); typeIcon = Icons.money_outlined; }
    else { typeColor = Colors.blueGrey; typeIcon = Icons.insert_drive_file_outlined; }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onView(doc),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // ── أيقونة النوع ──
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: isImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            doc.documentUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(typeIcon, color: typeColor, size: 26),
                          ),
                        )
                      : Icon(typeIcon, color: typeColor, size: 26),
                ),
                const SizedBox(width: 14),

                // ── اسم وتاريخ ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _navy),
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          intl.DateFormat('dd/MM/yyyy').format(doc.createdAt.toLocal()),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _typeShort(doc.type),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: typeColor),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),

                // ── أزرار الإجراء ──
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionBtn(icon: Icons.remove_red_eye_outlined, color: Colors.blue,   onTap: () => onView(doc)),
                    const SizedBox(width: 4),
                    _ActionBtn(icon: Icons.copy_rounded,            color: Colors.green,  onTap: () => onCopy(doc.documentUrl)),
                    const SizedBox(width: 4),
                    _ActionBtn(icon: Icons.delete_outline_rounded,  color: AppColors.errorRed, onTap: () => onDelete(doc)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _typeShort(DocumentType t) {
    switch (t) {
      case DocumentType.nationalId: return 'هوية';
      case DocumentType.contract:   return 'عقد';
      case DocumentType.check:      return 'شيك';
      case DocumentType.guarantee:  return 'ضمان';
      case DocumentType.pdf:        return 'PDF';
      case DocumentType.image:      return 'صورة';
      default:                      return 'أخرى';
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: color.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 17, color: color),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════
//  ERROR STATE
// ════════════════════════════════════════════════════════════════════
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.errorRed.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(24)),
          child: const Icon(Icons.cloud_off_rounded, size: 52, color: AppColors.errorRed),
        ),
        const SizedBox(height: 16),
        const Text('تعذّر تحميل المستندات', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _navy)),
        const SizedBox(height: 6),
        Text('تحقق من اتصالك بالإنترنت وأعد المحاولة', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('إعادة المحاولة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _navy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════════════
//  UPLOAD PROGRESS DIALOG
// ════════════════════════════════════════════════════════════════════
class _UploadProgressDialog extends ConsumerWidget {
  const _UploadProgressDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(uploadProgressProvider) ?? 0.0;
    final isDone = progress >= 1.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80, height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: isDone ? null : progress,
                      strokeWidth: 7,
                      backgroundColor: Colors.grey.shade100,
                      color: _navy,
                    ),
                    if (isDone)
                      const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 44),
                    if (!isDone)
                      Text('${(progress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: _navy)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isDone ? 'تم الرفع بنجاح! 🎉' : 'جاري رفع الملف...',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _navy),
              ),
              if (!isDone) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade100,
                  color: _gold,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 6,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
