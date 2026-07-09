import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مركز المساعدة والدعم'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('الأسئلة الشائعة (FAQ)'),
            _buildFaqItem(
              'كيف يمكنني إضافة مستثمر جديد؟',
              'يمكنك إضافة مستثمر من خلال شاشة "إدارة المستثمرين" ثم الضغط على زر "إضافة مستثمر". سيحتاج المستثمر بعدها إلى تفعيل حسابه من قبل المسؤول.',
            ),
            _buildFaqItem(
              'كيف يتم توزيع الأرباح؟',
              'يتم توزيع الأرباح تلقائياً عند استلام دفعات من العملاء بناءً على نسبة الاستثمار المخصصة لكل مستثمر في العقد.',
            ),
            _buildFaqItem(
              'ماذا أفعل في حالة تعثر العميل؟',
              'يمكنك تغيير حالة العقد إلى "متعثر" من شاشة تفاصيل العقد، وسيظهر ذلك في تقرير المتأخرات للمتابعة القانونية.',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('دليل المستخدم'),
            _buildGuideItem(Icons.menu_book_outlined, 'دليل إدارة العقود', 'شرح تفصيلي لدورة حياة العقد من الإنشاء حتى الإغلاق.'),
            _buildGuideItem(Icons.account_balance_outlined, 'الدليل المالي والمحاسبي', 'شرح كيفية قراءة التقارير المالية والقيود اليومية.'),
            const SizedBox(height: 24),
            _buildSectionHeader('الدعم الفني'),
            _buildContactItem(Icons.support_agent, 'تحدث مع الدعم الفني', 'متاح من 9 صباحاً حتى 5 مساءً'),
            _buildContactItem(Icons.email_outlined, 'ارسل بريد إلكتروني', 'support@carerp.com'),
            const SizedBox(height: 24),
            _buildSectionHeader('معلومات النظام'),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _InfoRow(label: 'إصدار النظام', value: '1.0.0'),
                    Divider(),
                    _InfoRow(label: 'آخر تحديث', value: '2023-10-27'),
                    Divider(),
                    _InfoRow(label: 'بيئة العمل', value: 'Production'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(IconData icon, String title, String subtitle) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {},
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
