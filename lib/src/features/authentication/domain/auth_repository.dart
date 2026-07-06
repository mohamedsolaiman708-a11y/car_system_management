import 'app_user.dart';

abstract class AuthRepository {
  /// Stream of [AppUser] to listen to authentication state changes.
  Stream<AppUser?> authStateChanges();

  /// Sign in with email and password.
  Future<void> signInWithEmailAndPassword(String email, String password);

  /// Sign up a new investor.
  Future<void> signUpInvestor({
    required String email,
    required String password,
    required String fullName,
    required String nationalId,
    required String phone,
  });

  /// Sign out the current user.
  Future<void> signOut();

  /// Send a password reset email.
  Future<void> recoverPassword(String email);

  /// Update the password for the current user.
  Future<void> updatePassword(String newPassword);

  /// Get the current logged in user profile.
  Future<AppUser?> getCurrentUser();
}
