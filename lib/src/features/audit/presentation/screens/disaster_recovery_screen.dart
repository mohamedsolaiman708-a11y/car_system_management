import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../disaster_recovery_controller.dart';

class DisasterRecoveryScreen extends ConsumerWidget {
  const DisasterRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(disasterRecoveryControllerProvider);
    final freezeAsync = ref.watch(systemFreezeStatusProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مركز التعافي والنزاهة المالية'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(disasterRecoveryControllerProvider.notifier).refresh(),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFreezeAlert(context, ref, freezeAsync),
            _buildActionHeader(context, ref),
            const Divider(),
            Expanded(
              child: historyAsync.when(
                data: (history) => _buildHistoryList(context, history),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('خطأ: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreezeAlert(BuildContext context, WidgetRef ref, AsyncValue<bool> freezeAsync) {
    return freezeAsync.when(
      data: (isFrozen) => isFrozen 
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.red.shade900,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.ac_unit, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'النظام المالي مجمد حالياً - كافة العمليات الحساسة متوقفة',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _confirmToggleFreeze(context, ref, false),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red.shade900),
                  child: const Text('إلغاء التجميد'),
                ),
              ],
            ),
          )
        : const SizedBox.shrink(),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildActionHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.health_and_safety_rounded, size: 48, color: Colors.blue),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أدوات صيانة البيانات',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'قم بإجراء فحص دوري للتأكد من توازن الحسابات وإصلاح أي فروقات.',
                      style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _runCheck(context, ref),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('بدء فحص النزاهة'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _confirmToggleFreeze(context, ref, true),
                    icon: const Icon(Icons.lock_outline_rounded),
                    label: const Text('تجميد العمليات'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _confirmRepair(context, ref),
                icon: const Icon(Icons.auto_fix_high_rounded),
                label: const Text('إصلاح أرصدة المستثمرين تلقائياً'),
                style: TextButton.styleFrom(foregroundColor: Colors.orange.shade900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<Map<String, dynamic>> history) {
    if (history.isEmpty) return const Center(child: Text('لا توجد سجلات فحص سابقة.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final isHealthy = item['is_healthy'] == true;
        final date = DateTime.parse(item['check_date']);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Icon(
              isHealthy ? Icons.check_circle : Icons.warning_amber_rounded,
              color: isHealthy ? Colors.green : Colors.red,
            ),
            title: Text(isHealthy ? 'النظام سليم ومتزن' : 'تم اكتشاف خلل في التوازن'),
            subtitle: Text(intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(date)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildMetricRow('فرق التوازن المحاسبي:', '${item['accounting_imbalance'] ?? 0} ر.س'),
                    _buildMetricRow('فرق أرصدة المستثمرين:', '${item['investor_imbalance'] ?? 0} ر.س'),
                    if (item['issues_found'] != null) ...[
                      const Divider(),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text('التفاصيل الفنية:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text(item['issues_found'].toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricRow(String label, String value) {
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

  Future<void> _runCheck(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري فحص نزاهة البيانات...')));
    await ref.read(disasterRecoveryControllerProvider.notifier).runIntegrityCheck();
  }

  Future<void> _confirmToggleFreeze(BuildContext context, WidgetRef ref, bool isFrozen) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isFrozen ? 'تجميد العمليات المالية' : 'إلغاء التجميد'),
        content: Text(isFrozen 
          ? 'هل أنت متأكد؟ سيؤدي هذا لإيقاف كافة عمليات الدفع والسحب في النظام فوراً.'
          : 'هل تريد إعادة تفعيل العمليات المالية؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: isFrozen ? Colors.red : Colors.green),
            child: Text(isFrozen ? 'تجميد الآن' : 'إعادة التفعيل'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(disasterRecoveryControllerProvider.notifier).toggleFreeze(isFrozen);
    }
  }

  Future<void> _confirmRepair(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إصلاح أرصدة المستثمرين'),
        content: const Text('سيقوم النظام بإعادة حساب كافة أرصدة المستثمرين بناءً على سجلات العمليات الفعلية. هل تريد الاستمرار؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('بدء الإصلاح'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(disasterRecoveryControllerProvider.notifier).repairBalances();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'تمت عملية الإصلاح بنجاح' : 'فشلت عملية الإصلاح'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
