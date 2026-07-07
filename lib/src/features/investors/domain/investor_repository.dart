import 'investor.dart';
import 'investor_transaction.dart';
import '../../documents/domain/document.dart';

abstract class InvestorRepository {
  Future<List<Investor>> getInvestors();
  Future<Investor?> getInvestorById(String id);
  Future<Investor> createInvestor(String fullName, String email, String? phone);
  Future<List<InvestorTransaction>> getInvestorTransactions(String investorId);
  Future<List<Map<String, dynamic>>> getInvestorFundedContracts(String investorId);
  Future<void> addTransaction(InvestorTransaction transaction);
  Future<void> processDeposit(String investorId, double amount, String description);
  Future<void> processWithdrawal(String investorId, double amount, String description);
  Future<void> allocateFunding(String contractId, String investorId, double amount);
  
  // --- Approval Flow ---
  Future<List<Map<String, dynamic>>> getPendingInvestorRequests();
  Future<void> approveInvestor(String profileId);
  Future<void> rejectInvestor(String profileId, String reason);

  Stream<Investor?> watchInvestor(String id);

  // --- Documents & Profits ---
  Future<List<AppDocument>> getInvestorDocuments(String investorId);
  Future<void> uploadInvestorDocument(String investorId, String name, String url);
  Future<void> deleteDocument(String documentId);
  Future<void> distributeProfit(String investorId, double amount, String description);
}
