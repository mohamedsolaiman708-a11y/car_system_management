import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/app_user.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/utils/error_handler.dart';

part 'supabase_staff_repository.g.dart';

class SupabaseStaffRepository {
  final SupabaseClient _client;

  SupabaseStaffRepository(this._client);

  Future<List<AppUser>> getStaffMembers() async {
    try {
      final profilesResponse = await _client
          .from('profiles')
          .select('*, roles!inner(*)')
          .order('full_name', ascending: true);
      
      final invitesResponse = await _client
          .from('user_invitations')
          .select('email');
      
      final invitedEmails = (invitesResponse as List)
          .map((i) => i['email'].toString().toLowerCase().trim())
          .toSet();

      final allUsers = (profilesResponse as List).map((json) {
        final roleData = json['roles'];
        
        String? userEmail = json['email']?.toString();
        if (userEmail == null || userEmail.isEmpty) {
          userEmail = json['raw_user_meta_data']?['email']?.toString();
        }

        return AppUser.fromJson({
          ...json,
          'role': roleData['slug'],
          'email': userEmail,
        });
      }).toList();

      return allUsers.where((u) {
        final isStaffRole = u.role.name != 'investor';
        final userEmail = u.email?.toLowerCase().trim();
        final hasStaffInvite = userEmail != null && invitedEmails.contains(userEmail);
        
        return isStaffRole || hasStaffInvite;
      }).toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> resetStaffPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://al-sami-auto.vercel.app/reset-password',
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

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
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> inviteStaff({
    required String email,
    required String fullName,
    required String roleId,
  }) async {
    try {
      await _client.from('user_invitations').insert({
        'email': email.trim().toLowerCase(),
        'full_name': fullName.trim(),
        'role_id': roleId,
        'invited_by': _client.auth.currentUser?.id,
        'token': 'INV-${DateTime.now().millisecondsSinceEpoch}',
        'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      });
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<Map<String, dynamic>>> getRoles() async {
    try {
      final response = await _client
          .from('roles')
          .select()
          .neq('slug', 'investor')
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}

@Riverpod(keepAlive: true)
SupabaseStaffRepository staffRepository(StaffRepositoryRef ref) {
  return SupabaseStaffRepository(ref.watch(supabaseClientProvider));
}
