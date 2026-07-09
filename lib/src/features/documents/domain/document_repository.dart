import 'document.dart';

abstract class DocumentRepository {
  Future<List<AppDocument>> getDocuments({
    String? customerId,
    String? contractId,
    String? investorId,
  });

  Future<void> uploadDocument({
    String? customerId,
    String? contractId,
    String? investorId,
    required DocumentType type,
    required String fileName,
    required List<int> fileBytes,
  });

  Future<void> deleteDocument(String documentId, String filePath);
  
  Future<String> getPublicUrl(String filePath);
}
