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
      backgroundColor: AppColors.bgGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Container(
          color: AppColors.primaryNavy,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildPremiumHeader(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // شريط البحث والفلاتر
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildModernSearchSection(),
          ),

          Expanded(
            child: customersAsync.when(
              data: (customers) => customers.isEmpty
                  ? _buildEmptyState()
                  : isDesktop
                  ? _buildPremiumTable(customers)
                  : _buildPremiumGrid(customers),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('حدث خطأ: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: !isDesktop
          ? FloatingActionButton.extended(
        onPressed: () => context.push('/crm/customers/new'),
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.primaryNavy,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('إضافة عميل', style: TextStyle(fontWeight: FontWeight.bold)),
      )
          : null,
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
            const Text(
              'إدارة علاقات العملاء (CRM)',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'متابعة الملفات الشخصية، الجدارة الائتمانية، والنشاط التعاقدي',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
            ),
          ],
        ),
        if (ResponsiveLayout.isDesktop(context))
          ElevatedButton.icon(
            onPressed: () => context.push('/crm/customers/new'),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
            label: const Text('إضافة عميل جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.primaryNavy,
              minimumSize: const Size(200, 54),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
      ],
    );
  }

  Widget _buildModernSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'بحث باسم العميل، الهوية، أو رقم الهاتف...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryNavy),
                filled: true,
                fillColor: AppColors.bgGrey.withOpacity(0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildToolButton(Icons.filter_list_rounded, 'تصفية', () {}),
          const SizedBox(width: 12),
          _buildExportMenu(),
        ],
      ),
    );
  }

  Widget _buildPremiumTable(List<dynamic> customers) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.primaryNavy.withOpacity(0.02)),
            dataRowHeight: 80,
            headingRowHeight: 60,
            columns: const [
              DataColumn(label: Text('ملف العميل', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
              DataColumn(label: Text('رقم الهوية', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
              DataColumn(label: Text('الاتصال', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
              DataColumn(label: Text('المخاطر', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
              DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
            ],
            rows: customers.map((c) => DataRow(
              cells: [
                DataCell(Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryNavy.withOpacity(0.05),
                      child: Text(c.fullName.isNotEmpty ? c.fullName[0] : '?',
                          style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                )),
                DataCell(Text(c.nationalId, style: const TextStyle(letterSpacing: 1.2))),
                DataCell(Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(c.phone),
                  ],
                )),
                DataCell(_buildRiskBadge(c.riskRating)),
                DataCell(IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primaryNavy),
                  onPressed: () => context.push('/crm/customers/${c.id}'),
                )),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumGrid(List<dynamic> customers) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final c = customers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppColors.bgGrey,
              child: Text(c.fullName.isNotEmpty ? c.fullName[0] : '?'),
            ),
            title: Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(c.phone),
            trailing: _buildRiskBadge(c.riskRating),
            onTap: () => context.push('/crm/customers/${c.id}'),
          ),
        );
      },
    );
  }

  Widget _buildRiskBadge(String rating) {
    Color color = AppColors.successGreen;
    String label = 'منخفضة';
    if (rating == 'medium') { color = Colors.orange; label = 'متوسطة'; }
    if (rating == 'high') { color = AppColors.errorRed; label = 'عالية'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 20, color: AppColors.primaryNavy),
      ),
    );
  }

  Widget _buildExportMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Icon(Icons.download_rounded, size: 20, color: AppColors.primaryNavy),
      ),
      onSelected: (val) => _handleExport(val),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'pdf', child: Text('تصدير بصيغة PDF')),
        const PopupMenuItem(value: 'excel', child: Text('تصدير بصيغة Excel')),
      ],
    );
  }

  Future<void> _handleExport(String format) async {
    final customersAsync = ref.read(customersListProvider(searchQuery: searchQuery));
    final customers = customersAsync.valueOrNull;

    if (customers == null || customers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد بيانات لتصديرها')),
        );
      }
      return;
    }

    final exportService = ref.read(exportServiceProvider);
    final columns = ['الاسم الكامل', 'رقم الهوية', 'رقم الهاتف', 'مستوى المخاطر', 'البريد الإلكتروني'];

    try {
      if (format == 'excel') {
        final data = customers.map((c) => c.toJson()).toList();
        final dataKeys = ['full_name', 'national_id', 'phone', 'risk_rating', 'email'];
        await exportService.exportToExcel(
          fileName: 'قائمة_العملاء_${DateTime.now().millisecondsSinceEpoch}',
          columns: columns,
          data: data,
          dataKeys: dataKeys,
        );
      } else if (format == 'pdf') {
        final rows = customers.map((c) => [
          c.fullName,
          c.nationalId,
          c.phone,
          c.riskRating == 'low' ? 'منخفضة' : (c.riskRating == 'high' ? 'عالية' : 'متوسطة'),
          c.email ?? '-',
        ]).toList();

        await exportService.exportToPdf(
          title: 'تقرير قائمة العملاء',
          columns: columns,
          rows: rows,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء التصدير: $e')),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('لا يوجد عملاء مسجلون حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
