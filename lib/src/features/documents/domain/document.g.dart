// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppDocumentImpl _$$AppDocumentImplFromJson(Map<String, dynamic> json) =>
    _$AppDocumentImpl(
      id: json['id'] as String,
      contractId: json['contract_id'] as String?,
      customerId: json['customer_id'] as String?,
      investorId: json['investor_id'] as String?,
      name: json['name'] as String,
      filePath: json['file_path'] as String,
      documentUrl: json['document_url'] as String,
      type: const DocumentTypeConverter().fromJson(
        json['document_type'] as String?,
      ),
      version: (json['version'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$AppDocumentImplToJson(_$AppDocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contract_id': instance.contractId,
      'customer_id': instance.customerId,
      'investor_id': instance.investorId,
      'name': instance.name,
      'file_path': instance.filePath,
      'document_url': instance.documentUrl,
      'document_type': const DocumentTypeConverter().toJson(instance.type),
      'version': instance.version,
      'created_at': instance.createdAt.toIso8601String(),
    };
