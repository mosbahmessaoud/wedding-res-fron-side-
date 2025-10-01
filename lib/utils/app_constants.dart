// lib/utils/app_constants.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppConstants {
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Screen Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Common Padding Values
  static const EdgeInsets defaultPadding = EdgeInsets.all(16);
  static const EdgeInsets smallPadding = EdgeInsets.all(8);
  static const EdgeInsets largePadding = EdgeInsets.all(24);

  // Common Margin Values
  static const EdgeInsets defaultMargin = EdgeInsets.all(8);
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  // Input Field Configurations
  static const int defaultMaxLines = 1;
  static const int textAreaMaxLines = 4;
  static const int longTextMaxLines = 8;

  // Common Strings
  static const String appName = 'نظام إدارة حجوزات الأفراح';
  static const String loadingMessage = 'جاري التحميل...';
  static const String errorMessage = 'حدث خطأ ما';
  static const String noDataMessage = 'لا توجد بيانات';
  static const String saveMessage = 'تم الحفظ بنجاح';
  static const String deleteMessage = 'تم الحذف بنجاح';
  static const String updateMessage = 'تم التحديث بنجاح';

  // Validation Messages
  static const String requiredFieldMessage = 'هذا الحقل مطلوب';
  static const String invalidPhoneMessage = 'رقم الهاتف غير صحيح';
  static const String invalidEmailMessage = 'البريد الإلكتروني غير صحيح';
  static const String passwordTooShortMessage = 'كلمة المرور قصيرة جداً';

  // Status Labels
  static const Map<String, String> statusLabels = {
    'active': 'نشط',
    'inactive': 'غير نشط',
    'validated': 'حجز مؤكد',
    'pending_validation': 'حجز معلق',
    'cancelled': 'حجز ملغى',
    'pending': 'في الانتظار',
    'approved': 'موافق عليه',
    'rejected': 'مرفوض',
  };

  // Status Colors
  static const Map<String, Color> statusColors = {
    'active': AppTheme.successColor,
    'inactive': AppTheme.errorColor,
    'validated': AppTheme.successColor,
    'pending_validation': AppTheme.warningColor,
    'cancelled': AppTheme.errorColor,
    'pending': AppTheme.warningColor,
    'approved': AppTheme.successColor,
    'rejected': AppTheme.errorColor,
  };

  // Icon Mappings
  static const Map<String, IconData> statusIcons = {
    'active': Icons.check_circle,
    'inactive': Icons.cancel,
    'validated': Icons.verified,
    'pending_validation': Icons.pending,
    'cancelled': Icons.cancel,
    'pending': Icons.hourglass_empty,
    'approved': Icons.check_circle,
    'rejected': Icons.cancel,
  };

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';

  // API Related
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const int cacheTimeoutMinutes = 15;
}

class AppUtils {
  // Date Formatting
  static String formatDate(String? dateString, {String format = AppConstants.displayDateFormat}) {
    if (dateString == null || dateString.isEmpty) return 'غير محدد';
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  static String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'غير محدد';
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return '${formatDate(dateTimeString)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  // Phone Number Formatting
  static String formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return 'غير محدد';
    
    // Remove any non-digit characters
    String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Format based on length
    if (digits.length >= 10) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }
    return phoneNumber;
  }

  // Validation Functions
  static bool isValidPhoneNumber(String phoneNumber) {
    final String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= 8 && digits.length <= 15;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Status Helpers
  static String getStatusLabel(String status) {
    return AppConstants.statusLabels[status] ?? status;
  }

  static Color getStatusColor(String status) {
    return AppConstants.statusColors[status] ?? AppTheme.textSecondary;
  }

  static IconData getStatusIcon(String status) {
    return AppConstants.statusIcons[status] ?? Icons.help_outline;
  }

  // Text Processing
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Number Formatting
  static String formatCurrency(double amount, {String currency = 'دينار'}) {
    return '${amount.toStringAsFixed(2)} $currency';
  }

  static String formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}k';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  // Color Utilities
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  // Error Handling
  static String getErrorMessage(dynamic error) {
    if (error == null) return AppConstants.errorMessage;
    
    String errorString = error.toString();
    
    // Common error patterns
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'خطأ في الاتصال بالشبكة';
    }
    if (errorString.contains('timeout')) {
      return 'انتهت مهلة الاتصال';
    }
    if (errorString.contains('unauthorized')) {
      return 'غير مخول للوصول';
    }
    if (errorString.contains('forbidden')) {
      return 'الوصول مرفوض';
    }
    if (errorString.contains('not found')) {
      return 'المورد غير موجود';
    }
    if (errorString.contains('server')) {
      return 'خطأ في الخادم';
    }
    
    return errorString.length > 100 
        ? '${errorString.substring(0, 100)}...' 
        : errorString;
  }

  // List Utilities
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<T> filterNonNull<T>(List<T?> list) {
    return list.whereType<T>().toList();
  }

  // Search and Filter Utilities
  static bool matchesQuery(String text, String query) {
    if (query.isEmpty) return true;
    return text.toLowerCase().contains(query.toLowerCase());
  }

  static List<Map<String, dynamic>> filterByQuery(
    List<Map<String, dynamic>> items,
    String query,
    List<String> searchFields,
  ) {
    if (query.isEmpty) return items;
    
    return items.where((item) {
      return searchFields.any((field) {
        final value = item[field]?.toString() ?? '';
        return matchesQuery(value, query);
      });
    }).toList();
  }

  // Animation Utilities
  static Animation<double> createFadeAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  // Dialog Utilities
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      builder: (context) => child,
    );
  }

  static void showCustomSnackBar({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? Colors.white),
              const SizedBox(width: AppTheme.spacingS),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor ?? Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
        duration: duration,
        action: action,
      ),
    );
  }

  // Storage Utilities (for future use with SharedPreferences)
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyUserToken = 'user_token';
  static const String keyUserRole = 'user_role';
  static const String keyLastSync = 'last_sync';

  // Debug Utilities
  static void debugLog(String message, {String tag = 'APP'}) {
    // Only log in debug mode
    assert(() {
      print('[$tag] $message');
      return true;
    }());
  }

  static void debugLogError(dynamic error, {String tag = 'ERROR', StackTrace? stackTrace}) {
    assert(() {
      print('[$tag] Error: $error');
      if (stackTrace != null) {
        print('[$tag] Stack trace: $stackTrace');
      }
      return true;
    }());
  }
}