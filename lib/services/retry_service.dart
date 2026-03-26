// // lib/services/retry_service.dart
// import 'dart:async';

// import 'api_service.dart';

// /// Manages background polling with automatic silent retry and exponential backoff.
// /// Used for notification polling — if a request fails due to network/block,
// /// it does NOT show an error. It just slows down and tries again silently.
// class RetryService {
//   static Timer? _pollTimer;
//   static int _failCount = 0;
//   static const int _maxFailsBeforeSlowdown = 3;

//   // Intervals: normal → slow → very slow
//   static const Duration _normalInterval = Duration(seconds: 10);
//   static const Duration _slowInterval   = Duration(seconds: 30);
//   static const Duration _verySlowInterval = Duration(seconds: 60);

//   static void Function(int count)? _onCount;
//   static bool _isRunning = false;

//   /// Start polling for unread notifications.
//   /// On success: calls [onCount] with the count.
//   /// On failure: silently backs off and retries — NEVER shows error to user.
//   static void startNotificationPolling({
//     required void Function(int count) onCount,
//     Duration? initialInterval,
//   }) {
//     stopPolling();
//     _failCount = 0;
//     _isRunning = true;
//     _onCount = onCount;

//     _schedulePoll(initialInterval ?? _normalInterval);
//   }

//   static void _schedulePoll(Duration interval) {
//     _pollTimer?.cancel();
//     if (!_isRunning) return;

//     _pollTimer = Timer(interval, () async {
//       if (!_isRunning) return;

//       try {
//         final count = await ApiService.getUnreadNotificationCount();
//         _failCount = 0; // Reset fail count on success
//         _onCount?.call(count);
//         _schedulePoll(_normalInterval); // Back to normal speed
//       } catch (_) {
//         _failCount++;
//         // Silently ignore — NO error shown to user
//         // Apply exponential-style backoff
//         final nextInterval = _failCount >= _maxFailsBeforeSlowdown * 2
//             ? _verySlowInterval
//             : _failCount >= _maxFailsBeforeSlowdown
//                 ? _slowInterval
//                 : _normalInterval;

//         print(
//           '⚠️ Notification poll failed ($_failCount times), '
//           'retrying in ${nextInterval.inSeconds}s...',
//         );
//         _schedulePoll(nextInterval);
//       }
//     });
//   }

//   static void stopPolling() {
//     _isRunning = false;
//     _pollTimer?.cancel();
//     _pollTimer = null;
//     _failCount = 0;
//   }

//   static bool get isPolling => _isRunning;
// }

// lib/services/retry_service.dart
import 'dart:async';

import 'api_service.dart';

class RetryService {
  static Timer? _pollTimer;
  static int _failCount = 0;
  static const int _maxFailsBeforeSlowdown = 3;

  static const Duration _normalInterval   = Duration(seconds: 10);
  static const Duration _slowInterval     = Duration(seconds: 30);
  static const Duration _verySlowInterval = Duration(seconds: 60);

  static void Function(int count)? _onCount;
  static bool _isRunning = false;

  static void startNotificationPolling({
    required void Function(int count) onCount,
    Duration? initialInterval,
  }) {
    stopPolling();
    _failCount = 0;
    _isRunning = true;
    _onCount = onCount;
    _schedulePoll(initialInterval ?? _normalInterval);
  }

  static void _schedulePoll(Duration interval) {
    _pollTimer?.cancel();
    if (!_isRunning) return;

    _pollTimer = Timer(interval, () async {
      if (!_isRunning) return;
      try {
        final count = await ApiService.getUnreadNotificationCount();
        _failCount = 0;
        _onCount?.call(count);
        _schedulePoll(_normalInterval);
      } catch (_) {
        _failCount++;
        final nextInterval = _failCount >= _maxFailsBeforeSlowdown * 2
            ? _verySlowInterval
            : _failCount >= _maxFailsBeforeSlowdown
                ? _slowInterval
                : _normalInterval;
        print('⚠️ Poll failed ($_failCount×), retry in ${nextInterval.inSeconds}s');
        _schedulePoll(nextInterval);
      }
    });
  }

  static void stopPolling() {
    _isRunning = false;
    _pollTimer?.cancel();
    _pollTimer = null;
    _failCount = 0;
  }

  static bool get isPolling => _isRunning;
}