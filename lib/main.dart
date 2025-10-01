// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wedding_reservation_app/screens/auth/tempCodeRunnerFile.dart';
import 'package:wedding_reservation_app/screens/clan%20admin/home_screen.dart';
import 'package:wedding_reservation_app/screens/groom/create_reservation_screen.dart';
import 'package:wedding_reservation_app/screens/groom/groom_home_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Arabic locale
  await initializeDateFormatting('ar');
  
  runApp(WeddingReservationApp());
}

class WeddingReservationApp extends StatelessWidget {
  const WeddingReservationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام حجز الأعراس',
      debugShowCheckedModeBanner: false,
      
      // Add localization support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'), // Arabic (Saudi Arabia)
        Locale('ar'), // Arabic (general)
        Locale('en'), // English fallback
      ],
      locale: const Locale('ar', 'SA'), // Default to Arabic
      
      // Add route definitions
      routes: {
        '/': (context) => const SplashScreen(), 
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const MultiStepSignupScreen(), // Add signup route
        '/splash': (context) => const SplashScreen(),
        '/clan_admin_home': (context) => const ClanAdminHomeScreen(),
        '/creat_new_reservation': (context) => const CreateReservationScreen(),
        '/groom_home': (context) => const GroomHomeScreen(
          initialTabIndex:1
        ),
        // Add other routes as needed
      },
      
      // Set initial route
      initialRoute: '/',
      
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Cairo', // Add Arabic font to assets
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
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}