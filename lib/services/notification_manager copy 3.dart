// // lib/services/notification_manager.dart
// //
// // Thin wrapper kept for backward compatibility.
// // All real work is delegated to WeddingNotificationService.

// import 'package:wedding_reservation_app/services/notification_service.dart';
// import 'package:wedding_reservation_app/services/foreground_notification_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NotificationManager {
//   static final NotificationManager _instance = NotificationManager._internal();
//   factory NotificationManager() => _instance;
//   NotificationManager._internal();

//   /// Start monitoring — call after login
//   Future<void> startMonitoring() async {
//     try {
//       await WeddingNotificationService().forceImmediateCheck();
//       await WeddingForegroundNotificationService().startService();
//     } catch (e) {
//       print('NotificationManager.startMonitoring error: $e');
//     }
//   }

//   /// Stop monitoring — call on logout
//   Future<void> stopMonitoring() async {
//     try {
//       await WeddingForegroundNotificationService().stopService();
//     } catch (e) {
//       print('NotificationManager.stopMonitoring error: $e');
//     }
//   }

//   /// Cancel all local notifications and clear tracking — call on logout
//   Future<void> cancelAllNotifications() async {
//     try {
//       await WeddingNotificationService().clearOnLogout();
//       await WeddingForegroundNotificationService().stopService();

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('auth_token');
//       await prefs.remove('user_role');
//     } catch (e) {
//       print('NotificationManager.cancelAllNotifications error: $e');
//     }
//   }
// }