import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
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
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('سجل العقود والتمويل', 
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/contracts/new'),
                icon: const Icon(Icons.add_task_rounded, size: 16),
                label: const Text('إصدار عقد جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Column(
        children: [
          // إحصائيات كلاسيكية مدمجة
          _buildCompactStatsBar(statsAsync, f),
          
          // شريط البحث المدمج
          _buildCompactFilterBar(),

          Expanded(
            child: contractsAsync.when(
              data: (contracts) => contracts.isEmpty 
                ? _buildEmptyState()
                : _buildClassicTable(contracts, f),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('حدث خطأ في تحميل البيانات')),
            ),
          ),
        ],
      ),
      floatingActionButton: !isDesktop ? FloatingActionButton(
        onPressed: () => context.push('/contracts/new'),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildCompactStatsBar(AsyncValue<Map<String, dynamic>> statsAsync, intl.NumberFormat f) {
    return statsAsync.when(
      data: (stats) => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            _buildSmallStat('إجمالي العقود', stats['total'] ?? 0, Colors.blue),
            _buildDivider(),
            _buildSmallStat('نشطة', stats['active'] ?? 0, Colors.green),
            _buildDivider(),
            _buildSmallStat('متأخرات', f.format(stats['total_overdue'] ?? 0), Colors.red),
            _buildDivider(),
            _buildSmallStat('مسودات', stats['draft'] ?? 0, Colors.orange),
          ],
        ),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildSmallStat(String label, dynamic value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
      ],
    );
  }

  Widget _buildDivider() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(width: 1, height: 15, color: Colors.grey.shade300),
  );

  Widget _buildCompactFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade300)),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'بحث برقم العقد، اسم العميل، أو السيارة...',
                  prefixIcon: Icon(Icons.search, size: 16),
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade300)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: statusFilter,
                style: const TextStyle(fontSize: 13, color: AppColors.primaryNavy),
                hint: const Text('تصفية الحالة', style: TextStyle(fontSize: 12)),
                onChanged: (val) => setState(() => statusFilter = val),
                items: const [
                  DropdownMenuItem(value: null, child: Text('كافة العقود')),
                  DropdownMenuItem(value: 'active', child: Text('نشطة')),
                  DropdownMenuItem(value: 'draft', child: Text('مسودات')),
                  DropdownMenuItem(value: 'closed', child: Text('مكتملة')),
                  DropdownMenuItem(value: 'defaulted', child: Text('متعثرة')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassicTable(List<dynamic> contracts, intl.NumberFormat f) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 45,
          dataRowHeight: 55,
          horizontalMargin: 16,
          columnSpacing: 24,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          columns: const [
            DataColumn(label: Text('رقم العقد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('العميل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('المركبة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('القيمة الإجمالية', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الحالة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('إجراء', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          ],
          rows: contracts.map((c) => DataRow(
            cells: [
              DataCell(Text(c.contractNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
              DataCell(Text(c.customer?['full_name'] ?? '-', style: const TextStyle(fontSize: 13))),
              DataCell(Text('${c.vehicle?['make'] ?? ''} ${c.vehicle?['model'] ?? ''}', style: const TextStyle(fontSize: 12))),
              DataCell(Text('${f.format(c.totalContractValue)} ر.س', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
              DataCell(_buildStatusChip(c.status)),
              DataCell(IconButton(
                icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.blue),
                onPressed: () => context.push('/contracts/${c.id}'),
              )),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    String label = status;
    if (status == 'active') { color = Colors.green; label = 'نشط'; }
    if (status == 'draft') { color = Colors.orange; label = 'مسودة'; }
    if (status == 'closed') { color = Colors.blue; label = 'مكتمل'; }
    if (status == 'defaulted') { color = Colors.red; label = 'متعثر'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('لا توجد عقود مسجلة حالياً', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
