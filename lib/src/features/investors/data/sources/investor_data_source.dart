import '../../domain/investor.dart';
import '../../domain/investor_transaction.dart';

abstract class InvestorDataSource {
  Future<List<Map<String, dynamic>>> getInvestors();
  Future<Map<String, dynamic>?> getInvestorById(String id);
  Future<Map<String, dynamic>> createInvestor(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getInvestorTransactions(String investorId);
  Future<void> insertTransaction(Map<String, dynamic> transactionData);
  Stream<Map<String, dynamic>?> watchInvestor(String id);
}
