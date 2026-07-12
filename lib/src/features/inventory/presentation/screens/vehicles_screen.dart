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
      backgroundColor: AppColors.bgGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Container(
          color: AppColors.primaryNavy,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPremiumHeader(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // لوحة الإحصائيات الفاخرة
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _buildExecutiveStats(statsAsync),
          ),

          // منطقة الفلاتر والبحث
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildModernFilterBar(),
          ),

          Expanded(
            child: vehiclesAsync.when(
              data: (vehicles) => vehicles.isEmpty
                  ? _buildEmptyState()
                  : isDesktop
                  ? _buildPremiumTable(vehicles, f)
                  : _buildPremiumGrid(vehicles, f),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('حدث خطأ: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: !isDesktop ? FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/new'),
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.primaryNavy,
        icon: const Icon(Icons.add_road_rounded),
        label: const Text('إضافة سيارة', style: TextStyle(fontWeight: FontWeight.bold)),
      ) : null,
    );
  }

  Widget _buildPremiumHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إدارة أصول الأسطول',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('تتبع المخزون، تقييم الأصول، وحالات التوافر اللحظية',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          ],
        ),
        if (ResponsiveLayout.isDesktop(context))
          ElevatedButton.icon(
            onPressed: () => context.push('/inventory/new'),
            icon: const Icon(Icons.add_road_rounded, size: 20),
            label: const Text('إضافة مركبة للمخزون'),
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

  Widget _buildExecutiveStats(AsyncValue<Map<String, dynamic>> statsAsync) {
    return statsAsync.when(
      data: (stats) => Row(
        children: [
          _buildExecutiveStatCard('إجمالي الأسطول', stats['total'] ?? 0, Icons.directions_car_rounded, Colors.blue),
          const SizedBox(width: 20),
          _buildExecutiveStatCard('متاحة للبيع', stats['available'] ?? 0, Icons.check_circle_rounded, Colors.green),
          const SizedBox(width: 20),
          _buildExecutiveStatCard('تحت التعاقد', stats['on_contract'] ?? 0, Icons.assignment_turned_in_rounded, AppColors.accentGold),
          const SizedBox(width: 20),
          _buildExecutiveStatCard('في الصيانة', stats['maintenance'] ?? 0, Icons.build_rounded, Colors.orange),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'البحث برقم اللوحة، الموديل، أو رقم الهيكل...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryNavy),
                filled: true,
                fillColor: AppColors.bgGrey.withOpacity(0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _buildPremiumDropdown(),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: statusFilter,
          hint: const Text('تصفية الحالة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          icon: const Icon(Icons.filter_list_rounded, color: AppColors.primaryNavy),
          isExpanded: true,
          onChanged: (val) => setState(() => statusFilter = val),
          items: [
            const DropdownMenuItem(value: null, child: Text('كافة الحالات')),
            const DropdownMenuItem(value: 'available', child: Text('متاحة')),
            const DropdownMenuItem(value: 'on_contract', child: Text('تحت عقد')),
            const DropdownMenuItem(value: 'maintenance', child: Text('صيانة')),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumTable(List<dynamic> vehicles, intl.NumberFormat f) {
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
              DataColumn(label: Text('المركبة والموديل', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
              DataColumn(label: Text('بيانات اللوحة', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
              DataColumn(label: Text('الحالة التشغيلية', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
              DataColumn(label: Text('القيمة الشرائية', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
              DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy))),
            ],
            rows: vehicles.map((v) => DataRow(
              cells: [
                DataCell(Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.directions_car_rounded, color: AppColors.primaryNavy, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${v.make} ${v.model}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('سنة الصنع: ${v.year}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                )),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                  child: Text(v.licensePlate ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                )),
                DataCell(_buildStatusBadge(v.status)),
                DataCell(Text('${f.format(v.purchasePrice)} ر.س', style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(IconButton(
                  icon: const Icon(Icons.settings_suggest_rounded, color: AppColors.primaryNavy),
                  onPressed: () => context.push('/inventory/${v.id}'),
                )),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumGrid(List<dynamic> vehicles, intl.NumberFormat f) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 20, mainAxisSpacing: 20),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final v = vehicles[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: InkWell(
            onTap: () => context.push('/inventory/${v.id}'),
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.bgGrey,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: const Center(child: Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 48)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${v.make} ${v.model}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(v.status),
                          Text(v.licensePlate ?? '-', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('${f.format(v.purchasePrice)} ر.س',
                          style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    String label = status;
    if (status == 'available') { color = Colors.green; label = 'متاحة للبيع'; }
    if (status == 'on_contract' || status == 'sold') { color = AppColors.accentGold; label = 'نشطة بعقد'; }
    if (status == 'maintenance') { color = Colors.orange; label = 'تحت الصيانة'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_photography_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('لا يوجد مركبات مسجلة في المخزون حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
