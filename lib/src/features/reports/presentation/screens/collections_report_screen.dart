import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../reports_controller.dart';
import '../../../../core/utils/export_helper.dart';

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

    final currency = intl.NumberFormat.currency(symbol: 'ر.س');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقرير التحصيل التفصيلي'),
          actions: [
            reportAsync.when(
              data: (data) => IconButton(
                icon: const Icon(Icons.file_download_outlined),
                tooltip: 'تصدير CSV',
                onPressed: () => _exportData(data),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterHeader(),
            Expanded(
              child: reportAsync.when(
                data: (data) {
                  if (data.isEmpty) return const Center(child: Text('لا توجد دفعات في هذه الفترة'));
                  
                  double total = data.fold(0, (sum, item) => sum + (item['amount_total'] as num).toDouble());

                  return Column(
                    children: [
                      _buildTotalSummary(total, currency),
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            final contract = item['financing_contracts'];
                            final customer = contract?['customers'];
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                                title: Text(customer?['full_name'] ?? 'عميل غير معروف'),
                                subtitle: Text('عقد: ${contract?['contract_no']} | ${intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(item['payment_date']))}'),
                                trailing: Text(currency.format(item['amount_total']), 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('خطأ: $e')),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: OutlinedButton.icon(
        onPressed: _selectDateRange,
        icon: const Icon(Icons.date_range),
        label: Text('الفترة: ${intl.DateFormat('yyyy/MM/dd').format(dateRange.start)} - ${intl.DateFormat('yyyy/MM/dd').format(dateRange.end)}'),
      ),
    );
  }

  Widget _buildTotalSummary(double total, intl.NumberFormat currency) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('إجمالي التحصيل للفترة', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(currency.format(total), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
    );
    if (picked != null) setState(() => dateRange = picked);
  }
}
