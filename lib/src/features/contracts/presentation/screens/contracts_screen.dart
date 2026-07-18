import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/utils/error_handler.dart';
import '../contract_controller.dart';

class ContractsScreen extends ConsumerStatefulWidget {
  const ContractsScreen({super.key});

  @override
  ConsumerState<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends ConsumerState<ContractsScreen> {
  String searchQuery = '';
  String? statusFilter;

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(contractsListProvider(
      searchQuery: searchQuery,
      status: statusFilter,
    ));
    final statsAsync = ref.watch(contractStatsProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Container(
          color: AppColors.primaryNavy,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: _buildPremiumHeader(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // لوحة الإحصائيات التنفيذية
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _buildExecutiveStats(statsAsync, f),
          ),

          // منطقة البحث والتصفية
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildModernFilterBar(),
          ),

          Expanded(
            child: contractsAsync.when(
              data: (contracts) => contracts.isEmpty
                  ? _buildEmptyState()
                  : isDesktop
                  ? _buildPremiumTable(contracts, f)
                  : _buildPremiumCards(contracts, f),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    Failure.fromException(err).message,
                    style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !isDesktop ? FloatingActionButton.extended(
        onPressed: () => context.push('/contracts/new'),
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.primaryNavy,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('عقد جديد', style: TextStyle(fontWeight: FontWeight.bold)),
      ) : null,
    );
  }

  Widget _buildPremiumHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('سجل العقود والتمويل',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('إدارة عمليات البيع الآجل، مراجعة الأقساط، وتحليل التحصيل',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
          ],
        ),
        if (ResponsiveLayout.isDesktop(context))
          ElevatedButton.icon(
            onPressed: () => context.push('/contracts/new'),
            icon: const Icon(Icons.add_task_rounded, size: 20),
            label: const Text('إصدار عقد تمويل جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.primaryNavy,
              minimumSize: const Size(220, 54),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
      ],
    );
  }

  Widget _buildExecutiveStats(AsyncValue<Map<String, dynamic>> statsAsync, intl.NumberFormat f) {
    return statsAsync.when(
      data: (stats) => Row(
        children: [
          _buildExecutiveStatCard('إجمالي العقود', stats['total'] ?? 0, Icons.assignment_rounded, Colors.blue),
          const SizedBox(width: 20),
          _buildExecutiveStatCard('عقود نشطة', stats['active'] ?? 0, Icons.check_circle_rounded, Colors.green),
          const SizedBox(width: 20),
          _buildExecutiveStatCard('متأخرات (قيمة)', f.format(stats['total_overdue'] ?? 0), Icons.warning_amber_rounded, Colors.red),
          const SizedBox(width: 20),
          _buildExecutiveStatCard('مسودات', stats['draft'] ?? 0, Icons.edit_note_rounded, Colors.orange),
        ],
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildExecutiveStatCard(String label, dynamic value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'البحث برقم العقد، اسم العميل، أو السيارة...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryNavy),
                filled: true,
                fillColor: AppColors.bgGrey.withValues(alpha: 0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _buildPremiumFilterDropdown(),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.bgGrey.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: statusFilter,
          hint: const Text('تصفية الحالة', style: TextStyle(fontSize: 14)),
          isExpanded: true,
          onChanged: (val) => setState(() => statusFilter = val),
          items: const [
            DropdownMenuItem(value: null, child: Text('كافة العقود')),
            DropdownMenuItem(value: 'active', child: Text('عقود نشطة')),
            DropdownMenuItem(value: 'draft', child: Text('مسودات')),
            DropdownMenuItem(value: 'closed', child: Text('عقود مغلقة')),
            DropdownMenuItem(value: 'defaulted', child: Text('متعثرة')),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumTable(List<dynamic> contracts, intl.NumberFormat f) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.primaryNavy.withValues(alpha: 0.02)),
            dataRowMinHeight: 80, dataRowMaxHeight: 80,
            columns: const [
              DataColumn(label: Text('رقم العقد', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('العميل المستفيد', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('المركبة', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('القيمة الإجمالية', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: contracts.map((c) => DataRow(
              cells: [
                DataCell(Text(c.contractNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, letterSpacing: 1))),
                DataCell(Text(c.customer?['full_name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Text('${c.vehicle?['make'] ?? ''} ${c.vehicle?['model'] ?? ''}', style: const TextStyle(fontSize: 13))),
                DataCell(Text('${f.format(c.totalContractValue)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(_buildStatusBadge(c.status)),
                DataCell(IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primaryNavy),
                  onPressed: () => context.push('/contracts/${c.id}'),
                )),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCards(List<dynamic> contracts, intl.NumberFormat f) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final c = contracts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(c.contractNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildStatusBadge(c.status),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text('العميل: ${c.customer?['full_name'] ?? '-'}', style: const TextStyle(color: Colors.black87)),
                Text('السيارة: ${c.vehicle?['make'] ?? ''} ${c.vehicle?['model'] ?? ''}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Text('${f.format(c.totalContractValue)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 16)),
              ],
            ),
            onTap: () => context.push('/contracts/${c.id}'),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    String label = status;
    if (status == 'active') { color = Colors.green; label = 'نشط'; }
    if (status == 'draft') { color = Colors.orange; label = 'مسودة'; }
    if (status == 'closed') { color = Colors.blue; label = 'مغلق'; }
    if (status == 'defaulted') { color = Colors.red; label = 'متعثر'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('لا توجد عقود مسجلة حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
