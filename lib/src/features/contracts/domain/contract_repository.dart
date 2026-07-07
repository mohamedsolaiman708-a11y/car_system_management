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
  
  // Phase 16: Activity Timeline
  Future<List<Map<String, dynamic>>> getContractTimeline(String contractId);
}
