// // lib/providers/theme_provider.dart
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider extends ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.light;
  
//   ThemeMode get themeMode => _themeMode;
//   bool get isDarkMode => _themeMode == ThemeMode.dark;
  
//   ThemeProvider() {
//     _loadTheme();
//   }
  
//   // Load saved theme preference
//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isDark = prefs.getBool('isDarkMode') ?? false;
//     _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }
  
//   // Toggle theme
//   Future<void> toggleTheme() async {
//     _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
    
//     // Save preference
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
//   }
  
//   // Set specific theme
//   Future<void> setTheme(ThemeMode mode) async {
//     _themeMode = mode;
//     notifyListeners();
    
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
//   }
// }