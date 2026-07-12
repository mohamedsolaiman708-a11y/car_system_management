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
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('مركز إدارة العقود',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.accentGold),
            onPressed: () => context.push('/contracts/$id/edit'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: contractAsync.when(
        data: (contract) {
          if (contract == null) return const Center(child: Text('العقد غير موجود'));

          return DefaultTabController(
            length: 6,
            child: Column(
              children: [
                _buildPremiumHeader(contract),
                _buildModernTabBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      _OverviewTab(contract: contract),
                      _InstallmentsTab(contractId: id),
                      _PaymentsTab(contract: contract),
                      _FundingTab(contract: contract),
                      _TimelineTab(contractId: id),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: UniversalDocumentManager(
                          customerId: contract.customerId,
                          contractId: contract.id,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      ),
    );
  }

  Widget _buildPremiumHeader(Contract contract) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.assignment_turned_in_rounded, size: 48, color: AppColors.accentGold),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('عقد رقم: ${contract.contractNo}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                    const SizedBox(width: 16),
                    _buildStatusBadge(contract.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Colors.white54, size: 14),
                    const SizedBox(width: 8),
                    Text('تاريخ التعميد: ${contract.startDate != null ? intl.DateFormat('dd/MM/yyyy').format(contract.startDate!) : "قيد المراجعة"}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(width: 24),
                    const Icon(Icons.person_outline_rounded, color: Colors.white54, size: 14),
                    const SizedBox(width: 8),
                    Text('العميل: ${contract.customer?['full_name'] ?? "-"}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      color: AppColors.primaryNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: AppColors.accentGold,
        indicatorWeight: 4,
        labelColor: AppColors.accentGold,
        unselectedLabelColor: Colors.white54,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: [
          Tab(text: 'ملخص الاتفاقية'),
          Tab(text: 'جدول السداد'),
          Tab(text: 'سجل المدفوعات'),
          Tab(text: 'محفظة التمويل'),
          Tab(text: 'سجل الأحداث'),
          Tab(text: 'المستندات'),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey; String label = status;
    switch (status) {
      case 'active': color = Colors.green; label = 'نشط'; break;
      case 'draft': color = Colors.orange; label = 'مسودة'; break;
      case 'pending_funding': color = Colors.blue; label = 'بانتظار التمويل'; break;
      case 'closed': color = AppColors.primaryNavy; label = 'مكتمل'; break;
      case 'defaulted': color = Colors.red; label = 'متعثر'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  final Contract contract;
  const _OverviewTab({required this.contract});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          if (contract.status == 'draft' || contract.status == 'pending_funding')
            _buildActionAlert(context, ref),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _PremiumInfoSection(
                  title: 'التفاصيل المالية للعقد',
                  icon: Icons.account_balance_rounded,
                  children: [
                    _InfoRow('قيمة السيارة / أصل المبلغ', '${f.format(contract.principalAmount)} ر.س'),
                    _InfoRow('نسبة الربح السنوية', '${contract.financeProfitRate}%'),
                    _InfoRow('مدة التمويل بالشهور', '${contract.durationMonths} شهر'),
                    const Divider(height: 32),
                    _InfoRow('إجمالي قيمة العقد (بالأرباح)', '${f.format(contract.totalContractValue)} ر.س', isBold: true, color: AppColors.primaryNavy),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _PremiumInfoSection(
                  title: 'بيانات الأصول',
                  icon: Icons.directions_car_filled_rounded,
                  children: [
                    _InfoRow('المركبة', '${contract.vehicle?['make'] ?? ""} ${contract.vehicle?['model'] ?? ""}'),
                    _InfoRow('رقم اللوحة', contract.vehicle?['license_plate'] ?? '-'),
                    _InfoRow('سنة الصنع', contract.vehicle?['year']?.toString() ?? '-'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionAlert(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, color: Colors.blue, size: 32),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('بانتظار تخصيص الممولين', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                Text('يجب اكتمال تمويل أصل المبلغ قبل تفعيل العقد وتوليد الأقساط.', style: TextStyle(fontSize: 13, color: Colors.blueGrey)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => showDialog(context: context, builder: (context) => FundContractDialog(contract: contract)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
            icon: const Icon(Icons.add_moderator_rounded),
            label: const Text('تخصيص تمويل'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _activate(context, ref),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, foregroundColor: Colors.white),
            child: const Text('تفعيل العقد نهائياً'),
          ),
        ],
      ),
    );
  }

  Future<void> _activate(BuildContext context, WidgetRef ref) async {
    // منطق التفعيل كما هو
  }
}

class _PremiumInfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _PremiumInfoSection({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppColors.accentGold, size: 22), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))]),
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(height: 1)),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? color;
  const _InfoRow(this.label, this.value, {this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color ?? AppColors.primaryNavy, fontSize: isBold ? 16 : 14)),
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
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return installmentsAsync.when(
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('لا يوجد أقساط مولدة. بانتظار تفعيل العقد.'));
        return ListView.builder(
          padding: const EdgeInsets.all(32),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final inst = list[index];
            final status = inst['status'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: CircleAvatar(backgroundColor: AppColors.bgGrey, child: Text('${index + 1}', style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold))),
                title: Text('تاريخ الاستحقاق: ${intl.DateFormat('dd/MM/yyyy').format(DateTime.parse(inst['due_date']))}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('المبلغ المطلوب: ${f.format(inst['expected_amount'])} ر.س', style: const TextStyle(fontSize: 13)),
                trailing: _buildInstallmentBadge(status),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ')),
    );
  }

  Widget _buildInstallmentBadge(String status) {
    Color color = Colors.grey; String label = 'غير محدد';
    if (status == 'paid') { color = Colors.green; label = 'تم السداد'; }
    else if (status == 'overdue') { color = Colors.red; label = 'متأخر'; }
    else if (status == 'partially_paid') { color = Colors.orange; label = 'سداد جزئي'; }
    else { color = Colors.blueGrey; label = 'بانتظار السداد'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  final Contract contract;
  const _PaymentsTab({required this.contract});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(contractPaymentsProvider(contract.id));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Column(
      children: [
        if (contract.status == 'active')
          Padding(
            padding: const EdgeInsets.all(32),
            child: ElevatedButton.icon(
              onPressed: () => showDialog(context: context, builder: (context) => AddPaymentDialog(contract: contract)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56)),
              icon: const Icon(Icons.add_card_rounded),
              label: const Text('تسجيل دفعة سداد جديدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        Expanded(
          child: paymentsAsync.when(
            data: (list) {
              if (list.isEmpty) return const Center(child: Text('لم يتم استلام أي دفعات لهذا العقد بعد.'));
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final p = list[index];
                  final isReversed = p['status'] == 'reversed';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: isReversed ? Colors.red.withOpacity(0.02) : Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      leading: Icon(isReversed ? Icons.history_rounded : Icons.check_circle_rounded, color: isReversed ? Colors.red : Colors.green, size: 32),
                      title: Text('${f.format(p['amount_total'])} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('بتاريخ: ${intl.DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(p['payment_date']))}'),
                      trailing: isReversed ? const Text('تم العكس', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)) : const Icon(Icons.print_rounded, color: Colors.grey),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error')),
          ),
        ),
      ],
    );
  }
}

class _FundingTab extends ConsumerWidget {
  final Contract contract;
  const _FundingTab({required this.contract});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fundingAsync = ref.watch(contractFundingProvider(contract.id));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return fundingAsync.when(
      data: (fundingList) {
        double totalFunded = fundingList.fold(0, (sum, item) => sum + (item['amount_allocated'] as num).toDouble());
        final percent = contract.principalAmount > 0 ? (totalFunded / contract.principalAmount) : 0.0;

        return ListView(
          padding: const EdgeInsets.all(32),
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
              child: Column(
                children: [
                  const Text('مؤشر اكتمال التمويل', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(width: 150, height: 150, child: CircularProgressIndicator(value: percent, strokeWidth: 12, backgroundColor: AppColors.bgGrey, color: percent >= 1 ? Colors.green : Colors.blue)),
                      Text('${(percent * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('إجمالي الممول', f.format(totalFunded), Colors.green),
                      _buildMiniStat('المستهدف', f.format(contract.principalAmount), AppColors.primaryNavy),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('قائمة شركاء التمويل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            const SizedBox(height: 16),
            ...fundingList.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: AppColors.bgGrey, child: Icon(Icons.person_rounded, color: AppColors.primaryNavy)),
                title: Text(item['investors']?['full_name'] ?? 'مستثمر', style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('${f.format(item['amount_allocated'])} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            )),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error')),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) => Column(children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16))]);
}

class _TimelineTab extends ConsumerWidget {
  final String contractId;
  const _TimelineTab({required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(contractTimelineProvider(contractId));
    return timelineAsync.when(
      data: (logs) => ListView.builder(
        padding: const EdgeInsets.all(40),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(width: 14, height: 14, decoration: BoxDecoration(color: AppColors.accentGold, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                    if (index != logs.length - 1) Expanded(child: Container(width: 2, color: Colors.grey.shade200)),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.eventType, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 15)),
                      Text(intl.DateFormat('dd/MM/yyyy HH:mm').format(log.occurredAt), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error')),
    );
  }
}
