import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/contract.dart';
import '../data/supabase_contract_repository.dart';

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
