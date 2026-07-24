import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../contracts/presentation/contract_timeline_controller.dart';
import '../data/supabase_investor_repository.dart';
import '../domain/investor.dart';
import '../domain/investor_transaction.dart';
import '../domain/investor_transaction_type.dart';
import '../../documents/domain/document.dart';
import '../../contracts/presentation/contract_controller.dart';
import '../../contracts/data/supabase_contract_repository.dart';

part 'investor_controller.g.dart';

@Riverpod(keepAlive: true)
class InvestorListController extends _$InvestorListController {
  @override
  FutureOr<List<Investor>> build() {
    return ref.watch(investorRepositoryProvider).getInvestors();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(investorRepositoryProvider).getInvestors());
  }

  Future<void> createInvestor(String fullName, String email, String? phone) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(investorRepositoryProvider).createInvestor(fullName, email, phone);
      return ref.read(investorRepositoryProvider).getInvestors();
    });
    state = result;
    if (result.hasError) {
      throw result.error!;
    }
  }
}

@riverpod
class InvestorDetailsController extends _$InvestorDetailsController {
  @override
  FutureOr<Investor?> build(String id) {
    return ref.watch(investorRepositoryProvider).getInvestorById(id);
  }

  Future<void> refresh() async {
    final result = await AsyncValue.guard(() => ref.read(investorRepositoryProvider).getInvestorById(id));
    if (result.hasValue) {
      state = result;
    }
  }
}

@riverpod
class InvestorTransactionsController extends _$InvestorTransactionsController {
  @override
  FutureOr<List<InvestorTransaction>> build(String investorId) {
    return ref.watch(investorRepositoryProvider).getInvestorTransactions(investorId);
  }

  Future<bool> allocateFunding({
    required String investorId,
    required String contractId,
    required double amount,
  }) async {
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(investorRepositoryProvider);
      final contractRepo = ref.read(contractRepositoryProvider);
      
      // جلب أحدث البيانات لحظياً لضمان الدقة المالية
      final investor = await repository.getInvestorById(investorId);
      final contract = await contractRepo.getContractById(contractId);
      final fundingRecords = await contractRepo.getContractFunding(contractId);

      if (investor == null || contract == null) {
        throw Exception('بيانات المستثمر أو العقد غير موجودة');
      }

      // 1. تحقق الرصيد (منع الرصيد السالب)
      if (investor.availableBalance < amount) {
        throw Exception('رصيد المستثمر غير كافٍ. المتاح: ${investor.availableBalance} ر.س');
      }

      // 2. تحقق سعة العقد (منع التمويل الزائد)
      double totalFunded = fundingRecords.fold(0.0, (sum, item) => sum + (item['amount_allocated'] as num).toDouble());
      double remainingRequired = contract.principalAmount - totalFunded;

      if (amount > (remainingRequired + 0.01)) {
        throw Exception('المبلغ يتجاوز المطلوب للعقد. المتبقي المطلوب: $remainingRequired ر.س');
      }

      // 3. تنفيذ العملية
      await repository.allocateFunding(contractId, investorId, amount);

      // 4. تحديث الحالات لضمان المزامنة الفورية
      contractRepo.clearCache();
      ref.invalidate(investorDetailsControllerProvider(investorId));
      ref.invalidate(investorListControllerProvider);
      ref.invalidate(contractFundingProvider(contractId));
      ref.invalidate(contractDetailsProvider(contractId));
      ref.invalidate(contractStatsProvider);
      
      state = const AsyncData([]);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> addTransaction({
    required String investorId,
    required double amount,
    required InvestorTransactionType type,
    String? description,
  }) async {
    final repository = ref.read(investorRepositoryProvider);
    state = const AsyncLoading();

    try {
      // تحقق من الرصيد في حالة السحب
      if (type == InvestorTransactionType.withdrawal) {
        final investor = await repository.getInvestorById(investorId);
        if (investor != null && investor.availableBalance < amount) {
          throw Exception('رصيد المستثمر غير كافٍ للسحب. المتاح: ${investor.availableBalance} ر.س');
        }
      }

      if (type == InvestorTransactionType.deposit) {
        await repository.processDeposit(investorId, amount, description ?? '');
      } else if (type == InvestorTransactionType.withdrawal) {
        await repository.processWithdrawal(investorId, amount, description ?? '');
      } else {
        await repository.addTransaction(InvestorTransaction(
          id: '',
          investorId: investorId,
          amount: amount,
          type: type,
          createdAt: DateTime.now(),
          description: description,
        ));
      }
      
      final updatedTransactions = await repository.getInvestorTransactions(investorId);
      state = AsyncData(updatedTransactions);
      ref.invalidate(investorDetailsControllerProvider(investorId));
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> distributeProfit({
    required String investorId,
    required double amount,
    required String description,
  }) async {
    final repository = ref.read(investorRepositoryProvider);
    state = const AsyncLoading();

    try {
      await repository.distributeProfit(investorId, amount, description);
      final updatedTransactions = await repository.getInvestorTransactions(investorId);
      state = AsyncData(updatedTransactions);
      ref.invalidate(investorDetailsControllerProvider(investorId));
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

@riverpod
class PendingInvestorsController extends _$PendingInvestorsController {
  @override
  FutureOr<List<Map<String, dynamic>>> build() {
    return ref.watch(investorRepositoryProvider).getPendingInvestorRequests();
  }

  Future<void> approveInvestor(String profileId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(investorRepositoryProvider).approveInvestor(profileId);
      ref.invalidate(investorListControllerProvider);
      return ref.read(investorRepositoryProvider).getPendingInvestorRequests();
    });
  }

  Future<void> rejectInvestor(String profileId, String reason) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(investorRepositoryProvider).rejectInvestor(profileId, reason);
      return ref.read(investorRepositoryProvider).getPendingInvestorRequests();
    });
  }
}

@riverpod
class InvestorFundedContractsController extends _$InvestorFundedContractsController {
  @override
  FutureOr<List<Map<String, dynamic>>> build(String investorId) {
    return ref.watch(investorRepositoryProvider).getInvestorFundedContracts(investorId);
  }
}

@riverpod
class InvestorDocumentsController extends _$InvestorDocumentsController {
  @override
  FutureOr<List<AppDocument>> build(String investorId) {
    return ref.watch(investorRepositoryProvider).getInvestorDocuments(investorId);
  }

  Future<void> uploadDocument(String name, String url) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(investorRepositoryProvider).uploadInvestorDocument(investorId, name, url);
      return ref.read(investorRepositoryProvider).getInvestorDocuments(investorId);
    });
  }

  Future<void> deleteDocument(String documentId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(investorRepositoryProvider).deleteDocument(documentId);
      return ref.read(investorRepositoryProvider).getInvestorDocuments(investorId);
    });
  }
}

@riverpod
class WithdrawalRequestsController extends _$WithdrawalRequestsController {
  @override
  FutureOr<List<Map<String, dynamic>>> build({String? investorId, String? status}) {
    return ref.watch(investorRepositoryProvider).getWithdrawalRequests(
      investorId: investorId,
      status: status,
    );
  }

  Future<bool> requestWithdrawal(double amount, String bankDetails) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() =>
        ref.read(investorRepositoryProvider).requestWithdrawal(amount, bankDetails)
    );
    return !result.hasError;
  }

  Future<void> approveRequest(String requestId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(investorRepositoryProvider).approveWithdrawalRequest(requestId);
      return ref.read(investorRepositoryProvider).getWithdrawalRequests(
        investorId: investorId,
        status: status,
      );
    });
  }

  Future<void> rejectRequest(String requestId, String reason) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(investorRepositoryProvider).rejectWithdrawalRequest(requestId, reason);
      return ref.read(investorRepositoryProvider).getWithdrawalRequests(
        investorId: investorId,
        status: status,
      );
    });
  }
}

@riverpod
Future<List<Map<String, dynamic>>> investorProjections(InvestorProjectionsRef ref, String investorId) {
  return ref.watch(investorRepositoryProvider).getInvestorProjections(investorId);
}
