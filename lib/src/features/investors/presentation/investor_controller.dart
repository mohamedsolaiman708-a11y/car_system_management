import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_investor_repository.dart';
import '../domain/investor.dart';
import '../domain/investor_repository.dart';
import '../domain/investor_transaction.dart';
import '../domain/investor_transaction_type.dart';
import '../../documents/domain/document.dart';

part 'investor_controller.g.dart';

@riverpod
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
    state = await AsyncValue.guard(() async {
      await ref.read(investorRepositoryProvider).createInvestor(fullName, email, phone);
      return ref.read(investorRepositoryProvider).getInvestors();
    });
  }
}

@riverpod
class InvestorDetailsController extends _$InvestorDetailsController {
  @override
  FutureOr<Investor?> build(String id) {
    return ref.watch(investorRepositoryProvider).getInvestorById(id);
  }

  Future<void> refresh() async {
    // لا نضع AsyncLoading() يدوياً هنا للحفاظ على البيانات القديمة في الواجهة أثناء التحديث
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

  Future<bool> addTransaction({
    required String investorId,
    required double amount,
    required InvestorTransactionType type,
    String? description,
  }) async {
    final repository = ref.read(investorRepositoryProvider);
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
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
      return repository.getInvestorTransactions(investorId);
    });

    state = result;
    if (!result.hasError) {
      ref.invalidate(investorDetailsControllerProvider(investorId));
    }
    return !result.hasError;
  }

  Future<bool> allocateFunding({
    required String investorId,
    required String contractId,
    required double amount,
  }) async {
    final repository = ref.read(investorRepositoryProvider);
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      await repository.allocateFunding(contractId, investorId, amount);
      return repository.getInvestorTransactions(investorId);
    });

    state = result;
    if (!result.hasError) {
      ref.invalidate(investorDetailsControllerProvider(investorId));
    }
    return !result.hasError;
  }

  Future<bool> distributeProfit({
    required String investorId,
    required double amount,
    required String description,
  }) async {
    final repository = ref.read(investorRepositoryProvider);
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      await repository.distributeProfit(investorId, amount, description);
      return repository.getInvestorTransactions(investorId);
    });

    state = result;
    if (!result.hasError) {
      ref.invalidate(investorDetailsControllerProvider(investorId));
    }
    return !result.hasError;
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
