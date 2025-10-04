// lib/utils/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Light Theme Colors
  static const Color _lightPrimary = Color(0xFF2E7D32);
  static const Color _lightPrimaryLight = Color(0xFF4CAF50);
  static const Color _lightPrimaryDark = Color(0xFF1B5E20);
  static const Color _lightSecondary = Color(0xFFFFB300);
  static const Color _lightBackground = Color(0xFFF5F5F5);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF212121);
  static const Color _lightTextSecondary = Color(0xFF757575);
  
  // Dark Theme Colors
  static const Color _darkPrimary = Color(0xFF4CAF50);
  static const Color _darkPrimaryLight = Color(0xFF66BB6A);
  static const Color _darkPrimaryDark = Color(0xFF2E7D32);
  static const Color _darkSecondary = Color(0xFFFFD54F);
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextSecondary = Color(0xFFB0B0B0);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: ColorScheme.light(
      primary: _lightPrimary,
      primaryContainer: _lightPrimaryLight,
      secondary: _lightSecondary,
      secondaryContainer: Color(0xFFFFD54F),
      surface: _lightSurface,
      background: _lightBackground,
      error: Color(0xFFF44336),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _lightTextPrimary,
      onBackground: _lightTextPrimary,
      onError: Colors.white,
      outline: Color(0xFFE0E0E0),
    ),
    
    scaffoldBackgroundColor: _lightBackground,
    
    appBarTheme: AppBarTheme(
      backgroundColor: _lightPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimary,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(color: _lightPrimary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimary,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFFF44336)),
      ),
      labelStyle: TextStyle(color: _lightTextSecondary),
      hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
    ),
    
    iconTheme: IconThemeData(
      color: _lightTextSecondary,
      size: 24,
    ),
    
    dividerTheme: DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
      space: 1,
    ),
    
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _lightTextPrimary),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _lightTextPrimary),
      displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _lightTextPrimary),
      headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _lightTextPrimary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: _lightTextPrimary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: _lightTextPrimary),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: _lightTextSecondary),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: _lightTextSecondary),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    colorScheme: ColorScheme.dark(
      primary: _darkPrimary,
      primaryContainer: _darkPrimaryLight,
      secondary: _darkSecondary,
      secondaryContainer: Color(0xFFFFCA28),
      surface: _darkSurface,
      background: _darkBackground,
      error: Color(0xFFEF5350),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: _darkTextPrimary,
      onBackground: _darkTextPrimary,
      onError: Colors.black,
      outline: Color(0xFF2C2C2C),
    ),
    
    scaffoldBackgroundColor: _darkBackground,
    
    appBarTheme: AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: _darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: _darkTextPrimary),
      titleTextStyle: TextStyle(
        color: _darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.black,
        elevation: 3,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkPrimary,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(color: _darkPrimary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkPrimary,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFF2C2C2C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFF2C2C2C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFFEF5350)),
      ),
      labelStyle: TextStyle(color: _darkTextSecondary),
      hintStyle: TextStyle(color: Color(0xFF757575)),
    ),
    
    iconTheme: IconThemeData(
      color: _darkTextSecondary,
      size: 24,
    ),
    
    dividerTheme: DividerThemeData(
      color: Color(0xFF2C2C2C),
      thickness: 1,
      space: 1,
    ),
    
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _darkTextPrimary),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _darkTextPrimary),
      displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _darkTextPrimary),
      headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _darkTextPrimary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: _darkTextPrimary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: _darkTextPrimary),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: _darkTextSecondary),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: _darkTextSecondary),
    ),
  );
}

// Extension to easily access theme colors
extension ThemeExtension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}