import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

@freezed
class AppDocument with _$AppDocument {
  const factory AppDocument({
    required String id,
    @JsonKey(name: 'contract_id') String? contractId,
    @JsonKey(name: 'customer_id') String? customerId,
    required String name,
    @JsonKey(name: 'document_url') required String documentUrl,
    @Default(1) int version,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AppDocument;

  factory AppDocument.fromJson(Map<String, dynamic> json) => _$AppDocumentFromJson(json);
}
