// lib/services/notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wedding_reservation_app/services/api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  Timer? _pollingTimer;
  int _lastUnreadCount = 0;
  List<int> _shownNotificationIds = [];
  bool _isInitialized = false;

  // Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request notification permissions
      await requestPermissions();

      // Android initialization settings
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
      );

      // Create notification channel for Android
      await _createNotificationChannel();

      _isInitialized = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
    }
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      // Check Android version
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.notification.request();
        
        if (status.isGranted) {
          print('✅ Notification permission granted');
          return true;
        } else if (status.isDenied) {
          print('⚠️ Notification permission denied');
          return false;
        } else if (status.isPermanentlyDenied) {
          print('❌ Notification permission permanently denied');
          await openAppSettings();
          return false;
        }
      }

      // For iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final granted = await _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        
        return granted ?? false;
      }

      return true;
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
      return false;
    }
  }

  // Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'wedding_reservations', // Channel ID
      'Wedding Reservations', // Channel name
      description: 'Notifications for wedding reservation updates', // Channel description
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Start polling for new notifications
  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    if (!_isInitialized) {
      print('⚠️ Cannot start polling: Notification service not initialized');
      return;
    }

    // Cancel existing timer if any
    stopPolling();

    print('🔄 Starting notification polling (every ${interval.inSeconds}s)');
    
    // Check immediately
    _checkForNewNotifications();

    // Then check periodically
    _pollingTimer = Timer.periodic(interval, (timer) {
      _checkForNewNotifications();
    });
  }

  // Stop polling for notifications
  void stopPolling() {
    if (_pollingTimer != null) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
      print('⏸️ Notification polling stopped');
    }
  }

  // Check for new notifications
  Future<void> _checkForNewNotifications() async {
    try {
      // Get unread notifications from API
      final unreadNotifications = await ApiService.getUnreadNotifications(limit: 50);
      
      if (unreadNotifications.isEmpty) {
        return;
      }

      // Find new notifications that haven't been shown yet
      for (var notification in unreadNotifications) {
        final notificationId = notification['id'] as int;
        
        // Skip if already shown
        if (_shownNotificationIds.contains(notificationId)) {
          continue;
        }

        // Show notification
        await _showNotification(
          id: notificationId,
          title: notification['title'] ?? 'إشعار جديد',
          body: notification['message'] ?? '',
          type: notification['notification_type'] ?? 'general',
          payload: jsonEncode(notification),
        );

        // Mark as shown
        _shownNotificationIds.add(notificationId);
        
        // Keep only last 100 notification IDs in memory
        if (_shownNotificationIds.length > 100) {
          _shownNotificationIds.removeAt(0);
        }
      }

      // Update last unread count
      _lastUnreadCount = unreadNotifications.length;

      print('✅ Checked for notifications: ${unreadNotifications.length} unread');
    } catch (e) {
      print('❌ Error checking for new notifications: $e');
    }
  }

  // Show a local notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String type,
    String? payload,
  }) async {
    try {
      // Get notification icon and color based on type
      final notificationStyle = _getNotificationStyle(type);

      // Android notification details
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'wedding_reservations',
        'Wedding Reservations',
        channelDescription: 'Notifications for wedding reservation updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        color: notificationStyle['color'],
        playSound: true,
        enableVibration: true,
        enableLights: true,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          htmlFormatContentTitle: true,
          htmlFormatBigText: true,
        ),
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined notification details
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show the notification
      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      print('📬 Notification shown: $title');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  // Get notification style based on type
  Map<String, dynamic> _getNotificationStyle(String type) {
    switch (type) {
      case 'reservation_approved':
        return {
          'color': const Color(0xFF4CAF50), // Green
          'icon': '@drawable/ic_check',
        };
      case 'reservation_rejected':
        return {
          'color': const Color(0xFFF44336), // Red
          'icon': '@drawable/ic_cancel',
        };
      case 'reservation_cancelled':
        return {
          'color': const Color(0xFFFF9800), // Orange
          'icon': '@drawable/ic_event_busy',
        };
      case 'payment_reminder':
        return {
          'color': const Color(0xFF2196F3), // Blue
          'icon': '@drawable/ic_payment',
        };
      case 'reservation_reminder':
        return {
          'color': const Color(0xFF9C27B0), // Purple
          'icon': '@drawable/ic_event',
        };
      case 'general_announcement':
        return {
          'color': const Color(0xFF4A90E2), // Primary blue
          'icon': '@drawable/ic_announcement',
        };
      default:
        return {
          'color': const Color(0xFF757575), // Gray
          'icon': '@drawable/ic_notification',
        };
    }
  }

  // Handle notification tap (foreground)
  void _onNotificationTap(NotificationResponse response) {
    _handleNotificationTap(response.payload);
  }

  // Handle notification tap (background)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    _instance._handleNotificationTap(response.payload);
  }

  // Common notification tap handler
  void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final notificationId = data['id'] as int?;
      
      if (notificationId != null) {
        // Mark notification as read when user taps it
        ApiService.markNotificationAsRead(notificationId).catchError((e) {
          print('Error marking notification as read: $e');
        });
      }

      // TODO: Navigate to relevant screen based on notification type
      // You can implement navigation logic here using a navigator key
      print('📱 Notification tapped: ${data['title']}');
    } catch (e) {
      print('❌ Error handling notification tap: $e');
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    _shownNotificationIds.clear();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await Permission.notification.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final granted = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  // Reset shown notifications (useful for testing)
  void resetShownNotifications() {
    _shownNotificationIds.clear();
    _lastUnreadCount = 0;
  }

  // Force check for new notifications (manual refresh)
  Future<void> forceCheck() async {
    await _checkForNewNotifications();
  }

  // Dispose resources
  void dispose() {
    stopPolling();
  }
}