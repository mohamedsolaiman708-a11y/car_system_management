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
import '../../../accounting/presentation/accounting_controller.dart';
import '../../../../core/utils/app_theme.dart';

class ContractDetailsScreen extends ConsumerWidget {
  final String id;
  const ContractDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مراقبة حالة الـ Controller بشكل مركزي لإظهار الرسائل
    ref.listen<AsyncValue<void>>(
      contractControllerProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $error'), backgroundColor: Colors.red),
          ),
          data: (_) {
            if (previous?.isLoading == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تمت العملية بنجاح')),
              );
            }
          },
        );
      },
    );

    final contractAsync = ref.watch(contractDetailsProvider(id));

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        toolbarHeight: 50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('مركز إدارة العقود',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.accentGold),
            onPressed: () => context.push('/contracts/$id/edit'),
          ),
        ],
      ),
      body: contractAsync.when(
        data: (contract) {
          if (contract == null) return const Center(child: Text('العقد غير موجود'));

          return DefaultTabController(
            length: 7,
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
                      _AccountingTab(contractId: id),
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
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.assignment_turned_in_rounded, size: 36, color: AppColors.accentGold),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('عقد رقم: ${contract.contractNo}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 12),
                    _buildStatusBadge(contract.status),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Colors.white54, size: 12),
                    const SizedBox(width: 6),
                    Text('تاريخ التعميد: ${contract.startDate != null ? intl.DateFormat('dd/MM/yyyy').format(contract.startDate!) : "قيد المراجعة"}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(width: 20),
                    const Icon(Icons.person_outline_rounded, color: Colors.white54, size: 12),
                    const SizedBox(width: 6),
                    Text('العميل: ${contract.customer?['full_name'] ?? "-"}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
        indicatorWeight: 3,
        labelColor: AppColors.accentGold,
        unselectedLabelColor: Colors.white54,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs: [
          Tab(text: 'ملخص الاتفاقية'),
          Tab(text: 'جدول السداد'),
          Tab(text: 'سجل المدفوعات'),
          Tab(text: 'محفظة التمويل'),
          Tab(text: 'القيود المحاسبية'),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  final Contract contract;
  const _OverviewTab({required this.contract});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installmentsAsync = ref.watch(contractInstallmentsProvider(contract.id));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _PremiumInfoSection(
              title: 'التفاصيل المالية للعقد',
              icon: Icons.account_balance_rounded,
              children: [
                _InfoRow('قيمة السيارة (الأصل)', '${f.format(contract.principalAmount)} ر.س'),
                _InfoRow('نسبة الربح السنوية', '${contract.financeProfitRate}%'),
                _InfoRow('مدة التمويل بالشهور', '${contract.durationMonths} شهر'),
                const Divider(height: 24),
                _InfoRow('الرسوم الإدارية والضريبة', '${f.format(contract.moroorFees + contract.tammFees + contract.insuranceFees + contract.vatAmount)} ر.س'),
                _InfoRow('إجمالي قيمة مديونية العقد', '${f.format(contract.totalContractValue)} ر.س'),
                
                installmentsAsync.when(
                  data: (list) {
                    final paid = list.where((i) => i['status'] == 'paid').fold(0.0, (sum, i) => sum + (i['expected_amount'] as num).toDouble());
                    final remaining = contract.totalContractValue - paid;
                    return Column(
                      children: [
                        const Divider(height: 24),
                        _InfoRow('المبلغ المتبقي للسداد', '${f.format(remaining)} ر.س', isBold: true, color: Colors.red.shade700),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _PremiumInfoSection(
              title: 'بيانات الأصول',
              icon: Icons.directions_car_filled_rounded,
              children: [
                _InfoRow('المركبة', '${contract.vehicle?['make'] ?? ""} ${contract.vehicle?['model'] ?? ""}'),
                _InfoRow('رقم اللوحة', contract.vehicle?['license_plate'] ?? '-'),
                _InfoRow('سنة الصنع', contract.vehicle?['year']?.toString() ?? '-'),
                const Divider(height: 24),
                _InfoRow('الكفيل الغارم', contract.guarantor1Name ?? 'لا يوجد كفيل'),
                _InfoRow('هوية الكفيل', contract.guarantor1Id ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppColors.accentGold, size: 18), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))]),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color ?? AppColors.primaryNavy, fontSize: isBold ? 14 : 13)),
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
          padding: const EdgeInsets.all(24),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final inst = list[index];
            final status = inst['status'];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(radius: 14, backgroundColor: AppColors.bgGrey, child: Text('${index + 1}', style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 10))),
                title: Text('تاريخ الاستحقاق: ${intl.DateFormat('dd/MM/yyyy').format(DateTime.parse(inst['due_date']))}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('المبلغ المطلوب: ${f.format(inst['expected_amount'])} ر.س', style: const TextStyle(fontSize: 12)),
                trailing: _buildInstallmentBadge(status),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('خطأ في تحميل الأقساط')),
    );
  }

  Widget _buildInstallmentBadge(String status) {
    Color color = Colors.grey; String label = 'غير محدد';
    if (status == 'paid') { color = Colors.green; label = 'تم السداد'; }
    else if (status == 'overdue') { color = Colors.red; label = 'متأخر'; }
    else if (status == 'partially_paid') { color = Colors.orange; label = 'سداد جزئي'; }
    else { color = Colors.blueGrey; label = 'بانتظار السداد'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
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
            padding: const EdgeInsets.all(24),
            child: ElevatedButton.icon(
              onPressed: () => showDialog(context: context, builder: (context) => AddPaymentDialog(contract: contract)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
              icon: const Icon(Icons.add_card_rounded),
              label: const Text('تسجيل دفعة سداد جديدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        Expanded(
          child: paymentsAsync.when(
            data: (list) {
              if (list.isEmpty) return const Center(child: Text('لم يتم استلام أي دفعات لهذا العقد بعد.'));
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final p = list[index];
                  final isReversed = p['status'] == 'reversed';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(color: isReversed ? Colors.red.withOpacity(0.02) : Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      dense: true,
                      leading: Icon(isReversed ? Icons.history_rounded : Icons.check_circle_rounded, color: isReversed ? Colors.red : Colors.green, size: 28),
                      title: Text('${f.format(p['amount_total'])} ر.س', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          decoration: isReversed ? TextDecoration.lineThrough : null,
                          color: isReversed ? Colors.grey : AppColors.primaryNavy,
                        )),
                      subtitle: Text('بتاريخ: ${intl.DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(p['payment_date']))}', style: const TextStyle(fontSize: 11)),
                      trailing: isReversed 
                        ? const Text('تم العكس', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)) 
                        : IconButton(
                            icon: const Icon(Icons.history_rounded, color: Colors.orange, size: 20),
                            onPressed: () => _showReversalDialog(context, ref, p['id']),
                            tooltip: 'عكس العملية',
                          ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Center(child: Text('خطأ في تحميل المدفوعات')),
          ),
        ),
      ],
    );
  }

  void _showReversalDialog(BuildContext context, WidgetRef ref, String paymentId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('عكس العملية المالية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('سيتم إلغاء أثر هذه الدفعة وإعادة فتح الأقساط وتصحيح أرصدة الممولين. هذا الإجراء لا يمكن التراجع عنه.'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'سبب العكس (إلزامي)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) return;
                final success = await ref.read(contractControllerProvider.notifier).reversePayment(contract.id, paymentId, reasonController.text.trim());
                if (context.mounted && success) {
                  Navigator.pop(context);
                }
              },
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
    final controllerState = ref.watch(contractControllerProvider);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return fundingAsync.when(
      data: (fundingList) {
        double totalFunded = fundingList.fold(0, (sum, item) => sum + (item['amount_allocated'] as num).toDouble());
        final percent = contract.principalAmount > 0 ? (totalFunded / contract.principalAmount) : 0.0;
        final bool isFullyFunded = percent >= 0.999;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  const Text('مؤشر اكتمال التمويل', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(width: 120, height: 120, child: CircularProgressIndicator(value: percent, strokeWidth: 10, backgroundColor: AppColors.bgGrey, color: isFullyFunded ? Colors.green : Colors.blue)),
                      Text('${(percent * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('إجمالي الممول', f.format(totalFunded), Colors.green),
                      _buildMiniStat('المستهدف', f.format(contract.principalAmount), AppColors.primaryNavy),
                    ],
                  ),
                  if (contract.status == 'draft' || contract.status == 'pending_funding') ...[
                    const Divider(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controllerState.isLoading ? null : () => showDialog(context: context, builder: (context) => FundContractDialog(contract: contract)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text('إضافة ممول', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                        if (isFullyFunded) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: controllerState.isLoading ? null : () => _activate(context, ref),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              icon: controllerState.isLoading 
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.flash_on, size: 18),
                              label: const Text('تفعيل العقد', style: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('قائمة شركاء التمويل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            const SizedBox(height: 12),
            ...fundingList.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                dense: true,
                leading: const CircleAvatar(radius: 14, backgroundColor: AppColors.bgGrey, child: Icon(Icons.person_rounded, color: AppColors.primaryNavy, size: 16)),
                title: Text(item['investors']?['full_name'] ?? 'مستثمر', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                trailing: Text('${f.format(item['amount_allocated'])} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
              ),
            )),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('Error')),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) => Column(children: [Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14))]);

  Future<void> _activate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفعيل العقد'),
        content: const Text('سيتم تفعيل العقد وتوليد جدول الأقساط. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم، تفعيل')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(contractControllerProvider.notifier).activateContract(contract.id);
    }
  }
}

class _AccountingTab extends ConsumerWidget {
  final String contractId;
  const _AccountingTab({required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesControllerProvider);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return entriesAsync.when(
      data: (entries) {
        final contractEntries = entries.where((e) => e.sourceId == contractId).toList();
        if (contractEntries.isEmpty) return const Center(child: Text('لا توجد قيود محاسبية مسجلة لهذا العقد بعد.'));

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: contractEntries.length,
          itemBuilder: (context, index) {
            final entry = contractEntries[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
              child: ExpansionTile(
                title: Text(entry.description ?? 'قيد محاسبي', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('تاريخ: ${intl.DateFormat('dd/MM/yyyy').format(entry.createdAt)}', style: const TextStyle(fontSize: 11)),
                leading: const CircleAvatar(backgroundColor: AppColors.bgGrey, child: Icon(Icons.account_balance_wallet_outlined, size: 18, color: AppColors.primaryNavy)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Expanded(flex: 3, child: Text('الحساب', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                            Expanded(child: Text('مدين', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                            Expanded(child: Text('دائن', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                          ],
                        ),
                        const Divider(),
                        ...(entry.lines ?? []).map((line) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text(
                                      line.accounts?['name'] ?? '-',
                                      style: const TextStyle(fontSize: 11)
                                  )
                              ),
                              Expanded(
                                  child: Text(
                                      (line.debit ?? 0) > 0 ? f.format(line.debit) : '-',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)
                                  )
                              ),
                              Expanded(
                                  child: Text(
                                      (line.credit ?? 0) > 0 ? f.format(line.credit) : '-',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)
                                  )
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('خطأ في تحميل القيود')),
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
      data: (logs) => ListView.builder(
        padding: const EdgeInsets.all(32),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.accentGold, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                    if (index != logs.length - 1) Expanded(child: Container(width: 2, color: Colors.grey.shade200)),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.eventType, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 14)),
                      Text(intl.DateFormat('dd/MM/yyyy HH:mm').format(log.occurredAt), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => const Center(child: Text('Error')),
    );
  }
}
