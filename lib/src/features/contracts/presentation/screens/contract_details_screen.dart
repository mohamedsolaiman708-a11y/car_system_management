import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../../domain/contract.dart';
import '../contract_controller.dart';
import '../contract_timeline_controller.dart';
import '../widgets/add_payment_dialog.dart';
import '../../../documents/presentation/widgets/universal_document_manager.dart';
import '../../../investors/presentation/widgets/fund_contract_dialog.dart';
import '../../../investors/presentation/investor_controller.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../../authentication/domain/user_role.dart';
import '../../../../core/utils/app_theme.dart';

class ContractDetailsScreen extends ConsumerWidget {
  final String id;
  const ContractDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(contractDetailsProvider(id));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => context.pop(),
        ),
        title: const Text('إدارة مديونية العقد', 
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
            onPressed: () => context.push('/contracts/$id/edit'),
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
            Tab(text: 'نظرة عامة'),
            Tab(text: 'جدول الأقساط'),
            Tab(text: 'سجل المدفوعات'),
            Tab(text: 'شركاء التمويل'),
            Tab(text: 'المستندات'),
            Tab(text: 'سجل العمليات'),
          ],
        ),
      ),
      body: contractAsync.when(
        data: (contract) {
          if (contract == null) return const Center(child: Text('غير موجود'));
          return TabBarView(
            children: [
              _OverviewClassicTab(contract: contract),
              _InstallmentsClassicTab(contractId: id),
              _PaymentsClassicTab(contract: contract),
              _FundingClassicTab(contract: contract),
              Padding(padding: const EdgeInsets.all(16), child: UniversalDocumentManager(customerId: contract.customerId, contractId: contract.id)),
              _TimelineClassicTab(contractId: id),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}

class _OverviewClassicTab extends ConsumerWidget {
  final Contract contract;
  const _OverviewClassicTab({required this.contract});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (contract.status == 'draft' || contract.status == 'pending_funding')
            _buildActionAlert(context, ref),
          
          _buildInfoSection('أطراف التعاقد', [
            _buildRow('المشتري (العميل)', contract.customer?['full_name'] ?? '-'),
            _buildRow('الهوية الوطنية', contract.customer?['national_id'] ?? '-'),
          ]),
          const SizedBox(height: 12),
          _buildInfoSection('بيانات المركبة المباعة', [
            _buildRow('المركبة', '${contract.vehicle?['make'] ?? ""} ${contract.vehicle?['model'] ?? ""}'),
            _buildRow('رقم اللوحة', contract.vehicle?['license_plate'] ?? '-'),
            _buildRow('رقم الهيكل', contract.vehicle?['vin'] ?? '-'),
          ]),
          const SizedBox(height: 12),
          _buildInfoSection('البيانات المالية', [
            _buildRow('القيمة الأساسية', '${f.format(contract.principalAmount)} ر.س'),
            _buildRow('نسبة الربح', '${contract.financeProfitRate}%'),
            _buildRow('مدة التمويل', '${contract.durationMonths} شهر'),
            const Divider(),
            _buildRow('إجمالي المديونية', '${f.format(contract.totalContractValue)} ر.س', isBold: true),
          ]),
        ],
      ),
    );
  }

  Widget _buildActionAlert(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blue.shade50, border: Border.all(color: Colors.blue.shade100), borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 18),
          const SizedBox(width: 12),
          const Expanded(child: Text('بانتظار تخصيص التمويل وتفعيل العقد لتوليد الأقساط.', style: TextStyle(fontSize: 12))),
          TextButton(
            onPressed: () => showDialog(context: context, builder: (context) => FundContractDialog(contract: contract)),
            child: const Text('تخصيص تمويل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const Divider(height: 24),
        ...children,
      ]),
    );
  }

  Widget _buildRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(val, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
      ]),
    );
  }
}

class _InstallmentsClassicTab extends ConsumerWidget {
  final String contractId;
  const _InstallmentsClassicTab({required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installmentsAsync = ref.watch(contractInstallmentsProvider(contractId));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return installmentsAsync.when(
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('لا يوجد أقساط مولدة'));
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
            child: DataTable(
              headingRowHeight: 40,
              dataRowHeight: 45,
              columns: const [
                DataColumn(label: Text('#', style: TextStyle(fontSize: 12))),
                DataColumn(label: Text('تاريخ الاستحقاق', style: TextStyle(fontSize: 12))),
                DataColumn(label: Text('المبلغ', style: TextStyle(fontSize: 12))),
                DataColumn(label: Text('الحالة', style: TextStyle(fontSize: 12))),
              ],
              rows: list.asMap().entries.map((e) {
                final inst = e.value;
                return DataRow(cells: [
                  DataCell(Text('${e.key + 1}', style: const TextStyle(fontSize: 11))),
                  DataCell(Text(intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(inst['due_date'])), style: const TextStyle(fontSize: 12))),
                  DataCell(Text(f.format(inst['expected_amount']), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                  DataCell(_buildStatusBadge(inst['status'])),
                ]);
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'paid') color = Colors.green;
    else if (status == 'overdue') color = Colors.red;
    return Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold));
  }
}

class _PaymentsClassicTab extends ConsumerWidget {
  final Contract contract;
  const _PaymentsClassicTab({required this.contract});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(contractPaymentsProvider(contract.id));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Column(
      children: [
        if (contract.status == 'active')
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showDialog(context: context, builder: (context) => AddPaymentDialog(contract: contract)),
                icon: const Icon(Icons.add_card, size: 16),
                label: const Text('تسجيل تحصيل جديد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        Expanded(
          child: paymentsAsync.when(
            data: (list) {
              if (list.isEmpty) return const Center(child: Text('لا توجد دفعات مسجلة'));
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = list[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.receipt_long, color: Colors.green, size: 18),
                    title: Text('${f.format(p['amount_total'])} ر.س', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('تاريخ: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(p['payment_date']))}'),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ],
    );
  }
}

class _FundingClassicTab extends ConsumerWidget {
  final Contract contract;
  const _FundingClassicTab({required this.contract});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fundingAsync = ref.watch(contractFundingProvider(contract.id));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return fundingAsync.when(
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('لم يتم تخصيص تمويل'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
              child: ListTile(
                dense: true,
                title: Text(item['investors']?['full_name'] ?? 'مستثمر', style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('${f.format(item['amount_allocated'])} ر.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }
}

class _TimelineClassicTab extends ConsumerWidget {
  final String contractId;
  const _TimelineClassicTab({required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(contractTimelineProvider(contractId));
    return timelineAsync.when(
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('لا توجد أحداث'));
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final log = list[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.accentGold),
                  const SizedBox(width: 12),
                  Expanded(child: Text(log.eventType, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  Text(intl.DateFormat('yyyy/MM/dd').format(log.occurredAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }
}
