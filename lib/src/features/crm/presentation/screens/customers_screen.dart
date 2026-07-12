import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/services/export_service.dart';
import '../crm_controller.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersListProvider(searchQuery: searchQuery));
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('دليل العملاء والتمويل', 
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/crm/customers/new'),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: const Text('إضافة عميل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
          _buildCompactSearchBar(),
          Expanded(
            child: customersAsync.when(
              data: (customers) => customers.isEmpty 
                ? _buildEmptyState()
                : _buildClassicTable(customers),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('حدث خطأ في تحميل البيانات')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(hintText: 'بحث...', prefixIcon: Icon(Icons.search, size: 14), border: InputBorder.none, contentPadding: EdgeInsets.zero),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildExportMenu(),
        ],
      ),
    );
  }

  Widget _buildExportMenu() {
    return PopupMenuButton<String>(
      tooltip: 'تصدير البيانات',
      icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.primaryNavy),
      onSelected: _handleExport,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'pdf', child: Text('تصدير PDF')),
        const PopupMenuItem(value: 'excel', child: Text('تصدير Excel')),
      ],
    );
  }

  Future<void> _handleExport(String format) async {
    final customers = ref.read(customersListProvider(searchQuery: searchQuery)).valueOrNull ?? [];
    if (customers.isEmpty) return;

    final exportService = ref.read(exportServiceProvider);
    final columns = ['الاسم', 'رقم الهوية', 'الجوال', 'المخاطر'];
    final exportData = customers.map((c) => {
      'full_name': c.fullName,
      'national_id': c.nationalId,
      'phone': c.phone,
      'risk': c.riskRating,
    }).toList();

    if (format == 'pdf') {
      await exportService.exportToPdf(
        title: 'قائمة العملاء',
        columns: columns,
        rows: exportData.map((e) => [e['full_name'], e['national_id'], e['phone'], e['risk']]).toList(),
      );
    } else {
      await exportService.exportToExcel(fileName: 'العملاء', columns: columns, data: exportData, dataKeys: ['full_name', 'national_id', 'phone', 'risk']);
    }
  }

  Widget _buildClassicTable(List<dynamic> customers) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 40,
          dataRowHeight: 50,
          horizontalMargin: 16,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          columns: const [
            DataColumn(label: Text('الاسم', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الهوية', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الجوال', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('إجراء', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          ],
          rows: customers.map((c) => DataRow(
            cells: [
              DataCell(Text(c.fullName, style: const TextStyle(fontSize: 13))),
              DataCell(Text(c.nationalId, style: const TextStyle(fontSize: 12))),
              DataCell(Text(c.phone, style: const TextStyle(fontSize: 12))),
              DataCell(IconButton(icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.blue), onPressed: () => context.push('/crm/customers/${c.id}'))),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text('لا توجد بيانات', style: TextStyle(color: Colors.grey)));
}
