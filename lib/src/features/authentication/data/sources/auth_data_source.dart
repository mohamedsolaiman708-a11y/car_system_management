import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthDataSource {
  /// الحصول على تدفق حالة تسجيل الدخول
  Stream<AuthState> get onAuthStateChange;

  /// الحصول على المستخدم الحالي من الجلسة
  User? get currentUser;

  /// تسجيل الدخول بالبريد وكلمة المرور
  Future<AuthResponse> signInWithEmailAndPassword(String email, String password);

  /// تسجيل مستخدم جديد كمستثمر
  Future<AuthResponse> signUpInvestor({
    required String email,
    required String password,
    required String fullName,
    required String nationalId,
    required String phone,
  });

  /// تسجيل الخروج
  Future<void> signOut();

  /// استعادة كلمة المرور
  Future<void> recoverPassword(String email);

  /// تحديث كلمة المرور
  Future<void> updatePassword(String newPassword);

  /// جلب بيانات البروفايل الخام من قاعدة البيانات
  Future<Map<String, dynamic>?> getProfile(String userId);
}
