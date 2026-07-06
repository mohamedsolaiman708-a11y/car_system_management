import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_role.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required UserRole role,
    @JsonKey(name: 'is_active') required bool isActive,
    @Default('pending') String status, // 'pending', 'approved', 'rejected', 'active'
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}
