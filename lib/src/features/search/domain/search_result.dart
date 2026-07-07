import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result.freezed.dart';
part 'search_result.g.dart';

enum SearchEntityType {
  customer,
  investor,
  contract,
  payment,
  staff
}

@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    required String id,
    required String title,
    String? subtitle,
    required SearchEntityType entityType,
    @Default({}) Map<String, dynamic> metadata,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) => _$SearchResultFromJson(json);
}
