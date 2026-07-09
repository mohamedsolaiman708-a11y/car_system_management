import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(
        title: const Text('تفاصيل العميل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/crm/customers/$id/edit'),
          ),
        ],
      ),
      body: customerAsync.when(
        data: (customer) {
          if (customer == null) return const Center(child: Text('العميل غير موجود'));
          
          return DefaultTabController(
            length: 5,
            child: Column(
              children: [
                _buildHeader(customer),
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'نظرة عامة'),
                    Tab(text: 'العقود'),
                    Tab(text: 'المدفوعات'),
                    Tab(text: 'المستندات'),
                    Tab(text: 'السجل والنشاط'),
                  ],
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                ),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TabBarView(
                      children: [
                        _OverviewTab(customer: customer),
                        _ContractsTab(customerId: id),
                        _PaymentsTab(customerId: id),
                        UniversalDocumentManager(customerId: id), // Updated to Universal Manager
                        _TimelineTab(customerId: id),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      ),
    );
  }

  Widget _buildHeader(Customer customer) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              customer.fullName.substring(0, 1),
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.fullName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTag(customer.nationalId, Icons.badge_outlined),
                    const SizedBox(width: 16),
                    _buildTag(customer.phone, Icons.phone_outlined),
                  ],
                ),
              ],
            ),
          ),
          _buildRiskBadge(customer.riskRating),
        ],
      ),
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.blueGrey)),
      ],
    );
  }

  Widget _buildRiskBadge(String risk) {
    Color color = Colors.orange;
    String label = 'متوسط المخاطر';
    if (risk == 'low') {
      color = Colors.green;
      label = 'منخفض المخاطر';
    } else if (risk == 'high') {
      color = Colors.red;
      label = 'عالي المخاطر';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  final Customer customer;
  const _OverviewTab({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(customerFinancialSummaryProvider(customer.id));
    final kyc = customer.kycData;
    final guarantor = kyc['guarantor'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryAsync.when(
            data: (summary) => _buildFinancialSummary(summary),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            title: 'المعلومات الشخصية والعمل',
            children: [
              _buildInfoRow('البريد الإلكتروني', customer.email ?? '-'),
              _buildInfoRow('العنوان', customer.address ?? '-'),
              _buildInfoRow('جهة العمل', kyc['employer']?.toString() ?? '-'),
              _buildInfoRow('المسمى الوظيفي', kyc['job_title']?.toString() ?? '-'),
              _buildInfoRow('الراتب الشهري', '${kyc['salary'] ?? 0} ر.س'),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            title: 'بيانات الضامن',
            children: [
              _buildInfoRow('اسم الضامن', guarantor['name']?.toString() ?? '-'),
              _buildInfoRow('هاتف الضامن', guarantor['phone']?.toString() ?? '-'),
              _buildInfoRow('صلة القرابة', guarantor['relationship']?.toString() ?? '-'),
            ],
          ),
          const SizedBox(height: 24),
          if (kyc['notes'] != null && kyc['notes'].toString().isNotEmpty)
            _buildInfoSection(
              title: 'ملاحظات',
              children: [
                Text(kyc['notes'].toString(), style: const TextStyle(height: 1.5)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(Map<String, dynamic> summary) {
    return Row(
      children: [
        _buildStatBox('إجمالي العقود', summary['total_contracts'].toString(), Colors.blue),
        const SizedBox(width: 16),
        _buildStatBox('الرصيد المتبقي', '${summary['outstanding_balance']} ر.س', Colors.red),
        const SizedBox(width: 16),
        _buildStatBox('المبالغ المحصلة', '${summary['total_paid']} ر.س', Colors.green),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ContractsTab extends ConsumerWidget {
  final String customerId;
  const _ContractsTab({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(customerContractsProvider(customerId));
    return contractsAsync.when(
      data: (contracts) => ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final contract = contracts[index];
          return Card(
            child: ListTile(
              title: Text('عقد رقم: ${contract['contract_no']}'),
              subtitle: Text('الحالة: ${contract['status']}'),
              onTap: () => context.push('/contracts/${contract['id']}'),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  final String customerId;
  const _PaymentsTab({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(customerPaymentsProvider(customerId));
    return paymentsAsync.when(
      data: (payments) => ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final p = payments[index];
          return ListTile(
            title: Text('مبلغ: ${p['amount_total']} ر.س'),
            subtitle: Text('التاريخ: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(p['created_at']))}'),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }
}

class _TimelineTab extends ConsumerWidget {
  final String customerId;
  const _TimelineTab({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(customerTimelineProvider(customerId));
    return timelineAsync.when(
      data: (logs) => ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(log['event_type']),
            subtitle: Text(intl.DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(log['created_at']))),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }
}
