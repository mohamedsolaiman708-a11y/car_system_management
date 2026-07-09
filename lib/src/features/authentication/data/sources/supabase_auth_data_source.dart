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
        'role': 'investor',
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
      // جلب البروفايل مع الدور (slug)
      final response = await _client
          .from('profiles')
          .select('*, roles(slug)')
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) return null;

      final authUser = _client.auth.currentUser;
      final now = DateTime.now().toIso8601String();

      // معالجة ذكية للبيانات لمنع Parsing Error في Flutter
      // نضع قيم افتراضية للحقول التي قد تكون NULL في حالة الإدخال اليدوي
      String roleSlug = 'admin'; 
      if (response['roles'] != null && response['roles']['slug'] != null) {
        roleSlug = (response['roles']['slug'] as String).toLowerCase();
      }

      final mappedData = {
        'id': response['id'],
        'full_name': response['full_name'] ?? 'مستخدم نظام',
        'email': authUser?.email ?? 'no-email@system.com',
        'is_active': response['is_active'] ?? true,
        'status': response['status'] ?? 'approved',
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
