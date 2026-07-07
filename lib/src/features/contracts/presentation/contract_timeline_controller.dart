import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_contract_repository.dart';
import '../domain/contract_activity.dart';

part 'contract_timeline_controller.g.dart';

@riverpod
Future<List<ContractActivity>> contractTimeline(ContractTimelineRef ref, String contractId) async {
  final repository = ref.watch(contractRepositoryProvider);
  final data = await repository.getContractTimeline(contractId);
  
  return data.map((json) {
    // Map database fields to model fields
    return ContractActivity(
      eventType: json['event_type'] as String,
      occurredAt: DateTime.parse(json['created_at'] as String),
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      // In a real app, we might join profile_id to get a name, 
      // but here we'll use the ID or a placeholder if name isn't joined yet.
      profileName: json['profile_id']?.toString(), 
    );
  }).toList();
}
