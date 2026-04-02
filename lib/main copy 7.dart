// // lib/main.dart
// // ✅ FIXED: only import desktop stuff when NOT on web
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:provider/provider.dart';
// import 'package:wedding_reservation_app/providers/theme_provider.dart';
// import 'package:wedding_reservation_app/screens/auth/sing_up_screen.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/home_screen.dart';
// import 'package:wedding_reservation_app/screens/groom/create_reservation_screen.dart';
// import 'package:wedding_reservation_app/screens/groom/groom_home_screen.dart';
// import 'package:wedding_reservation_app/services/api_service.dart';
// import 'package:wedding_reservation_app/services/connectivity_service.dart';

// // ignore: depend_on_referenced_packages
// import 'desktop_init.dart' if (dart.library.html) 'desktop_init_web.dart';
// // ✅ FIXED: conditional imports for window_manager and Platform
// import 'screens/auth/login_screen.dart';
// import 'screens/auth/splash_screen.dart';
// import 'utils/colors.dart';
// import 'package:wedding_reservation_app/services/notification_manager.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ADD THIS - warm up server silently
//   ApiService.warmUpServer();

//   // ✅ FIXED: only runs on desktop, skipped on web
//   if (!kIsWeb) {
//     await initDesktop();
//     // await NotificationManager.initForegroundTask(); // ✅ ADD THIS LINE

//   }

//   SystemChrome.setEnabledSystemUIMode(
//     SystemUiMode.manual,
//     overlays: [SystemUiOverlay.top],
//   );

//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       systemNavigationBarColor: Colors.transparent,
//     ),
//   );

//   await initializeDateFormatting('ar');
//   ConnectivityService().initialize();
//   await ApiService.initializeToken();

//   runApp(const WeddingReservationApp());
// }

// class WeddingReservationApp extends StatefulWidget {
//   const WeddingReservationApp({super.key});

//   @override
//   State<WeddingReservationApp> createState() => _WeddingReservationAppState();
// }

// class _WeddingReservationAppState extends State<WeddingReservationApp> {
//   @override
//   void dispose() {
//     ApiService.disposeClient();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => ThemeProvider(),
//       child: Consumer<ThemeProvider>(
//         builder: (context, themeProvider, child) {
//           return MaterialApp(
//             title: 'نظام حجز الأعراس',
//             debugShowCheckedModeBanner: false,

//             // Theme Mode from Provider
//             themeMode: themeProvider.themeMode,

//             // Add localization support
//             localizationsDelegates: const [
//               GlobalMaterialLocalizations.delegate,
//               GlobalWidgetsLocalizations.delegate,
//               GlobalCupertinoLocalizations.delegate,
//             ],
//             supportedLocales: const [
//               Locale('ar', 'DZ'),
//               Locale('ar'),
//               Locale('en'),
//             ],
//             locale: const Locale('ar', 'DZ'),

//             // Add route definitions
//             routes: {
//               '/': (context) => const SplashScreen(),
//               '/login': (context) => const LoginScreen(),
//               '/signup': (context) => const MultiStepSignupScreen(),
//               '/splash': (context) => const SplashScreen(),
//               '/clan_admin_home': (context) => const ClanAdminHomeScreen(),
//               '/creat_new_reservation': (context) => const CreateReservationScreen(),
//               '/groom_home': (context) => const GroomHomeScreen(
//                 initialTabIndex: 0,
//               ),
//             },

//             initialRoute: '/',

//             // Light Theme
//             theme: ThemeData(
//               useMaterial3: true,
//               brightness: Brightness.light,
//               primarySwatch: Colors.blue,
//               primaryColor: AppColors.primary,
//               scaffoldBackgroundColor: AppColors.background,
//               fontFamily: 'Cairo',
//               textTheme: TextTheme(
//                 displayLarge: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primary,
//                 ),
//                 titleLarge: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.textPrimary,
//                 ),
//                 bodyMedium: TextStyle(
//                   fontSize: 14,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               elevatedButtonTheme: ElevatedButtonThemeData(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   textStyle: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               inputDecorationTheme: InputDecorationTheme(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: AppColors.border),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: AppColors.border),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: AppColors.primary, width: 2),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: AppColors.error),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               ),
//             ),

//             // Dark Theme
//             darkTheme: ThemeData(
//               useMaterial3: true,
//               brightness: Brightness.dark,
//               primarySwatch: Colors.blue,
//               primaryColor: AppColors.primary,
//               scaffoldBackgroundColor: const Color(0xFF121212),
//               fontFamily: 'Cairo',
//               textTheme: TextTheme(
//                 displayLarge: const TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//                 titleLarge: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//                 bodyMedium: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white70,
//                 ),
//               ),
//               elevatedButtonTheme: ElevatedButtonThemeData(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   textStyle: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               inputDecorationTheme: InputDecorationTheme(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey[700]!),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey[700]!),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: AppColors.primary, width: 2),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: AppColors.error),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }