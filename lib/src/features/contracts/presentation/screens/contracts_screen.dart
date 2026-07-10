import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatsOverview(statsAsync),
            const SizedBox(height: 24),
            _buildSearchAndFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: contractsAsync.when(
                data: (contracts) => isDesktop 
                    ? _buildContractsTable(contracts)
                    : _buildContractsGrid(contracts),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('حدث خطأ: $err')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !isDesktop ? FloatingActionButton(
        onPressed: () => context.push('/contracts/new'),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(Icons.add_task_rounded, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('سجل العقود والتمويل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            Text('متابعة عقود البيع الآجل، الأقساط، وحالات السداد', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          ],
        ),
        if (ResponsiveLayout.isDesktop(context))
          ElevatedButton.icon(
            onPressed: () => context.push('/contracts/new'),
            icon: const Icon(Icons.add_task_rounded, size: 18),
            label: const Text('إصدار عقد جديد'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(180, 50)),
          ),
      ],
    );
  }

  Widget _buildStatsOverview(AsyncValue<Map<String, dynamic>> statsAsync) {
    return statsAsync.when(
      data: (stats) => Row(
        children: [
          _buildMiniStat('إجمالي العقود', stats['total'] ?? 0, Icons.assignment_rounded, Colors.blue),
          const SizedBox(width: 16),
          _buildMiniStat('عقود نشطة', stats['active'] ?? 0, Icons.check_circle_rounded, Colors.green),
          const SizedBox(width: 16),
          _buildMiniStat('مسودات', stats['draft'] ?? 0, Icons.edit_note_rounded, Colors.orange),
          const SizedBox(width: 16),
          _buildMiniStat('متعثرة', stats['defaulted'] ?? 0, Icons.warning_amber_rounded, Colors.red),
        ],
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildMiniStat(String label, dynamic value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0F0F0))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0F0F0))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'بحث برقم العقد، اسم العميل، أو السيارة...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: AppColors.bgGrey,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
      child: DropdownButton<String>(
        value: statusFilter,
        hint: const Text('الحالة', style: TextStyle(fontSize: 13)),
        underline: const SizedBox(),
        onChanged: (val) => setState(() => statusFilter = val),
        items: const [
          DropdownMenuItem(value: null, child: Text('الكل')),
          DropdownMenuItem(value: 'active', child: Text('نشط')),
          DropdownMenuItem(value: 'draft', child: Text('مسودة')),
          DropdownMenuItem(value: 'closed', child: Text('مغلق')),
          DropdownMenuItem(value: 'defaulted', child: Text('متعثر')),
        ],
      ),
    );
  }

  Widget _buildContractsTable(List<dynamic> contracts) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0F0F0))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.bgGrey),
            dataRowHeight: 65,
            columns: const [
              DataColumn(label: Text('رقم العقد', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('العميل', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('السيارة', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('القيمة الإجمالية', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: contracts.map((c) => DataRow(
              cells: [
                DataCell(Text(c.contractNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
                DataCell(Text(c.customer?['full_name'] ?? '-')),
                DataCell(Text('${c.vehicle?['make'] ?? ''} ${c.vehicle?['model'] ?? ''}')),
                DataCell(Text('${c.totalContractValue} ر.س')),
                DataCell(_buildStatusChip(c.status)),
                DataCell(IconButton(icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14), onPressed: () => context.push('/contracts/${c.id}'))),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildContractsGrid(List<dynamic> contracts) {
    return ListView.builder(
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final c = contracts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(c.contractNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                _buildStatusChip(c.status),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('العميل: ${c.customer?['full_name'] ?? '-'}'),
                Text('السيارة: ${c.vehicle?['make'] ?? ''} ${c.vehicle?['model'] ?? ''}'),
                const SizedBox(height: 4),
                Text('القيمة: ${c.totalContractValue} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
              ],
            ),
            onTap: () => context.push('/contracts/${c.id}'),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    String label = status;
    if (status == 'active') { color = Colors.green; label = 'نشط'; }
    if (status == 'draft') { color = Colors.orange; label = 'مسودة'; }
    if (status == 'closed') { color = Colors.blue; label = 'مغلق'; }
    if (status == 'defaulted') { color = Colors.red; label = 'متعثر'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
