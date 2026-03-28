// // lib/main.dart
// import 'dart:io' show Platform;

// import 'package:flutter/foundation.dart' show kIsWeb;
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
// import 'package:window_manager/window_manager.dart' if (dart.library.html) 'dart:html';

// import 'screens/auth/login_screen.dart';
// import 'screens/auth/splash_screen.dart';
// import 'utils/colors.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//     // ADD THIS - warm up server silently
//   ApiService.warmUpServer();

//   // Only initialize window_manager on desktop platforms (not mobile/web)
//   if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
//     await windowManager.ensureInitialized();
    
//     await windowManager.waitUntilReadyToShow(
//       const WindowOptions(
//         size: Size(1024, 768),
//         minimumSize: Size(360, 640),
//         center: true,
//       ),
//       () async {
//         await windowManager.show();
//         await windowManager.focus();
//       },
//     );
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
//             locale: const Locale('ar', 'DZ'), // Default to Arabic
            
//             // Add route definitions
//             routes: {
//               '/': (context) => const SplashScreen(), 
//               '/login': (context) => const LoginScreen(),
//               '/signup': (context) => const MultiStepSignupScreen(),
//               '/splash': (context) => const SplashScreen(),
//               '/clan_admin_home': (context) => const ClanAdminHomeScreen(),
//               '/creat_new_reservation': (context) => const CreateReservationScreen(),
//               '/groom_home': (context) => const GroomHomeScreen(
//                 initialTabIndex: 0
//               ),
//             },
            
//             // Set initial route
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
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   textStyle: TextStyle(
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
//                 contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               ),
//             ),
            
//             // Dark Theme
//             darkTheme: ThemeData(
//               useMaterial3: true,
//               brightness: Brightness.dark,
//               primarySwatch: Colors.blue,
//               primaryColor: AppColors.primary,
//               scaffoldBackgroundColor: Color(0xFF121212),
//               fontFamily: 'Cairo',
//               textTheme: TextTheme(
//                 displayLarge: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//                 titleLarge: TextStyle(
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
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   textStyle: TextStyle(
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
//                 contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }