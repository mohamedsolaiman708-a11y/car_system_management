import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../crm/presentation/crm_controller.dart';
import '../../../inventory/presentation/inventory_controller.dart';
import '../../../contracts/presentation/contract_controller.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'الكل';

  final List<String> _categories = ['الكل', 'العملاء', 'السيارات', 'العقود', 'المستثمرين'];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          elevation: 0,
          title: const Text('المحرك الذكي للبحث'),
        ),
        body: Column(
          children: [
            _buildSearchHeader(),
            _buildCategoryFilters(),
            Expanded(
              child: _query.isEmpty 
                ? _buildRecentSearches() 
                : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.primaryNavy,
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (val) => setState(() => _query = val),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'ابحث عن عميل، سيارة، رقم عقد، أو مستثمر...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: AppColors.accentGold),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          suffixIcon: _query.isNotEmpty 
            ? IconButton(icon: const Icon(Icons.clear, color: Colors.white70), onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              }) 
            : null,
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cat),
              selectedColor: AppColors.primaryNavy,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.primaryNavy, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    // محاكاة نتائج البحث المدمجة من عدة مصادر
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_selectedCategory == 'الكل' || _selectedCategory == 'العملاء') ...[
          _buildResultSection('العملاء والمشترين', Icons.people, [
            _buildResultTile('محمد أحمد العتيبي', 'هوية: 1029384756', Icons.person, () => context.push('/crm/customers/1')),
            _buildResultTile('شركة الرواد للتجارة', 'عميل تجاري نشط', Icons.business, () => {}),
          ]),
        ],
        if (_selectedCategory == 'الكل' || _selectedCategory == 'السيارات') ...[
          _buildResultSection('السيارات والمخزون', Icons.directions_car, [
            _buildResultTile('تويوتا كامري 2023', 'لوحة: أ ب ج 1234', Icons.car_rental, () => {}),
            _buildResultTile('هيونداي إلنترا 2022', 'لوحة: د هـ و 5678', Icons.car_repair, () => {}),
          ]),
        ],
        if (_selectedCategory == 'الكل' || _selectedCategory == 'العقود') ...[
          _buildResultSection('العقود والعمليات', Icons.description, [
            _buildResultTile('عقد بيع أجل #105', 'المشتري: فهد سليمان', Icons.history_edu, () => context.push('/contracts/1')),
            _buildResultTile('عقد كاش #202', 'مكتمل - سيارة كامري', Icons.payments, () => {}),
          ]),
        ],
      ],
    );
  }

  Widget _buildResultSection(String title, IconData icon, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ),
        ...items,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildResultTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.bgGrey, child: Icon(icon, color: AppColors.primaryNavy, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_outlined, size: 80, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('ابدأ الكتابة للبحث في النظام بالكامل', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
