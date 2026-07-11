import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/supabase_staff_repository.dart';
import '../domain/app_user.dart';

part 'staff_controller.g.dart';

@riverpod
class StaffListController extends _$StaffListController {
  @override
  FutureOr<List<AppUser>> build() {
    return ref.watch(staffRepositoryProvider).getStaffMembers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(staffRepositoryProvider).getStaffMembers());
  }

  Future<void> updateStatus(String userId, bool isActive) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(staffRepositoryProvider).updateStaffProfile(userId, isActive: isActive);
      return ref.read(staffRepositoryProvider).getStaffMembers();
    });
  }

  /// اعتماد المستخدم كعضو في الفريق (تغيير الحالة وتفعيل الحساب)
  Future<void> approveAsStaff(String userId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(staffRepositoryProvider).updateStaffProfile(
        userId, 
        status: 'approved', 
        isActive: true
      );
      return ref.read(staffRepositoryProvider).getStaffMembers();
    });
  }

  Future<void> updateRole(String userId, String roleId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(staffRepositoryProvider).updateStaffProfile(userId, roleId: roleId);
      return ref.read(staffRepositoryProvider).getStaffMembers();
    });
  }

  Future<void> updateName(String userId, String fullName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(staffRepositoryProvider).updateStaffProfile(userId, fullName: fullName);
      return ref.read(staffRepositoryProvider).getStaffMembers();
    });
  }

  Future<bool> resetPassword(String email) async {
    final result = await AsyncValue.guard(() => 
      ref.read(staffRepositoryProvider).resetStaffPassword(email)
    );
    return !result.hasError;
  }

  Future<bool> inviteStaff({
    required String email,
    required String fullName,
    required String roleId,
  }) async {
    final result = await AsyncValue.guard(() => 
      ref.read(staffRepositoryProvider).inviteStaff(
        email: email,
        fullName: fullName,
        roleId: roleId,
      )
    );
    return !result.hasError;
  }
}

@riverpod
Future<List<Map<String, dynamic>>> availableRoles(AvailableRolesRef ref) {
  return ref.watch(staffRepositoryProvider).getRoles();
}
