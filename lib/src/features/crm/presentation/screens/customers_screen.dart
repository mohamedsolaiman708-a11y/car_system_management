import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../crm_controller.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersListProvider(searchQuery: _searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء (CRM)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(customersListProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'بحث باسم العميل، رقم الهوية، أو رقم الهاتف...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                if (customers.isEmpty) {
                  return const Center(child: Text('لا يوجد عملاء مضافين حالياً'));
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('الاسم الكامل')),
                        DataColumn(label: Text('رقم الهوية')),
                        DataColumn(label: Text('رقم الهاتف')),
                        DataColumn(label: Text('العنوان')),
                        DataColumn(label: Text('تقييم المخاطر')),
                        DataColumn(label: Text('تاريخ الإضافة')),
                        DataColumn(label: Text('الإجراءات')),
                      ],
                      rows: customers.map((customer) {
                        return DataRow(cells: [
                          DataCell(Text(customer.fullName)),
                          DataCell(Text(customer.nationalId)),
                          DataCell(Text(customer.phone)),
                          DataCell(Text(customer.address ?? '-')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getRiskColor(customer.riskRating).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getRiskColor(customer.riskRating).withOpacity(0.5)),
                              ),
                              child: Text(
                                _getRiskLabel(customer.riskRating),
                                style: TextStyle(
                                  color: _getRiskColor(customer.riskRating),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(DateFormat('yyyy/MM/dd').format(customer.createdAt))),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.blue),
                                  onPressed: () => context.go('/crm/customers/${customer.id}'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => context.go('/crm/customers/${customer.id}/edit'),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/crm/customers/new'),
        label: const Text('إضافة عميل جديد'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'low':
        return Colors.green;
      case 'high':
        return Colors.red;
      case 'medium':
      default:
        return Colors.orange;
    }
  }

  String _getRiskLabel(String risk) {
    switch (risk) {
      case 'low':
        return 'منخفضة';
      case 'high':
        return 'عالية';
      case 'medium':
      default:
        return 'متوسطة';
    }
  }
}
