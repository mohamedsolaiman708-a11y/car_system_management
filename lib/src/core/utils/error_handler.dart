import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => message;

  /// فحص ما إذا كان الخطأ متعلقاً بالاتصال والشبكة فقط
  static bool isNetworkError(dynamic exception) {
    final errorStr = exception.toString();
    return errorStr.contains('SocketException') || 
           errorStr.contains('HandshakeException') || 
           errorStr.contains('Connection terminated') ||
           errorStr.contains('NetworkIsUnreachable') ||
           errorStr.contains('failed host lookup') ||
           exception is TimeoutException;
  }

  factory Failure.fromException(dynamic exception) {
    if (exception is Failure) return exception;

    String message = 'عذراً، حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
    String? code;

    final errorStr = exception.toString();

    if (isNetworkError(exception)) {
      message = 'تعذر الاتصال بالخادم. يرجى التحقق من جودة الإنترنت لديك.';
      code = 'OFFLINE';
    } 
    else if (errorStr.contains('RealtimeSubscribeException') || errorStr.contains('channelError')) {
      message = 'توجد مشكلة مؤقتة في تحديث البيانات اللحظي. جاري محاولة إعادة الاتصال.';
      code = 'REALTIME_ERROR';
    }
    else if (exception is PostgrestException) {
      message = _handlePostgrestError(exception);
      code = exception.code;
    } 
    else if (exception is AuthException) {
      message = _handleAuthError(exception);
      code = exception.statusCode ?? exception.code;
    }

    return Failure(message: message, code: code);
  }

  static String _handleAuthError(AuthException exception) {
    final msg = exception.message.toLowerCase();
    final code = (exception.code ?? '').toLowerCase();

    if (msg.contains('user already registered') || msg.contains('already exists') || code.contains('user_already_exists')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل. يرجى تسجيل الدخول بدلاً من ذلك.';
    }
    if (msg.contains('database error saving new user') || msg.contains('unexpected_failure')) {
      return 'حدث خطأ في قاعدة البيانات أثناء حفظ البروفايل.';
    }
    if (msg.contains('invalid login credentials') || msg.contains('invalid_credentials') || code.contains('invalid_credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }
    if (msg.contains('password should be at least') || msg.contains('weak password') || msg.contains('password_too_short')) {
      return 'كلمة المرور ضعيفة. يرجى استخدام كلمة مرور تحتوي على 6 أحرف/أرقام على الأقل.';
    }
    if (msg.contains('rate limit') || msg.contains('over_email_send_limit')) {
      return 'تم تجاوز الحد المسموح من المحاولات. يرجى الانتظار قليلاً والمحاولة لاحقاً.';
    }
    if (msg.contains('invalid email') || msg.contains('email_address_invalid')) {
      return 'صيغة البريد الإلكتروني غير صحيحة.';
    }
    return exception.message;
  }

  static String _handlePostgrestError(PostgrestException err) {
    // إضافة معالجة للمزيد من أكواد الأخطاء الشائعة في بوسطجرس
    switch (err.code) {
      case '42501': return 'عذراً، لا تملك الصلاحية الكافية للوصول لهذه البيانات (RLS Policy).';
      case '23505': return 'هذه البيانات مسجلة بالفعل في النظام (Unique Violation).';
      case '23503': return 'فشل الإجراء بسبب ارتباط البيانات بسجلات أخرى (Foreign Key Violation).';
      case '23502': return 'يوجد حقل مطلوب لم يتم إدخاله بشكل صحيح (Not Null Violation).';
      case 'P0001': return 'فشل الإجراء: ${err.message} (Database Trigger Error).';
      default: return 'خطأ في قاعدة البيانات: ${err.message}';
    }
  }
}
