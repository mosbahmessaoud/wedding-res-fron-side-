// lib/widgets/theme_toggle_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

// Simple IconButton for AppBar
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = MediaQuery.of(context).platformBrightness;
    final isCurrentlyDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system && brightness == Brightness.dark);
    
    return IconButton(
      icon: Icon(
        isCurrentlyDark ? Icons.light_mode : Icons.dark_mode,
      ),
      onPressed: () => themeProvider.toggleTheme(),
      tooltip: isCurrentlyDark ? 'الوضع النهاري' : 'الوضع الليلي',
    );
  }
}

// Switch Tile for Settings Screen
class ThemeToggleTile extends StatelessWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = MediaQuery.of(context).platformBrightness;
    final isCurrentlyDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system && brightness == Brightness.dark);
    
    return SwitchListTile(
      title: const Text('الوضع الداكن'),
      subtitle: Text(
        themeProvider.themeMode == ThemeMode.system 
          ? 'تابع إعدادات النظام (${brightness == Brightness.dark ? "داكن" : "فاتح"})'
          : 'تفعيل المظهر الليلي'
      ),
      value: isCurrentlyDark,
      onChanged: (_) => themeProvider.toggleTheme(),
      secondary: Icon(
        isCurrentlyDark ? Icons.dark_mode : Icons.light_mode,
      ),
    );
  }
}

// Advanced Theme Selector with System Option
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = MediaQuery.of(context).platformBrightness;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'اختر المظهر',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('فاتح'),
          subtitle: const Text('مظهر فاتح دائماً'),
          value: ThemeMode.light,
          groupValue: themeProvider.themeMode,
          onChanged: (value) => themeProvider.setTheme(value!),
          secondary: const Icon(Icons.light_mode),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('داكن'),
          subtitle: const Text('مظهر داكن دائماً'),
          value: ThemeMode.dark,
          groupValue: themeProvider.themeMode,
          onChanged: (value) => themeProvider.setTheme(value!),
          secondary: const Icon(Icons.dark_mode),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('تابع النظام'),
          subtitle: Text(
            'تطابق إعدادات الجهاز (حالياً: ${brightness == Brightness.dark ? "داكن" : "فاتح"})'
          ),
          value: ThemeMode.system,
          groupValue: themeProvider.themeMode,
          onChanged: (value) => themeProvider.setTheme(value!),
          secondary: const Icon(Icons.brightness_auto),
        ),
      ],
    );
  }
}

// Floating Action Button Style
class ThemeFAB extends StatelessWidget {
  const ThemeFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = MediaQuery.of(context).platformBrightness;
    final isCurrentlyDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system && brightness == Brightness.dark);
    
    return FloatingActionButton(
      onPressed: () => themeProvider.toggleTheme(),
      tooltip: isCurrentlyDark ? 'الوضع النهاري' : 'الوضع الليلي',
      child: Icon(
        isCurrentlyDark ? Icons.light_mode : Icons.dark_mode,
      ),
    );
  }
}