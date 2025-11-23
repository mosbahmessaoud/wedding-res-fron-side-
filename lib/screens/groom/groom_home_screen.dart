// lib/screens/home/groom_home_screen.dart
import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wedding_reservation_app/screens/groom/clan_rules_view_page.dart';
import 'package:wedding_reservation_app/screens/groom/food_menu_tab_Groom.dart';
import 'package:wedding_reservation_app/services/api_service.dart';

import '../../providers/theme_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_paint.dart';
import 'create_reservation_screen.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'reservations_tab.dart';

class GroomHomeScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const GroomHomeScreen({super.key, required this.initialTabIndex});

  @override
  _GroomHomeScreenState createState() => _GroomHomeScreenState();
}
class _GroomHomeScreenState extends State<GroomHomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _tabs;
  Widget? _externalScreen;
  String? _externalScreenTitle;
  int? _clanId;
  String? _clanName;
  int selectBtn = 0;

  // ADD THESE CACHE VARIABLES:
  bool _isInitialLoad = true;
  final Map<int, bool> _tabLoadingStatus = {};
  final Map<int, DateTime> _lastFetchTime = {};

  int _unreadNotificationCount = 0;
  Timer? _notificationPollTimer;
  bool _isLoadingNotifications = false;

  final GlobalKey<ReservationsTabState> _reservationsTabKey = GlobalKey<ReservationsTabState>();
  final GlobalKey<ProfileTabState> _profileTabKey = GlobalKey<ProfileTabState>();
  final GlobalKey<FoodMenuTabGState> _foodMenuTabKey = GlobalKey<FoodMenuTabGState>();
  final GlobalKey<CreateReservationScreenState> _creatResTabKey = GlobalKey<CreateReservationScreenState>();
  final GlobalKey<GroomClanRulesPageState> _rulesTabKey = GlobalKey<GroomClanRulesPageState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    
    _tabs = [
      HomeTab(onTabChanged: _changeTab),
      CreateReservationScreen(
        key: _creatResTabKey,
        onReservationCreated: () {
          _changeTab(2);
        },
      ),
      ReservationsTab(key: _reservationsTabKey),
      FoodMenuTabG(key: _foodMenuTabKey),
      ProfileTab(key: _profileTabKey),
      GroomClanRulesPage(key: _rulesTabKey),
    ];

    // MODIFIED: Load initial tab data in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCurrentTabInBackground(_currentIndex);
      _loadUnreadNotificationCount(); // Load initial notification count
      _startNotificationPolling(); // Start polling for new notifications
      
    });
  }
/// Show notification details dialog
void _showNotificationDetailsDialog(Map<String, dynamic> notification, bool isDark) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 500,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'تفاصيل الإشعار',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      notification['title'] ?? 'إشعار',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Date
                    Text(
                      _formatDateTime(notification['created_at']),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    
                    // Message
                    Text(
                      notification['message'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'موافق',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Helper to format datetime for notification details
String _formatDateTime(String? dateTimeStr) {
  if (dateTimeStr == null) return '';
  
  try {
    final dateTime = DateTime.parse(dateTimeStr);
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  } catch (e) {
    return '';
  }
}
  /// Load unread notification count
  Future<void> _loadUnreadNotificationCount() async {
    if (_isLoadingNotifications) return;
    
    setState(() {
      _isLoadingNotifications = true;
    });

    try {
      final count = await ApiService.getUnreadNotificationCount();
      if (mounted) {
        setState(() {
          _unreadNotificationCount = count;
        });
      }
    } catch (e) {
      print('Error loading notification count: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingNotifications = false;
        });
      }
    }
  }

  /// Start polling for new notifications every 30 seconds
  void _startNotificationPolling() {
    _notificationPollTimer?.cancel();
    _notificationPollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (mounted) {
          _loadUnreadNotificationCount();
        } else {
          timer.cancel();
        }
      },
    );
  }
/// Navigate to notifications screen
void _navigateToNotifications() {
  _navigateToExternalScreen(
    NotificationsScreen(
      onNotificationRead: () {
        // Refresh count when notification is read
        _loadUnreadNotificationCount();
      },
    ),
    'الإشعارات', // This will be the title in the app bar
  );
}


  /// Helper method to get relative time string
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    


    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years ${years == 1 ? 'سنة' : 'سنوات'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months ${months == 1 ? 'شهر' : 'أشهر'}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }


Future<bool> _checkConnectivity() async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult is List) {
      return !connectivityResult.contains(ConnectivityResult.none) && 
             connectivityResult.isNotEmpty;
    }
    return connectivityResult != ConnectivityResult.none;
  } catch (e) {
    return false;
  }
}

void _showNoInternetDialog() {
  // final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
      final isDark = Theme.of(context).brightness == Brightness.dark;

  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 360;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              color: AppColors.error,
              size: isSmallScreen ? 48 : 56,
            ),
            SizedBox(height: 16),
            Text(
              'لا يوجد اتصال بالإنترنت',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('إلغاء'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
  child: ElevatedButton(
    onPressed: () async {
      final nav = Navigator.of(context);
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 360;
      
      nav.pop();
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'جاري فحص الاتصال...',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Wait 2 seconds while checking
      await Future.delayed(Duration(seconds: 2));
      final hasInternet = await _checkConnectivity();
      
      nav.pop();
      
      if (!hasInternet) {
        _showNoInternetDialog();
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      padding: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Text(
      'إعادة المحاولة',
      style: TextStyle(
        fontSize: isSmallScreen ? 13 : 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}


void _changeTab(int index) async {
  setState(() {
    _currentIndex = index;
    _externalScreen = null;
    _externalScreenTitle = null;
  });
  
  // Check if data needs refresh (e.g., older than 5 minutes)
  final needsRefresh = _shouldRefreshTab(index);
  
  if (needsRefresh) {
    _refreshCurrentTabInBackground(index);
  }
}


// ============================================
// 3. ADD: Helper method to check if refresh is needed
// ============================================

bool _shouldRefreshTab(int index) {
  // Always refresh on first load
  if (!_lastFetchTime.containsKey(index)) {
    return true;
  }
  
  // Refresh if data is older than 5 minutes
  final lastFetch = _lastFetchTime[index];
  if (lastFetch == null) return true;
  
  final now = DateTime.now();
  final difference = now.difference(lastFetch);
  
  return difference.inMinutes >= 5;
}


// ============================================
// 4. ADD: Background refresh method (non-blocking)
// ============================================

void _refreshCurrentTabInBackground(int index) {
  // Don't refresh if already loading
  if (_tabLoadingStatus[index] == true) {
    return;
  }
  
  // Mark as loading
  _tabLoadingStatus[index] = true;
  
  // Perform refresh in background without blocking UI
  Future.microtask(() async {
    try {
      switch (index) {
        case 1:
          _creatResTabKey.currentState?.refreshData();
          break;
        case 2:
          _reservationsTabKey.currentState?.refreshData();
          break;
        case 3:
          _foodMenuTabKey.currentState?.refreshData();
          break;
        case 4:
          _profileTabKey.currentState?.refreshData();
          break;
        case 5:
          _rulesTabKey.currentState?.refreshData();
          break;
      }
      
      // Update last fetch time
      _lastFetchTime[index] = DateTime.now();
    } catch (e) {
      print('Background refresh error for tab $index: $e');
    } finally {
      _tabLoadingStatus[index] = false;
    }
  });
}


void _refreshCurrentTab(int index) {
  // This is now just for forced refresh (pull-to-refresh)
  _lastFetchTime.remove(index); // Clear cache
  _refreshCurrentTabInBackground(index);
}



// Update the _navigateToExternalScreen method
void _navigateToExternalScreen(Widget screen, String title) async {
  // final hasInternet = await _checkConnectivity();
  // if (!hasInternet) {
  //   _showNoInternetDialog();
  //   return;
  // }
  
  setState(() {
    _externalScreen = screen;
    _externalScreenTitle = title;
  });
}

  void _closeExternalScreen() {
    setState(() {
      _externalScreen = null;
      _externalScreenTitle = null;
    });
  }
   
  void _showLogoutDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ApiService.clearToken();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    // final isDark = themeProvider.isDarkMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;


    return WillPopScope(
      onWillPop: () async {
        if (_externalScreen != null) {
          _closeExternalScreen();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF6F6F6),
        appBar: _buildSpotifyAppBar(isDark),
        drawer: _buildSpotifyDrawer(isDark),
        body: Stack(
  children: [
    // Main content with bottom padding for nav bar
    Positioned.fill(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.width < 360 ? 65.0 : 70.0,
        ),
        child: _externalScreen != null
            ? Column(
                children: [
                  // Custom app bar for external screen
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 22,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          onPressed: _closeExternalScreen,
                        ),
                        Expanded(
                          child: Text(
                            _externalScreenTitle ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  // External screen content
                  Expanded(
                    child: _externalScreen!,
                  ),
                ],
              )
            : _tabs[_currentIndex],
      ),
    ),
    
    // Bottom Navigation Bar - FLOATING ON TOP
    Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: navigationBar(isDark),
      ),
    ),
  ],
),
      ),
    );
  }

  // Responsive Navigation Bar with smooth transitions
AnimatedContainer navigationBar(bool isDark) {
  // Get screen width for responsive sizing
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 360;
  final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
  
  // Responsive dimensions
  final navHeight = isSmallScreen ? 65.0 : 70.0;
  final borderRadius = isSmallScreen ? 15.0 : 20.0;
  
  return AnimatedContainer(

    height: navHeight,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOutCubic,
    decoration: BoxDecoration(
      color: isDark 
          ? const Color.fromARGB(173, 52, 52, 52) 
          : const Color.fromARGB(180, 212, 212, 212),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(_currentIndex == 5 ? 0.0 : borderRadius),
        topRight: Radius.circular(_currentIndex == 5 ? 0.0 : borderRadius),
      ),
      border: Border.all(
        color: const Color.fromARGB(255, 4, 99, 1).withOpacity(isDark ? 0.2 : 0.1),
        width: 0.5,
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(_currentIndex == 5 ? 0.0 : borderRadius),
        topRight: Radius.circular(_currentIndex == 5 ? 0.0 : borderRadius),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate item width based on available space
              final itemWidth = constraints.maxWidth / 5; // Changed from 6 to 5 items
              
              return Stack(
                children: [
                  // Animated sliding indicator background
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOutCubic,
                    left: _getIndicatorPosition(itemWidth),
                    top: 0,
                    bottom: 0,
                    width: itemWidth,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _externalScreen == null ? 0.1 : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              (isDark ? AppColors.primary : AppColors.primaryLight)
                                  .withOpacity(0.15),
                              (isDark ? AppColors.primary : AppColors.primaryLight)
                                  .withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Navigation items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(Icons.add_circle_outline_rounded, 'انشاء حجز', 1, isDark, itemWidth),
                      _buildNavItem(Icons.calendar_today_rounded, 'الحجوزات', 2, isDark, itemWidth),
                      _buildNavItem(Icons.home_rounded, 'الرئيسية', 0, isDark, itemWidth),
                      _buildNavItem(Icons.restaurant_menu_rounded, 'الوليمة', 3, isDark, itemWidth),
                      _buildNavItem(Icons.rule_outlined, 'اللوازم', 5, isDark, itemWidth),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}



// Helper method to calculate indicator position
double _getIndicatorPosition(double itemWidth) {
  // Map current index to position (accounting for RTL layout)
  final indexToPosition = {
    1: 0,  // انشاء حجز (leftmost)
    2: 1,  // الحجوزات
    0: 2,  // الرئيسية (center)
    3: 3,  // الوليمة
    5: 4,  // اللوازم (rightmost)
  };
  
  return (indexToPosition[_currentIndex] ?? 2) * itemWidth;
}
// Responsive _buildNavItem with dynamic sizing
Widget _buildNavItem(IconData icon, String label, int index, bool isDark, double itemWidth) {
  final isSelected = _currentIndex == index && _externalScreen == null;
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 360;
  final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
  
  // Responsive notch dimensions
  var notchHeight = isSelected ? (isSmallScreen ? 50.0 : 60.0) : 0.0;
  var notchWidth = isSelected ? (isSmallScreen ? 45.0 : 50.0) : 0.0;
  
  // Responsive icon sizes
  final selectedIconSize = isSmallScreen ? 24.0 : 28.0;
  final unselectedIconSize = isSmallScreen ? 20.0 : 24.0;
  
  // Responsive font size
  final fontSize = isSmallScreen ? 9.0 : (isMediumScreen ? 10.0 : 11.0);
  
  // Constrain item width
  final constrainedWidth = itemWidth.clamp(50.0, 80.0);
  
  return GestureDetector(
    onTap: () => _changeTab(index),
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      width: constrainedWidth,
      child: Stack(
        children: [
          // CustomPaint Notch at top
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              height: notchHeight,
              width: notchWidth,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? CustomPaint(
                      painter: ButtonNotch(
                        isDark: isDark,
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
          // Icon in center
          Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              child: Icon(
                icon,
                color: isSelected 
                    ? isDark ? AppColors.primary : AppColors.primaryLight
                    : (isDark 
                        ? Colors.white.withOpacity(0.6) 
                        : Colors.black.withOpacity(0.5)),
                size: isSelected ? selectedIconSize : unselectedIconSize,
              ),
            ),
          ),
          // Label at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: isSmallScreen ? 2 : 4),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected 
                      ? isDark ? AppColors.primary : AppColors.primaryLight
                      : (isDark 
                          ? Colors.white.withOpacity(0.6) 
                          : Colors.black.withOpacity(0.7)),
                  letterSpacing: 0.2,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Optional: Add SafeArea wrapper for better compatibility
Widget buildNavigationWithSafeArea(bool isDark) {
  return SafeArea(
    top: false,
    child: navigationBar(isDark),
  );
}

PreferredSizeWidget _buildSpotifyAppBar(bool isDark) {
    return AppBar(
      title: Text(
        _getAppBarTitle(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      backgroundColor: isDark 
          ? const Color(0xFF1E1E1E) 
          : const Color.fromARGB(201, 255, 255, 255),
      foregroundColor: isDark ? Colors.white : Colors.black87,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.menu,
              size: 20,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        // Notification Button with Badge
        // In _buildSpotifyAppBar method, replace the notification IconButton onPressed:
IconButton(
  icon: Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.notifications_outlined,
          size: 20,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      if (_unreadNotificationCount > 0)
        Positioned(
          right: 2,
          top: 2,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark 
                    ? const Color(0xFF1E1E1E) 
                    : Colors.white,
                width: 1.5,
              ),
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Center(
              child: Text(
                _unreadNotificationCount > 9 
                    ? '9+' 
                    : _unreadNotificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
    ],
  ),
  onPressed: () => _navigateToNotifications(), // CHANGED: Navigate to page instead of dialog
),
        const SizedBox(width: 4),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.logout_outlined,
              size: 20,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => _showLogoutDialog(isDark),
          tooltip: 'تسجيل الخروج',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () {
            final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
            themeProvider.toggleTheme();
          },
          tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
        ),
      ],
    );
  }


  Widget _buildSpotifyDrawer(bool isDark) {
    return Drawer(
      child: Container(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'قائمة التنقل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildDrawerItem(Icons.home_rounded, 'الرئيسية', 0, isDark),
                    _buildDrawerItem(Icons.add_circle_outline_rounded, 'انشاء حجز', 1, isDark),
                    _buildDrawerItem(Icons.calendar_today_rounded, 'حجوزاتي', 2, isDark),
                    _buildDrawerItem(Icons.restaurant_menu_rounded, 'قائمة مقادير الوليمة', 3, isDark),
                    _buildDrawerItem(Icons.person_outline_rounded, 'الملف الشخصي', 4, isDark),
                    _buildDrawerItem(Icons.rule_outlined, 'اللوازم', 5, isDark),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        thickness: 1,
                      ),
                    ),

                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'الإعدادات',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                'الإعدادات',
                                textAlign: TextAlign.right,
                              ),
                              content: const Text(
                                'هذه الصفحة قيد التطوير حالياً. سيتم إضافتها قريباً.',
                                textAlign: TextAlign.right,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('حسناً'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    // 2. Help and Support item - calls _showHelpSupport()
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.help_outline_rounded,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'المساعدة والدعم',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showHelpSupport();
                      }, 
                    ),

                    // 3. About App item - calls _showAboutApp()
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'حول التطبيق',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutApp();
                      },
                    ),

                    // 4. Rate App item - shows a "coming soon" dialog
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.star_outline_rounded,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'تقييم التطبيق',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                'تقييم التطبيق',
                                textAlign: TextAlign.right,
                              ),
                              content: const Text(
                                'هذه الميزة قيد التطوير حالياً. سيتم إضافتها قريباً.',
                                textAlign: TextAlign.right,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('حسناً'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                    
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                      ),
                      title: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog(isDark);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutApp() {
    final isDark = Theme.of(context).brightness == Brightness.dark;


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حول التطبيق'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تطبيق حجوزات الأعراس الخاص بجميع العشائر ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('الإصدار: 1.0.7'),
              const SizedBox(height: 16),
              const Text(
                'يسرّنا أن نرحب بكم في تطبيق الأعراس،\nونضع بين أيديكم وسيلة ميسرة لتنظيم و حجز العرس الخاص بكم',
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'برعاية:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('عشيرة آت الشيخ الحاج مسعود'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'معلومات عن المطورين:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('iTriDev.Soft@gmail.com'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 18),
                  const SizedBox(width: 8),
                  const Text('0658890501'),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ?Colors.green.shade300 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ?Colors.green.shade500 : Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.message, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '   لأي ملاحظات أو استفسارات عن التطبيق،  \n  عبر البريد الإلكتروني iTriDev.Soft@gmail.com '     ,
                        style: TextStyle(fontSize: 13, color: isDark ?AppColors.darkTextPrimary : AppColors.darkBorder),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('لدعم والمساعدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // const Text(
              //   'معلومات المطور:',
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('iTriDev.Soft@gmail.com'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 18),
                  const SizedBox(width: 8),
                  const Text('0658890501'),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ?Colors.green.shade300 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ?Colors.green.shade500 : Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.message, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '   لأي ملاحظات أو استفسارات عن التطبيق،  \n  عبر البريد الإلكتروني iTriDev.Soft@gmail.com '     ,
                        style: TextStyle(fontSize: 13, color: isDark ?AppColors.darkTextPrimary : AppColors.darkBorder),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

// Update _buildDrawerItem method - only the onTap part
Widget _buildDrawerItem(IconData icon, String title, int index, bool isDark) {
  final isSelected = _currentIndex == index && _externalScreen == null;
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    decoration: BoxDecoration(
      color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : (isDark ? Colors.grey[300] : Colors.grey[800]),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 15,
        ),
      ),
      onTap: () async {
        Navigator.pop(context);
        // final hasInternet = await _checkConnectivity();
        // if (!hasInternet) {
        //   _showNoInternetDialog();
        //   return;
        // }
        _changeTab(index);
      },
    ),
  );
}


// Update _buildExternalDrawerItem method - only the onTap part
Widget _buildExternalDrawerItem(IconData icon, String title, Widget screen, bool isDark) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.grey[400] : Colors.grey[700],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.grey[300] : Colors.grey[800],
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      onTap: () async {
        Navigator.pop(context);
        // final hasInternet = await _checkConnectivity();
        // if (!hasInternet) {
        //   _showNoInternetDialog();
        //   return;
        // }
        _navigateToExternalScreen(screen, title);
      },
    ),
  );
}

  String _getAppBarTitle() {
    if (_externalScreen != null) {
      return _externalScreenTitle ?? '';
    }
    
    switch (_currentIndex) {
      case 0:
        return AppConstants.appName;
      case 1:
        return 'حجز جديد';
      case 2:
        return 'الحجوزات';
      case 3:
        return 'مقادير الوليمة';
      case 4:
        return 'الملف الشخصي';
      case 5:
        return 'اللوازم';
      default:
        return AppConstants.appName;
    }
  }

  // void _showNotifications(bool isDark) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       title: Text(
  //         'الإشعارات',
  //         style: TextStyle(
  //           fontWeight: FontWeight.w700,
  //           fontSize: 20,
  //           color: isDark ? Colors.white : Colors.black87,
  //         ),
  //       ),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             _buildNotificationItem(
  //               Icons.info_rounded,
  //               Colors.blue,
  //               'مرحباً بك في التطبيق',
  //               'نتمنى لك تجربة ممتعة في حجز قاعة زفافك',
  //               isDark,
  //             ),
  //             const SizedBox(height: 12),
  //             _buildNotificationItem(
  //               Icons.update_rounded,
  //               Colors.green,
  //               'تحديث التطبيق',
  //               'تم إضافة ميزات جديدة للتطبيق',
  //               isDark,
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           style: TextButton.styleFrom(
  //             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //           ),
  //           child: Text(
  //             'موافق',
  //             style: TextStyle(
  //               color: AppColors.primary,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildNotificationItem(
  //   IconData icon,
  //   Color color,
  //   String title,
  //   String subtitle,
  //   bool isDark,
  // ) {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(isDark ? 0.2 : 0.1),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: color,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Icon(icon, color: Colors.white, size: 20),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 title,
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 14,
  //                   color: isDark ? Colors.white : Colors.black87,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 subtitle,
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   color: isDark ? Colors.grey[400] : Colors.grey[700],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}



class NotificationsScreen extends StatefulWidget {
  final VoidCallback onNotificationRead;
  
  const NotificationsScreen({
    super.key,
    required this.onNotificationRead,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}


class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  List<dynamic> _filteredNotifications = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all'; // all, today, week, month

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }


  
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await ApiService.getNotifications(
        unreadOnly: false,
        limit: 50,
      );
      
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

Widget _buildFilterChips(bool isDark) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('الكل', 'all', isDark),
          const SizedBox(width: 8),
          _buildFilterChip('اليوم', 'today', isDark),
          const SizedBox(width: 8),
          _buildFilterChip('هذا الأسبوع', 'week', isDark),
          const SizedBox(width: 8),
          _buildFilterChip('هذا الشهر', 'month', isDark),
        ],
      ),
    ),
  );
}

Widget _buildFilterChip(String label, String value, bool isDark) {
  final isSelected = _selectedFilter == value;
  
  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedFilter = value;
        _applyFilter();
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : (isDark ? Colors.grey[800] : Colors.grey[200]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.grey[300] : Colors.grey[700]),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    ),
  );
}

/// Show notification details dialog
void _showNotificationDetailsDialog(Map<String, dynamic> notification, bool isDark) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 500,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'تفاصيل الإشعار',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'] ?? 'إشعار',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDateTime(notification['created_at']),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text(
                      notification['message'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              // child: SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () => Navigator.pop(context),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.primary,
              //       padding: const EdgeInsets.symmetric(vertical: 12),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //     child: const Text(
              //       'موافق',
              //       style: TextStyle(
              //         fontWeight: FontWeight.w600,
              //         fontSize: 14,
              //       ),
              //     ),
              //   ),
              // ),
            ),
          ],
        ),
      ),
    ),
  );
}


  void _applyFilter() {
    final now = DateTime.now();
    
    switch (_selectedFilter) {
      case 'today':
        _filteredNotifications = _notifications.where((notification) {
          final createdAt = DateTime.tryParse(notification['created_at'] ?? '');
          if (createdAt == null) return false;
          return createdAt.year == now.year &&
                 createdAt.month == now.month &&
                 createdAt.day == now.day;
        }).toList();
        break;
        
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        _filteredNotifications = _notifications.where((notification) {
          final createdAt = DateTime.tryParse(notification['created_at'] ?? '');
          if (createdAt == null) return false;
          return createdAt.isAfter(weekAgo);
        }).toList();
        break;
        
      case 'month':
        final monthAgo = now.subtract(const Duration(days: 30));
        _filteredNotifications = _notifications.where((notification) {
          final createdAt = DateTime.tryParse(notification['created_at'] ?? '');
          if (createdAt == null) return false;
          return createdAt.isAfter(monthAgo);
        }).toList();
        break;
        
      case 'all':
      default:
        _filteredNotifications = _notifications;
        break;
    }
    
    // Sort by date (newest first)
    _filteredNotifications.sort((a, b) {
      final aDate = DateTime.tryParse(a['created_at'] ?? '');
      final bDate = DateTime.tryParse(b['created_at'] ?? '');
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });
  }

  @override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
    backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF6F6F6),
    // appBar: AppBar(
    //   // title: const Text('الإشعارات'),
    //   backgroundColor: isDark 
    //       ? const Color(0xFF1E1E1E) 
    //       : const Color.fromARGB(201, 255, 255, 255),
    //   actions: [
    //     if (_notifications.isNotEmpty)
    //       IconButton(
    //         icon: const Icon(Icons.done_all),
    //         onPressed: () async {
    //           try {
    //             await ApiService.markAllNotificationsAsRead();
    //             widget.onNotificationRead();
    //             _loadNotifications();
    //           } catch (e) {
    //             ScaffoldMessenger.of(context).showSnackBar(
    //               SnackBar(
    //                 content: Text('فشل في تعليم الكل كمقروء: $e'),
    //                 backgroundColor: AppColors.error,
    //               ),
    //             );
    //           }
    //         },
    //         tooltip: 'تعليم الكل كمقروء',
    //       ),
    //   ],
    // ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ في تحميل الإشعارات',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadNotifications,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Filter chips
                  _buildFilterChips(isDark),
                  
                  // Results count
                  if (_notifications.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            '${_filteredNotifications.length} إشعار',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Notifications list
                  Expanded(
                    child: _filteredNotifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  size: 64,
                                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _notifications.isEmpty
                                      ? 'لا توجد إشعارات'
                                      : 'لا توجد إشعارات في هذه الفترة',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadNotifications,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredNotifications.length,
                              itemBuilder: (context, index) {
                                final notification = _filteredNotifications[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildNotificationCard(
                                    notification: notification,
                                    isDark: isDark,
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
  );
}
Widget _buildNotificationCard({
  required Map<String, dynamic> notification,
  required bool isDark,
}) {
  final isUnread = notification['is_read'] == false;
  
  return GestureDetector(
    onTap: () async {
      // Show full notification details in popup
      _showNotificationDetailsDialog(notification, isDark);
      
      // Mark as read if unread
      if (isUnread) {
        try {
          await ApiService.markNotificationAsRead(notification['id']);
          widget.onNotificationRead();
          _loadNotifications();
        } catch (e) {
          print('Error marking as read: $e');
        }
      }
    },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread
              ? (isDark 
                  ? AppColors.primary.withOpacity(0.1) 
                  : AppColors.primary.withOpacity(0.05))
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withOpacity(0.3)
                : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification['title'] ?? 'إشعار',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isUnread)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                notification['message'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Text(
              _formatDateTime(notification['created_at']),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
      } else if (difference.inHours > 0) {
        return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
      } else if (difference.inMinutes > 0) {
        return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
      } else {
        return 'الآن';
      }
    } catch (e) {
      return '';
    }
  }
}