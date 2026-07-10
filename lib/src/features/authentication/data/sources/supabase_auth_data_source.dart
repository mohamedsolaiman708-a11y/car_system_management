import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:car_system_management/src/core/providers/supabase_provider.dart';
import 'auth_data_source.dart';

part 'supabase_auth_data_source.g.dart';

class SupabaseAuthDataSource implements AuthDataSource {
  final SupabaseClient _client;

  SupabaseAuthDataSource(this._client);

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUpInvestor({
    required String email,
    required String password,
    required String fullName,
    required String nationalId,
    required String phone,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'national_id': nationalId,
        'phone': phone,
        'role': 'investor', // تحديد الدور هنا كـ مستثمر
      },
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> recoverPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('*, roles(slug)')
          .eq('id', userId)
          .maybeSingle();
      
      final authUser = _client.auth.currentUser;
      final now = DateTime.now().toIso8601String();

      // منطق تحديد الدور بشكل آمن
      String roleSlug = 'investor'; // الدور الافتراضي للأمان هو مستثمر وليس أدمن
      
      if (response != null) {
        final rolesData = response['roles'] ?? response['role'];
        if (rolesData != null) {
          if (rolesData is Map && rolesData['slug'] != null) {
            roleSlug = (rolesData['slug'] as String).toLowerCase();
          } else if (rolesData is List && rolesData.isNotEmpty) {
            final firstRole = rolesData.first;
            if (firstRole is Map && firstRole['slug'] != null) {
              roleSlug = (firstRole['slug'] as String).toLowerCase();
            }
          }
        }
      }

      // إذا لم يتم تحديد دور مخصص من قاعدة البيانات، نأخذ الدور من الـ Metadata كاحتياط
      if (roleSlug == 'investor' && authUser?.userMetadata != null && authUser!.userMetadata!['role'] != null) {
        roleSlug = authUser.userMetadata!['role'].toString().toLowerCase();
      }

      // إذا لم يكن هناك استجابة من البروفايل (مستخدم جديد جداً)
      if (response == null) {
        return {
          'id': userId,
          'full_name': authUser?.userMetadata?['full_name'] ?? 'مستثمر جديد',
          'email': authUser?.email ?? '',
          'is_active': false, // غير نشط حتى يفعله الأدمن
          'status': 'pending', // قيد الانتظار
          'role': roleSlug,
          'created_at': now,
          'updated_at': now,
        };
      }

      final mappedData = {
        'id': response['id'],
        'full_name': response['full_name'] ?? authUser?.userMetadata?['full_name'] ?? 'مستخدم نظام',
        'email': authUser?.email ?? 'no-email@system.com',
        'is_active': response['is_active'] ?? false,
        'status': response['status'] ?? 'pending', // الافتراضي قيد الانتظار
        'role': roleSlug, 
        'created_at': response['created_at'] ?? now,
        'updated_at': response['updated_at'] ?? now,
      };

      developer.log('✅ تم جلب بيانات المستخدم بنجاح: $mappedData');
      return mappedData;
    } catch (e) {
      developer.log('❌ خطأ في جلب البروفايل: $e');
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
AuthDataSource authDataSource(AuthDataSourceRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthDataSource(client);
}
