// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  // Determine default theme based on platform
  bool _getDefaultThemeForPlatform() {
    if (kIsWeb) {
      // For web, default to light mode
      return false;
    }
    
    try {
      // Android and iOS: default to dark mode
      if (Platform.isAndroid || Platform.isIOS) {
        return true;
      }
      // Windows, macOS, Linux: default to light mode
      else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return false;
      }
    } catch (e) {
      // If Platform is not available, default to light mode
      debugPrint('Error detecting platform: $e');
      return false;
    }
    
    // Fallback to light mode
    return false;
  }
  
  // Load saved theme preference
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user has a saved preference
      if (prefs.containsKey('isDarkMode')) {
        // Load user's saved preference
        final isDark = prefs.getBool('isDarkMode') ?? _getDefaultThemeForPlatform();
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      } else {
        // First time launch: use platform-specific default
        final isDark = _getDefaultThemeForPlatform();
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        
        // Save the default preference
        await prefs.setBool('isDarkMode', isDark);
      }
      
      notifyListeners();
    } catch (e) {
      // If SharedPreferences fails, use platform default
      debugPrint('Error loading theme: $e');
      final isDark = _getDefaultThemeForPlatform();
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }
  
  // Toggle theme
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    
    try {
      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
  
  // Set specific theme
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}