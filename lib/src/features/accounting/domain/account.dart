import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
class Account with _$Account {
  const factory Account({
    required String id,
    required String code,
    required String name,
    required String type, // 'asset', 'liability', 'equity', 'revenue', 'expense'
    @JsonKey(name: 'current_balance', defaultValue: 0.0) required double currentBalance,
    @JsonKey(name: 'is_active', defaultValue: true) required bool isActive,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
}
