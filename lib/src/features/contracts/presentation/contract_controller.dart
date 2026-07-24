import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/contract.dart';
import '../data/supabase_contract_repository.dart';
import 'contract_timeline_controller.dart';

part 'contract_controller.g.dart';

@riverpod
class ContractController extends _$ContractController {
  @override
  FutureOr<void> build() => null;

  Future<bool> createContract(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(contractRepositoryProvider).createContract(data));
    
    if (!result.hasError) {
      ref.invalidate(contractsListProvider);
      ref.invalidate(contractStatsProvider);
      state = const AsyncData(null);
      return true;
    } else {
      state = AsyncError(result.error!, result.stackTrace!);
      return false;
    }
  }

  Future<bool> updateContract(String id, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(contractRepositoryProvider).updateContract(id, data));
    
    if (!result.hasError) {
      ref.invalidate(contractDetailsProvider(id));
      ref.invalidate(contractsListProvider);
      state = const AsyncData(null);
      return true;
    } else {
      state = AsyncError(result.error!, result.stackTrace!);
      return false;
    }
  }

  Future<bool> activateContract(String id) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    
    final result = await AsyncValue.guard(() async {
      await ref.read(contractRepositoryProvider).activateContract(id);
      _refreshContractData(id);
    });
    
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return false;
    }
    state = const AsyncData(null);
    return true;
  }

  Future<bool> processPayment({
    required String contractId,
    required double amount,
    required String method,
    String? reference,
    String? idempotencyKey,
    String? notes,
  }) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    
    final result = await AsyncValue.guard(() async {
      await ref.read(contractRepositoryProvider).processPayment(
        contractId: contractId,
        amount: amount,
        method: method,
        reference: reference,
        idempotencyKey: idempotencyKey,
        notes: notes,
      );
      _refreshContractData(contractId);
    });
    
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return false;
    }
    state = const AsyncData(null);
    return true;
  }

  Future<bool> reversePayment(String contractId, String paymentId, String reason) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    
    final result = await AsyncValue.guard(() async {
      await ref.read(contractRepositoryProvider).reversePayment(paymentId, reason);
      _refreshContractData(contractId);
    });
    
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return false;
    }
    state = const AsyncData(null);
    return true;
  }

  void _refreshContractData(String contractId) {
    ref.invalidate(contractPaymentsProvider(contractId));
    ref.invalidate(contractInstallmentsProvider(contractId));
    ref.invalidate(contractDetailsProvider(contractId));
    ref.invalidate(contractTimelineProvider(contractId));
    ref.invalidate(contractFundingProvider(contractId));
    ref.invalidate(contractStatsProvider);
  }
}

@Riverpod(keepAlive: true)
Future<List<Contract>> contractsList(ContractsListRef ref, {String? searchQuery, String? status}) {
  return ref.watch(contractRepositoryProvider).getContracts(searchQuery: searchQuery, status: status);
}

@riverpod
Future<Contract?> contractDetails(ContractDetailsRef ref, String id) {
  return ref.watch(contractRepositoryProvider).getContractById(id);
}

@Riverpod(keepAlive: true)
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
