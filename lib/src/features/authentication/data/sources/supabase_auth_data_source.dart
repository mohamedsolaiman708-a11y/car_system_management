import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
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
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
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
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  @override
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    return await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }
}

@Riverpod(keepAlive: true)
AuthDataSource authDataSource(AuthDataSourceRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthDataSource(client);
}
