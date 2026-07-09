import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/supabase_dashboard_repository.dart';

class GlobalSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  GlobalSearchDelegate(this.ref)
      : super(
    searchFieldLabel: 'بحث في النظام...',
    searchFieldStyle: const TextStyle(fontSize: 16),
  );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('أدخل اسم العميل، رقم العقد، أو ماركة السيارة للبحث'),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<Map<String, List<dynamic>>>(
      future: ref.read(dashboardRepositoryProvider).globalSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || (snapshot.data!['customers']!.isEmpty &&
            snapshot.data!['vehicles']!.isEmpty &&
            snapshot.data!['contracts']!.isEmpty &&
            snapshot.data!['investors']!.isEmpty)) {
          return const Center(child: Text('لا توجد نتائج مطابقة'));
        }

        final data = snapshot.data!;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (data['customers']!.isNotEmpty) ...[
                _buildSectionHeader('العملاء'),
                ...data['customers']!.map((c) => ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(c['full_name']),
                  subtitle: Text('هوية: ${c['national_id']}'),
                  onTap: () {
                    close(context, null);
                    context.push('/crm/customers/${c['id']}');
                  },
                )),
              ],
              if (data['vehicles']!.isNotEmpty) ...[
                _buildSectionHeader('السيارات والمخزون'),
                ...data['vehicles']!.map((v) => ListTile(
                  leading: const Icon(Icons.directions_car, color: Colors.orange),
                  title: Text('${v['make']} ${v['model']}'),
                  subtitle: Text('لوحة: ${v['license_plate'] ?? "بدون"} | هيكل: ${v['vin']}'),
                  onTap: () {
                    close(context, null);
                    context.push('/inventory/${v['id']}');
                  },
                )),
              ],
              if (data['contracts']!.isNotEmpty) ...[
                _buildSectionHeader('عقود التمويل'),
                ...data['contracts']!.map((con) => ListTile(
                  leading: const Icon(Icons.description, color: Colors.green),
                  title: Text('عقد رقم: ${con['contract_no']}'),
                  onTap: () {
                    close(context, null);
                    context.push('/contracts/${con['id']}');
                  },
                )),
              ],
              if (data['investors']!.isNotEmpty) ...[
                _buildSectionHeader('المستثمرين'),
                ...data['investors']!.map((inv) => ListTile(
                  leading: const Icon(Icons.trending_up, color: Colors.teal),
                  title: Text(inv['full_name']),
                  onTap: () {
                    close(context, null);
                    context.push('/investors/${inv['id']}');
                  },
                )),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 16),
      ),
    );
  }
}
