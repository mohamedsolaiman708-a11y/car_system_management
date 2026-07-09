import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

enum DocumentType {
  @JsonValue('NATIONAL_ID') nationalId,
  @JsonValue('CONTRACT') contract,
  @JsonValue('GUARANTEE') guarantee,
  @JsonValue('CHECK') check,
  @JsonValue('PDF') pdf,
  @JsonValue('IMAGE') image,
  @JsonValue('OTHER') other
}

@freezed
class AppDocument with _$AppDocument {
  const factory AppDocument({
    required String id,
    @JsonKey(name: 'contract_id') String? contractId,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'investor_id') String? investorId,
    required String name,
    @JsonKey(name: 'file_path') required String filePath,
    @JsonKey(name: 'document_url') required String documentUrl,
    @JsonKey(name: 'document_type') required DocumentType type,
    @Default(1) int version,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AppDocument;

  factory AppDocument.fromJson(Map<String, dynamic> json) => _$AppDocumentFromJson(json);
}
