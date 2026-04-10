// lib/services/foreground_notification_service.dart
//
// Mirrors the shopping-app ForegroundNotificationService exactly,
// adapted for the Wedding Reservation app.
//
// Platform support:
//   ✅ Android — full foreground service (flutter_foreground_task)
//   ✅ iOS     — flutter_foreground_task (limited background execution)
//   ⬛ Windows — no-op (Timer in WeddingApp widget handles it)
//   ⬛ Web     — no-op (Timer in WeddingApp widget handles it)
//
// pubspec.yaml:
//   flutter_foreground_task: ^8.0.0

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'notification_service.dart';

// ──────────────────────────────────────────────────────────────
// Top-level callback — required by flutter_foreground_task
// ──────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(WeddingNotificationTaskHandler());
}

// ──────────────────────────────────────────────────────────────
// Task handler
// Mirrors shopping app: reads role from SharedPreferences and
// calls the right check method.
// ──────────────────────────────────────────────────────────────
class WeddingNotificationTaskHandler extends TaskHandler {
  int _checkCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('🚀 Foreground service started at $timestamp');
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    _checkCount++;

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔄 Foreground service check #$_checkCount');
    print('   Time: $timestamp');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final prefs = await SharedPreferences.getInstance();
      final role  = prefs.getString('user_role');
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        print('⚠️ No auth token — user not logged in, skipping check');
        return;
      }

      print('👤 Role: $role');
      print('🔑 Token: ${token.substring(0, token.length.clamp(0, 20))}...');

      // Re-initialise token so ApiService headers work in the isolate
      await ApiService.initializeToken();

      print('📱 Initializing WeddingNotificationService...');
      final notificationService = WeddingNotificationService();
      await notificationService.initializeForBackground();

      print('🔍 Checking notifications...');
      // Both groom and clan_admin use the same endpoint (JWT scopes the results)
      await notificationService.forceImmediateCheck();

      print('✅ Foreground service check completed');
    } catch (e, stack) {
      print('❌ Error in foreground service: $e');
      print('Stack trace: $stack');
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isForcedTerminated) async {
    print('🛑 Foreground service stopped at $timestamp');
    print('   Total checks performed: $_checkCount');
    print('   Force terminated: $isForcedTerminated');
  }

  @override
  void onNotificationButtonPressed(String id) {
    print('🔘 Notification button pressed: $id');
    if (id == 'stop') FlutterForegroundTask.stopService();
  }

  @override
  void onNotificationPressed() {
    print('🔔 Notification pressed');
    FlutterForegroundTask.launchApp('/');
  }
}

// ──────────────────────────────────────────────────────────────
// Public service wrapper — safe to call on any platform
// ──────────────────────────────────────────────────────────────
class WeddingForegroundNotificationService {
  static final WeddingForegroundNotificationService _instance =
      WeddingForegroundNotificationService._internal();
  factory WeddingForegroundNotificationService() => _instance;
  WeddingForegroundNotificationService._internal();

  bool _isRunning = false;

  /// True only on Android and iOS where the plugin is supported.
  bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  // ── Initialize — mirrors shopping app exactly ─────────────
  Future<void> initialize() async {
    if (!_isSupported) {
      print('ℹ️ [FG] Foreground service not supported on ${_platformName()} — skipping');
      return;
    }

    print('🔧 Initializing foreground service...');

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'wedding_reservation_foreground_service',
        channelName: 'Wedding Reservation Notification Service',
        channelDescription: 'Keeps checking for new reservation notifications',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(60000), // every 60 sec
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    print('✅ Foreground service initialized (60-sec interval)');
  }

  // ── Start — mirrors shopping app exactly ──────────────────
  Future<bool> startService() async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🚀 startService() called');

    if (!_isSupported) {
      print('ℹ️ [FG] startService() skipped on ${_platformName()}');
      return true; // not an error — Timer covers it
    }

    if (_isRunning) {
      print('⚠️ Foreground service already running');
      return true;
    }

    // Log current token/role state
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final role  = prefs.getString('user_role');
      print('📊 Current state:');
      print('   Token exists: ${token != null && token.isNotEmpty}');
      print('   User role: $role');
      if (token == null || token.isEmpty) {
        print('⚠️ No auth token — service will start but skip checks until login');
      }
    } catch (e) {
      print('⚠️ Error checking preferences: $e');
    }

    print('🚀 Calling FlutterForegroundTask.startService...');

    try {
      final ServiceRequestResult result = await FlutterForegroundTask.startService(
        serviceId: 512,
        notificationTitle: 'أسُولي - ASULI',
        notificationText: 'نظام حجز الأعراس...',
        callback: startCallback,
      );

      print('📊 Service start result: $result');
      _isRunning = true;
      print('✅ Service state set to running');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('wedding_fg_service_running', true);
      print('✅ Saved service state to preferences');

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return true;
    } catch (e, stack) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ Failed to start foreground service');
      print('   Error: $e');
      print('   Stack: $stack');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return false;
    }
  }

  // ── Stop ──────────────────────────────────────────────────
  Future<bool> stopService() async {
    if (!_isSupported) {
      print('ℹ️ [FG] stopService() skipped on ${_platformName()}');
      return true;
    }

    if (!_isRunning) {
      print('⚠️ Foreground service not running');
      return true;
    }

    print('🛑 Stopping foreground service...');

    try {
      final ServiceRequestResult result =
          await FlutterForegroundTask.stopService();
      _isRunning = false;
      print('✅ Foreground service stopped: $result');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('wedding_fg_service_running', false);
      return true;
    } catch (e) {
      print('❌ Failed to stop foreground service: $e');
      return false;
    }
  }

  Future<bool> isRunning() async {
    if (!_isSupported) return false;
    return FlutterForegroundTask.isRunningService;
  }

  Future<void> updateNotificationText(String text) async {
    if (!_isSupported) return;
    await FlutterForegroundTask.updateService(
      notificationTitle: 'نظام حجز الأعراس',
      notificationText: text,
    );
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return 'android';
      case TargetPlatform.iOS:     return 'ios';
      case TargetPlatform.windows: return 'windows';
      default:                     return 'other';
    }
  }
}