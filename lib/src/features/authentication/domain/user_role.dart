import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('accountant')
  accountant,
  @JsonValue('investor')
  investor;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.accountant:
        return 'Accountant';
      case UserRole.investor:
        return 'Investor';
    }
  }
}
