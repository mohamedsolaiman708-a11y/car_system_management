import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/search_result.dart';
import '../search_controller.dart';

class GlobalSearchScreen extends ConsumerWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(filteredSearchResultsProvider);
    final query = ref.watch(searchQueryControllerProvider);
    final currentFilter = ref.watch(searchFilterControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('البحث الشامل'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => ref.read(searchQueryControllerProvider.notifier).updateQuery(val),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن عميل، مستثمر، عقد، أو موظف...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => ref.read(searchQueryControllerProvider.notifier).updateQuery(''),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'الكل',
                          isSelected: currentFilter == null,
                          onSelected: (_) => ref.read(searchFilterControllerProvider.notifier).setFilter(null),
                        ),
                        ...SearchEntityType.values.map((type) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _FilterChip(
                            label: _getEntityLabel(type),
                            isSelected: currentFilter == type,
                            onSelected: (_) => ref.read(searchFilterControllerProvider.notifier).setFilter(type),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: query.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('ابدأ الكتابة للبحث في النظام...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : _buildResultsList(context, searchResults, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<SearchResult> results, WidgetRef ref) {
    final state = ref.watch(globalSearchControllerProvider);

    return state.when(
      data: (data) {
        if (results.isEmpty) {
          return const Center(child: Text('لا توجد نتائج مطابقة.'));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return ListTile(
              leading: _getEntityIcon(result.entityType),
              title: Text(result.title),
              subtitle: Text(result.subtitle ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _handleNavigation(context, result),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
    );
  }

  String _getEntityLabel(SearchEntityType type) {
    switch (type) {
      case SearchEntityType.customer: return 'عملاء';
      case SearchEntityType.investor: return 'مستثمرين';
      case SearchEntityType.contract: return 'عقود';
      case SearchEntityType.payment: return 'مدفوعات';
      case SearchEntityType.staff: return 'موظفين';
    }
  }

  Widget _getEntityIcon(SearchEntityType type) {
    IconData iconData;
    Color color;
    switch (type) {
      case SearchEntityType.customer:
        iconData = Icons.person_outline;
        color = Colors.blue;
        break;
      case SearchEntityType.investor:
        iconData = Icons.monetization_on_outlined;
        color = Colors.green;
        break;
      case SearchEntityType.contract:
        iconData = Icons.description_outlined;
        color = Colors.orange;
        break;
      case SearchEntityType.payment:
        iconData = Icons.payment_outlined;
        color = Colors.purple;
        break;
      case SearchEntityType.staff:
        iconData = Icons.badge_outlined;
        color = Colors.teal;
        break;
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(iconData, color: color),
    );
  }

  void _handleNavigation(BuildContext context, SearchResult result) {
    switch (result.entityType) {
      case SearchEntityType.customer:
        context.push('/crm/customers/${result.id}');
        break;
      case SearchEntityType.investor:
        context.push('/investors/${result.id}');
        break;
      case SearchEntityType.contract:
        context.push('/contracts/${result.id}');
        break;
      case SearchEntityType.payment:
        // إذا كانت النتيجة دفعة، ننتقل لتفاصيل العقد المرتبط بها
        final contractId = result.metadata['contract_id'];
        if (contractId != null) {
          context.push('/contracts/$contractId');
        }
        break;
      case SearchEntityType.staff:
        // يمكن إضافة مسار خاص بإدارة الموظفين هنا لاحقاً
        // context.push('/settings/staff/${result.id}');
        break;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}
