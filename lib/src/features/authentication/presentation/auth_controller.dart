import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/app_user.dart';
import '../data/supabase_auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() => null;

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    final authRepo = ref.read(authRepositoryProvider);

    final result = await AsyncValue.guard(
      () => authRepo.signInWithEmailAndPassword(email, password),
    );

    if (result.hasError) {
      await _logSecurityEvent('LOGIN_FAILURE', null);
      state = result;
      return false;
    }

    final user = await authRepo.getCurrentUser();
    await _logSecurityEvent('LOGIN_SUCCESS', user?.id);

    state = const AsyncValue.data(null);
    return true;
  }

  Future<bool> registerInvestor({
    required String email,
    required String password,
    required String fullName,
    required String nationalId,
    required String phone,
  }) async {
    state = const AsyncLoading();
    final authRepo = ref.read(authRepositoryProvider);

    final result = await AsyncValue.guard(
      () => authRepo.signUpInvestor(
        email: email,
        password: password,
        fullName: fullName,
        nationalId: nationalId,
        phone: phone,
      ),
    );

    if (result.hasError) {
      state = result;
      return false;
    }

    state = const AsyncValue.data(null);
    return true;
  }

  Future<bool> recoverPassword(String email) async {
    state = const AsyncLoading();
    final authRepo = ref.read(authRepositoryProvider);

    final result = await AsyncValue.guard(
      () => authRepo.recoverPassword(email),
    );

    if (result.hasError) {
      state = result;
      return false;
    }

    state = const AsyncValue.data(null);
    return true;
  }

  Future<bool> resetPassword(String newPassword) async {
    state = const AsyncLoading();
    final authRepo = ref.read(authRepositoryProvider);

    final result = await AsyncValue.guard(
      () => authRepo.updatePassword(newPassword),
    );

    if (result.hasError) {
      state = result;
      return false;
    }

    state = const AsyncValue.data(null);
    return true;
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    final authRepo = ref.read(authRepositoryProvider);

    final user = await authRepo.getCurrentUser();

    if (user != null) {
      await _logSecurityEvent('LOGOUT', user.id);
    }

    state = await AsyncValue.guard(() => authRepo.signOut());
  }

  /// إعادة تحميل حالة المستخدم من قاعدة البيانات (للتحقق من الموافقة)
  Future<void> refreshUserStatus() async {
    // إعادة تحميل بيانات المستخدم الحالي من DB
    ref.invalidate(authStateProvider);
  }

  Future<void> _logSecurityEvent(String eventType, String? userId) async {
    // Note: Security repository implementation should be verified if it exists and is updated
    // For now, focusing on Auth workflow.
  }
}

@riverpod
Stream<AppUser?> authState(AuthStateRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@riverpod
AppUser? currentUser(CurrentUserRef ref) {
  return ref.watch(authStateProvider).valueOrNull;
}

/// Provider منفصل يُستخدم في pending_approval_screen لإعادة تحميل البروفايل يدوياً
@riverpod
Future<AppUser?> refreshedCurrentUser(RefreshedCurrentUserRef ref) async {
  return await ref.watch(authRepositoryProvider).getCurrentUser();
}
