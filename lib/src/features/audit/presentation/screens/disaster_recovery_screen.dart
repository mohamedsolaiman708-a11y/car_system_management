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
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('أدوات الرقابة والتعافي', 
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildIntegrityStatusBar(integrityAsync),
            const SizedBox(height: 20),
            _buildClassicActionGrid(context, ref),
            const SizedBox(height: 20),
            _buildFiscalPeriodsClassic(context, ref, periodsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrityStatusBar(AsyncValue<Map<String, dynamic>> integrityAsync) {
    return integrityAsync.when(
      data: (status) {
        final isHealthy = status['is_healthy'] == true;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isHealthy ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isHealthy ? Colors.green.shade100 : Colors.red.shade100),
          ),
          child: Row(
            children: [
              Icon(isHealthy ? Icons.verified_user : Icons.gpp_maybe, 
                   size: 20, color: isHealthy ? Colors.green : Colors.red),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  isHealthy ? 'تكامل البيانات: كافة الحسابات والقيود متطابقة' : 'تنبيه: تم رصد فجوة محاسبية في ميزان المراجعة',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isHealthy ? Colors.green.shade900 : Colors.red.shade900),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildClassicActionGrid(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _buildActionBtn(context, 'تجميد مالي', Icons.ac_unit, Colors.blue, () {}),
        const SizedBox(width: 12),
        _buildActionBtn(context, 'فحص عميق', Icons.manage_search, Colors.purple, () {}),
        const SizedBox(width: 12),
        _buildActionBtn(context, 'تحديث يدوي', Icons.sync, Colors.orange, () {
          ref.refresh(staffStatsProvider);
        }),
      ],
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiscalPeriodsClassic(BuildContext context, WidgetRef ref, AsyncValue<List<Map<String, dynamic>>> periodsAsync) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الفترات المالية والمحاسبية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                OutlinedButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.add, size: 14), 
                  label: const Text('فتح شهر مالي', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          periodsAsync.when(
            data: (periods) => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: periods.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = periods[index];
                final isClosed = p['is_closed'] == true;
                return ListTile(
                  dense: true,
                  leading: Icon(isClosed ? Icons.lock_outline : Icons.calendar_today, 
                               size: 16, color: isClosed ? Colors.red : Colors.green),
                  title: Text(p['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('المدة: ${p['start_date']} الى ${p['end_date']}', style: const TextStyle(fontSize: 11)),
                  trailing: isClosed 
                    ? const Text('مغلقة', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold))
                    : TextButton(onPressed: () {}, child: const Text('إغلاق الفترة', style: TextStyle(fontSize: 11))),
                );
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}
