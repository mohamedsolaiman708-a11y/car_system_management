// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Car Finance System';

  @override
  String get staffPortal => 'Staff Portal';

  @override
  String get investorPortal => 'Investor Portal';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get nationalId => 'National ID';

  @override
  String get phone => 'Phone Number';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get registerSuccess => 'Registered successfully';

  @override
  String get pendingApprovalTitle => 'Pending Approval';

  @override
  String get pendingApprovalMessage =>
      'Thank you for registering. Your account is currently under review by the administration. We will notify you once activated.';

  @override
  String get accountRejectedTitle => 'Account Rejected';

  @override
  String get accountRejectedMessage =>
      'We regret to inform you that your registration has been rejected. Please contact support for more details.';

  @override
  String get sessionExpired => 'Session expired, please login again';

  @override
  String get emailVerification => 'Email Verification';

  @override
  String get verifyEmailMessage =>
      'Please verify your email address to activate your account.';

  @override
  String get errorFieldRequired => 'This field is required';

  @override
  String get errorInvalidEmail => 'Invalid email address';

  @override
  String get errorPasswordTooShort => 'Password is too short';

  @override
  String get errorPasswordsDontMatch => 'Passwords do not match';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get submit => 'Submit';

  @override
  String get loading => 'Loading...';
}
