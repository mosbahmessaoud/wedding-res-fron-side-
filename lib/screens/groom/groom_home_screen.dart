// lib/screens/home/groom_home_screen.dart
import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
class _GroomHomeScreenState extends State<GroomHomeScreen> 
    with TickerProviderStateMixin {
      

  
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
// Add these after the existing state variables (around line 40)
  bool _hasValidReservation = false;
  bool _isCheckingReservation = true;



// ADD THESE NEW VARIABLES FOR BOTTOM NAV VISIBILITY:
  bool _isBottomNavVisible = true;
  Timer? _hideNavTimer;
  late AnimationController _navAnimationController;
  late Animation<Offset> _navSlideAnimation;

//   @override
// void initState() {
//   super.initState();
//   _currentIndex = widget.initialTabIndex;
  
//   _tabs = [
//     HomeTab(onTabChanged: _changeTab),
//     CreateReservationScreen(
//       key: _creatResTabKey,
//       onReservationCreated: () {
//         _changeTab(2);
//       },
//     ),
//     ReservationsTab(key: _reservationsTabKey),
//     FoodMenuTabG(key: _foodMenuTabKey),
//     ProfileTab(key: _profileTabKey),
//     GroomClanRulesPage(key: _rulesTabKey),
//   ];

//   // MODIFIED: Check reservation first, then load data
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     _checkReservationStatus().then((_) {
//       if (_hasValidReservation) {
//         _refreshCurrentTabInBackground(_currentIndex);
//         _loadUnreadNotificationCount();
//         _startNotificationPolling();
//       }
//     });
//   });



  
// }

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
  
  // ADD THIS INITIALIZATION FOR NAV ANIMATION:
  _navAnimationController = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );
  
  _navSlideAnimation = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _navAnimationController,
    curve: Curves.easeInOut,
  ));
  
  _navAnimationController.forward();
  
  // Modified: Check reservation first, then check profile completion
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkReservationStatus().then((_) {
      // Check profile completion after user is authenticated
      _checkGroomProfileCompletion();
      
      if (_hasValidReservation) {
        _refreshCurrentTabInBackground(_currentIndex);
        _loadUnreadNotificationCount();
        _startNotificationPolling();
        _startHideTimer();
      } else {
        _startHideTimer();
      }
    });
  });
}

  @override
  void dispose() {
    // ... existing dispose code ...
    _hideNavTimer?.cancel();
    _navAnimationController.dispose();
    _notificationPollTimer?.cancel(); // Don't forget existing timer
    super.dispose();
  }

// ADD THESE NEW METHODS:
  void _startHideTimer() {
    _hideNavTimer?.cancel();
    _hideNavTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _hideBottomNav();
      }
    });
  }

  void _hideBottomNav() {
    setState(() {
      _isBottomNavVisible = false;
    });
    _navAnimationController.reverse();
  }

  void _showBottomNav() {
    setState(() {
      _isBottomNavVisible = true;
    });
    _navAnimationController.forward();
    _startHideTimer();
  }

/// Check if groom's profile information is complete
Future<void> _checkGroomProfileCompletion() async {
  try {
    final validationMessage = await ApiService.validateGroomInfoForReservation();
    
    if (validationMessage != null && mounted) {
      // Profile is incomplete, show dialog after a short delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _showProfileIncompleteDialog(validationMessage);
        }
      });
    }
  } catch (e) {
    print('Error checking profile completion: $e');
  }
}

/// Show dialog when profile is incomplete
void _showProfileIncompleteDialog(String message) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async => false, // Prevent dismissing with back button
      child: AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'الملف الشخصي غير مكتمل',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   message,
            //   style: TextStyle(
            //     color: isDark ? Colors.white70 : Colors.black87,
            //     height: 1.5,
            //     fontSize: 15,
            //   ),
            // ),
            // const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.orange.shade900.withOpacity(0.3) 
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark 
                      ? Colors.orange.shade700 
                      : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isDark 
                        ? Colors.orange.shade300 
                        : Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يرجى إكمال معلومات ملفك الشخصي قبل تنزيل ورقة الحجز',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark 
                            ? Colors.orange.shade200 
                            : Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'لاحقاً',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to Profile tab
              setState(() {
                _currentIndex = 4; // Profile tab index
                _externalScreen = null;
                _externalScreenTitle = null;
              });
              
              // Optional: Show a snackbar to guide the user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('يرجى إكمال المعلومات الناقصة في ملفك الشخصي'),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 5),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text(
              'إكمال الملف الشخصي',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// // UPDATED METHOD - Uses the return value from _checkAccessPassword:
// Future<bool> _verifyAccessForTab() async {
//   // Get the result directly from _checkAccessPassword
//   // final hasPassword = await _checkAccessPassword();
  
//   // Check if user has access password set
//   // if (!hasPassword ) {
//   //   _showAccessPasswordNotSetDialog();
//   //   return false;
//   // }
  
//   // Show password verification dialog
//   return await _showAccessPasswordDialog();
// }

// Dialog when user doesn't have access password
void _showAccessPasswordNotSetDialog() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'كلمة مرور الوصول غير متوفرة',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
      // content: Text(
      //   'لم يتم تعيين كلمة مرور وصول لحسابك.\nيرجى الاتصال بالمدير الأعلى لإنشاء كلمة مرور.',
      //   style: TextStyle(
      //     color: isDark ? Colors.white70 : Colors.black87,
      //   ),
      // ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
          child: const Text('فهمت', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}



Future<bool> _showAccessPasswordDialog() async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  String? errorMessage;
  bool isLoading = false; // ADD THIS LINE

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.key, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'أدخل كلمة مرور الوصول',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              autofocus: true,
              enabled: !isLoading, // DISABLE WHEN LOADING
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: 'كلمة مرور ',
                hintText: 'أدخل كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: isLoading ? null : () { // DISABLE WHEN LOADING
                    setDialogState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: errorMessage,
              ),
              onSubmitted: isLoading ? null : (_) async { // DISABLE WHEN LOADING
                if (passwordController.text.isEmpty) {
                  setDialogState(() {
                    errorMessage = 'يرجى إدخال كلمة المرور';
                  });
                  return;
                }
                
                // Start loading
                setDialogState(() {
                  isLoading = true;
                  errorMessage = null;
                }); 
                
                try {
                  final isValid = await ApiService.validateSpecialPageAccess(
                    passwordController.text,
                  );
                  if (isValid) {
                    Navigator.pop(context, true);
                  } else {
                    setDialogState(() {
                      isLoading = false;
                      errorMessage = 'كلمة المرور غير صحيحة';
                    });
                  }
                } catch (e) {
                  setDialogState(() {
                    isLoading = false;
                    errorMessage = 'خطأ في التحقق من كلمة المرور';
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context, false), // DISABLE WHEN LOADING
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isLoading 
                    ? Colors.grey 
                    : (isDark ? Colors.white60 : Colors.grey[700]),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : () async { // DISABLE WHEN LOADING
              if (passwordController.text.isEmpty) {
                setDialogState(() {
                  errorMessage = 'يرجى إدخال كلمة المرور';
                });
                return;
              }

              // Start loading
              setDialogState(() {
                isLoading = true;
                errorMessage = null;
              });

              try {
                final isValid = await ApiService.validateSpecialPageAccess(
                  passwordController.text,
                );

                if (isValid) {
                  Navigator.pop(context, true);
                } else {
                  setDialogState(() {
                    isLoading = false;
                    errorMessage = 'كلمة المرور غير صحيحة';
                  });
                }
              } catch (e) {
                setDialogState(() {
                  isLoading = false;
                  errorMessage = 'خطأ في التحقق من كلمة المرور';
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isLoading 
                  ? Colors.grey 
                  : AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: isLoading // UPDATED CHILD WITH LOADING INDICATOR
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('جاري التحقق...', style: TextStyle(color: Colors.white)),
                    ],
                  )
                : const Text('تحقق', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );

  passwordController.dispose();
  return result ?? false;
}



/// Check if user has a valid reservation
Future<void> _checkReservationStatus() async {
  setState(() {
    _isCheckingReservation = true;
  });

  try {
    // Check for validated reservation
    final validatedReservation = await ApiService.getMyValidatedReservation();
    
    if (validatedReservation != null && validatedReservation.isNotEmpty) {
      setState(() {
        _hasValidReservation = true;
        _isCheckingReservation = false;
      });
      return;
    }
  } catch (e) {
    print('No validated reservation found: $e');
  }

  setState(() {
    _hasValidReservation = false;
    _isCheckingReservation = false;
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
void _navigateToNotifications() async {
  // Check if user has valid reservation
  if (!_hasValidReservation) {
    _showNoReservationForNotificationsDialog();
    return;
  }
  
  // Mark all notifications as read when opening the screen
  try {
    await ApiService.markAllNotificationsAsRead();
    // Refresh the notification count after marking as read
    await _loadUnreadNotificationCount();
  } catch (e) {
    print('Error marking notifications as read: $e');
    // Continue to open notifications screen even if marking as read fails
  }
  
  _navigateToExternalScreen(
    NotificationsScreen(
      onNotificationRead: () {
        // Refresh count when notification is read
        _loadUnreadNotificationCount();
      },
    ),
    'الإشعارات',
  );
}
/// Show dialog when trying to access notifications without valid reservation
void _showNoReservationForNotificationsDialog() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: Colors.orange,
            size: 28,
          ),
          // const SizedBox(width: 12),
          Expanded(
            child: Text(
              'حجز مؤكد مطلوب',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'للوصول إلى الإشعارات، يجب أن يكون لديك حجز مؤكد.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
          // const SizedBox(height: 16),
          // Container(
          //   padding: const EdgeInsets.all(12),
          //   decoration: BoxDecoration(
          //     color: isDark ? Colors.orange.shade900.withOpacity(0.3) : Colors.orange.shade50,
          //     borderRadius: BorderRadius.circular(8),
          //     border: Border.all(
          //       color: isDark ? Colors.orange.shade700 : Colors.orange.shade200,
          //     ),
          //   ),
          //   child: Row(
          //     children: [
          //       Icon(
          //         Icons.info_outline,
          //         color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
          //         size: 20,
          //       ),
          //       const SizedBox(width: 8),
          //       Expanded(
          //         child: Text(
          //           'قم بإنشاء حجز وانتظر التأكيد للوصول إلى الإشعارات',
          //           style: TextStyle(
          //             fontSize: 13,
          //             color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'موافق',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ),
        // ElevatedButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //     _changeTab(1); // Navigate to Create Reservation tab
        //   },
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: AppColors.primary,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(20),
        //     ),
        //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        //   ),
        //   child: const Text('إنشاء حجز'),
        // ),
      ],
    ),
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
  
  // Check if data needs refresh
  final needsRefresh = _shouldRefreshTab(index);
  
  if (needsRefresh) {
    _refreshCurrentTabInBackground(index);
  }
  
  // Reset hide timer when navigating
  _startHideTimer();
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
          // Main content with bottom padding to avoid overlap with nav bar
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: _isBottomNavVisible ? 70 : 0, // Add padding when nav is visible
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
          
          // Animated Bottom Navigation Bar - ALWAYS above system navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _navSlideAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  navigationBar(isDark),
                  // This ensures it sits above the system nav bar
                  Container(
                    height: MediaQuery.of(context).padding.bottom,
                    color: isDark 
                        ? const Color.fromARGB(173, 52, 52, 52) 
                        : const Color.fromARGB(180, 212, 212, 212),
                  ),
                ],
              ),
            ),
          ), 
          
          // Floating Show Button (appears when nav is hidden)
          if (!_isBottomNavVisible)
            Positioned(
              bottom: 30 + MediaQuery.of(context).padding.bottom,
              right: 16,
              child: _buildShowNavButton(isDark),
            ),
        ],
      ),
    ),
  );
}

// Updated navigationBar to handle tap events that reset timer
AnimatedContainer navigationBar(bool isDark) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 360;
  final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
  
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
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
        child: GestureDetector(
          onTap: _startHideTimer, // Reset timer on any tap
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 5;
              
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

   // ADD THIS NEW METHOD FOR THE SHOW BUTTON:
  Widget _buildShowNavButton(bool isDark) {
    return GestureDetector(
      onTap: _showBottomNav,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // border: Border.all(color: AppColors.primary.withOpacity(0.9)),
          gradient: LinearGradient(
            colors: [
              isDark ? Color.fromARGB(204, 46, 125, 50) : const Color.fromARGB(188, 34, 123, 38),
              isDark ? Color.fromARGB(196, 46, 125, 50) : const Color.fromARGB(166, 25, 120, 30),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(35),
          // boxShadow: [
          //   BoxShadow(
          //     color: AppColors.primary.withOpacity(0.4),
          //     blurRadius: 12,
          //     offset: const Offset(0, 3),
          //   ),
          // ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu,
              color: isDark ? Colors.white : Colors.white,
              size: 20,
            ),
            // const SizedBox(width: 8),
            // Text(
            //   'القائمة',
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 14,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
          ],
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



  // UPDATE _buildNavItem to reset timer on tap:
  Widget _buildNavItem(IconData icon, String label, int index, bool isDark, double itemWidth) {
    final isSelected = _currentIndex == index && _externalScreen == null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    
    var notchHeight = isSelected ? (isSmallScreen ? 50.0 : 60.0) : 0.0;
    var notchWidth = isSelected ? (isSmallScreen ? 45.0 : 50.0) : 0.0;
    
    final selectedIconSize = isSmallScreen ? 24.0 : 28.0;
    final unselectedIconSize = isSmallScreen ? 20.0 : 24.0;
    
    final fontSize = isSmallScreen ? 9.0 : (isMediumScreen ? 10.0 : 11.0);
    
    final constrainedWidth = itemWidth.clamp(50.0, 80.0);
    
    return GestureDetector(
      onTap: () {
        // Reset timer immediately on tap
        _startHideTimer();
        _changeTab(index);
      },
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
// In _buildSpotifyAppBar, replace the notification IconButton with:
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
      // Only show badge if user has valid reservation and unread notifications
      if (_hasValidReservation && _unreadNotificationCount > 0)
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
  onPressed: () => _navigateToNotifications(),
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
              Container(
                width: double.infinity, // Add this to make it full width

                padding: const EdgeInsets.all(10),
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

  // void _showAboutApp() {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;


  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('حول التطبيق'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               'تطبيق حجوزات الأعراس الخاص بجميع العشائر ',
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 8),
  //             const Text('الإصدار: 1.0.7'),
  //             const SizedBox(height: 16),
  //             const Text(
  //               'يسرّنا أن نرحب بكم في تطبيق الأعراس،\nونضع بين أيديكم وسيلة ميسرة لتنظيم و حجز العرس الخاص بكم',
  //             ),
  //             const SizedBox(height: 16),
  //             const Divider(),
  //             const SizedBox(height: 8),
  //             const Text(
  //               'برعاية:',
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 4),
  //             const Text('عشيرة آت الشيخ الحاج مسعود'),
  //             const SizedBox(height: 16),
  //             const Divider(),
  //             const SizedBox(height: 8),
  //             const Text(
  //               'معلومات عن المطورين:',
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 8),
  //             Row(
  //               children: [
  //                 const Icon(Icons.email, size: 18),
  //                 const SizedBox(width: 8),
  //                 const Expanded(
  //                   child: Text('iTriDev.Soft@gmail.com'),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 8),
  //             Row(
  //               children: [
  //                 const Icon(Icons.phone, size: 18),
  //                 const SizedBox(width: 8),
  //                 const Text('0658890501'),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //             Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: isDark ?Colors.green.shade300 : Colors.green.shade50,
  //                 borderRadius: BorderRadius.circular(8),
  //                 border: Border.all(color: isDark ?Colors.green.shade500 : Colors.green.shade200),
  //               ),
  //               child: Row(
  //                 children: [
  //                   Icon(Icons.message, color: Colors.green.shade700, size: 20),
  //                   const SizedBox(width: 8),
  //                   Expanded(
  //                     child: Text(
  //                       '   لأي ملاحظات أو استفسارات عن التطبيق،  \n  عبر البريد الإلكتروني iTriDev.Soft@gmail.com '     ,
  //                       style: TextStyle(fontSize: 13, color: isDark ?AppColors.darkTextPrimary : AppColors.darkBorder),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('موافق'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _showHelpSupport() {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('لدعم والمساعدة'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
              
  //             // const Text(
  //             //   'معلومات المطور:',
  //             //   style: TextStyle(fontWeight: FontWeight.bold),
  //             // ),
  //             // const SizedBox(height: 8),
  //             Row(
  //               children: [
  //                 const Icon(Icons.email, size: 18),
  //                 const SizedBox(width: 8),
  //                 const Expanded(
  //                   child: Text('iTriDev.Soft@gmail.com'),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 8),
  //             Row(
  //               children: [
  //                 const Icon(Icons.phone, size: 18),
  //                 const SizedBox(width: 8),
  //                 const Text('0658890501'),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //             Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: isDark ?Colors.green.shade300 : Colors.green.shade50,
  //                 borderRadius: BorderRadius.circular(8),
  //                 border: Border.all(color: isDark ?Colors.green.shade500 : Colors.green.shade200),
  //               ),
  //               child: Row(
  //                 children: [
  //                   Icon(Icons.message, color: Colors.green.shade700, size: 20),
  //                   const SizedBox(width: 8),
  //                   Expanded(
  //                     child: Text(
  //                       '   لأي ملاحظات أو استفسارات عن التطبيق،  \n  عبر البريد الإلكتروني iTriDev.Soft@gmail.com '     ,
  //                       style: TextStyle(fontSize: 13, color: isDark ?AppColors.darkTextPrimary : AppColors.darkBorder),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('موافق'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  
// Helper functions
Future<void> _launchWhatsApp() async {
  final Uri whatsappUri = Uri.parse('https://wa.me/213542951750');
  if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch WhatsApp');
  }
}

Future<void> _launchEmail() async {
  final Uri emailUri = Uri.parse('mailto:itridev.soft@gmail.com');
  if (!await launchUrl(emailUri)) {
    throw Exception('Could not launch email');
  }
}

Future<void> _launchPhone() async {
  final Uri phoneUri = Uri.parse('tel:+213542951750');
  if (!await launchUrl(phoneUri)) {
    throw Exception('Could not launch phone');
  }
}
void _showAboutApp() {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.info, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('حول التطبيق', style: TextStyle(fontSize: 20)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تطبيق حجوزات الأعراس الخاص بجميع العشائر',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('الإصدار: 1.0.5', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 16),
            Text(
              'يسرّنا أن نرحب بكم في تطبيق الأعراس، ونضع بين أيديكم وسيلة ميسرة لتنظيم وحجز العرس الخاص بكم',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'برعاية:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'عشيرة آت الشيخ الحاج مسعود',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'فريق التطوير',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            
            // Email Button
            InkWell(
              onTap: _launchEmail,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.email, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'itridev.soft@gmail.com',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // WhatsApp Button
            InkWell(
              onTap: _launchWhatsApp,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.green[900]?.withOpacity(0.3) : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.phone, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'واتساب',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '0542951750',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.green),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.green[900]?.withOpacity(0.2) : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.green[700]! : Colors.green[200]!,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'لأي استفسارات أو ملاحظات، نسعد بتواصلكم معنا',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.green[100] : Colors.green[900],
                        height: 1.4,
                      ),
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
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('إغلاق', style: TextStyle(fontSize: 15)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.support_agent, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('الدعم والمساعدة', style: TextStyle(fontSize: 20)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نحن هنا لمساعدتك! تواصل معنا عبر:',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            
            // Email Button
            InkWell(
              onTap: _launchEmail,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.email_outlined, size: 24, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'البريد الإلكتروني',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'itridev.soft@gmail.com',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // WhatsApp Button
            InkWell(
              onTap: _launchWhatsApp,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? Colors.green[900]!.withOpacity(0.4) : Colors.green[50]!,
                      isDark ? Colors.green[800]!.withOpacity(0.3) : Colors.green[100]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.chat, size: 24, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'واتساب',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '0542951750',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Help Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.orange[900]?.withOpacity(0.2) : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.schedule, color: Colors.orange[700], size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'نستجيب لاستفساراتكم في أقرب وقت ممكن',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.orange[100] : Colors.orange[900],
                        height: 1.4,
                      ),
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
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('إغلاق', style: TextStyle(fontSize: 15)),
        ),
      ],
    ),
  );
}

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
      onTap: () {
        Navigator.pop(context); // Close drawer
        _changeTab(index); // Navigate to tab
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
  String _selectedFilter = 'today'; // all, today, week, month

  @override
void initState() {
  super.initState();
  _loadNotifications();
  
  // Mark all as read after a short delay to let the UI load
  Future.delayed(const Duration(milliseconds: 500), () {
    _markAllAsReadOnOpen();
  });
}

/// Mark all notifications as read with loading indicator
Future<void> _markAllAsReadOnOpen() async {
  try {
    await ApiService.markAllNotificationsAsRead();
    
    if (mounted) {
      // Refresh the list to update UI
      await _loadNotifications();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تعليم جميع الإشعارات كمقروءة'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    print('✅ All notifications marked as read');
  } catch (e) {
    print('⚠️ Failed to mark all as read: $e');
  }
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
  _applyFilter();
  
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
  // Remove isUnread check since all are marked as read on open
  final isUnread = false; // Always false now
  
  return GestureDetector(
    onTap: () {
      // Just show details, no need to mark as read
      _showNotificationDetailsDialog(notification, isDark);
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
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
              // Removed unread indicator since all are read
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