import 'security_log.dart';

abstract class SecurityRepository {
  /// سجل حدثاً أمنياً (مثل تسجيل دخول، محاولة فاشلة، إلخ)
  Future<void> logEvent(SecurityLog log);
}
