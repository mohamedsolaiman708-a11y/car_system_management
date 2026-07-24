import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../../domain/contract.dart';
import '../contract_controller.dart';
import '../contract_timeline_controller.dart';
import '../utils/contract_print_helper.dart';
import '../widgets/add_payment_dialog.dart';
import '../../../documents/presentation/widgets/universal_document_manager.dart';
import '../../../investors/presentation/widgets/fund_contract_dialog.dart';
import '../../../accounting/presentation/accounting_controller.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/arabic_translator.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snack_bar_helper.dart';

class ContractDetailsScreen extends ConsumerWidget {
  final String id;
  const ContractDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(contractControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => SnackBarHelper.showError(context, error),
        data: (_) {
          if (previous?.isLoading == true) {
            SnackBarHelper.showSuccess(context, 'تم تحديث حالة العقد بنجاح');
          }
        },
      );
    });

    final contractAsync = ref.watch(contractDetailsProvider(id));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'تفاصيل الملف التعاقدي',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
          ),
          actions: [
            contractAsync.maybeWhen(
              data: (contract) => contract != null
                  ? IconButton(
                      icon: const Icon(Icons.print_rounded, color: Colors.white, size: 26),
                      tooltip: 'طباعة العقد',
                      onPressed: () async {
                        try {
                          await ContractPrintHelper.printContract(contract);
                        } catch (e) {
                          if (context.mounted) {
                            SnackBarHelper.showError(context, 'فشل تحضير ملف الطباعة: $e');
                          }
                        }
                      },
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.accentGold, size: 28),
              onPressed: () => context.push('/contracts/$id/edit'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: contractAsync.when(
          data: (contract) {
            if (contract == null) return const _NotFoundState();

            return DefaultTabController(
              length: 7,
              child: Column(
                children: [
                  _buildPremiumHeader(contract),
                  _buildModernTabBar(),
                  Expanded(
                    child: Container(
                      color: AppColors.bgGrey,
                      child: TabBarView(
                        children: [
                          _OverviewTab(contract: contract),
                          _InstallmentsTab(contractId: contract.id),
                          _PaymentsTab(contract: contract),
                          _FundingTab(contract: contract),
                          _AccountingTab(contractId: contract.id),
                          _TimelineTab(contractId: contract.id),
                          Container(
                            color: Colors.red.shade50,
                            padding: const EdgeInsets.all(24.0),
                            child: UniversalDocumentManager(
                              contractId: contract.id,
                              customerId: contract.customerId,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
          error: (err, _) => Center(child: Text(Failure.fromException(err).message)),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(Contract contract) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.assignment_rounded, size: 40, color: AppColors.accentGold),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'عقد رقم: ${contract.contractNo}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    _StatusBadge(status: contract.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, color: AppColors.accentGold, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'العميل: ${contract.customer?['full_name'] ?? "-"}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.calendar_month_rounded, color: AppColors.accentGold, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      intl.DateFormat('yyyy/MM/dd').format(contract.startDate ?? DateTime.now()),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
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
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.label,
          labelPadding: const EdgeInsets.symmetric(horizontal: 20),
          indicatorColor: AppColors.primaryNavy,
          indicatorWeight: 4,
          labelColor: AppColors.primaryNavy,
          unselectedLabelColor: Colors.grey.shade400,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Cairo'),
          tabs: const [
            Tab(text: 'ملخص العقد'),
            Tab(text: 'جدول السداد'),
            Tab(text: 'المدفوعات'),
            Tab(text: 'شركاء التمويل'),
            Tab(text: 'القيود المحاسبية'),
            Tab(text: 'سجل الأحداث'),
            Tab(text: 'المستندات'),
          ],
        ),
      ),
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
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _SectionCard(
                  title: 'التفاصيل المالية والربحية',
                  icon: Icons.account_balance_wallet_rounded,
                  children: [
                    _InfoRow('قيمة السيارة (الأصل)', '${f.format(contract.principalAmount)} ر.س'),
                    _InfoRow('نسبة الربح السنوية', '${contract.financeProfitRate}%'),
                    _InfoRow('مدة التمويل', '${contract.durationMonths} شهر'),
                    const Divider(height: 32),
                    _InfoRow('إجمالي مديونية العقد', '${f.format(contract.totalContractValue)} ر.س', isBold: true),
                    installmentsAsync.when(
                      data: (list) {
                        final paid = list.where((i) => i['status'] == 'paid').fold(0.0, (sum, i) => sum + (i['expected_amount'] as num).toDouble());
                        return _InfoRow('المبلغ المتبقي للسداد', '${f.format(contract.totalContractValue - paid)} ر.س', isBold: true, color: AppColors.errorRed);
                      },
                      loading: () => _InfoRow('المبلغ المتبقي', 'جاري الحساب...', isBold: true),
                      error: (_, __) => _InfoRow('المبلغ المتبقي', '-', isBold: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _SectionCard(
                  title: 'بيانات الأصول',
                  icon: Icons.directions_car_filled_rounded,
                  children: [
                    _InfoRow('المركبة', '${contract.vehicle?['make'] ?? ""} ${contract.vehicle?['model'] ?? ""}'),
                    _InfoRow('رقم اللوحة', contract.vehicle?['license_plate'] ?? '-'),
                    const SizedBox(height: 16),
                    const Text('الكفيل الغارم', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(contract.guarantor1Name ?? 'لا يوجد كفيل مسجل', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryNavy)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'ملاحظات وبنود إضافية',
            icon: Icons.info_outline_rounded,
            children: [
              Text(
                'تم إصدار هذا العقد وفقاً للشروط والأحكام المعتمدة لدى المؤسسة. يلتزم العميل بسداد الأقساط في المواعيد المحددة لتفادي الغرامات أو الإجراءات القانونية.',
                style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade700, height: 1.6, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentGold, size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
            ],
          ),
          const SizedBox(height: 20),
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
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w600)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: color ?? AppColors.primaryNavy,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    String label = ArabicTranslator.status(status);
    if (status == 'active') color = AppColors.successGreen;
    else if (status == 'draft') color = Colors.orange;
    else if (status == 'pending_funding') color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
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
      data: (list) => list.isEmpty
          ? const _EmptyState(title: 'جدول السداد فارغ', message: 'سيتم توليد الأقساط تلقائياً عند تفعيل العقد')
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final inst = list[index];
                final isPaid = inst['status'] == 'paid';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isPaid ? AppColors.successGreen.withOpacity(0.2) : Colors.transparent),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isPaid ? AppColors.successGreen.withOpacity(0.1) : AppColors.bgGrey,
                      child: Text('${index + 1}', style: TextStyle(color: isPaid ? AppColors.successGreen : AppColors.primaryNavy, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(
                      'تاريخ الاستحقاق: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(inst['due_date']))}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text('القسط المطلوب: ${f.format(inst['expected_amount'])} ر.س', style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                    trailing: _StatusBadge(status: inst['status']),
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
      error: (e, _) => Center(child: Text(e.toString())),
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
              icon: const Icon(Icons.add_card_rounded),
              label: const Text('تسجيل دفعة سداد جديدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
          ),
        Expanded(
          child: paymentsAsync.when(
            data: (list) => list.isEmpty
                ? const _EmptyState(title: 'لا توجد مدفوعات', message: 'لم يتم استلام أي مبالغ مالية لهذا العقد بعد')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final p = list[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.verified_rounded, color: AppColors.successGreen, size: 32),
                          title: Text('${f.format(p['amount_total'])} ر.س', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryNavy)),
                          subtitle: Text('التاريخ: ${intl.DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(p['payment_date']))}', style: const TextStyle(fontWeight: FontWeight.w500)),
                          trailing: IconButton(icon: const Icon(Icons.print_rounded, color: AppColors.primaryNavy), onPressed: () {}),
                        ),
                      );
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
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
            _FundingSummaryCard(percent: percent, totalFunded: totalFunded, principal: contract.principalAmount, f: f),
            const SizedBox(height: 24),
            if (contract.status == 'draft' || contract.status == 'pending_funding')
              _FundingActionsRow(isFullyFunded: isFullyFunded, contract: contract, isLoading: controllerState.isLoading),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(width: 4, height: 16, color: AppColors.accentGold),
                const SizedBox(width: 12),
                const Text('شركاء التمويل المعتمدين', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
              ],
            ),
            const SizedBox(height: 12),
            ...fundingList.map((item) => _InvestorTile(item: item, f: f)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _FundingSummaryCard extends StatelessWidget {
  final double percent, totalFunded, principal;
  final intl.NumberFormat f;
  const _FundingSummaryCard({required this.percent, required this.totalFunded, required this.principal, required this.f});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        children: [
          const Text('مؤشر اكتمال تغطية العقد', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGrey)),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 130, height: 130,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 12,
                  backgroundColor: AppColors.bgGrey,
                  color: percent >= 0.99 ? AppColors.successGreen : Colors.blue,
                ),
              ),
              Text('${(percent * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(label: 'المبلغ الممول', value: f.format(totalFunded), color: AppColors.successGreen),
              _MiniStat(label: 'قيمة الأصل', value: f.format(principal), color: AppColors.primaryNavy),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 15)),
    ],
  );
}

class _InvestorTile extends StatelessWidget {
  final dynamic item;
  final intl.NumberFormat f;
  const _InvestorTile({required this.item, required this.f});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.primaryNavy.withOpacity(0.05), child: const Icon(Icons.person_rounded, color: AppColors.primaryNavy)),
        title: Text(item['investors']?['full_name'] ?? 'مستثمر', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryNavy)),
        trailing: Text('${f.format(item['amount_allocated'])} ر.س', style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _FundingActionsRow extends ConsumerWidget {
  final bool isFullyFunded, isLoading;
  final Contract contract;
  const _FundingActionsRow({required this.isFullyFunded, required this.contract, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        if (!isFullyFunded)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => showDialog(context: context, builder: (context) => FundContractDialog(contract: contract)),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('إضافة شريك تمويل'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
        if (isFullyFunded)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => _activate(context, ref),
              icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.flash_on_rounded),
              label: const Text('تفعيل العقد وتوليد الأقساط'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, foregroundColor: Colors.white, minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
      ],
    );
  }

  Future<void> _activate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفعيل العقد'),
        content: const Text('سيتم تفعيل العقد رسمياً وتوليد جدول الأقساط. هل أنت متأكد من هذه الخطوة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم، تفعيل')),
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
        if (contractEntries.isEmpty) return const _EmptyState(title: 'لا توجد قيود محاسبية', message: 'لم يتم تسجيل أي قيود مالية لهذا العقد حتى الآن');
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: contractEntries.length,
          itemBuilder: (context, index) => _JournalEntryCard(entry: contractEntries[index], f: f),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final dynamic entry;
  final intl.NumberFormat f;
  const _JournalEntryCard({required this.entry, required this.f});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
      child: ExpansionTile(
        title: Text(ArabicTranslator.description(entry.description), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primaryNavy)),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          ...(entry.lines ?? []).map<Widget>((line) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(ArabicTranslator.accountName(line.accounts?['name']), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                Expanded(child: Text((line.debit ?? 0) > 0 ? f.format(line.debit) : '-', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.w900))),
                Expanded(child: Text((line.credit ?? 0) > 0 ? f.format(line.credit) : '-', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w900))),
              ],
            ),
          )).toList(),
        ],
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
      data: (logs) => logs.isEmpty
          ? const _EmptyState(title: 'سجل النشاطات فارغ', message: 'لا توجد أحداث مسجلة لهذا العقد حالياً')
          : ListView.builder(
              padding: const EdgeInsets.all(32),
              itemCount: logs.length,
              itemBuilder: (context, index) => _TimelineItem(log: logs[index], isLast: index == logs.length - 1),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(err.toString())),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final dynamic log;
  final bool isLast;
  const _TimelineItem({required this.log, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.accentGold, shape: BoxShape.circle)),
              if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade200)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ArabicTranslator.eventType(log.eventType), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
                Text(intl.DateFormat('yyyy/MM/dd HH:mm').format(log.occurredAt), style: const TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title, message;
  const _EmptyState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textGrey)),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 80, color: Colors.grey),
          const Text('عذراً، العقد المطلوب غير موجود', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => context.pop(), child: const Text('العودة للقائمة الرئيسية')),
        ],
      ),
    );
  }
}
