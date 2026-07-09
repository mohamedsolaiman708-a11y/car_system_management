import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/contract.dart';
import '../data/supabase_contract_repository.dart';
import 'contract_timeline_controller.dart';

part 'contract_controller.g.dart';

@riverpod
class ContractController extends _$ContractController {
  @override
  FutureOr<void> build() {
    // Initial build
  }

  Future<void> createContract(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(contractRepositoryProvider).createContract(data));
  }

  Future<void> activateContract(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(contractRepositoryProvider).activateContract(id));
    ref.invalidate(contractDetailsProvider(id));
    ref.invalidate(contractInstallmentsProvider(id));
  }

  /// تنفيذ عملية تحصيل دفعة من العميل
  Future<bool> processPayment({
    required String contractId,
    required double amount,
    required String method,
    String? reference,
    String? idempotencyKey,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(contractRepositoryProvider).processPayment(
      contractId: contractId,
      amount: amount,
      method: method,
      reference: reference,
      idempotencyKey: idempotencyKey,
    ));
    
    if (!result.hasError) {
      _refreshContractData(contractId);
      return true;
    }
    state = result;
    return false;
  }

  /// عكس (إلغاء) دفعة مالية مسجلة
  Future<bool> reversePayment(String contractId, String paymentId, String reason) async {
    state = const AsyncLoading();
    // استدعاء RPC عكس الدفع في قاعدة البيانات
    final result = await AsyncValue.guard(() => 
      ref.read(contractRepositoryProvider).reversePayment(paymentId, reason)
    );
    
    if (!result.hasError) {
      _refreshContractData(contractId);
      return true;
    }
    state = result;
    return false;
  }

  void _refreshContractData(String contractId) {
    ref.invalidate(contractPaymentsProvider(contractId));
    ref.invalidate(contractInstallmentsProvider(contractId));
    ref.invalidate(contractDetailsProvider(contractId));
    ref.invalidate(contractTimelineProvider(contractId));
  }
}

@riverpod
Future<List<Contract>> contractsList(
  ContractsListRef ref, {
  String? searchQuery,
  String? status,
}) {
  return ref.watch(contractRepositoryProvider).getContracts(
        searchQuery: searchQuery,
        status: status,
      );
}

@riverpod
Future<Contract?> contractDetails(ContractDetailsRef ref, String id) {
  return ref.watch(contractRepositoryProvider).getContractById(id);
}

@riverpod
Future<Map<String, dynamic>> contractStats(ContractStatsRef ref) {
  return ref.watch(contractRepositoryProvider).getContractStats();
}

@riverpod
Future<List<Map<String, dynamic>>> contractInstallments(ContractInstallmentsRef ref, String id) {
  return ref.watch(contractRepositoryProvider).getContractInstallments(id);
}

@riverpod
Future<List<Map<String, dynamic>>> contractPayments(ContractPaymentsRef ref, String id) {
  return ref.watch(contractRepositoryProvider).getContractPayments(id);
}

@riverpod
Future<List<Map<String, dynamic>>> contractFunding(ContractFundingRef ref, String id) {
  return ref.watch(contractRepositoryProvider).getContractFunding(id);
}
