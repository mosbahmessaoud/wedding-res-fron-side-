// lib/main.dart
//
// Mirrors the shopping-app main.dart pattern exactly:
//   • WithForegroundTask wrapper
//   • WidgetsBindingObserver for app lifecycle
//   • Role-aware foreground Timer (15-sec desktop, 60-sec mobile)
//   • Permission request on Android
//   • Foreground service started on Android/iOS only

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wedding_reservation_app/providers/theme_provider.dart';
import 'package:wedding_reservation_app/screens/auth/sing_up_screen.dart';
import 'package:wedding_reservation_app/screens/clan%20admin/home_screen.dart';
import 'package:wedding_reservation_app/screens/groom/create_reservation_screen.dart';
import 'package:wedding_reservation_app/screens/groom/groom_home_screen.dart';
import 'package:wedding_reservation_app/services/api_service.dart';
import 'package:wedding_reservation_app/services/connectivity_service.dart';
import 'package:wedding_reservation_app/services/notification_service.dart';
import 'package:wedding_reservation_app/services/foreground_notification_service.dart';

// Conditional desktop init (unchanged from your original)
import 'desktop_init.dart' if (dart.library.html) 'desktop_init_web.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Warm up backend silently
  ApiService.warmUpServer();

  // Desktop window setup
  if (!kIsWeb) {
    await initDesktop();
  }

  // System UI
  if (!kIsWeb) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  await initializeDateFormatting('ar');
  ConnectivityService().initialize();
  await ApiService.initializeToken();

  // ── Notification service init ──────────────────────────────
  print('📱 Initializing notification service...');
  try {
    await WeddingNotificationService().initialize();
    print('✅ Notification service initialized');
  } catch (e, stack) {
    print('❌ Failed to initialize notification service: $e');
    print(stack);
  }

  // ── Permissions (Android / iOS) ────────────────────────────
  print('🔐 Requesting permissions...');
  await _requestPermissions();
  print('✅ Permissions requested');

  // ── Foreground service (Android & iOS only) ────────────────
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      print('🔧 Initializing foreground service...');
      await WeddingForegroundNotificationService().initialize();
      print('✅ Foreground service initialized');

      await Future.delayed(const Duration(seconds: 1));

      print('🚀 Starting foreground service...');
      final started = await WeddingForegroundNotificationService().startService();
      print(started
          ? '✅ Foreground service started'
          : '⚠️ Foreground service failed to start');
    } catch (e, stack) {
      print('❌ Foreground service error: $e');
      print(stack);
    }
  }

  print('✅ App initialization complete');
  runApp(const WeddingReservationApp());
}

// ──────────────────────────────────────────────────────────────
// Permission helper — mirrors shopping app exactly
// ──────────────────────────────────────────────────────────────
Future<void> _requestPermissions() async {
  if (kIsWeb) return;

  if (defaultTargetPlatform == TargetPlatform.android) {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Notification permission (Android 13+)
      if (sdkInt >= 33) {
        var status = await Permission.notification.status;
        if (!status.isGranted) {
          status = await Permission.notification.request();
          if (status.isPermanentlyDenied) {
            debugPrint('⚠️ Notification permission permanently denied');
          }
        }
      } else {
        var status = await Permission.notification.status;
        if (!status.isGranted) await Permission.notification.request();
      }

      // Exact alarm permission (Android 12+)
      if (sdkInt >= 31) {
        var alarmStatus = await Permission.scheduleExactAlarm.status;
        if (!alarmStatus.isGranted) {
          alarmStatus = await Permission.scheduleExactAlarm.request();
          if (alarmStatus.isPermanentlyDenied) {
            debugPrint('⚠️ Schedule exact alarm permanently denied');
          }
        }
      }
    } catch (e) {
      debugPrint('Error requesting Android permissions: $e');
    }
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
        if (status.isPermanentlyDenied) {
          debugPrint('⚠️ iOS notification permission permanently denied');
        }
      }
    } catch (e) {
      debugPrint('Error requesting iOS permissions: $e');
    }
  }
}

// ──────────────────────────────────────────────────────────────
// Root widget
// ──────────────────────────────────────────────────────────────
class WeddingReservationApp extends StatelessWidget {
  const WeddingReservationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // ── WithForegroundTask wraps the whole app (mirrors shopping app) ──
          return WithForegroundTask(
            child: _WeddingAppContent(themeProvider: themeProvider),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// App content with WidgetsBindingObserver + role-aware Timer
// Mirrors _AppContentState from the shopping app exactly.
// ──────────────────────────────────────────────────────────────
class _WeddingAppContent extends StatefulWidget {
  final ThemeProvider themeProvider;
  const _WeddingAppContent({required this.themeProvider});

  @override
  State<_WeddingAppContent> createState() => _WeddingAppContentState();
}

class _WeddingAppContentState extends State<_WeddingAppContent>
    with WidgetsBindingObserver {
  Timer? _notificationCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startForegroundNotificationChecker();
  }

  @override
  void dispose() {
    _notificationCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    ApiService.disposeClient();
    super.dispose();
  }

  // ── Lifecycle observer — mirrors shopping app ─────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📱 Lifecycle: $state');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (state == AppLifecycleState.resumed) {
      print('📱 App resumed — forcing notification check');
      _triggerNotificationCheck();

      if (_notificationCheckTimer == null || !_notificationCheckTimer!.isActive) {
        _startForegroundNotificationChecker();
      }
    } else if (state == AppLifecycleState.paused) {
      print('📱 App paused');

      // Mobile: let the foreground service handle background polling
      // Desktop / Web: keep timer alive
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        print('📱 Stopping foreground Timer (mobile — background service active)');
        _notificationCheckTimer?.cancel();
      } else {
        print('💻 Keeping Timer active (desktop/web)');
      }
    }
  }

  // ── Trigger check — same endpoint for both roles ──────────
  void _triggerNotificationCheck() {
    WeddingNotificationService().forceImmediateCheck().catchError(
          (e) => print('⚠️ Notification check error: $e'),
        );
  }

  // ── Start foreground Timer — mirrors shopping app ─────────
  void _startForegroundNotificationChecker() {
    _notificationCheckTimer?.cancel();

    // Trigger immediately
    _triggerNotificationCheck();

    // Desktop/Web: 15 sec | Mobile: 60 sec (background service covers the rest)
    final bool isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);

    final Duration interval =
        isDesktop ? const Duration(seconds: 15) : const Duration(seconds: 60);

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔄 Starting foreground notification checker');
    print('   Platform : ${kIsWeb ? "web" : defaultTargetPlatform.name}');
    print('   Interval : ${interval.inSeconds} seconds');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    _notificationCheckTimer = Timer.periodic(interval, (_) {
      print('⏰ Foreground Timer triggered');
      _triggerNotificationCheck();
    });
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام حجز الأعراس',
      debugShowCheckedModeBanner: false,
      themeMode: widget.themeProvider.themeMode,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'DZ'),
        Locale('ar'),
        Locale('en'),
      ],
      locale: const Locale('ar', 'DZ'),

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const MultiStepSignupScreen(),
        '/splash': (context) => const SplashScreen(),
        '/clan_admin_home': (context) => const ClanAdminHomeScreen(),
        '/creat_new_reservation': (context) => const CreateReservationScreen(),
        '/groom_home': (context) =>
            const GroomHomeScreen(initialTabIndex: 0),
      },
      initialRoute: '/',

      // ── Light Theme ──
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Cairo',
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),

      // ── Dark Theme ──
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Cairo',
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}