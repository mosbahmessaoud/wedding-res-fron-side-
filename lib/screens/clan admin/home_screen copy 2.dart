// // lib/screens/home/clan_admin_home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/HallsTab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/clan_settings_tab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/food_menu_tab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/grooms_tab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/reservations_tab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/home_tab.dart'; // Import the new home tab
// import 'admin_otp_screen.dart';
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

//   // Tab keys for refreshing specific tabs
//   final GlobalKey<HomeTabState> _homeTabKey = GlobalKey<HomeTabState>(); // Add home tab key
//   final GlobalKey<HallsTabState> _hallsTabKey = GlobalKey<HallsTabState>();
//   final GlobalKey<GroomManagementScreenState> _groomsTabKey = GlobalKey<GroomManagementScreenState>();
//   final GlobalKey<ReservationsTabState> _reservationsTabKey = GlobalKey<ReservationsTabState>();
//   final GlobalKey<FoodTabState> _foodTabKey = GlobalKey<FoodTabState>();
//   final GlobalKey<SettingsTabState> _settingsTabKey = GlobalKey<SettingsTabState>();
//   final GlobalKey<AdminOTPScreenState> _otpTabKey = GlobalKey<AdminOTPScreenState>();

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
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _refreshAnimationController.dispose();
//     super.dispose();
//   }

//   @override
//   void didUpdateWidget(ClanAdminHomeScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // This would be called when the widget updates
//   }

//   // Navigation method with tab refresh logic
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

//   // Method for refreshing specific tabs
//   void _refreshCurrentTab(int index) {
//     switch (index) {
//       case 0:
//         // Home tab - refresh dashboard data
//         _homeTabKey.currentState?.refreshData();
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

//   void _notifyTabRefresh(int tabIndex) {
//     _refreshCurrentTab(tabIndex);
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

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isMobile = screenSize.width <= 480;

//     return Scaffold(
//       backgroundColor: Color(0xFFF8FAFC),
//       body: IndexedStack(
//         index: _currentIndex,
//         children: [
//           HomeTab(key: _homeTabKey, onNavigateToTab: _navigateToTab),
//           HallsTab(key: _hallsTabKey),
//           GroomManagementScreen(key: _groomsTabKey),
//           ReservationsTab(key: _reservationsTabKey),
//           FoodTab(key: _foodTabKey),
//           SettingsTab(key: _settingsTabKey),
//           AdminOTPScreen(key: _otpTabKey),
//           _buildProfileTab(),
//         ],
//       ),
//       // appBar: _buildSliverAppBar(isMobile),
//       bottomNavigationBar: _buildModernBottomNav(isMobile),
//     );
//   }

//   PreferredSizeWidget _buildSliverAppBar(bool isMobile) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       automaticallyImplyLeading: false, // Remove automatic back button
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               AppColors.primary,
//               AppColors.primary.withOpacity(0.8),
//               Colors.deepPurple.withOpacity(0.9),
//             ],
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