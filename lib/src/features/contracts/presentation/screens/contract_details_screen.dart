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
            length: 6,
            child: Column(
              children: [
                _buildHeader(contract),
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'نظرة عامة'),
                    Tab(text: 'جدول الأقساط'),
                    Tab(text: 'المدفوعات'),
                    Tab(text: 'جهات التمويل'),
                    Tab(text: 'سجل الأحداث'),
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
                        _PaymentsTab(contract: contract),
                        _FundingTab(contract: contract),
                        _TimelineTab(contractId: id),
                        UniversalDocumentManager(
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
    Color color;
    String label;
    switch (status) {
      case 'paid':
        color = Colors.green;
        label = 'تم السداد';
        break;
      case 'partially_paid':
        color = Colors.orange;
        label = 'مسدد جزئياً';
        break;
      case 'overdue':
        color = Colors.red.shade700;
        label = 'متأخر';
        break;
      default: // unpaid
        color = Colors.red;
        label = 'غير مسدد';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  final Contract contract;
  const _PaymentsTab({required this.contract});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(contractPaymentsProvider(contract.id));
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        if (contract.status == 'active')
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AddPaymentDialog(contract: contract),
              ),
              icon: const Icon(Icons.add_card),
              label: const Text('تسجيل دفعة مالية جديدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        Expanded(
          child: paymentsAsync.when(
            data: (list) {
              if (list.isEmpty) return const Center(child: Text('لا يوجد دفعات مستلمة بعد.'));
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final p = list[index];
                  final isReversed = p['status'] == 'reversed';
                  
                  return Card(
                    color: isReversed ? Colors.red.shade50 : null,
                    child: ListTile(
                      leading: Icon(
                        isReversed ? Icons.history : Icons.receipt_long,
                        color: isReversed ? Colors.red : Colors.green,
                      ),
                      title: Text('دفعة بمبلغ: ${p['amount_total']} ر.س'),
                      subtitle: Text('التاريخ: ${intl.DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(p['payment_date']))}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isReversed ? 'تم العكس' : 'مكتملة',
                            style: TextStyle(color: isReversed ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                          ),
                          if (!isReversed && (user?.role == UserRole.admin || user?.role == UserRole.accountant))
                            IconButton(
                              icon: const Icon(Icons.undo, color: Colors.orange),
                              tooltip: 'عكس الدفعة',
                              onPressed: () => _confirmReversal(context, ref, p['id']),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
          ),
        ),
      ],
    );
  }

  void _confirmReversal(BuildContext context, WidgetRef ref, String paymentId) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('عكس عملية الدفع',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'سيتم إلغاء أثر هذه الدفعة محاسبياً وإعادة فتح الأقساط.',
                    style: TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'سبب العكس *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'يرجى إدخال سبب العكس' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final success = await ref
                    .read(contractControllerProvider.notifier)
                    .reversePayment(
                      contract.id,
                      paymentId,
                      reasonController.text.trim(),
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'تم عكس الدفعة بنجاح'
                          : 'فشل عكس الدفعة'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('تأكيد العكس'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FundingTab extends ConsumerWidget {
  final Contract contract;
  const _FundingTab({required this.contract});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fundingAsync = ref.watch(contractFundingProvider(contract.id));

    return fundingAsync.when(
      data: (fundingList) {
        double totalFunded = 0;
        for (var f in fundingList) {
          totalFunded += (f['amount_allocated'] as num).toDouble();
        }
        final remaining = contract.principalAmount - totalFunded;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFundingHeader(totalFunded, contract.principalAmount),
              const SizedBox(height: 24),
              const Text('قائمة الممولين', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (fundingList.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('لم يتم تخصيص ممولين لهذا العقد بعد.')))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: fundingList.length,
                  itemBuilder: (context, index) {
                    final f = fundingList[index];
                    final investor = f['investors'] ?? {'full_name': 'مستثمر'};
                    final amount = (f['amount_allocated'] as num).toDouble();
                    final percent = (amount / contract.principalAmount) * 100;

                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.trending_up)),
                        title: Text(investor['full_name'] ?? 'مستثمر غير معروف'),
                        subtitle: Text('حصة التمويل: ${percent.toStringAsFixed(1)}%'),
                        trailing: Text('${intl.NumberFormat.currency(symbol: '', decimalDigits: 2).format(amount)} ر.س', 
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              if (remaining > 0) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(child: Text('يتبقى مبلغ ${intl.NumberFormat.currency(symbol: 'ر.س').format(remaining)} لاكتمال تمويل العقد.')),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ في تحميل بيانات التمويل: $e')),
    );
  }

  Widget _buildFundingHeader(double current, double target) {
    final percent = target > 0 ? (current / target) : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('حالة تمويل أصل المبلغ', style: TextStyle(color: Colors.grey)),
                Text('${(percent * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percent > 1 ? 1 : percent,
              backgroundColor: Colors.grey.shade200,
              color: percent >= 1.0 ? Colors.green : Colors.blue,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الممول: ${intl.NumberFormat.currency(symbol: 'ر.س').format(current)}', style: const TextStyle(fontSize: 12)),
                Text('المستهدف: ${intl.NumberFormat.currency(symbol: 'ر.س').format(target)}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineTab extends ConsumerWidget {
  final String contractId;
  const _TimelineTab({required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(contractTimelineProvider(contractId));

    return timelineAsync.when(
      data: (activities) {
        if (activities.isEmpty) return const Center(child: Text('لا توجد أحداث مسجلة لهذا العقد.'));
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            final isLast = index == activities.length - 1;
            
            return _buildTimelineItem(context, activity, isLast);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ في تحميل سجل الأحداث: $e')),
    );
  }

  Widget _buildTimelineItem(BuildContext context, dynamic activity, bool isLast) {
    IconData icon = Icons.info_outline;
    Color color = Colors.blue;
    String title = activity.eventType;
    String subtitle = intl.DateFormat('yyyy/MM/dd HH:mm').format(activity.occurredAt);

    switch (activity.eventType) {
      case 'CONTRACT_CREATED':
        icon = Icons.add_circle_outline;
        color = Colors.blue;
        title = 'تم إنشاء العقد';
        break;
      case 'CONTRACT_ACTIVATED':
        icon = Icons.check_circle_outline;
        color = Colors.green;
        title = 'تم تفعيل العقد';
        break;
      case 'PAYMENT_RECEIVED':
        icon = Icons.account_balance_wallet_outlined;
        color = Colors.teal;
        title = 'استلام دفعة مالية';
        subtitle += ' - مبلغ: ${activity.details['amount']} ر.س';
        break;
      case 'PAYMENT_REVERSED':
        icon = Icons.history;
        color = Colors.red;
        title = 'عكس دفعة مالية';
        subtitle += ' - سبب: ${activity.details['reason'] ?? "غير محدد"}';
        break;
      case 'FUNDING_ALLOCATED':
        icon = Icons.monetization_on_outlined;
        color = Colors.orange;
        title = 'تخصيص تمويل استثماري';
        subtitle += ' - مبلغ: ${activity.details['amount']} ر.س';
        break;
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Center(child: Icon(icon, size: 12, color: color)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
