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
    final contractAsync = ref.watch(contractDetailsProvider(id));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'تفاصيل الملف التعاقدي',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          actions: [
            contractAsync.maybeWhen(
              data: (contract) => contract != null
                  ? IconButton(
                      icon: const Icon(
                        Icons.print_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      tooltip: 'طباعة العقد',
                      onPressed: () async {
                        try {
                          await ContractPrintHelper.printContract(contract);
                        } catch (e) {
                          if (context.mounted) {
                            SnackBarHelper.showError(
                              context,
                              'فشل تحضير ملف الطباعة: $e',
                            );
                          }
                        }
                      },
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_note_rounded,
                color: AppColors.accentGold,
                size: 28,
              ),
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
                          _AccountingTab(contractNo: contract.contractNo),
                          _TimelineTab(contractId: contract.id),
                          Padding(
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
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryNavy),
          ),
          error: (err, _) =>
              Center(child: Text(Failure.fromException(err).message)),
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
            ),
            child: const Icon(
              Icons.assignment_rounded,
              size: 40,
              color: AppColors.accentGold,
            ),
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
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusBadge(status: contract.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'العميل: ${contract.customer?['full_name'] ?? "-"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
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
          indicatorColor: AppColors.primaryNavy,
          indicatorWeight: 4,
          labelColor: AppColors.primaryNavy,
          unselectedLabelColor: Colors.grey.shade400,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            fontFamily: 'Cairo',
          ),
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
    final paymentsAsync = ref.watch(contractPaymentsProvider(contract.id));
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
                  title: 'التفاصيل المالية وأطراف العقد',
                  icon: Icons.account_balance_wallet_rounded,
                  children: [
                    _InfoRow(
                      'نوع العقد',
                      contract.type == 'cash'
                          ? 'بيع نقدي مباشر'
                          : 'بيع بالأجل (أقساط)',
                      isBold: true,
                    ),
                    _InfoRow(
                      'الطرف الأول (المستثمر البائع)',
                      contract.investor?['full_name'] ?? '-',
                    ),
                    _InfoRow(
                      'الطرف الثاني (المشتري)',
                      contract.customer?['full_name'] ?? '-',
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      'قيمة السيارة (الأصل)',
                      '${f.format(contract.principalAmount)} ر.س',
                    ),
                    if (contract.type != 'cash') ...[
                      _InfoRow(
                        'نسبة الربح السنوية',
                        '${contract.financeProfitRate}%',
                      ),
                      _InfoRow('مدة التمويل', '${contract.durationMonths} شهر'),
                    ],
                    const Divider(height: 24),
                    _InfoRow(
                      'إجمالي قيمة العقد',
                      '${f.format(contract.totalContractValue)} ر.س',
                      isBold: true,
                    ),

                    paymentsAsync.when(
                      data: (payments) {
                        final double totalPaid = payments.fold(
                          0.0,
                          (sum, p) =>
                              sum + (p['amount_total'] as num).toDouble(),
                        );
                        final double remaining =
                            contract.totalContractValue - totalPaid;
                        return _InfoRow(
                          'المبلغ المتبقي للسداد',
                          '${f.format(remaining > 0 ? remaining : 0.0)} ر.س',
                          isBold: true,
                          color: remaining > 0
                              ? AppColors.errorRed
                              : AppColors.successGreen,
                        );
                      },
                      loading: () => _InfoRow(
                        'المبلغ المتبقي',
                        'جاري الحساب...',
                        isBold: true,
                      ),
                      error: (_, __) =>
                          _InfoRow('المبلغ المتبقي', '-', isBold: true),
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
                    _InfoRow(
                      'المركبة',
                      '${contract.vehicle?['make'] ?? ""} ${contract.vehicle?['model'] ?? ""}',
                    ),
                    _InfoRow(
                      'رقم اللوحة',
                      contract.vehicle?['license_plate'] ?? '-',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'الكفيل الغارم',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      contract.guarantor1Name ?? 'لا يوجد كفيل مسجل',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
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
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentGold, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
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
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
          ),
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
    if (status == 'active' || status == 'completed')
      color = AppColors.successGreen;
    else if (status == 'draft')
      color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        ArabicTranslator.status(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InstallmentsTab extends ConsumerWidget {
  final String contractId;
  const _InstallmentsTab({required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installmentsAsync = ref.watch(
      contractInstallmentsProvider(contractId),
    );
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return installmentsAsync.when(
      data: (list) {
        if (list.isEmpty) return const _EmptyState(message: 'لا يوجد جدول سداد لهذا العقد');
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final inst = list[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: Text(
                  'تاريخ الاستحقاق: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(inst['due_date']))}',
                ),
                subtitle: Text(
                  'المبلغ: ${f.format(inst['expected_amount'])} ر.س',
                ),
                trailing: _StatusBadge(status: inst['status']),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
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
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AddPaymentDialog(contract: contract),
              ),
              icon: const Icon(Icons.add_card_rounded),
              label: const Text('تسجيل دفعة سداد جديدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
        Expanded(
          child: paymentsAsync.when(
            data: (list) {
              if (list.isEmpty) return const _EmptyState(message: 'لم يتم تسجيل أي دفعات بعد');
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final p = list[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.verified_rounded,
                      color: AppColors.successGreen,
                    ),
                    title: Text('${f.format(p['amount_total'])} ر.س'),
                    subtitle: Text(
                      'التاريخ: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(p['payment_date']))}',
                    ),
                  );
                },
              );
            },
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
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return fundingAsync.when(
      data: (list) {
        if (list.isEmpty) return const _EmptyState(message: 'لا يوجد شركاء تمويل لهذا العقد');
        return ListView(
          padding: const EdgeInsets.all(24),
          children: list
              .map(
                (fund) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_rounded, color: AppColors.accentGold),
                    title: Text(fund['investors']?['full_name'] ?? 'مستثمر'),
                    trailing: Text(
                      '${f.format(fund['amount_allocated'])} ر.س',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _AccountingTab extends ConsumerWidget {
  final String contractNo;
  const _AccountingTab({required this.contractNo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesControllerProvider);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 2);

    return entriesAsync.when(
      data: (allEntries) {
        // تصفية القيود التي تحتوي على رقم العقد في البيان أو المرجع
        final filtered = allEntries.where((e) => 
          (e.description?.contains(contractNo) ?? false) || 
          (e.reference?.contains(contractNo) ?? false)
        ).toList();

        if (filtered.isEmpty) return const _EmptyState(message: 'لا توجد قيود محاسبية مسجلة لهذا العقد');

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final entry = filtered[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text(entry.description ?? 'قيد محاسبي'),
                subtitle: Text('التاريخ: ${intl.DateFormat('yyyy/MM/dd').format(entry.entryDate)}'),
                children: [
                  ...entry.lines.map((line) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(line.accounts?['name'] ?? '-'),
                        Text(
                          line.debit > 0 
                            ? 'مدين: ${f.format(line.debit)}' 
                            : 'دائن: ${f.format(line.credit)}',
                          style: TextStyle(
                            color: line.debit > 0 ? AppColors.errorRed : AppColors.successGreen,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
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
      data: (logs) {
        if (logs.isEmpty) return const _EmptyState(message: 'لا يوجد سجل أحداث لهذا العقد');
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return ListTile(
              leading: const Icon(Icons.history_rounded, color: AppColors.primaryNavy),
              title: Text(ArabicTranslator.eventType(log.eventType)),
              subtitle: Text(
                intl.DateFormat('yyyy/MM/dd HH:mm').format(log.occurredAt),
              ),
              trailing: log.profileName != null
                  ? Text(
                      log.profileName!,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    )
                  : null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ],
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('العقد غير موجود'));
  }
}
