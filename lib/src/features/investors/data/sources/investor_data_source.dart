import '../../domain/investor.dart';
import '../../domain/investor_transaction.dart';

abstract class InvestorDataSource {
  Future<List<Map<String, dynamic>>> getInvestors();
  Future<Map<String, dynamic>?> getInvestorById(String id);
  Future<Map<String, dynamic>> createInvestor(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getInvestorTransactions(String investorId);
  Future<List<Map<String, dynamic>>> getInvestorFundedContracts(String investorId);
  Future<void> insertTransaction(Map<String, dynamic> transactionData);
  
  // RPC methods for financial integrity
  Future<void> processDeposit(String investorId, double amount, String description);
  Future<void> processWithdrawal(String investorId, double amount, String description);
  Future<void> allocateFunding(String contractId, String investorId, double amount);
  
  // Approval flow
  Future<List<Map<String, dynamic>>> getPendingInvestorRequests();
  Future<void> approveInvestor(String profileId);
  Future<void> rejectInvestor(String profileId, String reason);
  
  Stream<Map<String, dynamic>?> watchInvestor(String id);

  // Document Management
  Future<List<Map<String, dynamic>>> getInvestorDocuments(String investorId);
  Future<void> uploadInvestorDocument(Map<String, dynamic> documentData);
  Future<void> deleteDocument(String documentId);

  // Profit Distribution
  Future<void> distributeProfit(String investorId, double amount, String description);

  // Withdrawal Requests
  Future<void> requestWithdrawal(double amount, String bankDetails);
  Future<List<Map<String, dynamic>>> getWithdrawalRequests({String? investorId, String? status});
  Future<void> approveWithdrawalRequest(String requestId);
  Future<void> rejectWithdrawalRequest(String requestId, String reason);

  // --- Projections (New) ---
  Future<List<Map<String, dynamic>>> getInvestorProjections(String investorId);
}
