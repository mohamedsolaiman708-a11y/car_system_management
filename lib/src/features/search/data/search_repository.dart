import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';
import '../domain/search_result.dart';

part 'search_repository.g.dart';

class SearchRepository {
  final SupabaseClient _client;

  SearchRepository(this._client);

  Future<List<SearchResult>> globalSearch(String query) async {
    if (query.isEmpty) return [];

    final response = await _client.rpc('global_search', params: {
      'p_query': query,
    });

    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) {
      // Mapping database string entity_type to enum
      final entityTypeStr = json['entity_type'] as String;
      final entityType = SearchEntityType.values.firstWhere(
        (e) => e.name == entityTypeStr,
        orElse: () => SearchEntityType.customer,
      );

      return SearchResult(
        id: json['id'],
        title: json['title'],
        subtitle: json['subtitle'],
        entityType: entityType,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
    }).toList();
  }
}

@Riverpod(keepAlive: true)
SearchRepository searchRepository(SearchRepositoryRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return SearchRepository(client);
}
