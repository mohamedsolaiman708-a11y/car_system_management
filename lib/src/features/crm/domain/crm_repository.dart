import 'customer.dart';

abstract class CrmRepository {
  Future<List<Customer>> getCustomers({
    String? searchQuery,
    String? status,
    String? city,
    int limit = 20,
    int offset = 0,
  });

  Future<Customer?> getCustomerById(String id);

  Future<Customer> createCustomer(Map<String, dynamic> data);

  Future<Customer> updateCustomer(String id, Map<String, dynamic> data);

  Future<void> deleteCustomer(String id);

  Future<Map<String, dynamic>> getCustomerFinancialSummary(String id);

  Future<List<Map<String, dynamic>>> getCustomerTimeline(String id);

  Future<List<Map<String, dynamic>>> getCustomerContracts(String customerId);

  Future<List<Map<String, dynamic>>> getCustomerPayments(String customerId);

  Future<List<Map<String, dynamic>>> getCustomerInstallments(String customerId);

  // Document Management
  Future<List<Map<String, dynamic>>> getCustomerDocuments(String customerId);

  Future<void> uploadDocument({
    required String customerId,
    required String? contractId,
    required String documentType,
    required String fileName,
    required List<int> fileBytes,
  });

  Future<void> deleteDocument(String documentId, String filePath);
}
