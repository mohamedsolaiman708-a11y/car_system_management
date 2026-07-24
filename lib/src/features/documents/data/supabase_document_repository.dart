import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/document.dart';
import '../domain/document_repository.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_document_repository.g.dart';

class SupabaseDocumentRepository implements DocumentRepository {
  final SupabaseClient _client;
  SupabaseDocumentRepository(this._client);


  @override
  Future<List<AppDocument>> getDocuments({
    String? customerId,
    String? contractId,
    String? investorId,
  }) async {
    var query = _client.from('contract_documents').select().isFilter('deleted_at', null);

    List<String> filters = [];
    if (contractId != null) filters.add('contract_id.eq.$contractId');
    if (customerId != null) filters.add('customer_id.eq.$customerId');
    if (investorId != null) filters.add('investor_id.eq.$investorId');

    if (filters.isNotEmpty) {
      query = query.or(filters.join(','));
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List).map((json) {
      try {
        return AppDocument.fromJson(json);
      } catch (e) {
        return null;
      }
    }).whereType<AppDocument>().toList();
  }

  @override
  Future<void> uploadDocument({
    String? customerId,
    String? contractId,
    String? investorId,
    required DocumentType type,
    required String fileName,
    required List<int> fileBytes,
    void Function(double progress)? onProgress,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final folder = investorId != null ? 'investors/$investorId' : contractId != null ? 'contracts/$contractId' : 'customers/$customerId';
    final fileExtension = fileName.split('.').last;
    final storagePath = '$folder/${type.name.toUpperCase()}_$timestamp.$fileExtension';

    onProgress?.call(0.1);

    // استخدام Uint8List لضمان التوافق مع Supabase Storage
    await _client.storage.from('documents').uploadBinary(
      storagePath,
      Uint8List.fromList(fileBytes),
      fileOptions: FileOptions(contentType: _getContentType(fileExtension), upsert: false),
    );

    onProgress?.call(0.8);
    final fileUrl = _client.storage.from('documents').getPublicUrl(storagePath);

    await _client.from('contract_documents').insert({
      'customer_id': customerId,
      'contract_id': contractId,
      'investor_id': investorId,
      'name': fileName,
      'file_path': storagePath,
      'document_url': fileUrl,
      'document_type': type.name.toUpperCase(),
      'version': 1,
    });

    onProgress?.call(1.0);
  }

  @override
  Future<void> deleteDocument(String documentId, String filePath) async {
    await _client.from('contract_documents').update({'deleted_at': DateTime.now().toIso8601String()}).eq('id', documentId);
  }

  @override
  Future<String> getPublicUrl(String filePath) async {
    return _client.storage.from('documents').getPublicUrl(filePath);
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf': return 'application/pdf';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      default: return 'application/octet-stream';
    }
  }
}

@Riverpod(keepAlive: true)
DocumentRepository documentRepository(DocumentRepositoryRef ref) {
  return SupabaseDocumentRepository(ref.watch(supabaseClientProvider));
}
