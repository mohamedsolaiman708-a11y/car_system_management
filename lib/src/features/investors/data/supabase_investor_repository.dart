import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/investor.dart';
import '../domain/investor_repository.dart';
import '../domain/investor_transaction.dart';
import '../../documents/domain/document.dart';
import 'sources/investor_data_source.dart';
import 'sources/supabase_investor_data_source.dart';
import '../../../core/utils/error_handler.dart';

part 'supabase_investor_repository.g.dart';

class SupabaseInvestorRepository implements InvestorRepository {
  final InvestorDataSource _dataSource;
  final Map<String, dynamic> _memCache = {};

  SupabaseInvestorRepository(this._dataSource);

  @override
  Future<List<Investor>> getInvestors() async {
    const key = 'investors_list';
    try {
      final data = await _dataSource.getInvestors();
      final list = data.map((json) => Investor.fromJson(json)).toList();
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<Investor>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Investor?> getInvestorById(String id) async {
    final key = 'investor_$id';
    try {
      final data = await _dataSource.getInvestorById(id);
      if (data == null) return null;
      final investor = Investor.fromJson(data);
      _memCache[key] = investor;
      return investor;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as Investor?;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Investor> createInvestor(String fullName, String email, String? phone) async {
    try {
      final data = await _dataSource.createInvestor({
        'full_name': fullName,
        'email': email,
        'phone': phone,
      });
      _memCache.clear();
      return Investor.fromJson(data);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<InvestorTransaction>> getInvestorTransactions(String investorId) async {
    final key = 'investor_transactions_$investorId';
    try {
      final data = await _dataSource.getInvestorTransactions(investorId);
      final list = data.map((json) => InvestorTransaction.fromJson(json)).toList();
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<InvestorTransaction>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorFundedContracts(String investorId) async {
    final key = 'investor_contracts_$investorId';
    try {
      final list = await _dataSource.getInvestorFundedContracts(investorId);
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<Map<String, dynamic>>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> addTransaction(InvestorTransaction transaction) async {
    try {
      await _dataSource.insertTransaction({
        'investor_id': transaction.investorId,
        'amount': transaction.amount,
        'type': transaction.type.name,
        'reference_id': transaction.referenceId,
        'description': transaction.description,
      });
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> processDeposit(String investorId, double amount, String description) async {
    try {
      await _dataSource.processDeposit(investorId, amount, description);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> processWithdrawal(String investorId, double amount, String description) async {
    try {
      await _dataSource.processWithdrawal(investorId, amount, description);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> allocateFunding(String contractId, String investorId, double amount) async {
    try {
      await _dataSource.allocateFunding(contractId, investorId, amount);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingInvestorRequests() async {
    const key = 'pending_investor_requests';
    try {
      final list = await _dataSource.getPendingInvestorRequests();
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<Map<String, dynamic>>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> approveInvestor(String profileId) async {
    try {
      await _dataSource.approveInvestor(profileId);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> rejectInvestor(String profileId, String reason) async {
    try {
      await _dataSource.rejectInvestor(profileId, reason);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
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
    final key = 'investor_docs_$investorId';
    try {
      final data = await _dataSource.getInvestorDocuments(investorId);
      final list = data.map((json) => AppDocument.fromJson(json)).toList();
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<AppDocument>;
      }
      return [];
    }
  }

  @override
  Future<void> uploadInvestorDocument(String investorId, String name, String url) async {
    try {
      await _dataSource.uploadInvestorDocument({
        'investor_id': investorId,
        'name': name,
        'document_url': url,
        'created_at': DateTime.now().toIso8601String(),
      });
      _memCache.remove('investor_docs_$investorId');
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      await _dataSource.deleteDocument(documentId);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> distributeProfit(String investorId, double amount, String description) async {
    try {
      await _dataSource.distributeProfit(investorId, amount, description);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> requestWithdrawal(double amount, String bankDetails) async {
    try {
      await _dataSource.requestWithdrawal(amount, bankDetails);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWithdrawalRequests({String? investorId, String? status}) async {
    final key = 'withdrawal_requests_${investorId}_$status';
    try {
      final list = await _dataSource.getWithdrawalRequests(investorId: investorId, status: status);
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<Map<String, dynamic>>;
      }
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> approveWithdrawalRequest(String requestId) async {
    try {
      await _dataSource.approveWithdrawalRequest(requestId);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> rejectWithdrawalRequest(String requestId, String reason) async {
    try {
      await _dataSource.rejectWithdrawalRequest(requestId, reason);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorProjections(String investorId) async {
    final key = 'investor_projections_$investorId';
    try {
      final list = await _dataSource.getInvestorProjections(investorId);
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<Map<String, dynamic>>;
      }
      throw Failure.fromException(e);
    }
  }
}

@Riverpod(keepAlive: true)
InvestorRepository investorRepository(InvestorRepositoryRef ref) {
  final dataSource = ref.watch(investorDataSourceProvider);
  return SupabaseInvestorRepository(dataSource);
}
