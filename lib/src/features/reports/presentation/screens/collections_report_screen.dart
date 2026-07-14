import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../reports_controller.dart';
import '../../../../core/utils/export_helper.dart';
import '../../../../core/utils/app_theme.dart';

class CollectionsReportScreen extends ConsumerStatefulWidget {
  const CollectionsReportScreen({super.key});

  @override
  ConsumerState<CollectionsReportScreen> createState() => _CollectionsReportScreenState();
}

class _CollectionsReportScreenState extends ConsumerState<CollectionsReportScreen> {
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(collectionsReportProvider(
      startDate: dateRange.start,
      endDate: dateRange.end,
    ));

    final currency = intl.NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Container(
            color: AppColors.primaryNavy,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('تقرير التحصيل التفصيلي',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('سجل التدفقات النقدية الداخلة من العقود',
                                style: TextStyle(color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                        _buildDateRangePicker(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: reportAsync.when(
          data: (data) {
            if (data.isEmpty) {
              return _buildEmptyState();
            }

            double total = data.fold(0, (sum, item) => sum + (item['amount_total'] as num).toDouble());

            return Column(
              children: [
                _buildSummaryHeader(total, currency, data.length),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      final contract = item['financing_contracts'];
                      final customer = contract?['customers'];
                      
                      return _buildCollectionCard(item, customer, contract, currency);
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
        floatingActionButton: reportAsync.maybeWhen(
          data: (data) => data.isNotEmpty ? FloatingActionButton.extended(
            onPressed: () => _exportData(data),
            backgroundColor: AppColors.accentGold,
            foregroundColor: AppColors.primaryNavy,
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('تصدير التقرير'),
          ) : null,
          orElse: () => null,
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return InkWell(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: AppColors.accentGold, size: 18),
            const SizedBox(width: 10),
            Text(
              '${intl.DateFormat('dd/MM').format(dateRange.start)} - ${intl.DateFormat('dd/MM').format(dateRange.end)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(double total, intl.NumberFormat currency, int count) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إجمالي المحصل', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 4),
              Text(currency.format(total), 
                style: const TextStyle(color: AppColors.successGreen, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const Text('عدد العمليات', style: TextStyle(color: Colors.grey, fontSize: 11)),
                Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCollectionCard(Map<String, dynamic> item, dynamic customer, dynamic contract, intl.NumberFormat currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_downward_rounded, color: AppColors.successGreen, size: 20),
        ),
        title: Text(customer?['full_name'] ?? 'عميل غير معروف', 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('عقد: ${contract?['contract_no']} | ${intl.DateFormat('dd MMMM yyyy', 'ar').format(DateTime.parse(item['payment_date']))}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        trailing: Text(currency.format(item['amount_total']), 
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy, fontSize: 16)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('لا توجد دفعات محصلة في هذه الفترة', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: dateRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryNavy, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => dateRange = picked);
  }

  void _exportData(List<Map<String, dynamic>> data) async {
    final headers = ['العميل', 'رقم العقد', 'التاريخ', 'المبلغ'];
    final rows = data.map((item) {
      final contract = item['financing_contracts'];
      final customer = contract?['customers'];
      return [
        customer?['full_name'] ?? 'غير معروف',
        contract?['contract_no'] ?? '',
        intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(item['payment_date'])),
        item['amount_total'].toString(),
      ];
    }).toList();

    await ExportHelper.exportToCsv(
      fileName: 'تقرير_التحصيل_${intl.DateFormat('yyyyMMdd').format(DateTime.now())}',
      headers: headers,
      rows: rows,
    );
  }
}
