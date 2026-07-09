import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_document_repository.dart';
import '../domain/document.dart';
import '../domain/document_repository.dart';

part 'document_controller.g.dart';

@riverpod
class DocumentController extends _$DocumentController {
  @override
  FutureOr<void> build() {
    // Initial build
  }

  Future<void> uploadDocument({
    String? customerId,
    String? contractId,
    String? investorId,
    required DocumentType type,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(documentRepositoryProvider).uploadDocument(
          customerId: customerId,
          contractId: contractId,
          investorId: investorId,
          type: type,
          fileName: fileName,
          fileBytes: fileBytes,
        ));
    
    if (!result.hasError) {
      // Invalidate the relevant lists
      if (customerId != null) ref.invalidate(documentsListProvider(customerId: customerId));
      if (contractId != null) ref.invalidate(documentsListProvider(contractId: contractId));
      if (investorId != null) ref.invalidate(documentsListProvider(investorId: investorId));
    }
    state = result;
  }

  Future<void> deleteDocument({
    required String documentId,
    required String filePath,
    String? customerId,
    String? contractId,
    String? investorId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(documentRepositoryProvider).deleteDocument(documentId, filePath));
    
    if (!result.hasError) {
      if (customerId != null) ref.invalidate(documentsListProvider(customerId: customerId));
      if (contractId != null) ref.invalidate(documentsListProvider(contractId: contractId));
      if (investorId != null) ref.invalidate(documentsListProvider(investorId: investorId));
    }
    state = result;
  }
}

@riverpod
Future<List<AppDocument>> documentsList(
  DocumentsListRef ref, {
  String? customerId,
  String? contractId,
  String? investorId,
}) {
  return ref.watch(documentRepositoryProvider).getDocuments(
        customerId: customerId,
        contractId: contractId,
        investorId: investorId,
      );
}
