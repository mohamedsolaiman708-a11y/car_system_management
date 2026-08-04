import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_provider.g.dart';

@Riverpod(keepAlive: true)
class ConnectionNotifier extends _$ConnectionNotifier {
  Timer? _pingTimer;
  bool _isChecking = false;

  @override
  bool build() {
    // Start periodic check
    _startPeriodicCheck();
    
    ref.onDispose(() {
      _pingTimer?.cancel();
    });

    // Initial check
    _checkConnection();
    return false;
  }

  void _startPeriodicCheck() {
    _pingTimer?.cancel();
    // تقليل وتيرة الفحص لتجنب الإزعاج في حال كانت الشبكة متذبذبة
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkConnection();
    });
  }

  Future<bool> _checkConnection() async {
    if (_isChecking) return state;
    _isChecking = true;

    bool isNowOffline = false;
    
    if (kIsWeb) {
      // على الويب، لا يمكن استخدام InternetAddress.lookup
      // لذا نفترض وجود اتصال إلا إذا تم استدعاء setOffline يدوياً عند فشل طلب فعلي
      isNowOffline = false;
    } else {
      try {
        // فحص الاتصال عبر محاولة الوصول لخدمة موثوقة (Google) بدلاً من رابط Supabase الخاص
        // لتجنب الخلط بين تعطل السيرفر وانقطاع الإنترنت العام
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 5));
        isNowOffline = result.isEmpty || result[0].rawAddress.isEmpty;
      } catch (_) {
        isNowOffline = true;
      }
    }

    _isChecking = false;

    if (state != isNowOffline) {
      state = isNowOffline;
      if (isNowOffline) {
        // إذا كان أوفلاين، نفحص بوتيرة أسرع لمحاولة استعادة الاتصال
        _pingTimer?.cancel();
        _pingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
          final stillOffline = await _checkConnection();
          if (!stillOffline) {
            _startPeriodicCheck();
          }
        });
      }
    }
    return isNowOffline;
  }

  /// فرض فحص الاتصال يدوياً (مثلاً عند ضغط زر "إعادة المحاولة")
  Future<void> forceCheck() async {
    final offline = await _checkConnection();
    state = offline;
  }

  /// تعيين الحالة كـ "أوفلاين" يدوياً عند فشل طلب API حقيقي
  void setOffline() {
    if (!state) {
      state = true;
      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        final stillOffline = await _checkConnection();
        if (!stillOffline) {
          _startPeriodicCheck();
        }
      });
    }
  }
}
