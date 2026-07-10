import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';
import '../../../core/providers/supabase_provider.dart';

part 'supabase_staff_repository.g.dart';

class SupabaseStaffRepository {
  final SupabaseClient _client;
  SupabaseStaffRepository(this._client);

  /// جلب كافة الموظفين
  Future<List<AppUser>> getStaffMembers() async {
    try {
      final response = await _client
          .from('profiles')
          .select('*, roles!inner(*)')
          .neq('roles.slug', 'investor')
          .order('full_name', ascending: true);
      
      return (response as List).map((json) {
        final roleData = json['roles'];
        return AppUser.fromJson({
          ...json,
          'role': roleData['slug'], 
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// تحديث بيانات الموظف
  Future<void> updateStaffProfile(String userId, {
    bool? isActive, 
    String? roleId,
    String? fullName,
  }) async {
    final updates = <String, dynamic>{};
    if (isActive != null) updates['is_active'] = isActive;
    if (roleId != null) updates['role_id'] = roleId;
    if (fullName != null) updates['full_name'] = fullName;
    
    updates['updated_at'] = DateTime.now().toIso8601String();
    
    await _client.from('profiles').update(updates).eq('id', userId);
  }

  /// طلب إعادة تعيين كلمة المرور
  Future<void> resetStaffPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// إرسال دعوة لموظف جديد
  Future<void> inviteStaff({
    required String email,
    required String fullName,
    required String roleId,
  }) async {
    await _client.from('user_invitations').insert({
      'email': email,
      'role_id': roleId,
      'invited_by': _client.auth.currentUser?.id,
      'token': 'INV-${DateTime.now().millisecondsSinceEpoch}',
      'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
    });
  }

  /// جلب الأدوار المتاحة (تم تعديل الاستعلام ليكون أكثر مرونة)
  Future<List<Map<String, dynamic>>> getRoles() async {
    try {
      final response = await _client
          .from('roles')
          .select()
          .not('slug', 'eq', 'investor')
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // في حالة وجود خطأ RLS، نرجع قائمة فارغة لكي تتعامل معها الواجهة
      return [];
    }
  }
}

@Riverpod(keepAlive: true)
SupabaseStaffRepository staffRepository(StaffRepositoryRef ref) {
  return SupabaseStaffRepository(ref.watch(supabaseClientProvider));
}
