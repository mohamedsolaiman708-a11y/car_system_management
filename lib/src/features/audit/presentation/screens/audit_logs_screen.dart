import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../data/supabase_audit_repository.dart';
import '../../domain/audit_log.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        toolbarHeight: 90,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('سجل الرقابة والنشاط',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('تتبع دقيق لكافة العمليات المالية والإدارية',
                style: TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => ref.invalidate(auditLogsListProvider),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: logsAsync.when(
        data: (logs) => logs.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            return _EliteAuditLogCard(log: logs[index]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (err, _) => Center(child: Text('خطأ في تحميل السجلات: $err')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('لا توجد سجلات حالياً', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}

class _EliteAuditLogCard extends StatelessWidget {
  final AuditLog log;
  const _EliteAuditLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final eventType = log.eventType;
    final staffName = log.profile?['full_name'] ?? 'نظام آلي';
    
    // استخراج اسم المستثمر بأسلوب "بريميوم"
    final String? investorName = log.newValues?['المستثمر'] ?? 
                                 log.newValues?['investor'] ?? 
                                 log.newValues?['للمستثمر'] ??
                                 log.newValues?['investor_name'];

    Color statusColor;
    IconData icon;

    if (eventType.contains('CREATED') || eventType.contains('DEPOSIT')) {
      statusColor = const Color(0xFF4CAF50);
      icon = Icons.add_circle_rounded;
    } else if (eventType.contains('UPDATED')) {
      statusColor = const Color(0xFF2196F3);
      icon = Icons.edit_rounded;
    } else if (eventType.contains('DELETED') || eventType.contains('WITHDRAWAL')) {
      statusColor = const Color(0xFFF44336);
      icon = Icons.remove_circle_rounded;
    } else {
      statusColor = AppColors.primaryNavy;
      icon = Icons.info_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        onTap: () => _showLogDetails(context, log),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_formatEventType(eventType),
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: statusColor, letterSpacing: 0.5)),
                        const Spacer(),
                        if (investorName != null) _buildInvestorBadge(investorName),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (investorName == null)
                      const Text('إجراء نظام عام', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500))
                    else
                      Text(investorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_pin_rounded, size: 12, color: Colors.grey.withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Text('المنفذ: $staffName', 
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(intl.DateFormat('dd/MM/yyyy').format(log.createdAt),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                  Text(intl.DateFormat('HH:mm').format(log.createdAt),
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 12),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvestorBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentGold.withValues(alpha: 0.2), AppColors.accentGold.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 12, color: AppColors.primaryNavy),
          const SizedBox(width: 4),
          Text(name, 
            style: const TextStyle(fontSize: 10, color: AppColors.primaryNavy, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  String _formatEventType(String type) {
    return type
        .replaceAll('_', ' ')
        .replaceAll('CREATED', 'إضافة')
        .replaceAll('UPDATED', 'تحديث')
        .replaceAll('DELETED', 'حذف')
        .replaceAll('CONTRACT', 'عقد')
        .replaceAll('CUSTOMER', 'عميل')
        .replaceAll('VEHICLE', 'سيارة')
        .replaceAll('PAYMENT', 'عملية دفع')
        .replaceAll('INVESTOR DEPOSIT', 'إيداع مالي')
        .replaceAll('INVESTOR WITHDRAWAL', 'سحب مالي')
        .replaceAll('PROFIT DISTRIBUTION', 'توزيع أرباح');
  }

  void _showLogDetails(BuildContext context, AuditLog log) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.analytics_rounded, color: AppColors.primaryNavy, size: 24),
                    SizedBox(width: 12),
                    Text('تفاصيل العملية الرقابية', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
                  ],
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    child: _buildDetailsList(log.newValues ?? {}),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsList(Map<String, dynamic> values) {
    // تصفية الـ ID تماماً إذا كان الاسم موجوداً ليكون الشكل "لطيف" ونظيف
    final hasProperName = values.containsKey('المستثمر') || values.containsKey('investor') || values.containsKey('للمستثمر');
    
    final entries = values.entries.where((e) {
      if (e.key.toLowerCase().contains('id') && hasProperName) return false; 
      if (e.key == 'recorded_by_name' || e.key == 'performed_by' || e.key == 'الموظف المسؤول') return false; 
      return true;
    }).toList();

    return Column(
      children: entries.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FD),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_translateKey(e.key), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(width: 16),
            Expanded(
              child: Text('${e.value}', 
                textAlign: TextAlign.left,
                style: const TextStyle(color: AppColors.primaryNavy, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace')
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  String _translateKey(String key) {
    switch (key.toLowerCase()) {
      case 'amount': return 'المبلغ';
      case 'المبلغ': return 'المبلغ';
      case 'description': return 'البيان';
      case 'البيان': return 'البيان';
      case 'investor': return 'المستثمر';
      case 'المستثمر': return 'المستثمر';
      case 'للمستثمر': return 'المستثمر';
      case 'status': return 'الحالة';
      case 'balance_after': return 'الرصيد المحدث';
      default: return key;
    }
  }
}
