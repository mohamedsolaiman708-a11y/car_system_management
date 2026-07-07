import 'package:freezed_annotation/freezed_annotation.dart';

part 'contract_activity.freezed.dart';
part 'contract_activity.g.dart';

@freezed
class ContractActivity with _$ContractActivity {
  const factory ContractActivity({
    required String eventType,
    required DateTime occurredAt,
    @Default({}) Map<String, dynamic> details,
    String? profileName,
  }) = _ContractActivity;

  factory ContractActivity.fromJson(Map<String, dynamic> json) => _$ContractActivityFromJson(json);
}
