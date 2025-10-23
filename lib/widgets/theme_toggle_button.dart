// lib/widgets/theme_toggle_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

// Simple IconButton for AppBar
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return IconButton(
      icon: Icon(
        themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
      ),
      onPressed: () => themeProvider.toggleTheme(),
      tooltip: themeProvider.isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
    );
  }
}

// Switch Tile for Settings Screen
class ThemeToggleTile extends StatelessWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return SwitchListTile(
      title: const Text('الوضع الداكن'),
      subtitle: const Text('تفعيل المظهر الليلي'),
      value: themeProvider.isDarkMode,
      onChanged: (_) => themeProvider.toggleTheme(),
      secondary: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
      ),
    );
  }
}

// Floating Action Button Style
class ThemeFAB extends StatelessWidget {
  const ThemeFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return FloatingActionButton(
      onPressed: () => themeProvider.toggleTheme(),
      tooltip: themeProvider.isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
      child: Icon(
        themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
      ),
    );
  }
}