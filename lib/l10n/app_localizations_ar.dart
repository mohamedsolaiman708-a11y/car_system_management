// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'نظام تمويل السيارات';

  @override
  String get staffPortal => 'بوابة الموظفين';

  @override
  String get investorPortal => 'بوابة المستثمرين';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get nationalId => 'الرقم القومي / الهوية';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get registerSuccess => 'تم تسجيل طلبك بنجاح';

  @override
  String get pendingApprovalTitle => 'طلبك قيد المراجعة';

  @override
  String get pendingApprovalMessage =>
      'شكراً لتسجيلك. حسابك قيد المراجعة من قبل الإدارة. سنخطرك فور تفعيل الحساب.';

  @override
  String get accountRejectedTitle => 'تم رفض الطلب';

  @override
  String get accountRejectedMessage =>
      'نأسف لإبلاغك بأنه تم رفض طلب انضمامك. يرجى التواصل مع الدعم للمزيد من التفاصيل.';

  @override
  String get sessionExpired => 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى';

  @override
  String get emailVerification => 'تفعيل البريد الإلكتروني';

  @override
  String get verifyEmailMessage =>
      'يرجى التحقق من بريدك الإلكتروني لتفعيل الحساب.';

  @override
  String get errorFieldRequired => 'هذا الحقل مطلوب';

  @override
  String get errorInvalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get errorPasswordTooShort => 'كلمة المرور قصيرة جداً';

  @override
  String get errorPasswordsDontMatch => 'كلمات المرور غير متطابقة';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get submit => 'إرسال';

  @override
  String get loading => 'جاري التحميل...';
}
