import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/investor.dart';
import '../domain/investor_repository.dart';
import '../domain/investor_transaction.dart';
import '../../documents/domain/document.dart';
import 'sources/investor_data_source.dart';
import 'sources/supabase_investor_data_source.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_investor_repository.g.dart';

class SupabaseInvestorRepository implements InvestorRepository {
  final InvestorDataSource _dataSource;
  final SupabaseClient _client; // أضفنا العميل للتحقق من الدعوات
  final Map<String, dynamic> _memCache = {};

  SupabaseInvestorRepository(this._dataSource, this._client);

  /// جلب الموظفين المدعوين لاستبعادهم من قوائم المستثمرين
  Future<Set<String>> _getInvitedEmails() async {
    try {
      final response = await _client.from('user_invitations').select('email');
      return (response as List)
          .map((i) => i['email'].toString().toLowerCase().trim())
          .toSet();
    } catch (_) {
      return {};
    }
  }

  @override
  Future<List<Investor>> getInvestors() async {
    try {
      final invitedEmails = await _getInvitedEmails();
      final data = await _dataSource.getInvestors();
      
      // استبعاد أي مستثمر بريده موجود في قائمة دعوات الموظفين
      return data
          .map((json) => Investor.fromJson(json))
          .where((inv) => !invitedEmails.contains(inv.email.toLowerCase().trim()))
          .toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingInvestorRequests() async {
    try {
      final invitedEmails = await _getInvitedEmails();
      final list = await _dataSource.getPendingInvestorRequests();
      
      // استبعاد طلبات الانضمام التي تخص موظفين مدعوين
      return list.where((p) {
        final email = (p['email'] ?? '').toString().toLowerCase().trim();
        return !invitedEmails.contains(email);
      }).toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<Investor?> getInvestorById(String id) async {
    try {
      final data = await _dataSource.getInvestorById(id);
      if (data == null) return null;
      return Investor.fromJson(data);
    } catch (e) {
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
      return Investor.fromJson(data);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<InvestorTransaction>> getInvestorTransactions(String investorId) async {
    try {
      final data = await _dataSource.getInvestorTransactions(investorId);
      return data.map((json) => InvestorTransaction.fromJson(json)).toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorFundedContracts(String investorId) async {
    try {
      return await _dataSource.getInvestorFundedContracts(investorId);
    } catch (e) {
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
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> processDeposit(String investorId, double amount, String description) async {
    try {
      await _dataSource.processDeposit(investorId, amount, description);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> processWithdrawal(String investorId, double amount, String description) async {
    try {
      await _dataSource.processWithdrawal(investorId, amount, description);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> allocateFunding(String contractId, String investorId, double amount) async {
    try {
      await _dataSource.allocateFunding(contractId, investorId, amount);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> approveInvestor(String profileId) async {
    try {
      await _dataSource.approveInvestor(profileId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> rejectInvestor(String profileId, String reason) async {
    try {
      await _dataSource.rejectInvestor(profileId, reason);
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
    try {
      final data = await _dataSource.getInvestorDocuments(investorId);
      return data.map((json) => AppDocument.fromJson(json)).toList();
    } catch (e) {
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
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      await _dataSource.deleteDocument(documentId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> distributeProfit(String investorId, double amount, String description) async {
    try {
      await _dataSource.distributeProfit(investorId, amount, description);
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
    try {
      return await _dataSource.getWithdrawalRequests(investorId: investorId, status: status);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> approveWithdrawalRequest(String requestId) async {
    try {
      await _dataSource.approveWithdrawalRequest(requestId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<void> rejectWithdrawalRequest(String requestId, String reason) async {
    try {
      await _dataSource.rejectWithdrawalRequest(requestId, reason);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorProjections(String investorId) async {
    try {
      return await _dataSource.getInvestorProjections(investorId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}

@Riverpod(keepAlive: true)
InvestorRepository investorRepository(InvestorRepositoryRef ref) {
  final dataSource = ref.watch(investorDataSourceProvider);
  final client = ref.watch(supabaseClientProvider);
  return SupabaseInvestorRepository(dataSource, client);
}
