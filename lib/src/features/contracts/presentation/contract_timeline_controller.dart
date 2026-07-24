import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_contract_repository.dart';
import '../domain/contract_activity.dart';

part 'contract_timeline_controller.g.dart';

@riverpod
class ContractTimelineNotifier extends _$ContractTimelineNotifier {
  @override
  FutureOr<List<ContractActivity>> build(String contractId) async {
    final repository = ref.watch(contractRepositoryProvider);
    
    // ضمان استخدام الـ UUID الحقيقي للجلب من سجلات الرقابة
    String effectiveId = contractId;
    if (!contractId.contains('-') || contractId.length < 30) {
      final contract = await repository.getContractById(contractId);
      if (contract != null) effectiveId = contract.id;
    }

    final data = await repository.getContractTimeline(effectiveId);
    
    if (data.isEmpty) return [];

    final List<ContractActivity> activities = data.map((json) {
      String eventType = (json['event_type'] ?? json['action'] ?? 'ACTIVITY').toString();
      
      // تحويل العمليات الخام لأسماء أحداث مفهومة
      if (eventType == 'INSERT' && json['table_name'] == 'financing_contracts') eventType = 'CONTRACT_CREATED';
      if (eventType == 'UPDATE' && json['table_name'] == 'financing_contracts') eventType = 'CONTRACT_UPDATED';
      
      final createdAtStr = json['created_at'] ?? json['occurred_at'] ?? DateTime.now().toIso8601String();
      
      return ContractActivity(
        eventType: eventType,
        occurredAt: DateTime.parse(createdAtStr.toString()),
        details: Map<String, dynamic>.from(json['details'] ?? json['new_values'] ?? {}),
        profileName: json['full_name'] ?? 'نظام المعرض', 
      );
    }).toList();

    activities.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return activities;
  }

  /// وظيفة إضافة سجل حدث يدوياً (مثل رفع المستندات)
  Future<void> addLog({required String eventType, Map<String, dynamic>? metadata}) async {
    final repository = ref.read(contractRepositoryProvider);
    await repository.addContractLog(contractId: contractId, eventType: eventType, metadata: metadata);
    ref.invalidateSelf(); // تحديث التايم لاين فوراً لظهور الحدث الجديد
  }
}

// Provider القديم للتوافق مع الشاشات الحالية دون تغيير الكود في كل مكان
@riverpod
Future<List<ContractActivity>> contractTimeline(ContractTimelineRef ref, String contractId) {
  return ref.watch(contractTimelineNotifierProvider(contractId).future);
}
