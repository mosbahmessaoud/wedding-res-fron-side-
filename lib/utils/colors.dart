// /lib/utils/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7D32);        // Green
  static const Color primaryLight = Color(0xFF4CAF50);    // Light Green
  static const Color primaryDark = Color(0xFF1B5E20);     // Dark Green
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFFB300);       // Gold
  static const Color secondaryLight = Color(0xFFFFD54F);  // Light Gold
  static const Color secondaryDark = Color(0xFFFF8F00);   // Dark Gold
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);      // Light Grey
  static const Color surface = Color(0xFFFFFFFF);         // White
  static const Color surfaceVariant = Color(0xFFF8F9FA);  // Very Light Grey
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);     // Dark Grey
  static const Color textSecondary = Color(0xFF757575);   // Medium Grey
  static const Color textHint = Color(0xFFBDBDBD);        // Light Grey
  static const Color textOnPrimary = Color(0xFFFFFFFF);   // White
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);         // Green
  static const Color warning = Color(0xFFFF9800);         // Orange
  static const Color error = Color(0xFFF44336);           // Red
  static const Color info = Color(0xFF2196F3);            // Blue
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);          // Light Grey
  static const Color borderFocus = Color(0xFF2E7D32);     // Green
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F9FA), Color(0xFFE8F5E8)],
  );
}

class AppTextStyles {
  // Use system fonts instead of Cairo
  static const String _fontFamily = 'Roboto'; // Default Material font
  
  // Heading Styles
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  // Button Styles
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
  
  // Input Styles
  static const TextStyle input = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle inputLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle inputHint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );
  
  // Caption and Helper Styles
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );
}