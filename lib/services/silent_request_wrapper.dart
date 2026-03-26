// // lib/services/silent_request_wrapper.dart
// //
// // HOW TO USE:
// //   Instead of:
// //     final response = await _client.get(uri, headers: headers).timeout(_timeout);
// //
// //   Write:
// //     final response = await SilentRequestWrapper.run(
// //       () => _client.get(uri, headers: headers),
// //     );
// //
// // This silently retries on timeout/network errors and NEVER surfaces those
// // errors to the user. Only non-retryable errors (4xx/5xx) are rethrown.

// import 'dart:async';

// class SilentRequestWrapper {
//   static const int _defaultMaxRetries  = 5;
//   static const Duration _baseDelay     = Duration(seconds: 2);
//   static const Duration _maxDelay      = Duration(seconds: 30);

//   /// Run [requestFn] with automatic silent retry on network/timeout errors.
//   ///
//   /// - Retries up to [maxRetries] times with exponential backoff.
//   /// - NEVER retries on HTTP 4xx/5xx — those are app-logic errors.
//   /// - Prints debug info but never throws to the UI on network errors alone
//   ///   (unless all retries are exhausted, in which case the last error
//   ///   is rethrown so callers can decide — but the UI layer should catch
//   ///   and stay silent for polling operations).
//   static Future<T> run<T>(
//     Future<T> Function() requestFn, {
//     int maxRetries = _defaultMaxRetries,
//     String? label, // optional label for debug logs
//   }) async {
//     int attempt = 0;

//     while (true) {
//       try {
//         return await requestFn();
//       } catch (e) {
//         attempt++;
//         final tag = label != null ? '[$label] ' : '';

//         if (!_isRetryable(e)) {
//           // HTTP errors, auth errors, etc. — rethrow immediately
//           rethrow;
//         }

//         if (attempt >= maxRetries) {
//           print('❌ ${tag}All $maxRetries retries exhausted: $e');
//           rethrow;
//         }

//         final delay = _backoffDelay(attempt);
//         print(
//           '⚠️ ${tag}Request failed (attempt $attempt/$maxRetries), '
//           'retrying in ${delay.inSeconds}s... ($e)',
//         );
//         await Future.delayed(delay);
//       }
//     }
//   }

//   // ── helpers ──────────────────────────────────────────────────────────────

//   static bool _isRetryable(dynamic e) {
//     final s = e.toString().toLowerCase();
//     return s.contains('timeout') ||
//         s.contains('timeoutexception') ||
//         s.contains('socketexception') ||
//         s.contains('connection refused') ||
//         s.contains('network unreachable') ||
//         s.contains('os error') ||
//         s.contains('handshake') ||
//         s.contains('connection reset') ||
//         s.contains('broken pipe');
//   }

//   /// Exponential backoff capped at [_maxDelay].
//   static Duration _backoffDelay(int attempt) {
//     final ms = _baseDelay.inMilliseconds * (1 << (attempt - 1)); // 2s, 4s, 8s …
//     return Duration(milliseconds: ms.clamp(0, _maxDelay.inMilliseconds));
//   }
// }



// lib/services/silent_request_wrapper.dart
import 'dart:async';

class SilentRequestWrapper {
  static const int _defaultMaxRetries = 5;
  static const Duration _baseDelay    = Duration(seconds: 2);
  static const Duration _maxDelay     = Duration(seconds: 30);

  static Future<T> run<T>(
    Future<T> Function() requestFn, {
    int maxRetries = _defaultMaxRetries,
    String? label,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await requestFn();
      } catch (e) {
        attempt++;
        final tag = label != null ? '[$label] ' : '';
        if (!_isRetryable(e) || attempt >= maxRetries) {
          if (attempt >= maxRetries) print('❌ ${tag}All $maxRetries retries exhausted');
          rethrow;
        }
        final delay = _backoffDelay(attempt);
        print('⚠️ ${tag}Retry $attempt/$maxRetries in ${delay.inSeconds}s...');
        await Future.delayed(delay);
      }
    }
  }

  static bool _isRetryable(dynamic e) {
    final s = e.toString().toLowerCase();
    return s.contains('timeout') || s.contains('socketexception') ||
        s.contains('connection refused') || s.contains('network unreachable') ||
        s.contains('os error') || s.contains('handshake') ||
        s.contains('connection reset') || s.contains('broken pipe');
  }

  static Duration _backoffDelay(int attempt) {
    final ms = _baseDelay.inMilliseconds * (1 << (attempt - 1));
    return Duration(milliseconds: ms.clamp(0, _maxDelay.inMilliseconds));
  }
}