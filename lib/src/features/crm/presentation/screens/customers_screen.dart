import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/export_service.dart';
import '../crm_controller.dart';
import 'package:intl/intl.dart' as intl;

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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة العملاء'),
          actions: [
            _buildExportButton(ref),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(customersListProvider),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: customersAsync.when(
                data: (customers) => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(customer.fullName),
                        subtitle: Text('الهوية: ${customer.nationalId} | الهاتف: ${customer.phone}'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => context.push('/crm/customers/${customer.id}'),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('خطأ: $err')),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/crm/customers/new'),
          label: const Text('عميل جديد'),
          icon: const Icon(Icons.person_add_alt_1),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (val) => setState(() => searchQuery = val),
        decoration: InputDecoration(
          hintText: 'بحث باسم العميل، الهوية، أو رقم الهاتف...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildExportButton(WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.download_rounded),
      onSelected: (val) => _handleExport(val, ref),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'pdf', child: Text('تصدير كـ PDF')),
        const PopupMenuItem(value: 'excel', child: Text('تصدير كـ Excel')),
      ],
    );
  }

  Future<void> _handleExport(String format, WidgetRef ref) async {
    final customers = ref.read(customersListProvider(searchQuery: searchQuery)).value ?? [];
    if (customers.isEmpty) return;

    final exportService = ref.read(exportServiceProvider);
    final columns = ['الاسم الكامل', 'رقم الهوية', 'الهاتف', 'المخاطر'];
    final rows = customers.map((c) => [
      c.fullName,
      c.nationalId,
      c.phone,
      c.riskRating,
    ]).toList();

    if (format == 'pdf') {
      await exportService.exportToPdf(title: 'قائمة العملاء', columns: columns, rows: rows);
    } else {
      await exportService.exportToExcel(fileName: 'قائمة_العملاء', columns: columns, rows: rows);
    }
  }
}
