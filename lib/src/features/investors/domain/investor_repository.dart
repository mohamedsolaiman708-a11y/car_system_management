import 'investor.dart';
import 'investor_transaction.dart';

abstract class InvestorRepository {
  /// Fetches a list of all investors.
  Future<List<Investor>> getInvestors();

  /// Fetches a specific investor by ID.
  Future<Investor?> getInvestorById(String id);

  /// Creates a new investor profile.
  Future<Investor> createInvestor(String fullName, String email, String? phone);

  /// Fetches all transactions for a specific investor.
  Future<List<InvestorTransaction>> getInvestorTransactions(String investorId);

  /// Records a new financial transaction (Deposit, Withdrawal, etc.).
  Future<void> addTransaction(InvestorTransaction transaction);

  /// Stream of an investor's data for real-time updates.
  Stream<Investor?> watchInvestor(String id);
}
