import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_theme.dart';
import '../widgets/universal_document_manager.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── الهيدر ──────────────────────────────────────────────
            _buildHeader(),
            const SizedBox(height: 20),

            // ── مركز المستندات (يملأ الشاشة) ────────────────────────
            const Expanded(
              child: UniversalDocumentManager(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // الخط الذهبي
        Container(
          width: 5,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accentGold, Color(0xFFE5C17E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 14),

        // العنوان
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مركز المستندات',
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'إدارة وأرشفة الوثائق والمستندات الرسمية',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // أيقونة ديكور
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: const Icon(
            Icons.folder_special_rounded,
            color: AppColors.accentGold,
            size: 24,
          ),
        ),
      ],
    );
  }
}
