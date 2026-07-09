import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/investor.dart';
import '../domain/investor_repository.dart';
import '../domain/investor_transaction.dart';
import '../../documents/domain/document.dart';
import 'sources/investor_data_source.dart';
import 'sources/supabase_investor_data_source.dart';

part 'supabase_investor_repository.g.dart';

class SupabaseInvestorRepository implements InvestorRepository {
  final InvestorDataSource _dataSource;

  SupabaseInvestorRepository(this._dataSource);

  @override
  Future<List<Investor>> getInvestors() async {
    final data = await _dataSource.getInvestors();
    return data.map((json) => Investor.fromJson(json)).toList();
  }

  @override
  Future<Investor?> getInvestorById(String id) async {
    final data = await _dataSource.getInvestorById(id);
    if (data == null) return null;
    return Investor.fromJson(data);
  }

  @override
  Future<Investor> createInvestor(String fullName, String email, String? phone) async {
    final data = await _dataSource.createInvestor({
      'full_name': fullName,
      'email': email,
      'phone': phone,
    });
    return Investor.fromJson(data);
  }

  @override
  Future<List<InvestorTransaction>> getInvestorTransactions(String investorId) async {
    final data = await _dataSource.getInvestorTransactions(investorId);
    return data.map((json) => InvestorTransaction.fromJson(json)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorFundedContracts(String investorId) async {
    return await _dataSource.getInvestorFundedContracts(investorId);
  }

  @override
  Future<void> addTransaction(InvestorTransaction transaction) async {
    await _dataSource.insertTransaction({
      'investor_id': transaction.investorId,
      'amount': transaction.amount,
      'type': transaction.type.name,
      'reference_id': transaction.referenceId,
      'description': transaction.description,
    });
  }

  @override
  Future<void> processDeposit(String investorId, double amount, String description) async {
    await _dataSource.processDeposit(investorId, amount, description);
  }

  @override
  Future<void> processWithdrawal(String investorId, double amount, String description) async {
    await _dataSource.processWithdrawal(investorId, amount, description);
  }

  @override
  Future<void> allocateFunding(String contractId, String investorId, double amount) async {
    await _dataSource.allocateFunding(contractId, investorId, amount);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingInvestorRequests() async {
    return await _dataSource.getPendingInvestorRequests();
  }

  @override
  Future<void> approveInvestor(String profileId) async {
    await _dataSource.approveInvestor(profileId);
  }

  @override
  Future<void> rejectInvestor(String profileId, String reason) async {
    await _dataSource.rejectInvestor(profileId, reason);
  }

  @override
  Stream<Investor?> watchInvestor(String id) {
    return _dataSource.watchInvestor(id).map((data) {
      if (data == null) return null;
      return Investor.fromJson(data);
    });
  }

  @override
  Future<List<AppDocument>> getInvestorDocuments(String investorId) async {
    final data = await _dataSource.getInvestorDocuments(investorId);
    return data.map((json) => AppDocument.fromJson(json)).toList();
  }

  @override
  Future<void> uploadInvestorDocument(String investorId, String name, String url) async {
    await _dataSource.uploadInvestorDocument({
      'investor_id': investorId,
      'name': name,
      'document_url': url,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    await _dataSource.deleteDocument(documentId);
  }

  @override
  Future<void> distributeProfit(String investorId, double amount, String description) async {
    await _dataSource.distributeProfit(investorId, amount, description);
  }

  @override
  Future<void> requestWithdrawal(double amount, String bankDetails) async {
    await _dataSource.requestWithdrawal(amount, bankDetails);
  }

  @override
  Future<List<Map<String, dynamic>>> getWithdrawalRequests({String? investorId, String? status}) async {
    return await _dataSource.getWithdrawalRequests(investorId: investorId, status: status);
  }

  @override
  Future<void> approveWithdrawalRequest(String requestId) async {
    await _dataSource.approveWithdrawalRequest(requestId);
  }

  @override
  Future<void> rejectWithdrawalRequest(String requestId, String reason) async {
    await _dataSource.rejectWithdrawalRequest(requestId, reason);
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorProjections(String investorId) async {
    return await _dataSource.getInvestorProjections(investorId);
  }
}

@Riverpod(keepAlive: true)
InvestorRepository investorRepository(InvestorRepositoryRef ref) {
  final dataSource = ref.watch(investorDataSourceProvider);
  return SupabaseInvestorRepository(dataSource);
}
