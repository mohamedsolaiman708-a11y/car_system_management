import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../inventory_controller.dart';

class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  String searchQuery = '';
  String? statusFilter;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesListProvider(
      searchQuery: searchQuery,
      status: statusFilter,
    ));
    final statsAsync = ref.watch(inventoryStatsProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final f = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('إدارة المخزون والأسطول', 
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/inventory/new'),
                icon: const Icon(Icons.add_road_rounded, size: 16),
                label: const Text('إضافة مركبة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(140, 0),
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
          // إحصائيات مدمجة
          _buildCompactStatsBar(statsAsync),
          
          // شريط البحث المنسق
          _buildCompactFilterBar(),

          Expanded(
            child: vehiclesAsync.when(
              data: (vehicles) {
                if (vehicles.isEmpty) return _buildEmptyState();
                return isDesktop 
                    ? _buildClassicTable(vehicles, f)
                    : _buildClassicMobileList(vehicles, f);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('حدث خطأ في تحميل البيانات')),
            ),
          ),
        ],
      ),
      floatingActionButton: !isDesktop ? FloatingActionButton(
        onPressed: () => context.push('/inventory/new'),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildClassicMobileList(List<dynamic> vehicles, intl.NumberFormat f) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final v = vehicles[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text('${v.make} ${v.model}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('لوحة: ${v.licensePlate ?? "-"} | سنة: ${v.year}', style: const TextStyle(fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusChip(v.status),
                const SizedBox(height: 4),
                Text('${f.format(v.purchasePrice)} ر.س', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            onTap: () => context.push('/inventory/${v.id}'),
          ),
        );
      },
    );
  }

  Widget _buildClassicTable(List<dynamic> vehicles, intl.NumberFormat f) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 40,
          dataRowHeight: 50,
          horizontalMargin: 16,
          columnSpacing: 24,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          columns: const [
            DataColumn(label: Text('المركبة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('اللوحة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('سنة الصنع', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الحالة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('سعر الشراء', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('إجراء', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          ],
          rows: vehicles.map((v) => DataRow(
            cells: [
              DataCell(Text('${v.make} ${v.model}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
              DataCell(Text(v.licensePlate ?? '-', style: const TextStyle(fontSize: 13, fontFamily: 'monospace'))),
              DataCell(Text(v.year.toString(), style: const TextStyle(fontSize: 13))),
              DataCell(_buildStatusChip(v.status)),
              DataCell(Text('${f.format(v.purchasePrice)} ر.س', style: const TextStyle(fontSize: 13))),
              DataCell(IconButton(icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.blue), onPressed: () => context.push('/inventory/${v.id}'))),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildCompactStatsBar(AsyncValue<Map<String, dynamic>> statsAsync) {
    return statsAsync.when(
      data: (stats) => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          children: [
            _buildSmallStat('الإجمالي', stats['total'] ?? 0, Colors.blue),
            _buildDivider(),
            _buildSmallStat('متاحة', stats['available'] ?? 0, Colors.green),
            _buildDivider(),
            _buildSmallStat('عقود نشطة', stats['on_contract'] ?? 0, AppColors.accentGold),
            _buildDivider(),
            _buildSmallStat('صيانة', stats['maintenance'] ?? 0, Colors.orange),
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
                  hintText: 'بحث برقم اللوحة، الموديل، VIN...',
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
                  DropdownMenuItem(value: null, child: Text('كافة الحالات')),
                  DropdownMenuItem(value: 'available', child: Text('متاحة')),
                  DropdownMenuItem(value: 'on_contract', child: Text('تحت عقد')),
                  DropdownMenuItem(value: 'maintenance', child: Text('صيانة')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    String label = status;
    if (status == 'available') { color = Colors.green; label = 'متاحة'; }
    if (status == 'on_contract' || status == 'sold') { color = AppColors.accentGold; label = 'مباعة'; }
    if (status == 'maintenance') { color = Colors.orange; label = 'صيانة'; }

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
          Icon(Icons.directions_car_filled_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('لا توجد مركبات مطابقة للبحث', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
