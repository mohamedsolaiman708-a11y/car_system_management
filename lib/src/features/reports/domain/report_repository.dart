abstract class ReportRepository {
  Future<List<Map<String, dynamic>>> getRevenueReport({
    required DateTime startDate,
    required DateTime endDate,
    String? investorId,
  });

  Future<List<Map<String, dynamic>>> getProfitReport({
    required DateTime startDate,
    required DateTime endDate,
    String? investorId,
    String? customerId,
  });

  Future<List<Map<String, dynamic>>> getCashFlowReport({
    required DateTime startDate,
    required DateTime endDate,
    String? investorId,
  });

  Future<List<Map<String, dynamic>>> getOverdueReport();

  Future<List<Map<String, dynamic>>> getInvestorsPerformance();

  Future<List<Map<String, dynamic>>> getCollectionsReport({
    required DateTime startDate,
    required DateTime endDate,
    String? customerId,
  });

  Future<List<Map<String, dynamic>>> getContractsSummary();

  /// جلب ميزان المراجعة (محاسبي)
  Future<List<Map<String, dynamic>>> getTrialBalance();
}
