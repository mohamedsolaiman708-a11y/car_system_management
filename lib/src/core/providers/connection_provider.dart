import 'dart:async';
import 'dart:io';
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

    // Default to online initially, then verify
    _checkConnection();
    return false;
  }

  void _startPeriodicCheck() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      await _checkConnection();
    });
  }

  Future<bool> _checkConnection() async {
    if (_isChecking) return state;
    _isChecking = true;

    bool isNowOffline = false;
    try {
      // Fast DNS lookup for Supabase host
      final result = await InternetAddress.lookup('trflombswaszomydbnoo.supabase.co')
          .timeout(const Duration(seconds: 5));
      isNowOffline = result.isEmpty || result[0].rawAddress.isEmpty;
    } catch (_) {
      isNowOffline = true;
    }

    _isChecking = false;

    if (state != isNowOffline) {
      state = isNowOffline;
      if (isNowOffline) {
        // Check more frequently when offline to restore connection quickly
        _pingTimer?.cancel();
        _pingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
          final resolved = await _checkConnection();
          if (!resolved) {
            // Returned online, go back to normal cycle
            _startPeriodicCheck();
          }
        });
      }
    }
    return isNowOffline;
  }

  /// Manually force a connection check (e.g. from user retry button)
  Future<void> forceCheck() async {
    final offline = await _checkConnection();
    state = offline;
  }

  /// Mark the state as offline due to a failed request
  void setOffline() {
    if (!state) {
      state = true;
      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        final resolved = await _checkConnection();
        if (!resolved) {
          _startPeriodicCheck();
        }
      });
    }
  }
}
