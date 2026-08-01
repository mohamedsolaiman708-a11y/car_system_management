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

const _navy = AppColors.primaryNavy;
const _gold = AppColors.accentGold;

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
    extends ConsumerState<UniversalDocumentManager> {

  String _selectedFilter = 'all';
  final _searchCtrl = TextEditingController();
  String _searchText = '';

  static const _filters = [
    ('all',         'الكل',    Icons.layers_rounded),
    ('NATIONAL_ID', 'هوية',    Icons.badge_outlined),
    ('CONTRACT',    'عقود',    Icons.assignment_outlined),
    ('CHECK',       'شيكات',   Icons.money_outlined),
    ('GUARANTEE',   'ضمانات',  Icons.verified_outlined),
    ('OTHER',       'أخرى',    Icons.folder_outlined),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── شريط البحث + زر الرفع (ثابت دائماً) ─────────────────
          _buildSearchBar(),
          const SizedBox(height: 16),

          // ── المحتوى يتمدد ────────────────────────────────────────
          Expanded(
            child: docsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: _navy, strokeWidth: 2),
              ),
              error: (err, _) => _ErrorState(
                onRetry: () => ref.invalidate(documentsListProvider),
              ),
              data: (allDocs) {
                final filtered = allDocs.where((d) {
                  final matchType = _selectedFilter == 'all' ||
                      d.type.name.toUpperCase() == _selectedFilter;
                  final matchSearch = _searchText.isEmpty ||
                      d.name.toLowerCase().contains(_searchText.toLowerCase());
                  return matchType && matchSearch;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── إحصاءات ──
                    _StatsRow(docs: allDocs),
                    const SizedBox(height: 14),

                    // ── فلاتر ──
                    _FilterChips(
                      filters: _filters,
                      selected: _selectedFilter,
                      docs: allDocs,
                      onSelect: (k) => setState(() => _selectedFilter = k),
                    ),
                    const SizedBox(height: 14),

                    // ── قائمة المستندات ──
                    Expanded(
                      child: filtered.isEmpty
                          ? _EmptyState(
                              isFiltered: _selectedFilter != 'all',
                              onUpload: _showUploadDialog,
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 40),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (_, i) => _DocCard(
                                doc: filtered[i],
                                onView: _viewDocument,
                                onCopy: (url) {
                                  Clipboard.setData(ClipboardData(text: url));
                                  SnackBarHelper.showSuccess(context, 'تم نسخ الرابط!');
                                },
                                onDelete: _confirmDelete,
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── شريط البحث + زر الرفع ────────────────────────────────────────
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchText = v),
              decoration: InputDecoration(
                hintText: 'ابحث في المستندات...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: Colors.grey,
                        onPressed: () => setState(() {
                          _searchCtrl.clear();
                          _searchText = '';
                        }),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // ── زر الرفع ── دائماً مرئي
        ElevatedButton.icon(
          onPressed: _showUploadDialog,
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: const Text('رفع مستند'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _navy,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 46),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ── عرض المستند ───────────────────────────────────────────────────
  void _viewDocument(AppDocument doc) {
    final n = doc.name.toLowerCase();
    final isImg = n.endsWith('.png') || n.endsWith('.jpg') || n.endsWith('.jpeg');
    if (isImg) {
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
      _launchUrl(doc.documentUrl);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── حذف المستند ──────────────────────────────────────────────────
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(documentControllerProvider.notifier)
                    .deleteDocument(
                      documentId: doc.id,
                      filePath: doc.filePath,
                      customerId: widget.customerId,
                      contractId: widget.contractId,
                      investorId: widget.investorId,
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  // ── نافذة الرفع ──────────────────────────────────────────────────
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── عنوان ──
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _navy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.upload_file_rounded, color: _navy, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('أرشفة مستند جديد',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _navy)),
                            Text('رفع الملف وربطه بالسجلات',
                                style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ]),

                    const Divider(height: 28),

                    // ── نوع المستند ──
                    const Text('نوع المستند',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _navy)),
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
                            child: Text(_typeLabel(t),
                                style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          onChanged: (v) => setState(() => selectedType = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── اسم المستند ──
                    const Text('اسم المستند (اختياري)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _navy)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: 'مثال: هوية محمد أحمد',
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── منطقة الرفع ──
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
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        decoration: BoxDecoration(
                          color: picked != null
                              ? AppColors.successGreen.withValues(alpha: 0.05)
                              : Colors.grey.shade50,
                          border: Border.all(
                            color: picked != null
                                ? AppColors.successGreen
                                : Colors.grey.shade300,
                            width: picked != null ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(children: [
                          Icon(
                            picked != null
                                ? Icons.check_circle_rounded
                                : Icons.cloud_upload_rounded,
                            size: 38,
                            color: picked != null
                                ? AppColors.successGreen
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            picked != null
                                ? picked!.name
                                : 'اضغط لاختيار ملف (PDF أو صورة)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: picked != null
                                  ? AppColors.successGreen
                                  : Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── أزرار ──
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 46),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: picked == null
                              ? null
                              : () async {
                                  final nav = Navigator.of(ctx);
                                  nav.pop();
                                  await ref
                                      .read(documentControllerProvider.notifier)
                                      .uploadDocument(
                                        customerId: widget.customerId,
                                        contractId: widget.contractId,
                                        investorId: widget.investorId,
                                        type: selectedType,
                                        fileName: nameCtrl.text.trim().isNotEmpty
                                            ? nameCtrl.text.trim()
                                            : picked!.name,
                                        fileBytes: picked!.bytes!.toList(),
                                      );
                                },
                          icon: const Icon(Icons.upload_rounded, size: 18),
                          label: const Text('بدء الرفع'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navy,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 46),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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
      ),
    );
  }

  String _typeLabel(DocumentType t) {
    switch (t) {
      case DocumentType.nationalId: return '🪪 هوية وطنية';
      case DocumentType.contract:   return '📄 عقد موثق';
      case DocumentType.check:      return '💳 شيك بنكي';
      case DocumentType.guarantee:  return '🔒 ضمان / سند';
      case DocumentType.pdf:        return '📋 ملف PDF';
      case DocumentType.image:      return '🖼️ صورة';
      default:                      return '📁 أخرى';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STATS ROW
// ═══════════════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  final List<AppDocument> docs;
  const _StatsRow({required this.docs});

  @override
  Widget build(BuildContext context) {
    final total    = docs.length;
    final pdfs     = docs.where((d) => d.name.toLowerCase().endsWith('.pdf')).length;
    final images   = docs.where((d) {
      final n = d.name.toLowerCase();
      return n.endsWith('.jpg') || n.endsWith('.jpeg') || n.endsWith('.png');
    }).length;
    final contracts = docs.where((d) => d.type == DocumentType.contract).length;

    return Row(children: [
      _StatCard(value: '$total',     label: 'إجمالي',  icon: Icons.folder_zip_outlined,      color: _navy),
      const SizedBox(width: 10),
      _StatCard(value: '$pdfs',      label: 'PDF',     icon: Icons.picture_as_pdf_rounded,   color: const Color(0xFFE53935)),
      const SizedBox(width: 10),
      _StatCard(value: '$images',    label: 'صور',     icon: Icons.image_outlined,            color: const Color(0xFF1E88E5)),
      const SizedBox(width: 10),
      _StatCard(value: '$contracts', label: 'عقود',    icon: Icons.assignment_outlined,       color: const Color(0xFF43A047)),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.icon, required this.color});

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
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  FILTER CHIPS
// ═══════════════════════════════════════════════════════════════════
class _FilterChips extends StatelessWidget {
  final List<(String, String, IconData)> filters;
  final String selected;
  final List<AppDocument> docs;
  final void Function(String) onSelect;
  const _FilterChips({required this.filters, required this.selected, required this.docs, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (key, label, icon) = filters[i];
          final count = key == 'all' ? docs.length : docs.where((d) => d.type.name.toUpperCase() == key).length;
          final isSelected = selected == key;
          return GestureDetector(
            onTap: () => onSelect(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _navy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? _navy : Colors.grey.shade200),
                boxShadow: isSelected
                    ? [BoxShadow(color: _navy.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 14, color: isSelected ? _gold : Colors.grey),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.grey.shade600)),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? _gold.withValues(alpha: 0.3) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
                        color: isSelected ? _gold : Colors.grey)),
                  ),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DOC CARD
// ═══════════════════════════════════════════════════════════════════
class _DocCard extends StatelessWidget {
  final AppDocument doc;
  final void Function(AppDocument) onView;
  final void Function(String) onCopy;
  final void Function(AppDocument) onDelete;
  const _DocCard({required this.doc, required this.onView, required this.onCopy, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final n = doc.name.toLowerCase();
    final isImg = n.endsWith('.png') || n.endsWith('.jpg') || n.endsWith('.jpeg');
    final isPdf = n.endsWith('.pdf');

    Color typeColor;
    IconData typeIcon;
    if (isImg)                            { typeColor = const Color(0xFF1E88E5); typeIcon = Icons.image_rounded; }
    else if (isPdf)                       { typeColor = const Color(0xFFE53935); typeIcon = Icons.picture_as_pdf_rounded; }
    else if (doc.type == DocumentType.nationalId) { typeColor = Colors.indigo; typeIcon = Icons.badge_outlined; }
    else if (doc.type == DocumentType.contract)   { typeColor = const Color(0xFF43A047); typeIcon = Icons.assignment_outlined; }
    else if (doc.type == DocumentType.check)      { typeColor = const Color(0xFFF57C00); typeIcon = Icons.money_outlined; }
    else                                  { typeColor = Colors.blueGrey; typeIcon = Icons.insert_drive_file_outlined; }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onView(doc),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              // أيقونة النوع
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: isImg
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(doc.documentUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(typeIcon, color: typeColor, size: 26)),
                      )
                    : Icon(typeIcon, color: typeColor, size: 26),
              ),
              const SizedBox(width: 14),

              // الاسم والتاريخ
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(doc.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _navy)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(intl.DateFormat('dd/MM/yyyy').format(doc.createdAt.toLocal()),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_typeShort(doc.type),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: typeColor)),
                    ),
                  ]),
                ]),
              ),

              // أزرار الإجراء
              Row(mainAxisSize: MainAxisSize.min, children: [
                _Btn(icon: Icons.remove_red_eye_outlined, color: Colors.blue,         onTap: () => onView(doc)),
                const SizedBox(width: 6),
                _Btn(icon: Icons.copy_rounded,            color: Colors.green,        onTap: () => onCopy(doc.documentUrl)),
                const SizedBox(width: 6),
                _Btn(icon: Icons.delete_outline_rounded,  color: AppColors.errorRed,  onTap: () => onDelete(doc)),
              ]),
            ]),
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

class _Btn extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback onTap;
  const _Btn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: color.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: 17, color: color)),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onUpload;
  const _EmptyState({required this.isFiltered, required this.onUpload});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 90, height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_navy.withValues(alpha: 0.08), _navy.withValues(alpha: 0.03)]),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Icon(Icons.folder_open_rounded, size: 48, color: _navy),
      ),
      const SizedBox(height: 18),
      Text(
        isFiltered ? 'لا توجد مستندات من هذا النوع' : 'لا توجد مستندات بعد',
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _navy),
      ),
      const SizedBox(height: 8),
      Text(
        isFiltered ? 'جرّب فلتراً آخر' : 'اضغط على "رفع مستند" لإضافة أول ملف',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
      ),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  ERROR STATE
// ═══════════════════════════════════════════════════════════════════
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.errorRed.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.cloud_off_rounded, size: 52, color: AppColors.errorRed),
      ),
      const SizedBox(height: 16),
      const Text('تعذّر تحميل المستندات', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _navy)),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('إعادة المحاولة'),
        style: ElevatedButton.styleFrom(backgroundColor: _navy, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
      ),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  UPLOAD PROGRESS DIALOG
// ═══════════════════════════════════════════════════════════════════
class _UploadProgressDialog extends ConsumerWidget {
  const _UploadProgressDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(uploadProgressProvider) ?? 0.0;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 80, height: 80,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                  value: progress >= 1.0 ? null : progress,
                  strokeWidth: 7,
                  backgroundColor: Colors.grey.shade100,
                  color: _navy,
                ),
                if (progress >= 1.0)
                  const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 44)
                else
                  Text('${(progress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: _navy)),
              ]),
            ),
            const SizedBox(height: 20),
            Text(progress >= 1.0 ? 'تم الرفع بنجاح! 🎉' : 'جاري رفع الملف...',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _navy)),
            if (progress < 1.0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress,
                  backgroundColor: Colors.grey.shade100, color: _gold,
                  borderRadius: BorderRadius.circular(10), minHeight: 6),
            ],
          ]),
        ),
      ),
    );
  }
}
