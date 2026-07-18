import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/supabase_document_repository.dart';
import '../domain/document.dart';

part 'document_controller.g.dart';

// Provider لتتبع تقدم الرفع (0.0 = لا يوجد رفع، 1.0 = مكتمل)
final uploadProgressProvider = StateProvider<double?>((ref) => null);

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

    // إعادة ضبط التقدم
    ref.read(uploadProgressProvider.notifier).state = 0.0;

    final result = await AsyncValue.guard(
      () => ref.read(documentRepositoryProvider).uploadDocument(
            customerId: customerId,
            contractId: contractId,
            investorId: investorId,
            type: type,
            fileName: fileName,
            fileBytes: fileBytes,
            onProgress: (progress) {
              ref.read(uploadProgressProvider.notifier).state = progress;
            },
          ),
    );

    if (!result.hasError) {
      // Invalidate the relevant lists
      if (customerId != null) {
        ref.invalidate(documentsListProvider(customerId: customerId));
      }
      if (contractId != null) {
        ref.invalidate(documentsListProvider(contractId: contractId));
      }
      if (investorId != null) {
        ref.invalidate(documentsListProvider(investorId: investorId));
      }
    }

    // إعادة الـ progress إلى null بعد الانتهاء
    await Future.delayed(const Duration(milliseconds: 600));
    ref.read(uploadProgressProvider.notifier).state = null;
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
    final result = await AsyncValue.guard(
        () => ref.read(documentRepositoryProvider).deleteDocument(documentId, filePath));

    if (!result.hasError) {
      if (customerId != null) {
        ref.invalidate(documentsListProvider(customerId: customerId));
      }
      if (contractId != null) {
        ref.invalidate(documentsListProvider(contractId: contractId));
      }
      if (investorId != null) {
        ref.invalidate(documentsListProvider(investorId: investorId));
      }
    }
    state = result;
  }
}

@riverpod
Future<List<AppDocument>> documentsList(
  Ref ref, {
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
