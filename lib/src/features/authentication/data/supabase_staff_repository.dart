import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/app_user.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/utils/error_handler.dart';

part 'supabase_staff_repository.g.dart';

class SupabaseStaffRepository {
  final SupabaseClient _client;
  final Map<String, dynamic> _memCache = {};

  SupabaseStaffRepository(this._client);

  /// جلب كافة الموظفين فقط (استبعاد المستثمرين)
  Future<List<AppUser>> getStaffMembers() async {
    const key = 'staff_members_list';
    try {
      // أعدنا الفلترة لاستبعاد المستثمرين من قائمة فريق العمل
      final response = await _client
          .from('profiles')
          .select('*, roles!inner(*)')
          .neq('roles.slug', 'investor') // استبعاد المستثمرين
          .order('full_name', ascending: true);
      
      final list = (response as List).map((json) {
        final roleData = json['roles'];
        return AppUser.fromJson({
          ...json,
          'role': roleData['slug'],
          'email': json['email'], // سيقرأ القيمة الجديدة من قاعدة البيانات
        });
      }).toList();

      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<AppUser>;
      }
      throw Failure.fromException(e);
    }
  }

  /// تحديث بيانات الموظف
  Future<void> updateStaffProfile(String userId, {
    bool? isActive, 
    String? roleId,
    String? fullName,
    String? status,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (isActive != null) updates['is_active'] = isActive;
      if (roleId != null) updates['role_id'] = roleId;
      if (fullName != null) updates['full_name'] = fullName;
      if (status != null) updates['status'] = status;
      
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      await _client.from('profiles').update(updates).eq('id', userId);
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// طلب إعادة تعيين كلمة المرور
  Future<void> resetStaffPassword(String email) async {
    try {
      // نقوم بإضافة رابط العودة للتطبيق ليتمكن المستخدم من تغيير كلمة المرور
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://al-sami-auto.vercel.app/reset-password', // استبدله برابط تطبيقك الفعلي أو رابط التوجيه المناسب
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// إرسال دعوة لموظف جديد
  Future<void> inviteStaff({
    required String email,
    required String fullName,
    required String roleId,
  }) async {
    try {
      await _client.from('user_invitations').insert({
        'email': email.trim().toLowerCase(),
        'role_id': roleId,
        'invited_by': _client.auth.currentUser?.id,
        'token': 'INV-${DateTime.now().millisecondsSinceEpoch}',
        'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      });
      _memCache.clear();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// جلب الأدوار المتاحة (استبعاد دور المستثمر)
  Future<List<Map<String, dynamic>>> getRoles() async {
    const key = 'available_roles_list';
    try {
      final response = await _client
          .from('roles')
          .select()
          .neq('slug', 'investor') // لا نحتاج لدور المستثمر هنا
          .order('name');
      final list = List<Map<String, dynamic>>.from(response);
      _memCache[key] = list;
      return list;
    } catch (e) {
      if (_memCache.containsKey(key)) {
        return _memCache[key] as List<Map<String, dynamic>>;
      }
      throw Failure.fromException(e);
    }
  }
}

@Riverpod(keepAlive: true)
SupabaseStaffRepository staffRepository(StaffRepositoryRef ref) {
  return SupabaseStaffRepository(ref.watch(supabaseClientProvider));
}
