import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../domain/contract.dart';
import '../contract_controller.dart';

class ContractsScreen extends ConsumerStatefulWidget {
  const ContractsScreen({super.key});

  @override
  ConsumerState<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends ConsumerState<ContractsScreen> {
  String _searchQuery = '';
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(contractsListProvider(
      searchQuery: _searchQuery,
      status: _selectedStatus,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة عقود التمويل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(contractsListProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: contractsAsync.when(
              data: (contracts) {
                if (contracts.isEmpty) {
                  return const Center(child: Text('لا توجد عقود تمويل حالياً'));
                }
                return _buildContractsTable(contracts);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/contracts/new'),
        label: const Text('إنشاء عقد جديد'),
        icon: const Icon(Icons.add_task),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'بحث برقم العقد...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              hint: const Text('الحالة'),
              items: const [
                DropdownMenuItem(value: null, child: Text('الكل')),
                DropdownMenuItem(value: 'draft', child: Text('مسودة')),
                DropdownMenuItem(value: 'active', child: Text('نشط')),
                DropdownMenuItem(value: 'closed', child: Text('مغلق')),
                DropdownMenuItem(value: 'defaulted', child: Text('متعثر')),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractsTable(List<Contract> contracts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('رقم العقد')),
            DataColumn(label: Text('العميل')),
            DataColumn(label: Text('المبلغ الأساسي')),
            DataColumn(label: Text('المدة')),
            DataColumn(label: Text('الحالة')),
            DataColumn(label: Text('تاريخ البدء')),
            DataColumn(label: Text('الإجراءات')),
          ],
          rows: contracts.map((contract) {
            final currencyFormat = intl.NumberFormat.currency(symbol: '', decimalDigits: 0);
            return DataRow(cells: [
              DataCell(Text(contract.contractNo)),
              DataCell(Text(contract.customer?['full_name'] ?? '-')),
              DataCell(Text('${currencyFormat.format(contract.principalAmount)} ر.س')),
              DataCell(Text('${contract.durationMonths} شهر')),
              DataCell(_StatusBadge(status: contract.status)),
              DataCell(Text(contract.startDate != null ? intl.DateFormat('yyyy/MM/dd').format(contract.startDate!) : '-')),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  onPressed: () => context.push('/contracts/${contract.id}'),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = Colors.green;
        label = 'نشط';
        break;
      case 'draft':
        color = Colors.grey;
        label = 'مسودة';
        break;
      case 'closed':
        color = Colors.blue;
        label = 'مغلق';
        break;
      case 'defaulted':
        color = Colors.red;
        label = 'متعثر';
        break;
      default:
        color = Colors.orange;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
