// lib/services/notification_manager.dart
//
// Thin compatibility wrapper — keeps all existing call-sites working
// without any changes. All real work is in WeddingNotificationService.

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_reservation_app/services/notification_service.dart';
import 'package:wedding_reservation_app/services/foreground_notification_service.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  /// Start monitoring — call after login
  Future<void> startMonitoring() async {
    try {
      await WeddingNotificationService().forceImmediateCheck();
      await WeddingForegroundNotificationService().startService();
    } catch (e) {
      print('NotificationManager.startMonitoring error: $e');
    }
  }

  /// Stop monitoring — call on logout
  Future<void> stopMonitoring() async {
    try {
      await WeddingForegroundNotificationService().stopService();
    } catch (e) {
      print('NotificationManager.stopMonitoring error: $e');
    }
  }

  /// Cancel all + clear tracking — call on logout
  Future<void> cancelAllNotifications() async {
    try {
      await WeddingNotificationService().clearOnLogout();
      await WeddingForegroundNotificationService().stopService();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
    } catch (e) {
      print('NotificationManager.cancelAllNotifications error: $e');
    }
  }
}