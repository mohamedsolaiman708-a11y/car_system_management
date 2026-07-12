import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../../domain/customer.dart';
import '../crm_controller.dart';
import '../../../documents/presentation/widgets/universal_document_manager.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  final String id;
  const CustomerDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerDetailsProvider(id));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => context.pop(),
        ),
        title: const Text('ملف العميل التفصيلي', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
            onPressed: () => context.push('/crm/customers/$id/edit'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const TabBar(
          isScrollable: true,
          labelColor: AppColors.primaryNavy,
          indicatorColor: AppColors.primaryNavy,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: 'المعلومات العامة'),
            Tab(text: 'سجل العقود'),
            Tab(text: 'المدفوعات'),
            Tab(text: 'المستندات'),
            Tab(text: 'النشاط'),
          ],
        ),
      ),
      body: customerAsync.when(
        data: (customer) {
          if (customer == null) return const Center(child: Text('غير موجود'));
          return DefaultTabController(
            length: 5,
            child: TabBarView(
              children: [
                _OverviewClassicTab(customer: customer),
                _ContractsClassicTab(customerId: id),
                _PaymentsClassicTab(customerId: id),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: UniversalDocumentManager(customerId: id),
                ),
                _TimelineClassicTab(customerId: id),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}

class _OverviewClassicTab extends StatelessWidget {
  final Customer customer;
  const _OverviewClassicTab({required this.customer});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoSection('البيانات الشخصية', [
            _buildRow('الاسم الكامل', customer.fullName),
            _buildRow('رقم الهوية', customer.nationalId),
            _buildRow('رقم الجوال', customer.phone),
            _buildRow('البريد الإلكتروني', customer.email ?? '-'),
          ]),
          const SizedBox(height: 16),
          _buildInfoSection('بيانات العمل والدخل', [
            _buildRow('جهة العمل', customer.kycData['employer'] ?? '-'),
            _buildRow('الراتب الشهري', '${customer.kycData['salary'] ?? 0} ر.س'),
            _buildRow('المسمى الوظيفي', customer.kycData['job_title'] ?? '-'),
          ]),
          const SizedBox(height: 16),
          _buildInfoSection('التقييم الائتماني', [
            _buildRow('درجة المخاطر', _getRiskLabel(customer.riskRating)),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _getRiskLabel(String risk) {
    if (risk == 'low') return 'منخفضة';
    if (risk == 'high') return 'عالية';
    return 'متوسطة';
  }
}

class _ContractsClassicTab extends ConsumerWidget {
  final String customerId;
  const _ContractsClassicTab({required this.customerId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(customerContractsProvider(customerId));
    return contractsAsync.when(
      data: (list) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final c = list[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
            child: ListTile(
              dense: true,
              title: Text('عقد رقم: ${c['contract_no']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('القيمة: ${c['total_contract_value']} ر.س', style: const TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () => context.push('/contracts/${c['id']}'),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('خطأ في جلب العقود'),
    );
  }
}

class _PaymentsClassicTab extends ConsumerWidget {
  final String customerId;
  const _PaymentsClassicTab({required this.customerId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(customerPaymentsProvider(customerId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    
    return paymentsAsync.when(
      data: (list) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final p = list[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle, color: Colors.green, size: 16),
              title: Text('${f.format(p['amount_total'])} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('تاريخ: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(p['created_at']))}', style: const TextStyle(fontSize: 11)),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('خطأ في جلب المدفوعات'),
    );
  }
}

class _TimelineClassicTab extends ConsumerWidget {
  final String customerId;
  const _TimelineClassicTab({required this.customerId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(customerTimelineProvider(customerId));
    return timelineAsync.when(
      data: (logs) => ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.accentGold),
                const SizedBox(width: 12),
                Expanded(child: Text(log['event_type'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                Text(intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(log['created_at'])), style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }
}
