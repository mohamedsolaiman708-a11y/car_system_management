import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../disaster_recovery_controller.dart';
import '../../../dashboard/presentation/dashboard_controller.dart';

class DisasterRecoveryScreen extends ConsumerWidget {
  const DisasterRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final integrityAsync = ref.watch(systemIntegrityStatusProvider);
    final periodsAsync = ref.watch(fiscalPeriodsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('مركز التحكم في نزاهة البيانات والفترات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                ref.invalidate(systemIntegrityStatusProvider);
                ref.invalidate(fiscalPeriodsProvider);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntegrityHeader(integrityAsync),
              const SizedBox(height: 32),
              const Text('إجراءات الحماية المتقدمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
              const SizedBox(height: 16),
              _buildActionCards(context, ref),
              const SizedBox(height: 32),
              _buildFiscalPeriodsSection(context, ref, periodsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntegrityHeader(AsyncValue<Map<String, dynamic>> integrityAsync) {
    return integrityAsync.when(
      data: (status) {
        final isHealthy = status['is_healthy'] == true;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isHealthy ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isHealthy ? Colors.green.shade100 : Colors.red.shade100),
          ),
          child: Row(
            children: [
              Icon(isHealthy ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                  size: 48, color: isHealthy ? Colors.green : Colors.red),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isHealthy ? 'حالة النظام: سليم ومستقر' : 'تنبيه: تم اكتشاف خلل في ميزان المراجعة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isHealthy ? Colors.green.shade900 : Colors.red.shade900)),
                    const SizedBox(height: 4),
                    Text(isHealthy
                        ? 'تم فحص القيود المحاسبية وأرصدة المستثمرين وجميعها متطابقة.'
                        : 'يوجد فرق مالي بين مجموع المدين والدائن بقيمة ${status['accounting_gap']} ر.س',
                        style: TextStyle(color: isHealthy ? Colors.green.shade700 : Colors.red.shade700, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('خطأ في جلب حالة النزاهة: $e'),
    );
  }

  Widget _buildActionCards(BuildContext context, WidgetRef ref) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _ActionCard(
          title: 'تجميد العمليات',
          description: 'إيقاف فوري لكافة حركات القبض والصرف والسحب.',
          icon: Icons.ac_unit_rounded,
          color: Colors.blue,
          onTap: () => _confirmAction(context, 'تجميد النظام المالي', () {
            ref.read(disasterRecoveryControllerProvider.notifier).toggleFreeze(true);
          }),
        ),
        _ActionCard(
          title: 'فحص النزاهة العميق',
          description: 'إعادة حساب كافة الأرصدة من واقع القيود اليومية.',
          icon: Icons.manage_search_rounded,
          color: Colors.purple,
          onTap: () {
            ref.read(disasterRecoveryControllerProvider.notifier).runIntegrityCheck();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بدأ الفحص الشامل في الخلفية...')));
          },
        ),
        _ActionCard(
          title: 'تحديث المؤشرات',
          description: 'تنشيط بيانات الداشبورد والرسوم البيانية.',
          icon: Icons.auto_mode_rounded,
          color: Colors.orange,
          onTap: () {
            ref.refresh(staffStatsProvider);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث إحصائيات النظام.')));
          },
        ),
      ],
    );
  }

  Widget _buildFiscalPeriodsSection(BuildContext context, WidgetRef ref, AsyncValue<List<Map<String, dynamic>>> periodsAsync) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الفترات المالية (الشهور)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showOpenPeriodDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('فتح شهر مالي جديد'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          periodsAsync.when(
            data: (periods) => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: periods.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final p = periods[index];
                final isClosed = p['is_closed'] == true;
                return ListTile(
                  leading: Icon(isClosed ? Icons.lock_outline : Icons.calendar_today,
                      color: isClosed ? Colors.red : Colors.green),
                  title: Text(p['name'] ?? 'فترة غير مسماة'),
                  subtitle: Text('من: ${p['start_date']} إلى: ${p['end_date']}'),
                  trailing: isClosed
                      ? const Text('مغلقة', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                    onPressed: () => _confirmAction(context, 'إغلاق الفترة المالية ${p['name']}', () {
                      ref.read(disasterRecoveryControllerProvider.notifier).closePeriod(p['id']);
                    }),
                    child: const Text('إغلاق الآن'),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('خطأ في تحميل الفترات: $err'),
          ),
        ],
      ),
    );
  }

  void _showOpenPeriodDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('فتح فترة مالية جديدة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الفترة (مثلاً: يوليو 2026)')),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(startDate == null ? 'اختر تاريخ البداية' : intl.DateFormat('yyyy/MM/dd').format(startDate!)),
                  trailing: const Icon(Icons.date_range),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                    if (d != null) setDialogState(() => startDate = d);
                  },
                ),
                ListTile(
                  title: Text(endDate == null ? 'اختر تاريخ النهاية' : intl.DateFormat('yyyy/MM/dd').format(endDate!)),
                  trailing: const Icon(Icons.date_range),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                    if (d != null) setDialogState(() => endDate = d);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty && startDate != null && endDate != null) {
                    final success = await ref.read(disasterRecoveryControllerProvider.notifier).openPeriod(nameController.text, startDate!, endDate!);
                    if (context.mounted && success) Navigator.pop(context);
                  }
                },
                child: const Text('تأكيد الفتح'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmAction(BuildContext context, String action, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تأكيد $action'),
          content: const Text('هل أنت متأكد؟ هذا الإجراء سيغير حالة النظام المالية وسيتم تسجيله في سجل الرقابة.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('تأكيد التنفيذ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title, description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.title, required this.description, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
