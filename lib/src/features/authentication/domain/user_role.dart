import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('admin')
  admin,
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
      case UserRole.accountant:
        return 'محاسب مالي';
      case UserRole.sales:
        return 'مسؤول مبيعات';
      case UserRole.investor:
        return 'مستثمر';
    }
  }
}
