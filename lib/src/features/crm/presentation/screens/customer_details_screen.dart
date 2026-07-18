import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
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
      backgroundColor: AppColors.bgGrey,
      body: customerAsync.when(
        data: (customer) {
          if (customer == null)
            return const Center(child: Text('العميل غير موجود'));

          return DefaultTabController(
            length: 5,
            child: Column(
              children: [
                _buildPremiumHeader(context, customer),
                _buildModernTabBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ExecutiveOverviewTab(customer: customer),
                      _ContractsListTab(customerId: id),
                      _PaymentsHistoryTab(customerId: id),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: UniversalDocumentManager(customerId: id),
                      ),
                      _ActivityTimelineTab(customerId: id),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryNavy),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              Failure.fromException(err).message,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, Customer customer) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 12),
              Hero(
                tag: 'cust-${customer.id}',
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  child: Text(
                    customer.fullName[0],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          customer.fullName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildRiskBadge(customer.riskRating),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _HeaderInfoChip(
                          Icons.badge_rounded,
                          'هوية: ${customer.nationalId}',
                        ),
                        const SizedBox(width: 20),
                        _HeaderInfoChip(
                          Icons.phone_iphone_rounded,
                          customer.phone,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.push(
                      '/contracts/new?customerId=${customer.id}',
                    ),
                    icon: const Icon(Icons.add_task_rounded, size: 18),
                    label: const Text('تعميد عقد جديد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.primaryNavy,
                      minimumSize: const Size(160, 48),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/crm/customers/$id/edit'),
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text('تعديل الملف'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      minimumSize: const Size(160, 42),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      color: AppColors.primaryNavy,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: const TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.accentGold,
        unselectedLabelColor: Colors.white54,
        indicatorColor: AppColors.accentGold,
        indicatorWeight: 4,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: [
          Tab(text: 'نظرة عامة'),
          Tab(text: 'العقود الجارية'),
          Tab(text: 'سجل المدفوعات'),
          Tab(text: 'المستندات الرقمية'),
          Tab(text: 'سجل النشاط'),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    Color color = AppColors.successGreen;
    String label = 'منخفض المخاطر';
    if (risk == 'medium') {
      color = Colors.orange;
      label = 'مخاطر متوسطة';
    } else if (risk == 'high') {
      color = AppColors.errorRed;
      label = 'مخاطر عالية';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HeaderInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeaderInfoChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white60),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ExecutiveOverviewTab extends ConsumerWidget {
  final Customer customer;
  const _ExecutiveOverviewTab({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(
      customerFinancialSummaryProvider(customer.id),
    );
    final kyc = customer.kycData;
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          summaryAsync.when(
            data: (summary) => Row(
              children: [
                _ExecutiveStatBox(
                  'إجمالي العقود',
                  summary['total_contracts'].toString(),
                  Icons.assignment_rounded,
                  Colors.blue,
                ),
                const SizedBox(width: 24),
                _ExecutiveStatBox(
                  'الرصيد القائم',
                  '${f.format(summary['outstanding_balance'])} ر.س',
                  Icons.pending_actions_rounded,
                  AppColors.errorRed,
                ),
                const SizedBox(width: 24),
                _ExecutiveStatBox(
                  'إجمالي المسدد',
                  '${f.format(summary['total_paid'])} ر.س',
                  Icons.verified_rounded,
                  AppColors.successGreen,
                ),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _PremiumInfoCard(
                  title: 'البيانات الوظيفية والدخل',
                  icon: Icons.work_history_rounded,
                  children: [
                    _DetailRow(
                      'جهة العمل الحالية',
                      kyc['employer'] ?? 'غير مسجل',
                    ),
                    _DetailRow(
                      'المسمى الوظيفي',
                      kyc['job_title'] ?? 'غير مسجل',
                    ),
                    _DetailRow(
                      'صافي الراتب الشهري',
                      '${f.format(kyc['salary'] ?? 0)} ر.س',
                    ),
                    _DetailRow(
                      'تاريخ الالتحاق',
                      kyc['join_date'] ?? 'غير مسجل',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: _PremiumInfoCard(
                  title: 'بيانات الضامن',
                  icon: Icons.gpp_good_rounded,
                  children: [
                    _DetailRow(
                      'اسم الضامن',
                      kyc['guarantor']?['name'] ?? 'لا يوجد',
                    ),
                    _DetailRow('رقم الجوال', kyc['guarantor']?['phone'] ?? '-'),
                    _DetailRow(
                      'صلة القرابة',
                      kyc['guarantor']?['relationship'] ?? '-',
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

class _ExecutiveStatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ExecutiveStatBox(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _PremiumInfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentGold, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractsListTab extends ConsumerWidget {
  final String customerId;
  const _ContractsListTab({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(customerContractsProvider(customerId));
    return contractsAsync.when(
      data: (contracts) => ListView.builder(
        padding: const EdgeInsets.all(32),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final c = contracts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgGrey,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.primaryNavy,
                ),
              ),
              title: Text(
                'عقد تمويل #${c['contract_no']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'تاريخ الإصدار: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(c['created_at']))}',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () => context.push('/contracts/${c['id']}'),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          Failure.fromException(err).message,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}

class _PaymentsHistoryTab extends ConsumerWidget {
  final String customerId;
  const _PaymentsHistoryTab({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(customerPaymentsProvider(customerId));
    return paymentsAsync.when(
      data: (payments) => ListView.builder(
        padding: const EdgeInsets.all(32),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final p = payments[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.arrow_circle_down_rounded,
                color: AppColors.successGreen,
                size: 32,
              ),
              title: Text(
                '${p['amount_total']} ر.س',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                'وسيلة الدفع: ${p['payment_method'] ?? 'تحويل بنكي'}',
              ),
              trailing: Text(
                intl.DateFormat(
                  'dd/MM/yyyy',
                ).format(DateTime.parse(p['created_at'])),
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          Failure.fromException(err).message,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}

class _ActivityTimelineTab extends ConsumerWidget {
  final String customerId;
  const _ActivityTimelineTab({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(customerTimelineProvider(customerId));
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
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.accentGold,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    if (index != logs.length - 1)
                      Expanded(
                        child: Container(width: 2, color: Colors.grey.shade200),
                      ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log['event_type'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        intl.DateFormat(
                          'dd MMMM yyyy • HH:mm',
                          'ar',
                        ).format(DateTime.parse(log['created_at'])),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
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
      error: (err, _) => Center(
        child: Text(
          Failure.fromException(err).message,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
