import 'package:flutter/material.dart';
import '../../../../core/utils/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          elevation: 0,
          toolbarHeight: 80,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مركز المساعدة والدعم',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('دليل الاستخدام والأسئلة الشائعة للنظام',
                  style: TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionTitle('الأسئلة الشائعة (FAQ)'),
            _buildFaqItem('كيف يتم توزيع أرباح المستثمرين؟', 'يتم التوزيع آلياً بنظام FIFO (الأول في الأول)، حيث يتم سداد أصل رأس المال ثم الأرباح بناءً على نسبة المساهمة في كل عقد.'),
            _buildFaqItem('هل يمكن عكس عملية دفع خاطئة؟', 'نعم، من خلال شاشة تفاصيل العقد -> سجل المدفوعات -> زر العكس. سيقوم النظام آلياً بتعديل القيود المحاسبية وإعادة فتح الأقساط.'),
            _buildFaqItem('كيف أضيف موظفاً جديداً؟', 'من خلال إعدادات النظام -> إدارة فريق العمل -> دعوة موظف. سيصل للموظف بريد إلكتروني لإكمال بياناته.'),
            
            const SizedBox(height: 32),
            _buildSectionTitle('دليل الاستخدام السريع'),
            _buildStepItem(1, 'تكوين ملف العميل ورفع هويته الوطنية.'),
            _buildStepItem(2, 'اختيار السيارة من المخزون أو إضافتها.'),
            _buildStepItem(3, 'إنشاء مسودة العقد وتحديد الممولين.'),
            _buildStepItem(4, 'تفعيل العقد للبدء في توليد جدول الأقساط.'),
            
            const SizedBox(height: 32),
            _buildSectionTitle('معلومات النظام'),
            _buildVersionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 8),
      child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(answer, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: AppColors.accentGold, child: Text('$step', style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 12))),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildVersionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('نسخة التطبيق', style: TextStyle(color: Colors.grey)),
              Text('1.0.0 (Stable)', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('تاريخ التحديث', style: TextStyle(color: Colors.grey)),
              Text('أكتوبر 2023', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
