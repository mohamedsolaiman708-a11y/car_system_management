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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // هيدر تعريفي فخم
            _buildPremiumHeader(),
            
            const SizedBox(height: 16),

            // مدير المستندات الشامل
            const Expanded(
              child: UniversalDocumentManager(), // يعرض كافة مستندات النظام
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Row(
        children: [
          // المؤشر الذهبي (Saudi Signature)
          Container(
            width: 6,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentGold, Color(0xFFE5C17E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(2, 0),
                )
              ],
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المستندات والمرفقات العامة',
                  style: TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'مراجعة ورقابة كافة الوثائق الحكومية، العقود، والضمانات البنكية المرفوعة',
                  style: TextStyle(
                    fontSize: 13, 
                    color: AppColors.textGrey, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // أيقونة إحصائية سريعة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.accentGold),
          ),
        ],
      );
  }
}
