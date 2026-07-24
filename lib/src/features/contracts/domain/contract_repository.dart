import 'contract.dart';

abstract class ContractRepository {
  Future<List<Contract>> getContracts({
    String? searchQuery,
    String? status,
    int limit = 20,
    int offset = 0,
  });

  Future<Contract?> getContractById(String id);
  Future<Contract> createContract(Map<String, dynamic> data);
  Future<Contract> updateContract(String id, Map<String, dynamic> data);
  Future<void> activateContract(String id);
  Future<Map<String, dynamic>> getContractStats();

  // Installments & Payments
  Future<List<Map<String, dynamic>>> getContractInstallments(String contractId);
  Future<List<Map<String, dynamic>>> getContractPayments(String contractId);
  
  Future<void> processPayment({
    required String contractId,
    required double amount,
    required String method,
    String? reference,
    String? idempotencyKey,
  });

  Future<void> reversePayment(String paymentId, String reason);

  // Phase 16: Activity Timeline
  Future<List<Map<String, dynamic>>> getContractTimeline(String contractId);
  
  /// إضافة سجل حدث يدوي للرقابة (مثل رفع المستندات)
  Future<void> addContractLog({
    required String contractId,
    required String eventType,
    Map<String, dynamic>? metadata,
  });

  // Funding
  Future<List<Map<String, dynamic>>> getContractFunding(String contractId);
}
