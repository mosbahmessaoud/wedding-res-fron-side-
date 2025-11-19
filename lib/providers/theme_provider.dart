// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Start with system default
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  // Get system's current brightness
  Brightness _getSystemBrightness() {
    try {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness;
    } catch (e) {
      debugPrint('Error getting system brightness: $e');
      return Brightness.light; // Fallback
    }
  }
  
  // Determine default theme based on platform and system settings
  ThemeMode _getDefaultThemeMode() {
    if (kIsWeb) {
      // For web, follow system theme
      final brightness = _getSystemBrightness();
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    
    try {
      // Android and iOS: follow system theme
      if (Platform.isAndroid || Platform.isIOS) {
        return ThemeMode.system; // Let Flutter handle system theme
      }
      // Windows, macOS, Linux: follow system theme
      else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return ThemeMode.system;
      }
    } catch (e) {
      debugPrint('Error detecting platform: $e');
      return ThemeMode.system;
    }
    
    // Fallback to system theme
    return ThemeMode.system;
  }
  
  // Load saved theme preference
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user has a saved preference
      if (prefs.containsKey('theme_mode')) {
        // Load user's saved preference
        final savedTheme = prefs.getString('theme_mode');
        
        switch (savedTheme) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
            _themeMode = ThemeMode.system;
            break;
          default:
            _themeMode = _getDefaultThemeMode();
        }
      } else {
        // First time launch: use system default
        _themeMode = _getDefaultThemeMode();
        
        // Save the default preference
        await prefs.setString('theme_mode', 'system');
      }
      
      notifyListeners();
    } catch (e) {
      // If SharedPreferences fails, use system default
      debugPrint('Error loading theme: $e');
      _themeMode = _getDefaultThemeMode();
      notifyListeners();
    }
  }
  
  // Toggle theme (switches between light and dark, not system)
  Future<void> toggleTheme() async {
    // If currently in system mode, determine current appearance and toggle
    if (_themeMode == ThemeMode.system) {
      final brightness = _getSystemBrightness();
      _themeMode = brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    } else {
      // Toggle between light and dark
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }
    
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', _themeMode == ThemeMode.light ? 'light' : 'dark');
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
  
  // Set specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;
      
      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      
      await prefs.setString('theme_mode', themeString);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
  
  // Reset to system default
  Future<void> useSystemTheme() async {
    _themeMode = ThemeMode.system;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', 'system');
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
  
  // Check if currently using system theme
  bool get isSystemTheme => _themeMode == ThemeMode.system;
  
  // Get current effective brightness (considering system mode)
  Brightness getCurrentBrightness() {
    if (_themeMode == ThemeMode.system) {
      return _getSystemBrightness();
    }
    return _themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  }
}