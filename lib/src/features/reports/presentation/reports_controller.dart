import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_report_repository.dart';

part 'reports_controller.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> revenueReport(
  RevenueReportRef ref, {
  required DateTime startDate,
  required DateTime endDate,
  String? investorId,
}) {
  return ref.watch(reportRepositoryProvider).getRevenueReport(
        startDate: startDate,
        endDate: endDate,
        investorId: investorId,
      );
}

@riverpod
Future<List<Map<String, dynamic>>> profitReport(
  ProfitReportRef ref, {
  required DateTime startDate,
  required DateTime endDate,
  String? investorId,
  String? customerId,
}) {
  return ref.watch(reportRepositoryProvider).getProfitReport(
        startDate: startDate,
        endDate: endDate,
        investorId: investorId,
        customerId: customerId,
      );
}

@riverpod
Future<List<Map<String, dynamic>>> trialBalance(TrialBalanceRef ref) {
  return ref.watch(reportRepositoryProvider).getTrialBalance();
}

@riverpod
Future<List<Map<String, dynamic>>> cashFlowReport(
  CashFlowReportRef ref, {
  required DateTime startDate,
  required DateTime endDate,
  String? investorId,
}) {
  return ref.watch(reportRepositoryProvider).getCashFlowReport(
        startDate: startDate,
        endDate: endDate,
        investorId: investorId,
      );
}

@riverpod
Future<List<Map<String, dynamic>>> contractsSummary(ContractsSummaryRef ref) {
  return ref.watch(reportRepositoryProvider).getContractsSummary();
}

@riverpod
Future<List<Map<String, dynamic>>> collectionsReport(
  CollectionsReportRef ref, {
  required DateTime startDate,
  required DateTime endDate,
  String? customerId,
}) {
  return ref.watch(reportRepositoryProvider).getCollectionsReport(
        startDate: startDate,
        endDate: endDate,
        customerId: customerId,
      );
}

@riverpod
class ReportFiltersController extends _$ReportFiltersController {
  @override
  Map<String, String?> build() {
    return {
      'investorId': null,
      'customerId': null,
    };
  }

  void setInvestor(String? id) {
    state = {...state, 'investorId': id};
  }

  void setCustomer(String? id) {
    state = {...state, 'customerId': id};
  }

  void clearFilters() {
    state = {'investorId': null, 'customerId': null};
  }
}
