import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/supabase_document_repository.dart';
import '../domain/document.dart';
import '../../contracts/presentation/contract_timeline_controller.dart';

part 'document_controller.g.dart';

// Provider لتتبع تقدم الرفع وإظهار شريط التحميل
final uploadProgressProvider = StateProvider<double?>((ref) => null);

@riverpod
class DocumentController extends _$DocumentController {
  @override
  FutureOr<void> build() {}

  Future<void> uploadDocument({
    String? customerId,
    String? contractId,
    String? investorId,
    required DocumentType type,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    state = const AsyncLoading();
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
      // 1. تحديث قائمة المستندات فوراً (Real-time Simulation)
      ref.invalidate(documentsListProvider);
      
      // 2. توثيق العملية في سجل أحداث العقد (Audit Trail)
      if (contractId != null) {
        await ref.read(contractTimelineNotifierProvider(contractId).notifier).addLog(
          eventType: 'document_uploaded',
          metadata: {'file_name': fileName, 'type': type.name},
        );
      }
    }

    // تأخير بسيط لإعطاء انطباع سلاسة الواجهة
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
      ref.invalidate(documentsListProvider);
      
      // توثيق الحذف في التايم لاين لضمان الرقابة
      if (contractId != null) {
        await ref.read(contractTimelineNotifierProvider(contractId).notifier).addLog(
          eventType: 'document_deleted',
          metadata: {'file_path': filePath},
        );
      }
    }
    state = result;
  }
}

@Riverpod(keepAlive: true)
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
