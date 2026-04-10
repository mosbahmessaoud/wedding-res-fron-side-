// lib/services/notification_service.dart
//
// Mirrors the shopping-app NotificationService pattern exactly,
// adapted for the Wedding Reservation app.
//
// Platform support:
//   ✅ Android  — local notifications + WorkManager (15-min background)
//   ✅ iOS      — local notifications
//   ✅ Windows  — local notifications (Windows channel)
//   ✅ Web      — silent poll only (no OS notifications)
//
// pubspec.yaml:
//   flutter_local_notifications: ^18.0.0
//   workmanager: ^0.5.2
//   shared_preferences: ^2.2.0

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'api_service.dart';

// ──────────────────────────────────────────────────────────────
// WorkManager background entry-point — Android only, top-level
// ──────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('🔔 [WM] Background task: $task');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        print('⚠️ [WM] No token – skipping');
        return Future.value(false);
      }

      await ApiService.initializeToken();

      final service = WeddingNotificationService();
      await service.initializeForBackground();
      await service.checkAndShowNewNotifications();

      print('✅ [WM] Background task completed');
      return Future.value(true);
    } catch (e) {
      print('❌ [WM] Error: $e');
      return Future.value(false);
    }
  });
}

// ──────────────────────────────────────────────────────────────
// Main service
// ──────────────────────────────────────────────────────────────
class WeddingNotificationService {
  static final WeddingNotificationService _instance =
      WeddingNotificationService._internal();
  factory WeddingNotificationService() => _instance;
  WeddingNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId   = 'wedding_reservation_notifications';
  static const String _channelName = 'Wedding Reservation Notifications';
  static const String _shownIdsKey = 'wedding_shown_notification_ids';

  bool _isInitialized        = false;
  bool _workManagerInitialized = false;

  // ── Lightweight init used by WorkManager isolate ──────────
  Future<void> initializeForBackground() async {
    if (_isInitialized) return;
    if (kIsWeb) return;

    const android  = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
    _isInitialized = true;
  }

  // ── Full init — called from main() ───────────────────────
  Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ WeddingNotificationService already initialized');
      return;
    }

    print('🚀 Initializing WeddingNotificationService | platform=${_platformName()}');

    if (kIsWeb) {
      // Web: plugin not available — polling handled by Timer in main app
      _isInitialized = true;
      print('✅ Web: notification plugin skipped (Timer polling active)');
      return;
    }

    // ── Plugin settings ──
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const windows = WindowsInitializationSettings(
      appName: 'نظام حجز الأعراس',
      appUserModelId: 'com.wedding.reservation',
      guid: 'b3f1a2c4-5d6e-7f8a-9b0c-1d2e3f4a5b6c',
    );

    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios, windows: windows),
      onDidReceiveNotificationResponse: (r) =>
          print('📱 Notification tapped: ${r.id}'),
    );

    print('✅ Notification plugin initialized');

    // ── Android: channel + WorkManager ──
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Reservation approvals, rejections, and reminders',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      );
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      try {
        await Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
        _workManagerInitialized = true;
        print('✅ WorkManager initialized');

        await Workmanager().registerPeriodicTask(
          'wedding_notification_check',
          'weddingNotificationCheckTask',
          frequency: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
          initialDelay: const Duration(seconds: 10),
        );
        print('✅ WorkManager periodic task registered (15-min)');
      } catch (e, stack) {
        print('⚠️ WorkManager init failed: $e');
        if (kDebugMode) print(stack);
        _workManagerInitialized = false;
      }
    }

    _isInitialized = true;
    print('✅ WeddingNotificationService initialized');

    // Initial check
    await forceImmediateCheck();
  }

  // ── Core check — called by Timer, foreground service & WorkManager ──
  Future<void> checkAndShowNewNotifications() async {
    try {
      print('🔍 [${_platformName()}] Checking notifications...');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        print('⚠️ No auth token — skipping');
        return;
      }

      print('✅ Token found: ${token.substring(0, token.length.clamp(0, 20))}...');

      await ApiService.initializeToken();

      final List<dynamic> notifications =
          await ApiService.getNotifications(unreadOnly: true, limit: 50);

      print('📦 ${notifications.length} unread notification(s)');

      if (kIsWeb) return; // Web: fetched for badge count only, no OS popup

      final shownIds = await _getShownIds();
      int shown = 0;

      for (final notif in notifications) {
        final id = notif['id'] as int?;
        if (id == null) continue;
        if (shownIds.contains(id)) {
          print('⏭️ Skipping #$id (already shown)');
          continue;
        }
        print('🔔 Showing notification #$id');
        await _showNotification(notif);
        await _addShownId(id);
        shown++;
        print('✅ Notification #$id shown');
      }

      print('✅ Showed $shown new notification(s)');
    } catch (e, stack) {
      print('❌ checkAndShowNewNotifications: $e');
      if (kDebugMode) print(stack);
    }
  }

  // ── Show a single OS notification ────────────────────────
  Future<void> _showNotification(Map<String, dynamic> notif) async {
    if (kIsWeb) return;

    // Safely extract type
    final rawType = notif['notification_type'];
    final String typeStr = rawType is String ? rawType : 'general_announcement';

    // Safely extract message
    final rawMsg = notif['message'];
    final String messageStr = rawMsg is String
        ? rawMsg
        : (rawMsg is List && rawMsg.isNotEmpty)
            ? rawMsg.join(', ')
            : '';

    final int    id    = notif['id'] as int? ?? 0;
    final String title = (notif['title'] as String?)?.isNotEmpty == true
        ? notif['title'] as String
        : _titleForType(typeStr);

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 SHOWING NOTIFICATION');
    print('   Platform : ${_platformName()}');
    print('   ID       : $id');
    print('   Type     : $typeStr');
    print('   Title    : $title');
    print('   Message  : $messageStr');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          print('📱 Creating Android notification...');
          await _notifications.show(
            id, title, messageStr,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channelId, _channelName,
                channelDescription: 'Reservation approvals, rejections, and reminders',
                importance: Importance.max,
                priority: Priority.high,
                enableVibration: true,
                playSound: true,
                showWhen: true,
                when: DateTime.now().millisecondsSinceEpoch,
                visibility: NotificationVisibility.public,
                ticker: 'نظام حجز الأعراس',
                autoCancel: true,
                ongoing: false,
                styleInformation: BigTextStyleInformation(
                  messageStr,
                  contentTitle: title,
                  summaryText: 'نظام حجز الأعراس',
                ),
                icon: '@mipmap/ic_launcher',
                largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
                color: _colorForType(typeStr),
              ),
            ),
          );
          print('✅ Android notification $id shown');
          break;

        case TargetPlatform.iOS:
          print('🍎 Creating iOS notification...');
          await _notifications.show(
            id, title, messageStr,
            const NotificationDetails(
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: 'default',
              ),
            ),
          );
          print('✅ iOS notification $id shown');
          break;

        case TargetPlatform.windows:
          print('🪟 Creating Windows notification...');
          await _notifications.show(
            id, title, messageStr,
            NotificationDetails(
              windows: WindowsNotificationDetails(
                subtitle: 'نظام حجز الأعراس',
                duration: WindowsNotificationDuration.long,
                timestamp: DateTime.now(),
              ),
            ),
          );
          print('✅ Windows notification $id shown');
          break;

        default:
          print('🔧 Creating generic notification...');
          await _notifications.show(id, title, messageStr, const NotificationDetails());
          print('✅ Generic notification $id shown');
      }
    } catch (e, stack) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ ERROR SHOWING NOTIFICATION');
      print('   Error: $e');
      if (kDebugMode) print(stack);
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  // ── Helpers ───────────────────────────────────────────────

  String _titleForType(String type) {
    switch (type) {
      case 'reservation_approved':  return '✅ تمت الموافقة على الحجز';
      case 'reservation_rejected':  return '❌ تم رفض الحجز';
      case 'reservation_cancelled': return '🚫 تم إلغاء الحجز';
      case 'reservation_reminder':  return '🔔 تذكير بالحجز';
      case 'payment_reminder':      return '💰 تذكير بالدفع';
      case 'general_announcement':  return '📢 إعلان عام';
      case 'system_update':         return '⚙️ تحديث النظام';
      case 'new_reservation':       return '📋 حجز جديد';
      default:                      return '🔔 إشعار';
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'reservation_approved':                return const Color(0xFF4CAF50);
      case 'reservation_rejected':
      case 'reservation_cancelled':              return const Color(0xFFF44336);
      case 'payment_reminder':                   return const Color(0xFFFF9800);
      case 'new_reservation':                    return const Color(0xFF2196F3);
      default:                                   return const Color(0xFF6200EE);
    }
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return 'android';
      case TargetPlatform.iOS:     return 'ios';
      case TargetPlatform.windows: return 'windows';
      case TargetPlatform.macOS:   return 'macos';
      case TargetPlatform.linux:   return 'linux';
      default:                     return 'unknown';
    }
  }

  // ── Persisted shown-IDs ───────────────────────────────────

  Future<Set<int>> _getShownIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.get(_shownIdsKey);
      if (value == null) return {};
      if (value is String) {
        return (jsonDecode(value) as List<dynamic>).map((e) => e as int).toSet();
      } else if (value is List) {
        return value.map((e) => e as int).toSet();
      }
      return {};
    } catch (e) {
      print('⚠️ Error reading shown IDs, resetting: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_shownIdsKey);
      return {};
    }
  }

  Future<void> _addShownId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids   = await _getShownIds();
    ids.add(id);
    await prefs.setString(_shownIdsKey, jsonEncode(ids.toList()));
    print('💾 Saved notification #$id to shown IDs');
  }

  // ── Public API ────────────────────────────────────────────

  /// Force immediate check — call after login or on app resume
  Future<void> forceImmediateCheck() async {
    print('⚡ forceImmediateCheck() | ${_platformName()}');
    await checkAndShowNewNotifications();
  }

  /// Clear on logout
  Future<void> clearOnLogout() async {
    if (!kIsWeb) await _notifications.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shownIdsKey);
    print('🗑️ Notification tracking cleared on logout');
  }

  /// Cancel one notification
  Future<void> cancelNotification(int id) async {
    if (!kIsWeb) await _notifications.cancel(id);
    final prefs = await SharedPreferences.getInstance();
    final ids   = await _getShownIds();
    ids.remove(id);
    await prefs.setString(_shownIdsKey, jsonEncode(ids.toList()));
    print('🗑️ Removed notification #$id from tracking');
  }

  bool get isBackgroundTasksAvailable => _workManagerInitialized;
}