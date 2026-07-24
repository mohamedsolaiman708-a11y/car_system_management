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

class DocumentTypeConverter implements JsonConverter<DocumentType, String?> {
  const DocumentTypeConverter();

  @override
  DocumentType fromJson(String? json) {
    if (json == null) return DocumentType.other;
    final dt = json.toUpperCase().replaceAll('_', '').replaceAll(' ', '');
    if (dt == 'NATIONALID' || dt == 'ID' || dt == 'IDENTITY') return DocumentType.nationalId;
    if (dt == 'CONTRACT') return DocumentType.contract;
    if (dt == 'CHECK') return DocumentType.check;
    if (dt == 'GUARANTEE' || dt == 'SANAD') return DocumentType.guarantee;
    if (dt == 'PDF') return DocumentType.pdf;
    if (dt == 'IMAGE') return DocumentType.image;
    return DocumentType.other;
  }

  @override
  String toJson(DocumentType object) => object.name.toUpperCase();
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
    @DocumentTypeConverter() @JsonKey(name: 'document_type') required DocumentType type,
    @Default(1) int version,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AppDocument;

  factory AppDocument.fromJson(Map<String, dynamic> json) => _$AppDocumentFromJson(json);
}
