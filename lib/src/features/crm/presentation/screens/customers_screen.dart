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
    final customersAsync = ref.watch(
      customersListProvider(searchQuery: searchQuery),
    );
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor:
          Colors.transparent, // لأن الخلفية تأتي من الـ Scaffold الرئيسي
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchAndFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: customersAsync.when(
                data: (customers) => isDesktop
                    ? _buildCustomersTable(customers)
                    : _buildCustomersCards(customers),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('حدث خطأ: $err')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !isDesktop
          ? FloatingActionButton(
              onPressed: () => context.push('/crm/customers/new'),
              backgroundColor: AppColors.primaryNavy,
              child: const Icon(Icons.person_add_alt_1, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'قاعدة بيانات العملاء',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            Text(
              'إدارة وتتبع بيانات العملاء والمخاطر الائتمانية',
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
          ],
        ),
        if (ResponsiveLayout.isDesktop(context))
          ElevatedButton.icon(
            onPressed: () => context.push('/crm/customers/new'),
            icon: const Icon(Icons.person_add_alt_1, size: 18),
            label: const Text('إضافة عميل جديد'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(180, 50)),
          ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'بحث باسم العميل، الهوية، أو رقم الهاتف...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: AppColors.bgGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildActionButton(Icons.filter_list_rounded, 'تصفية'),
          const SizedBox(width: 8),
          _buildExportMenu(),
        ],
      ),
    );
  }

  Widget _buildCustomersTable(List<dynamic> customers) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.bgGrey),
          dataRowHeight: 70,
          columns: const [
            DataColumn(
              label: Text(
                'العميل',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'رقم الهوية',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'رقم الجوال',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'درجة المخاطر',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'الإجراءات',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: customers
              .map(
                (c) => DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primaryNavy.withOpacity(
                              0.1,
                            ),
                            child: Text(
                              c.fullName[0],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            c.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(c.nationalId)),
                    DataCell(Text(c.phone)),
                    DataCell(_buildRiskChip(c.riskRating)),
                    DataCell(
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                        ),
                        onPressed: () => context.push('/crm/customers/${c.id}'),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCustomersCards(List<dynamic> customers) {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final c = customers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppColors.bgGrey,
              child: Text(c.fullName[0]),
            ),
            title: Text(
              c.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(c.phone),
            trailing: _buildRiskChip(c.riskRating),
            onTap: () => context.push('/crm/customers/${c.id}'),
          ),
        );
      },
    );
  }

  Widget _buildRiskChip(String rating) {
    Color color = AppColors.successGreen;
    String label = 'منخفضة';
    if (rating == 'medium') {
      color = Colors.orange;
      label = 'متوسطة';
    }
    if (rating == 'high') {
      color = AppColors.errorRed;
      label = 'عالية';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: AppColors.primaryNavy),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فلترة متقدمة — ستكون متاحة قريباً'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExportMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: const Icon(
          Icons.download_rounded,
          size: 20,
          color: AppColors.primaryNavy,
        ),
      ),
      onSelected: (val) => _handleExport(val),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'pdf', child: Text('تصدير كـ PDF')),
        const PopupMenuItem(value: 'excel', child: Text('تصدير كـ Excel')),
      ],
    );
  }

  Future<void> _handleExport(String format) async {
    final customersAsync = ref.read(
      customersListProvider(searchQuery: searchQuery),
    );
    final customers = customersAsync.valueOrNull ?? [];
    if (customers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا يوجد عملاء للتصدير')));
      return;
    }

    final exportService = ref.read(exportServiceProvider);
    final columns = ['الاسم', 'رقم الهوية', 'الجوال', 'درجة المخاطر'];
    final rows = customers
        .map(
          (c) => [
            c.fullName,
            c.nationalId,
            c.phone,
            c.riskRating == 'high'
                ? 'عالية'
                : (c.riskRating == 'medium' ? 'متوسطة' : 'منخفضة'),
          ],
        )
        .toList();

    if (format == 'pdf') {
      await exportService.exportToPdf(
        title: 'قائمة العملاء',
        columns: columns,
        rows: rows,
      );
    } else {
      await exportService.exportToExcel(
        fileName: 'قائمة_العملاء',
        columns: columns,
        rows: rows,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تصدير الملف كـ ${format.toUpperCase()} بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
