import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/customer.dart';
import '../data/supabase_crm_repository.dart';

part 'crm_controller.g.dart';

@riverpod
class CrmController extends _$CrmController {
  @override
  FutureOr<void> build() {
    // Initial build
  }

  Future<void> createCustomer(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(crmRepositoryProvider).createCustomer(data));
  }

  Future<void> updateCustomer(String id, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(crmRepositoryProvider).updateCustomer(id, data));
  }

  Future<void> deleteCustomer(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(crmRepositoryProvider).deleteCustomer(id));
  }

  // Phase 17: Document Management Methods
  Future<void> uploadDocument({
    required String customerId,
    required String? contractId,
    required String documentType,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(crmRepositoryProvider).uploadDocument(
          customerId: customerId,
          contractId: contractId,
          documentType: documentType,
          fileName: fileName,
          fileBytes: fileBytes,
        ));
    
    if (!result.hasError) {
      ref.invalidate(customerDocumentsProvider(customerId));
    }
    state = result;
  }

  Future<void> deleteDocument({
    required String documentId,
    required String filePath,
    required String customerId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(crmRepositoryProvider).deleteDocument(documentId, filePath));
    
    if (!result.hasError) {
      ref.invalidate(customerDocumentsProvider(customerId));
    }
    state = result;
  }
}

@Riverpod(keepAlive: true)
Future<List<Customer>> customersList(
    CustomersListRef ref, {
  String? searchQuery,
  String? status,
  String? city,
}) {
  return ref.watch(crmRepositoryProvider).getCustomers(
        searchQuery: searchQuery,
        status: status,
        city: city,
      );
}

@riverpod
Future<Customer?> customerDetails(CustomerDetailsRef ref, String id) {
  return ref.watch(crmRepositoryProvider).getCustomerById(id);
}

@riverpod
Future<Map<String, dynamic>> customerFinancialSummary(CustomerFinancialSummaryRef ref, String id) {
  return ref.watch(crmRepositoryProvider).getCustomerFinancialSummary(id);
}

@riverpod
Future<List<Map<String, dynamic>>> customerTimeline(CustomerTimelineRef ref, String id) {
  return ref.watch(crmRepositoryProvider).getCustomerTimeline(id);
}

@riverpod
Future<List<Map<String, dynamic>>> customerContracts(CustomerContractsRef ref, String id) {
  return ref.watch(crmRepositoryProvider).getCustomerContracts(id);
}

@riverpod
Future<List<Map<String, dynamic>>> customerPayments(CustomerPaymentsRef ref, String id) {
  return ref.watch(crmRepositoryProvider).getCustomerPayments(id);
}

@riverpod
Future<List<Map<String, dynamic>>> customerInstallments(CustomerInstallmentsRef ref, String id) {
  return ref.watch(crmRepositoryProvider).getCustomerInstallments(id);
}

@riverpod
Future<List<Map<String, dynamic>>> customerDocuments(CustomerDocumentsRef ref, String id) {
  return ref.watch(crmRepositoryProvider).getCustomerDocuments(id);
}
