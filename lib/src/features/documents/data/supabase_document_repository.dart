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
    // استخدام filter('column', 'is', null) هو الحل الأكثر أماناً للتحقق من القيم الفارغة
    var query = _client
        .from('contract_documents')
        .select()
        .filter('deleted_at', 'is', null);

    if (contractId != null) {
      query = query.eq('contract_id', contractId);
    } else if (customerId != null) {
      query = query.eq('customer_id', customerId);
    } else if (investorId != null) {
      query = query.eq('investor_id', investorId);
    }

    final response = await query.order('created_at', ascending: false);
    
    return (response as List).map((json) => AppDocument.fromJson(json)).toList();
  }

  @override
  Future<void> uploadDocument({
    String? customerId,
    String? contractId,
    String? investorId,
    required DocumentType type,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final folder = investorId != null ? 'investors/$investorId' : 
                   contractId != null ? 'contracts/$contractId' : 'customers/$customerId';
    
    final fileExtension = fileName.split('.').last;
    final storagePath = '$folder/${type.name.toUpperCase()}_$timestamp.$fileExtension';

    // الرفع إلى Storage
    await _client.storage.from('documents').uploadBinary(
      storagePath, 
      fileBytes as dynamic,
      fileOptions: FileOptions(
        contentType: _getContentType(fileExtension),
        upsert: false,
      ),
    );

    // جلب الرابط العام
    final fileUrl = _client.storage.from('documents').getPublicUrl(storagePath);

    // تسجيل البيانات
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
  }

  @override
  Future<void> deleteDocument(String documentId, String filePath) async {
    // تنفيذ الحذف الناعم (Soft Delete)
    await _client.from('contract_documents')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', documentId);
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
