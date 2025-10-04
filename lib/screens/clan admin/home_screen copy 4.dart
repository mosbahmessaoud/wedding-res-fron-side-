// // lib/screens/home/clan_admin_home_screen.dart
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/HallsTab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/clan_settings_tab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/food_menu_tab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/grooms_tab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/reservations_tab.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/home_tab.dart';
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
//   final GlobalKey<HomeTabState> _homeTabKey = GlobalKey<HomeTabState>();
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
//   }

//   // Navigation method with tab refresh logic
//   void _navigateToTab(int index) {
//     if (_lastTabIndex != index) {
//       setState(() {
//         _currentIndex = index;
//       });
      
//       _refreshCurrentTab(index);
//       _lastTabIndex = index;
//     } else {
//       setState(() {
//         _currentIndex = index;
//       });
//     }
//   }

//   // Method for refreshing specific tabs
//   void _refreshCurrentTab(int index) {
//     switch (index) {
//       case 0:
//         _homeTabKey.currentState?.refreshData();
//         break;
//       case 1:
//         _hallsTabKey.currentState?.refreshData();
//         break;
//       case 2:
//         _groomsTabKey.currentState?.refreshData();
//         break;
//       case 3:
//         _reservationsTabKey.currentState?.refreshData();
//         break;
//       case 4:
//         _foodTabKey.currentState?.refreshData();
//         break;
//       case 5:
//         _settingsTabKey.currentState?.refreshData();
//         break;
//       case 6:
//         _otpTabKey.currentState?.refreshData();
//         break;
//       case 7:
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
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'تسجيل الخروج',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'إلغاء',
//               style: TextStyle(color: Colors.grey[700]),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               ApiService.clearToken();
//               Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//             ),
//             child: const Text('تسجيل الخروج'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isLargeScreen = screenSize.width > 1024;
//     final isMobile = screenSize.width <= 480;

//     return Scaffold(
//       backgroundColor: Color(0xFFF8FAFC),
//       body: Row(
//         children: [
//           // Right Side Navigation for Large Screens
//           if (isLargeScreen) _buildRightNavigation(),
          
//           // Main Content
//           Expanded(
//             child: Stack(
//               children: [
//                 // Main content - FULL SCREEN
//                 Positioned.fill(
//                   child: IndexedStack(
//                     index: _currentIndex,
//                     children: [
//                       HomeTab(key: _homeTabKey, onNavigateToTab: _navigateToTab),
//                       HallsTab(key: _hallsTabKey),
//                       GroomManagementScreen(key: _groomsTabKey),
//                       ReservationsTab(key: _reservationsTabKey),
//                       FoodTab(key: _foodTabKey),
//                       SettingsTab(key: _settingsTabKey),
//                       AdminOTPScreen(key: _otpTabKey),
//                       _buildProfileTab(),
//                     ],
//                   ),
//                 ),
                
//                 // Bottom Navigation Bar - Only for small/medium screens
//                 if (!isLargeScreen)
//                   Positioned(
//                     left: 0,
//                     right: 0,
//                     bottom: 0,
//                     child: _buildModernBottomNav(isMobile),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       // appBar: _buildAppBar(isMobile),
//     );
//   }

//   Widget _buildRightNavigation() {
//     return Container(
//       width: 280,
//       decoration: BoxDecoration(
//         color: const Color.fromARGB(47, 79, 79, 79),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 25,
//             offset: const Offset(4, 0),
//             spreadRadius: 5,
//           ),
//           BoxShadow(
//             color: const Color.fromARGB(255, 21, 219, 90).withOpacity(0.1),
//             blurRadius: 25,
//             offset: const Offset(4, 0),
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
//           child: SafeArea(
//             child: Column(
//               children: [
//                 // Logo/Header Section
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               AppColors.primary,
//                               AppColors.primary.withOpacity(0.7),
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppColors.primary.withOpacity(0.3),
//                               blurRadius: 20,
//                               offset: const Offset(0, 10),
//                             ),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.admin_panel_settings,
//                           color: Colors.white,
//                           size: 40,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'لوحة التحكم',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 const Divider(color: Colors.white24, height: 1),
                
//                 // Navigation Items
//                 Expanded(
//                   child: ListView(
//                     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//                     children: [
//                       _buildRightNavItem(Icons.home_rounded, 'الرئيسية', 0),
//                       _buildRightNavItem(Icons.castle_outlined, 'القاعات', 1),
//                       _buildRightNavItem(Icons.group_outlined, 'العرسان', 2),
//                       _buildRightNavItem(Icons.book_outlined, 'الحجوزات', 3),
//                       _buildRightNavItem(Icons.restaurant_menu_outlined, 'قوائم الطعام', 4),
//                       _buildRightNavItem(Icons.settings_outlined, 'الإعدادات', 5),
//                       _buildRightNavItem(Icons.lock_outline, 'رموز التحقق', 6),
//                       _buildRightNavItem(Icons.person_outline, 'الملف الشخصي', 7),
//                     ],
//                   ),
//                 ),
                
//                 // Footer Section
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       const Divider(color: Colors.white24, height: 1),
//                       const SizedBox(height: 16),
//                       _buildRightNavLogoutButton(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRightNavItem(IconData icon, String label, int index) {
//     final isSelected = _currentIndex == index;
    
//     return GestureDetector(
//       onTap: () => _navigateToTab(index),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOutCubic,
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           gradient: isSelected
//               ? const LinearGradient(
//                   colors: [
//                     Color.fromARGB(82, 98, 216, 139),
//                     Color.fromARGB(43, 2, 168, 110),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 )
//               : null,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? Colors.white : Colors.black.withOpacity(0.5),
//               size: 24,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                   color: isSelected ? Colors.white : Colors.black.withOpacity(0.6),
//                   letterSpacing: 0.2,
//                 ),
//               ),
//             ),
//             if (isSelected)
//               Container(
//                 width: 4,
//                 height: 4,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRightNavLogoutButton() {
//     return GestureDetector(
//       onTap: _showLogoutDialog,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: Colors.red.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: const Color.fromARGB(255, 255, 24, 8).withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.logout_rounded,
//               color: const Color.fromARGB(255, 161, 25, 25),
//               size: 24,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 'تسجيل الخروج',
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: const Color.fromARGB(255, 161, 25, 25),
//                   letterSpacing: 0.2,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar(bool isMobile) {
//     return AppBar(
//       title: Text(
//         _getAppBarTitle(),
//         style: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.w700,
//           letterSpacing: -0.5,
//         ),
//       ),
//       backgroundColor: const Color.fromARGB(201, 255, 255, 255),
//       foregroundColor: Colors.black87,
//       elevation: 0,
//       automaticallyImplyLeading: false,
//       actions: [
//         IconButton(
//           icon: Stack(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(Icons.notifications_outlined, size: 20),
//               ),
//               Positioned(
//                 right: 4,
//                 top: 4,
//                 child: Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: AppColors.primary,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           onPressed: () {
//             // TODO: Navigate to notifications
//           },
//         ),
//         const SizedBox(width: 4),
//         IconButton(
//           icon: Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(Icons.logout_outlined, size: 20),
//           ),
//           onPressed: _showLogoutDialog,
//           tooltip: 'تسجيل الخروج',
//         ),
//         const SizedBox(width: 8),
//       ],
//     );
//   }

//   Widget _buildModernBottomNav(bool isMobile) {
//     return Container(
//       // margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
//       margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
//       padding: EdgeInsets.zero,
//       decoration: BoxDecoration(
//         color: const Color.fromARGB(105, 79, 79, 79),
//         // borderRadius: const BorderRadius.all(Radius.circular(25)),
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 25,
//             offset: const Offset(0, -4),
//             spreadRadius: 2,
//           ),
//           BoxShadow(
//             color: const Color.fromARGB(255, 21, 219, 90).withOpacity(0.3),
//             blurRadius: 25,
//             offset: const Offset(0, -4),
//             spreadRadius: 0,
//           ),
//         ],
//         border: Border.all(
//           color: const Color.fromARGB(255, 4, 99, 1).withOpacity(0.3),
//           width: 0,
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(25),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
//           child: SafeArea(
//             bottom: true,
//             top: false,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   _buildNavItem(Icons.castle_outlined, 'القاعات', 1),
//                   _buildNavItem(Icons.group_outlined, 'العرسان', 2),
//                   _buildNavItem(Icons.book_outlined, 'الحجوزات', 3),
//                   _buildNavItem(Icons.home_rounded, 'الرئيسية', 0),
//                   _buildNavItem(Icons.restaurant_menu_outlined, 'الطعام', 4),
//                   _buildNavItem(Icons.settings_outlined, 'الإعدادات', 5),
//                   _buildNavItem(Icons.lock_outline, 'OTP', 6),
//                   // _buildNavItem(Icons.person_outline, 'الملف', 7),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, String label, int index) {
//     final isSelected = _currentIndex == index;
    
//     return GestureDetector(
//       onTap: () => _navigateToTab(index),
//       behavior: HitTestBehavior.opaque,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOutCubic,
//         padding: EdgeInsets.symmetric(
//           horizontal: isSelected ? 12 : 8,
//           vertical: 8,
//         ),
//         decoration: BoxDecoration(
//           gradient: isSelected
//               ? const LinearGradient(
//                   colors: [
//                     Color.fromARGB(82, 98, 216, 139),
//                     Color.fromARGB(43, 2, 168, 110),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 )
//               : null,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? Colors.white : Colors.black.withOpacity(0.5),
//               size: isSelected ? 22 : 20,
//             ),
//             if (isSelected) ...[
//               const SizedBox(height: 4),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 9,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                   letterSpacing: 0.2,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   String _getAppBarTitle() {
//     switch (_currentIndex) {
//       case 0:
//         return AppConstants.appName;
//       case 1:
//         return 'إدارة القاعات';
//       case 2:
//         return 'إدارة العرسان';
//       case 3:
//         return 'إدارة الحجوزات';
//       case 4:
//         return 'قوائم الطعام';
//       case 5:
//         return 'الإعدادات';
//       case 6:
//         return 'رموز التحقق';
//       case 7:
//         return 'الملف الشخصي';
//       default:
//         return AppConstants.appName;
//     }
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

// // FoodMenu model class
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