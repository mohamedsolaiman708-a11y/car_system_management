import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        body: customerAsync.when(
          data: (customer) {
            if (customer == null) return const Center(child: Text('العميل غير موجود'));

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
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
          error: (err, _) => Center(child: Text(Failure.fromException(err).message)),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, Customer customer) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => context.pop(),
              ),
              const Spacer(),
              _buildCommunicationButtons(customer.phone),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.accentGold.withOpacity(0.1),
                child: Text(customer.fullName[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accentGold)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    _buildRiskBadge(customer.riskRating),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationButtons(String phone) {
    return Row(
      children: [
        _CircleActionBtn(
          icon: Icons.phone_forwarded_rounded,
          color: AppColors.successGreen,
          onTap: () => launchUrl(Uri.parse('tel:$phone')),
        ),
        const SizedBox(width: 12),
        _CircleActionBtn(
          icon: Icons.chat_bubble_rounded,
          color: const Color(0xFF25D366), // WhatsApp Color
          onTap: () => launchUrl(Uri.parse('https://wa.me/$phone')),
        ),
      ],
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      color: AppColors.primaryNavy,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: const TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primaryNavy,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryNavy,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'العقود'),
            Tab(text: 'المدفوعات'),
            Tab(text: 'المستندات'),
            Tab(text: 'السجل'),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    Color color = risk == 'high' ? Colors.red : (risk == 'medium' ? Colors.orange : Colors.green);
    String label = risk == 'high' ? 'مخاطر عالية' : (risk == 'medium' ? 'مخاطر متوسطة' : 'آمن / منخفض');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _CircleActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CircleActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.2))),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _ExecutiveOverviewTab extends ConsumerWidget {
  final Customer customer;
  const _ExecutiveOverviewTab({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(customerFinancialSummaryProvider(customer.id));
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          summaryAsync.when(
            data: (summary) => Row(
              children: [
                _StatCard('إجمالي العقود', summary['total_contracts'].toString(), Icons.assignment_rounded, Colors.blue),
                const SizedBox(width: 16),
                _StatCard('الرصيد المتبقي', '${f.format(summary['outstanding_balance'])}', Icons.money_off_rounded, Colors.red),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),
          _InfoSection(
            title: 'بيانات التواصل والهوية',
            children: [
              _InfoTile('رقم الهوية', customer.nationalId),
              _InfoTile('رقم الجوال', customer.phone),
              _InfoTile('البريد الإلكتروني', customer.email ?? 'غير متوفر'),
            ],
          ),
          const SizedBox(height: 24),
          _InfoSection(
            title: 'البيانات الوظيفية',
            children: [
              _InfoTile('جهة العمل', customer.kycData['employer'] ?? 'غير مسجل'),
              _InfoTile('المسمى الوظيفي', customer.kycData['job_title'] ?? 'غير مسجل'),
              _InfoTile('الراتب الشهري', '${f.format(customer.kycData['salary'] ?? 0)} ريال'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.bgGrey)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
        padding: const EdgeInsets.all(24),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final c = contracts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text('عقد رقم #${c['contract_no']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('الحالة: ${c['status']}'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => context.push('/contracts/${c['id']}'),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('خطأ في تحميل العقود')),
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
        padding: const EdgeInsets.all(24),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final p = payments[index];
          return ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text('${p['amount_total']} ريال'),
            subtitle: Text('التاريخ: ${p['created_at'].toString().split('T')[0]}'),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('خطأ في تحميل المدفوعات')),
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
        padding: const EdgeInsets.all(24),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Row(
            children: [
              const Icon(Icons.circle, size: 12, color: AppColors.accentGold),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log['event_type'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(log['created_at'].toString().split('T')[0], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('خطأ في تحميل السجل')),
    );
  }
}
