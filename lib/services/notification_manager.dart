// lib/services/notification_manager.dart
import 'package:wedding_reservation_app/services/notification_service.dart';
import 'package:wedding_reservation_app/services/token_manager.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final NotificationService _notificationService = NotificationService();
  bool _isRunning = false;

  // Start notification monitoring after login
  Future<void> startMonitoring() async {
    // Check if user is logged in
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      print('⚠️ Cannot start monitoring: User not logged in');
      return;
    }

    if (_isRunning) {
      print('⚠️ Notification monitoring already running');
      return;
    }

    print('▶️ Starting notification monitoring...');
    
    // Initialize notification service if not already initialized
    await _notificationService.initialize();
    
    // Start polling for new notifications every 30 seconds
    _notificationService.startPolling(
      interval: const Duration(seconds: 30),
    );
    
    _isRunning = true;
    print('✅ Notification monitoring started');
  }

  // Stop notification monitoring (e.g., on logout)
  void stopMonitoring() {
    if (!_isRunning) {
      print('⚠️ Notification monitoring not running');
      return;
    }

    print('⏹️ Stopping notification monitoring...');
    _notificationService.stopPolling();
    _isRunning = false;
    print('✅ Notification monitoring stopped');
  }

  // Force check for new notifications
  Future<void> refreshNotifications() async {
    await _notificationService.forceCheck();
  }

  // Check if monitoring is active
  bool get isRunning => _isRunning;

  // Request notification permissions
  Future<bool> requestPermissions() async {
    return await _notificationService.requestPermissions();
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await _notificationService.areNotificationsEnabled();
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  // Dispose resources
  void dispose() {
    stopMonitoring();
    _notificationService.dispose();
  }
}