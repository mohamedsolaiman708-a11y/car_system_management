import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'sources/auth_data_source.dart';
import 'sources/supabase_auth_data_source.dart';

part 'supabase_auth_repository.g.dart';

class SupabaseAuthRepository implements AuthRepository {
  final AuthDataSource _dataSource;

  SupabaseAuthRepository(this._dataSource);

  @override
  Stream<AppUser?> authStateChanges() {
    return _dataSource.onAuthStateChange.asyncMap((AuthState state) async {
      final User? user = state.session?.user;
      if (user == null) return null;
      
      return await getCurrentUser();
    });
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final User? user = _dataSource.currentUser;
    if (user == null) return null;

    try {
      final Map<String, dynamic>? response = await _dataSource.getProfile(user.id);
      if (response == null) return null;
      return AppUser.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _dataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signUpInvestor({
    required String email,
    required String password,
    required String fullName,
    required String nationalId,
    required String phone,
  }) async {
    await _dataSource.signUpInvestor(
      email: email,
      password: password,
      fullName: fullName,
      nationalId: nationalId,
      phone: phone,
    );
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  Future<void> recoverPassword(String email) async {
    await _dataSource.recoverPassword(email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _dataSource.updatePassword(newPassword);
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return SupabaseAuthRepository(dataSource);
}
