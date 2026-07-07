import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../../domain/contract.dart';
import '../contract_controller.dart';
import '../../../crm/presentation/widgets/document_manager_widget.dart';
import '../../../investors/presentation/widgets/fund_contract_dialog.dart';

class ContractDetailsScreen extends ConsumerWidget {
  final String id;
  const ContractDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(contractDetailsProvider(id));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل عقد التمويل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/contracts/$id/edit'),
          ),
        ],
      ),
      body: contractAsync.when(
        data: (contract) {
          if (contract == null) return const Center(child: Text('العقد غير موجود'));
          
          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                _buildHeader(contract),
                const TabBar(
                  tabs: [
                    Tab(text: 'نظرة عامة'),
                    Tab(text: 'جدول الأقساط'),
                    Tab(text: 'المدفوعات'),
                    Tab(text: 'المستندات'),
                  ],
                  labelColor: Colors.blue,
                  indicatorColor: Colors.blue,
                ),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TabBarView(
                      children: [
                        _OverviewTab(contract: contract),
                        _InstallmentsTab(contractId: id),
                        _PaymentsTab(contractId: id),
                        DocumentManagerWidget(
                          customerId: contract.customerId,
                          contractId: contract.id,
                        ),
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

  Widget _buildHeader(Contract contract) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.assignment, size: 40, color: Colors.blue.shade900),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عقد رقم: ${contract.contractNo}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'تاريخ العقد: ${contract.startDate != null ? intl.DateFormat('yyyy/MM/dd').format(contract.startDate!) : "غير محدد"}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          _buildStatusBadge(contract.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    String label = status;
    switch (status) {
      case 'active': color = Colors.green; label = 'نشط'; break;
      case 'draft': color = Colors.orange; label = 'مسودة'; break;
      case 'pending_funding': color = Colors.blue; label = 'بانتظار التمويل'; break;
      case 'closed': color = Colors.blueGrey; label = 'مغلق'; break;
      case 'defaulted': color = Colors.red; label = 'متعثر'; break;
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
  final Contract contract;
  const _OverviewTab({required this.contract});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = intl.NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);
    final customer = contract.customer ?? {};
    final vehicle = contract.vehicle ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (contract.status == 'draft' || contract.status == 'pending_funding')
            _buildActionAlert(context, ref),
          
          _buildInfoSection(
            title: 'بيانات العميل',
            icon: Icons.person_outline,
            children: [
              _buildInfoRow('الاسم الكامل', customer['full_name'] ?? '-'),
              _buildInfoRow('رقم الهوية', customer['national_id'] ?? '-'),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoSection(
            title: 'بيانات المركبة',
            icon: Icons.directions_car_outlined,
            children: [
              _buildInfoRow('النوع/الموديل', '${vehicle['make'] ?? ""} ${vehicle['model'] ?? ""}'),
              _buildInfoRow('اللوحة', vehicle['license_plate'] ?? 'بدون لوحة'),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoSection(
            title: 'الملخص المالي',
            icon: Icons.account_balance_wallet_outlined,
            children: [
              _buildInfoRow('المبلغ الأساسي', currency.format(contract.principalAmount)),
              _buildInfoRow('نسبة الربح', '${contract.financeProfitRate}%'),
              _buildInfoRow('إجمالي قيمة العقد', currency.format(contract.totalContractValue), isBold: true),
              _buildInfoRow('مدة التمويل', '${contract.durationMonths} شهر'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionAlert(BuildContext context, WidgetRef ref) {
    bool needsFunding = contract.status == 'draft' || contract.status == 'pending_funding';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade800),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('هذا العقد يتطلب تخصيص تمويل من المستثمرين قبل التفعيل.'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => FundContractDialog(contract: contract),
                ),
                icon: const Icon(Icons.add_card),
                label: const Text('تخصيص تمويل'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
              ),
              const SizedBox(width: 12),
              if (contract.status == 'pending_funding' || contract.status == 'draft')
                ElevatedButton(
                  onPressed: () => _activate(context, ref),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                  child: const Text('تفعيل العقد'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _activate(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التفعيل'),
        content: const Text('سيتم التحقق من اكتمال التمويل وتوليد جدول الأقساط. هل تريد الاستمرار؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('تفعيل')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(contractControllerProvider.notifier).activateContract(contract.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تفعيل العقد بنجاح')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التفعيل: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Widget _buildInfoSection({required String title, required IconData icon, required List<Widget> children}) {
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
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade800, size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}

class _InstallmentsTab extends ConsumerWidget {
  final String contractId;
  const _InstallmentsTab({required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installmentsAsync = ref.watch(contractInstallmentsProvider(contractId));

    return installmentsAsync.when(
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('لا يوجد أقساط مولدة بعد. يرجى تفعيل العقد.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final inst = list[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('تاريخ الاستحقاق: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(inst['due_date']))}'),
                subtitle: Text('المبلغ: ${inst['expected_amount']} ر.س'),
                trailing: _buildStatusBadge(inst['status']),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'paid') color = Colors.green;
    if (status == 'unpaid') color = Colors.red;
    return Text(status == 'paid' ? 'تم السداد' : 'غير مسدد', style: TextStyle(color: color, fontWeight: FontWeight.bold));
  }
}

class _PaymentsTab extends ConsumerWidget {
  final String contractId;
  const _PaymentsTab({required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(contractPaymentsProvider(contractId));

    return paymentsAsync.when(
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('لا يوجد دفعات مستلمة بعد.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final p = list[index];
            return ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.green),
              title: Text('دفعة بمبلغ: ${p['amount_total']} ر.س'),
              subtitle: Text('تاريخ الدفع: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(p['payment_date']))}'),
              trailing: const Text('مكتملة', style: TextStyle(color: Colors.green)),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }
}
