import '../../domain/security_log.dart';

abstract class SecurityDataSource {
  /// إدراج سجل أمني جديد في قاعدة البيانات
  Future<void> insertLog(SecurityLog log);
}
