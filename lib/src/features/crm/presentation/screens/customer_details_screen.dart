import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
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
      backgroundColor: Colors.transparent,
      body: customerAsync.when(
        data: (customer) {
          if (customer == null) return const Center(child: Text('العميل غير موجود'));
          
          return DefaultTabController(
            length: 5,
            child: Column(
              children: [
                _buildHeader(context, customer),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      _OverviewTab(customer: customer),
                      _ContractsTab(customerId: id),
                      _PaymentsTab(customerId: id),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: UniversalDocumentManager(customerId: id),
                      ),
                      _TimelineTab(customerId: id),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('حدث خطأ: $err')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Customer customer) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: AppColors.primaryNavy.withOpacity(0.1),
                child: Text(customer.fullName[0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(customer.fullName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                        const SizedBox(width: 12),
                        _buildRiskBadge(customer.riskRating),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 20,
                      children: [
                        _buildHeaderInfo(Icons.badge_outlined, 'هوية: ${customer.nationalId}'),
                        _buildHeaderInfo(Icons.phone_android_rounded, 'جوال: ${customer.phone}'),
                        _buildHeaderInfo(Icons.location_on_outlined, customer.address ?? 'العنوان غير مسجل'),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.push('/crm/customers/$id/edit'),
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text('تعديل البيانات'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(140, 45)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_task_rounded, size: 18),
                    label: const Text('عقد جديد'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(140, 45)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textGrey),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: const TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.primaryNavy,
        unselectedLabelColor: AppColors.textGrey,
        indicatorColor: AppColors.accentGold,
        indicatorWeight: 3,
        tabs: [
          Tab(child: Row(children: [Icon(Icons.dashboard_customize_outlined, size: 18), SizedBox(width: 8), Text('نظرة عامة')])),
          Tab(child: Row(children: [Icon(Icons.assignment_rounded, size: 18), SizedBox(width: 8), Text('العقود')])),
          Tab(child: Row(children: [Icon(Icons.payments_outlined, size: 18), SizedBox(width: 8), Text('المدفوعات')])),
          Tab(child: Row(children: [Icon(Icons.folder_shared_outlined, size: 18), SizedBox(width: 8), Text('المستندات')])),
          Tab(child: Row(children: [Icon(Icons.history_rounded, size: 18), SizedBox(width: 8), Text('السجل والنشاط')])),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    Color color = AppColors.successGreen;
    String label = 'منخفض المخاطر';
    if (risk == 'medium') { color = Colors.orange; label = 'متوسط المخاطر'; }
    else if (risk == 'high') { color = AppColors.errorRed; label = 'عالي المخاطر'; }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          summaryAsync.when(
            data: (summary) => _buildFinancialCards(summary),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _InfoCard(
                  title: 'معلومات العمل والدخل',
                  icon: Icons.work_outline_rounded,
                  children: [
                    _InfoRow('جهة العمل', kyc['employer'] ?? '-'),
                    _InfoRow('المسمى الوظيفي', kyc['job_title'] ?? '-'),
                    _InfoRow('الراتب الشهري', '${kyc['salary'] ?? 0} ر.س'),
                    _InfoRow('تاريخ التعيين', kyc['join_date'] ?? '-'),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _InfoCard(
                  title: 'بيانات الضامن الائتماني',
                  icon: Icons.security_rounded,
                  children: [
                    _InfoRow('اسم الضامن', kyc['guarantor']?['name'] ?? '-'),
                    _InfoRow('رقم الجوال', kyc['guarantor']?['phone'] ?? '-'),
                    _InfoRow('صلة القرابة', kyc['guarantor']?['relationship'] ?? '-'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCards(Map<String, dynamic> summary) {
    return Row(
      children: [
        _StatBox('إجمالي العقود', summary['total_contracts'].toString(), Icons.assignment_outlined, Colors.indigo),
        const SizedBox(width: 20),
        _StatBox('الرصيد المتبقي', '${summary['outstanding_balance']} ر.س', Icons.pending_actions_rounded, AppColors.errorRed),
        const SizedBox(width: 20),
        _StatBox('إجمالي المحصل', '${summary['total_paid']} ر.س', Icons.check_circle_outline_rounded, AppColors.successGreen),
      ],
    );
  }
}

// --- مكونات التصميم المساعدة ---

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBox(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF0F0F0))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF0F0F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppColors.accentGold, size: 20), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryNavy))]),
          const Divider(height: 40, color: Color(0xFFF0F0F0)),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryNavy)),
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
      data: (contracts) => ListView.separated(
        padding: const EdgeInsets.all(32),
        itemCount: contracts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final c = contracts[index];
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0F0F0))),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.description_outlined, color: AppColors.primaryNavy)),
              title: Text('عقد رقم: ${c['contract_no']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('تاريخ الإصدار: ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(c['created_at']))}'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => context.push('/contracts/${c['id']}'),
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
      data: (payments) => ListView.separated(
        padding: const EdgeInsets.all(32),
        itemCount: payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = payments[index];
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF0F0F0))),
            child: ListTile(
              leading: const Icon(Icons.arrow_downward_rounded, color: AppColors.successGreen),
              title: Text('${p['amount_total']} ر.س', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('طريقة الدفع: ${p['payment_method'] ?? 'نقدي'}'),
              trailing: Text(intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(p['created_at'])), style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
            ),
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
        padding: const EdgeInsets.all(32),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Row(
            children: [
              Column(
                children: [
                  Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.accentGold, shape: BoxShape.circle)),
                  if (index != logs.length - 1) Container(width: 2, height: 50, color: const Color(0xFFEEEEEE)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log['event_type'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                    Text(intl.DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(log['created_at'])), style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }
}
