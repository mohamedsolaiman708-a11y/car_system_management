import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/search_repository.dart';
import '../domain/search_result.dart';

part 'search_controller.g.dart';

@riverpod
class GlobalSearchController extends _$GlobalSearchController {
  @override
  FutureOr<List<SearchResult>> build() {
    return [];
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(searchRepositoryProvider).globalSearch(query));
  }
}

@riverpod
class SearchQueryController extends _$SearchQueryController {
  Timer? _debounceTimer;

  @override
  String build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return '';
  }

  void updateQuery(String query) {
    state = query;
    
    // إلغاء التايمر السابق إذا بدأ المستخدم بالكتابة مجدداً
    _debounceTimer?.cancel();
    
    // الانتظار لمدة 500 ملي ثانية قبل البحث الفعلي
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!ref.exists(globalSearchControllerProvider)) return;
      ref.read(globalSearchControllerProvider.notifier).search(query);
    });
  }
}

@riverpod
class SearchFilterController extends _$SearchFilterController {
  @override
  SearchEntityType? build() => null;

  void setFilter(SearchEntityType? type) {
    state = type;
  }
}

@riverpod
List<SearchResult> filteredSearchResults(FilteredSearchResultsRef ref) {
  final results = ref.watch(globalSearchControllerProvider).value ?? [];
  final filter = ref.watch(searchFilterControllerProvider);

  if (filter == null) return results;
  return results.where((r) => r.entityType == filter).toList();
}
