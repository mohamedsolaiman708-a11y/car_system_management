import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('accountant')
  accountant,
  @JsonValue('sales')
  sales,
  @JsonValue('investor')
  investor;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'مدير نظام';
      case UserRole.manager:
        return 'مدير عمليات';
      case UserRole.accountant:
        return 'محاسب';
      case UserRole.sales:
        return 'مسؤول مبيعات';
      case UserRole.investor:
        return 'مستثمر';
    }
  }
}
