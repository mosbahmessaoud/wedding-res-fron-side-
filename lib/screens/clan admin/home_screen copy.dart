// // lib/screens/home/clan_admin_home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/HallsTab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/clan_settings_tab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/food_menu_tab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/grooms_tab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/reservations_tab.dart';
// import 'admin_otp_screen.dart'; // Add this import
// import '../../utils/colors.dart';
// import '../../utils/constants.dart';
// import '../../services/api_service.dart';

// class ClanAdminHomeScreen extends StatefulWidget {
//   const ClanAdminHomeScreen({super.key});

//   @override
//   _ClanAdminHomeScreenState createState() => _ClanAdminHomeScreenState();
// }

// class _ClanAdminHomeScreenState extends State<ClanAdminHomeScreen>
//     with TickerProviderStateMixin {
//   int _currentIndex = 0;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late AnimationController _refreshAnimationController;
//   late Animation<double> _refreshAnimation;
//   int _lastTabIndex = 0;

//   final GlobalKey<HallsTabState> _hallsTabKey = GlobalKey<HallsTabState>();
//   final GlobalKey<GroomManagementScreenState> _groomsTabKey = GlobalKey<GroomManagementScreenState>();
//   final GlobalKey<ReservationsTabState> _reservationsTabKey = GlobalKey<ReservationsTabState>();
//   final GlobalKey<FoodTabState> _foodTabKey = GlobalKey<FoodTabState>();
//   final GlobalKey<SettingsTabState> _settingsTabKey = GlobalKey<SettingsTabState>();
//   final GlobalKey<AdminOTPScreenState> _otpTabKey = GlobalKey<AdminOTPScreenState>();

//   // Dynamic data variables
//   bool _isLoading = false;
//   Map<String, dynamic> _dashboardData = {
//     'halls_count': 0,
//     'reservations_count': 0,
//     'grooms_count': 0,
//     'menus_count': 0,
//     'pending_reservations': 0,
//     'validated_reservations': 0,
//     'cancelled_reservations': 0,
//   };
//   List<dynamic> _recentActivities = [];
//   String _adminName = 'مدير العشيرة';

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 1200),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );

//     _refreshAnimationController = AnimationController(
//       duration: Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _refreshAnimationController, curve: Curves.elasticOut),
//     );

//     _animationController.forward();
//     _loadDashboardData();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _refreshAnimationController.dispose();
//     super.dispose();
//   }
// @override
// void didUpdateWidget(ClanAdminHomeScreen oldWidget) {
//   super.didUpdateWidget(oldWidget);
//   // This would be called when the widget updates
// }


//  // Replace the existing _navigateToTab method with this updated version:
//   void _navigateToTab(int index) {
//     // Only proceed if we're actually changing tabs
//     if (_lastTabIndex != index) {
//       setState(() {
//         _currentIndex = index;
//       });
      
//       // Refresh the target tab when switching
//       _refreshCurrentTab(index);
      
//       _lastTabIndex = index;
//     } else {
//       // Same tab selected, just update current index without refresh
//       setState(() {
//         _currentIndex = index;
//       });
//     }
//   }
// // Add this new method for refreshing specific tabs:
//   void _refreshCurrentTab(int index) {
//     switch (index) {
//       case 0:
//         // Home tab - refresh dashboard data
//         _loadDashboardData();
//         break;
//       case 1:
//         // Halls tab
//         _hallsTabKey.currentState?.refreshData();
//         break;
//       case 2:
//         // Grooms tab
//         _groomsTabKey.currentState?.refreshData();
//         break;
//       case 3:
//         // Reservations tab
//         _reservationsTabKey.currentState?.refreshData();
//         break;
//       case 4:
//         // Food tab
//         _foodTabKey.currentState?.refreshData();
//         break;
//       case 5:
//         // Settings tab
//         _settingsTabKey.currentState?.refreshData();
//         break;
//       case 6:
//         // OTP tab
//         _otpTabKey.currentState?.refreshData();
//         break;
//       case 7:
//         // Profile tab doesn't need refresh typically
//         break;
//     }
//   }

//    // Remove or replace the old _notifyTabRefresh method at the bottom of the file with:
//   void _notifyTabRefresh(int tabIndex) {
//     _refreshCurrentTab(tabIndex);
//   }

//   Future<void> _loadDashboardData() async {
//     if (!mounted) return;
    
//     setState(() => _isLoading = true);

//     try {
//       // Load data concurrently for better performance
//       final futures = await Future.wait([
//         ApiService.listHalls().catchError((_) => <dynamic>[]),
//         ApiService.listGrooms().catchError((_) => <dynamic>[]),
//         ApiService.getClanMenus().catchError((_) => <dynamic>[]),
//         ApiService.getAllReservations().catchError((_) => <dynamic>[]),
//         ApiService.getPendingReservations().catchError((_) => <dynamic>[]),
//         ApiService.getValidatedReservations().catchError((_) => <dynamic>[]),
//         ApiService.getCancelledReservations().catchError((_) => <dynamic>[]),
//         ApiService.getCurrentUserInfo().catchError((_) => <String, dynamic>{}),
//       ]);

//       if (!mounted) return;

//       final halls = futures[0] as List<dynamic>;
//       final grooms = futures[1] as List<dynamic>;
//       final menus = futures[2] as List<dynamic>;
//       final allReservations = futures[3] as List<dynamic>;
//       final pendingReservations = futures[4] as List<dynamic>;
//       final validatedReservations = futures[5] as List<dynamic>;
//       final cancelledReservations = futures[6] as List<dynamic>;
//       final userInfo = futures[7] as Map<String, dynamic>;

//       // Create recent activities from the latest data
//       _recentActivities = _generateRecentActivities(
//         halls, grooms, menus, allReservations
//       );

//       setState(() {
//         _dashboardData = {
//           'halls_count': halls.length,
//           'reservations_count': allReservations.length,
//           'grooms_count': grooms.length,
//           'menus_count': menus.length,
//           'pending_reservations': pendingReservations.length,
//           'validated_reservations': validatedReservations.length,
//           'cancelled_reservations': cancelledReservations.length,
//         };
        
//         _adminName = _extractAdminName(userInfo);
//         _isLoading = false;
//       });

//       _refreshAnimationController.forward().then((_) {
//         _refreshAnimationController.reverse();
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//       print('Error loading dashboard data: $e');
//     }
//   }
//   // Update the existing refreshData method to be more specific:
//   void refreshData() {
//     _loadDashboardData();
//     setState(() {
//       // Trigger rebuild for home tab specifically
//     });
//   }
//   String _extractAdminName(Map<String, dynamic> userInfo) {
//     if (userInfo.isEmpty) return 'مدير العشيرة';
    
//     final firstName = userInfo['first_name'] ?? '';
//     final lastName = userInfo['last_name'] ?? '';
    
//     if (firstName.isNotEmpty && lastName.isNotEmpty) {
//       return '$firstName $lastName';
//     } else if (firstName.isNotEmpty) {
//       return firstName;
//     } else {
//       return 'مدير العشيرة';
//     }
//   }

//   List<Map<String, dynamic>> _generateRecentActivities(
//     List<dynamic> halls,
//     List<dynamic> grooms,
//     List<dynamic> menus,
//     List<dynamic> reservations,
//   ) {
//     List<Map<String, dynamic>> activities = [];

//     // Add recent reservations
//     if (reservations.isNotEmpty) {
//       final recentReservations = reservations.take(2).toList();
//       for (var reservation in recentReservations) {
//         activities.add({
//           'icon': Icons.book_outlined,
//           'title': 'حجز جديد',
//           'subtitle': '${reservation['guardian_name'] ?? 'غير محدد'} - ${_formatTimeAgo(reservation['created_at'])}',
//           'color': Colors.orange,
//         });
//       }
//     }

//     // Add recent grooms
//     if (grooms.isNotEmpty) {
//       final recentGrooms = grooms.take(1).toList();
//       for (var groom in recentGrooms) {
//         activities.add({
//           'icon': Icons.person_add_outlined,
//           'title': 'عريس جديد',
//           'subtitle': '${groom['first_name'] ?? ''} ${groom['last_name'] ?? ''} - ${_formatTimeAgo(groom['created_at'])}',
//           'color': Colors.blue,
//         });
//       }
//     }

//     // Add recent menus
//     if (menus.isNotEmpty) {
//       final recentMenu = menus.first;
//       activities.add({
//         'icon': Icons.restaurant_menu,
//         'title': 'قائمة طعام محدثة',
//         'subtitle': '${recentMenu['name'] ?? 'قائمة جديدة'} - ${_formatTimeAgo(recentMenu['created_at'])}',
//         'color': Colors.purple,
//       });
//     }

//     // Add halls info
//     if (halls.isNotEmpty) {
//       activities.add({
//         'icon': Icons.add_circle_outline,
//         'title': 'إجمالي القاعات',
//         'subtitle': 'يتم إدارة ${halls.length} قاعة حالياً',
//         'color': Colors.green,
//       });
//     }

//     return activities.take(4).toList();
//   }

//   String _formatTimeAgo(dynamic createdAt) {
//     if (createdAt == null) return 'منذ وقت قريب';
    
//     try {
//       final date = DateTime.parse(createdAt.toString());
//       final now = DateTime.now();
//       final difference = now.difference(date);

//       if (difference.inDays > 0) {
//         return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
//       } else if (difference.inHours > 0) {
//         return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
//       } else if (difference.inMinutes > 0) {
//         return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
//       } else {
//         return 'منذ لحظات';
//       }
//     } catch (e) {
//       return 'منذ وقت قريب';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isTablet = screenSize.width > 768;
//     final isMobile = screenSize.width <= 480;

//     return Scaffold(
//       backgroundColor: Color(0xFFF8FAFC),
//       body: IndexedStack(
//           index: _currentIndex,
//           children: [
//             _buildHomeTab(screenSize, isTablet, isMobile),
//             HallsTab(key: _hallsTabKey),
//             GroomManagementScreen(key: _groomsTabKey),
//             ReservationsTab(key: _reservationsTabKey),
//             FoodTab(key: _foodTabKey),
//             SettingsTab(key: _settingsTabKey),
//             AdminOTPScreen(key: _otpTabKey),
//             _buildProfileTab(),
//           ],
//         ),
//       bottomNavigationBar: _buildModernBottomNav(isMobile),
//     );
//   }

//   Widget _buildHomeTab(Size screenSize, bool isTablet, bool isMobile) {
//     return RefreshIndicator(
//       onRefresh: _loadDashboardData,
//       color: AppColors.primary,
//       backgroundColor: Colors.white,
//       displacement: 20,
//       child: CustomScrollView(
//         physics: AlwaysScrollableScrollPhysics(),
//         slivers: [
//           _buildSliverAppBar(isMobile),
//           SliverToBoxAdapter(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isMobile ? 16 : (isTablet ? 32 : 20),
//                   vertical: 20,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildWelcomeCard(isMobile, isTablet),
//                     SizedBox(height: isMobile ? 24 : 32),
//                     _buildStatsCards(isMobile, isTablet),
//                     SizedBox(height: isMobile ? 24 : 32),
//                     _buildQuickActions(isMobile, isTablet),
//                     SizedBox(height: isMobile ? 24 : 32),
//                     _buildRecentActivity(isMobile, isTablet),
//                     SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Show confirmation dialog for sign out
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تسجيل الخروج'),
//         content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               ApiService.clearToken();
//               Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//             child: const Text('تسجيل الخروج'),
//           ),
//         ],
//       ),
//     );
//   }

// Widget _buildSliverAppBar(bool isMobile) {
//     return SliverAppBar(
//       expandedHeight: isMobile ? 100 : 120,
//       floating: false,
//       pinned: true,
//       backgroundColor: Colors.white,
//       elevation: 0,
//       automaticallyImplyLeading: false, // Remove automatic back button
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 AppColors.primary,
//                 AppColors.primary.withOpacity(0.8),
//                 Colors.deepPurple.withOpacity(0.9),
//               ],
//             ),
//           ),
//         ),
//       ),
//       title: Text(
//         AppConstants.appName,
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w700,
//           fontSize: isMobile ? 16 : 20,
//         ),
//       ),
//       actions: [
//         if (_isLoading)
//           Container(
//             margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             width: 20,
//             height: 20,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//             ),
//           ),
//         // Removed the logout button from here - it was being used as back button incorrectly
//         Container(
//           margin: EdgeInsets.only(right: isMobile ? 4 : 8),
//           child: Stack(
//             children: [
//               IconButton(
//                 icon: Icon(Icons.notifications_outlined, 
//                   color: Colors.white, 
//                   size: isMobile ? 20 : 24),
//                 onPressed: () {
//                   // TODO: Navigate to notifications
//                 },
//               ),
//               Positioned(
//                 right: isMobile ? 6 : 8,
//                 top: isMobile ? 6 : 8,
//                 child: AnimatedBuilder(
//                   animation: _refreshAnimation,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   builder: (context, child) {
//                     return Transform.scale(
//                       scale: 1.0 + (_refreshAnimation.value * 0.3),
//                       child: child,
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // Profile menu with logout option
//         PopupMenuButton<String>(
//           icon: CircleAvatar(
//             radius: isMobile ? 16 : 18,
//             backgroundColor: Colors.white.withOpacity(0.2),
//             child: Icon(Icons.person, 
//               color: Colors.white, 
//               size: isMobile ? 18 : 20),
//           ),
//           onSelected: (String value) {
//             if (value == 'logout') {
//               _showLogoutDialog();
//             } else if (value == 'profile') {
//               _navigateToTab(7); // Navigate to profile tab
//             }
//           },
//           itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//             PopupMenuItem<String>(
//               value: 'profile',
//               child: Row(
//                 children: [
//                   Icon(Icons.person_outline, color: AppColors.primary),
//                   SizedBox(width: 8),
//                   Text('الملف الشخصي'),
//                 ],
//               ),
//             ),
//             PopupMenuDivider(),
//             PopupMenuItem<String>(
//               value: 'logout',
//               child: Row(
//                 children: [
//                   Icon(Icons.logout, color: Colors.red),
//                   SizedBox(width: 8),
//                   Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
//                 ],
//               ),
//             ),
//           ],
//           color: Colors.white,
//           elevation: 8,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       ],
//     );
//   }
//   Widget _buildWelcomeCard(bool isMobile, bool isTablet) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(isMobile ? 20 : 24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primary,
//             AppColors.primary.withOpacity(0.7),
//             Colors.purple.withOpacity(0.8),
//             Colors.deepPurple.withOpacity(0.9),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             spreadRadius: 0,
//             blurRadius: 20,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'مرحباً $_adminName',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: isMobile ? 22 : (isTablet ? 32 : 28),
//                         fontWeight: FontWeight.w800,
//                         height: 1.2,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'لوحة تحكم شاملة لإدارة القصور والعشائر',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: isMobile ? 14 : 16,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     if (isTablet) ...[
//                       SizedBox(height: 16),
//                       Row(
//                         children: [
//                           _buildMiniStatCard('الحجوزات', _dashboardData['reservations_count'].toString()),
//                           SizedBox(width: 16),
//                           _buildMiniStatCard('العرسان', _dashboardData['grooms_count'].toString()),
//                         ],
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.all(isMobile ? 12 : 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
//                 ),
//                 child: Icon(
//                   Icons.dashboard_outlined,
//                   color: Colors.white,
//                   size: isMobile ? 24 : 32,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMiniStatCard(String label, String value) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             value,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.8),
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsCards(bool isMobile, bool isTablet) {
//     final stats = [
//       {
//         'title': 'القاعات',
//         'value': _dashboardData['halls_count'].toString(),
//         'icon': Icons.castle_outlined,
//         'color': Colors.blue,
//         'trend': '+2.5%'
//       },
//       {
//         'title': 'الحجوزات',
//         'value': _dashboardData['reservations_count'].toString(),
//         'icon': Icons.book_outlined,
//         'color': Colors.green,
//         'trend': '+12.3%'
//       },
//       {
//         'title': 'العرسان',
//         'value': _dashboardData['grooms_count'].toString(),
//         'icon': Icons.group_outlined,
//         'color': Colors.orange,
//         'trend': '+8.1%'
//       },
//       if (!isMobile) {
//         'title': 'القوائم',
//         'value': _dashboardData['menus_count'].toString(),
//         'icon': Icons.restaurant_menu,
//         'color': Colors.purple,
//         'trend': '+5.7%'
//       },
//     ];

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final crossAxisCount = isMobile ? 2 : (isTablet ? 4 : 3);
//         final childAspectRatio = isMobile ? 1.3 : (isTablet ? 1.5 : 1.4);
        
//         return GridView.builder(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: crossAxisCount,
//             mainAxisSpacing: isMobile ? 12 : 16,
//             crossAxisSpacing: isMobile ? 12 : 16,
//             childAspectRatio: childAspectRatio,
//           ),
//           itemCount: stats.length,
//           itemBuilder: (context, index) {
//             final stat = stats[index] as Map<String, dynamic>;
//             return _buildStatCard(
//               stat['title'],
//               stat['value'],
//               stat['icon'],
//               stat['color'],
//               stat['trend'],
//               isMobile,
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildStatCard(String title, String value, IconData icon, Color color, 
//                        String trend, bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 16 : 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             spreadRadius: 0,
//             blurRadius: 12,
//             offset: Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.withOpacity(0.1)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(isMobile ? 8 : 10),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
//                 ),
//                 child: Icon(icon, color: color, size: isMobile ? 18 : 22),
//               ),
//               if (!isMobile)
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     trend,
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: Colors.green.shade700,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           SizedBox(height: isMobile ? 12 : 16),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: isMobile ? 20 : 26,
//               fontWeight: FontWeight.w800,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: isMobile ? 11 : 13,
//               color: AppColors.textSecondary,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActions(bool isMobile, bool isTablet) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'الإجراءات السريعة',
//           style: TextStyle(
//             fontSize: isMobile ? 20 : (isTablet ? 28 : 24),
//             fontWeight: FontWeight.w700,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         SizedBox(height: isMobile ? 16 : 20),
//         GridView.count(
//           crossAxisCount: isMobile ? 2 : (isTablet ? 4 : 2),
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           mainAxisSpacing: isMobile ? 12 : 16,
//           crossAxisSpacing: isMobile ? 12 : 16,
//           childAspectRatio: isMobile ? 1.0 : (isTablet ? 1.1 : 1.1),
//           children: [
//             _buildModernActionCard(
//               icon: Icons.castle_outlined,
//               title: 'القاعات',
//               subtitle: 'إدارة ${_dashboardData['halls_count']} قاعة',
//               gradient: [Colors.blue.shade400, Colors.blue.shade600],
//               onTap: () => _navigateToTab(1),
//               isMobile: isMobile,
//             ),
//             _buildModernActionCard(
//               icon: Icons.group_outlined,
//               title: 'العرسان',
//               subtitle: '${_dashboardData['grooms_count']} عريس مسجل',
//               gradient: [Colors.green.shade400, Colors.green.shade600],
//               onTap: () => _navigateToTab(2),
//               isMobile: isMobile,
//             ),
//             _buildModernActionCard(
//               icon: Icons.book_outlined,
//               title: 'الحجوزات',
//               subtitle: '${_dashboardData['pending_reservations']} معلق',
//               gradient: [Colors.purple.shade400, Colors.purple.shade600],
//               onTap: () => _navigateToTab(3),
//               isMobile: isMobile,
//             ),
//             _buildModernActionCard(
//               icon: Icons.restaurant_outlined,
//               title: 'قوائم الطعام',
//               subtitle: '${_dashboardData['menus_count']} قائمة متاحة',
//               gradient: [Colors.orange.shade400, Colors.orange.shade600],
//               onTap: () => _navigateToTab(4),
//               isMobile: isMobile,
//             ),
//             // Add OTP action card
//             _buildModernActionCard(
//               icon: Icons.lock_outline,
//               title: 'رموز التحقق',
//               subtitle: 'البحث عن رموز المستخدمين',
//               gradient: [Colors.red.shade400, Colors.red.shade600],
//               onTap: () => _navigateToTab(6), // Navigate to OTP screen (index 6)
//               isMobile: isMobile,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildModernActionCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required List<Color> gradient,
//     required VoidCallback onTap,
//     required bool isMobile,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: gradient,
//           ),
//           borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//           boxShadow: [
//             BoxShadow(
//               color: gradient[0].withOpacity(0.3),
//               spreadRadius: 0,
//               blurRadius: 15,
//               offset: Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Container(
//           padding: EdgeInsets.all(isMobile ? 16 : 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(isMobile ? 10 : 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: Colors.white,
//                   size: isMobile ? 24 : 28,
//                 ),
//               ),
//               Spacer(),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: isMobile ? 16 : 18,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   fontSize: isMobile ? 11 : 12,
//                   color: Colors.white.withOpacity(0.8),
//                   fontWeight: FontWeight.w400,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentActivity(bool isMobile, bool isTablet) {
//     if (_recentActivities.isEmpty && !_isLoading) {
//       return SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'النشاط الأخير',
//           style: TextStyle(
//             fontSize: isMobile ? 20 : (isTablet ? 28 : 24),
//             fontWeight: FontWeight.w700,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         SizedBox(height: isMobile ? 16 : 20),
//         Container(
//           padding: EdgeInsets.all(isMobile ? 16 : 20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.04),
//                 spreadRadius: 0,
//                 blurRadius: 12,
//                 offset: Offset(0, 4),
//               ),
//             ],
//             border: Border.all(color: Colors.grey.withOpacity(0.1)),
//           ),
//           child: _isLoading
//               ? Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(20),
//                     child: CircularProgressIndicator(color: AppColors.primary),
//                   ),
//                 )
//               : _recentActivities.isEmpty
//                   ? Center(
//                       child: Padding(
//                         padding: EdgeInsets.all(20),
//                         child: Text(
//                           'لا توجد أنشطة حديثة',
//                           style: TextStyle(
//                             color: AppColors.textSecondary,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     )
//                   : Column(
//                       children: _recentActivities.map<Widget>((activity) {
//                         final index = _recentActivities.indexOf(activity);
//                         return Column(
//                           children: [
//                             _buildActivityItem(
//                               icon: activity['icon'],
//                               title: activity['title'],
//                               subtitle: activity['subtitle'],
//                               color: activity['color'],
//                               isMobile: isMobile,
//                             ),
//                             if (index < _recentActivities.length - 1)
//                               Divider(height: isMobile ? 20 : 24, color: Colors.grey.shade200),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActivityItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required bool isMobile,
//   }) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(isMobile ? 8 : 10),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
//           ),
//           child: Icon(icon, color: color, size: isMobile ? 18 : 20),
//         ),
//         SizedBox(width: isMobile ? 12 : 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: isMobile ? 13 : 14,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               SizedBox(height: 2),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   fontSize: isMobile ? 11 : 12,
//                   color: AppColors.textSecondary,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//         Icon(
//           Icons.chevron_right,
//           color: AppColors.textSecondary,
//           size: isMobile ? 16 : 18,
//         ),
//       ],
//     );
//   }

//   Widget _buildModernBottomNav(bool isMobile) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             spreadRadius: 0,
//             blurRadius: 20,
//             offset: Offset(0, -5),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(isMobile ? 16 : 20),
//           topRight: Radius.circular(isMobile ? 16 : 20),
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: _navigateToTab,
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.white,
//           selectedItemColor: AppColors.primary,
//           unselectedItemColor: AppColors.textSecondary,
//           elevation: 0,
//           selectedLabelStyle: TextStyle(
//             fontWeight: FontWeight.w600, 
//             fontSize: isMobile ? 9 : 10,
//           ),
//           unselectedLabelStyle: TextStyle(fontSize: isMobile ? 9 : 10),
//           iconSize: isMobile ? 20 : 24,
//           items: [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined),
//               activeIcon: Container(
//                 padding: EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.home, color: AppColors.primary),
//               ),
//               label: 'الرئيسية',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.castle_outlined),
//               activeIcon: Container(
//                 padding: EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.castle, color: AppColors.primary),
//               ),
//               label: 'القاعات',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.group_outlined),
//               activeIcon: Container(
//                 padding: EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.group, color: AppColors.primary),
//               ),
//               label: 'العرسان',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.book_outlined),
//               activeIcon: Container(
//                 padding: EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.book, color: AppColors.primary),
//               ),
//               label: 'الحجوزات',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.restaurant_menu_outlined),
//               activeIcon: Container(
//                 padding: EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.restaurant_menu, color: AppColors.primary),
//               ),
//               label: 'قوائم الطعام',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.settings_outlined),
//               activeIcon: Container(
//                 padding: EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.settings, color: AppColors.primary),
//               ),
//               label: 'الإعدادات',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.lock_outline),
//               activeIcon: Container(
//                 padding: EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.lock, color: AppColors.primary),
//               ),
//               label: 'رموز التحقق',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               activeIcon: Container(
//                 padding: EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.person, color: AppColors.primary),
//               ),
//               label: 'الملف الشخصي',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileTab() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   AppColors.primary.withOpacity(0.1),
//                   AppColors.primary.withOpacity(0.05),
//                 ],
//               ),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: AppColors.primary.withOpacity(0.2),
//                 width: 2,
//               ),
//             ),
//             child: Icon(
//               Icons.person_outline,
//               size: 48,
//               color: AppColors.primary,
//             ),
//           ),
//           SizedBox(height: 32),
//           Text(
//             'قريباً...',
//             style: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.w700,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           SizedBox(height: 12),
//           Text(
//             'صفحة الملف الشخصي قيد التطوير',
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 40),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(25),
//               border: Border.all(
//                 color: AppColors.primary.withOpacity(0.2),
//               ),
//             ),
//             child: Text(
//               'سيتم إضافة المزيد من الميزات قريباً',
//               style: TextStyle(
//                 color: AppColors.primary,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }


// }

// // Add this class for the FoodMenu model if it doesn't exist
// class FoodMenu {
//   final int id;
//   final String name;
//   final String? description;
//   final String foodType;
//   final int visitors;
//   final double price;
//   final int clanId;
//   final String? createdAt;

//   FoodMenu({
//     required this.id,
//     required this.name,
//     this.description,
//     required this.foodType,
//     required this.visitors,
//     required this.price,
//     required this.clanId,
//     this.createdAt,
//   });

//   factory FoodMenu.fromJson(Map<String, dynamic> json) {
//     return FoodMenu(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       description: json['description'],
//       foodType: json['food_type'] ?? '',
//       visitors: json['visitors'] ?? 0,
//       price: (json['price'] ?? 0).toDouble(),
//       clanId: json['clan_id'] ?? 0,
//       createdAt: json['created_at'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'food_type': foodType,
//       'visitors': visitors,
//       'price': price,
//       'clan_id': clanId,
//       'created_at': createdAt,
//     };
//   }
// }