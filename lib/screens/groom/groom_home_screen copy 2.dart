// // lib/screens/home/groom_home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:wedding_reservation_app/screens/groom/food_menu_tab.dart';
// import 'package:wedding_reservation_app/screens/groom/food_menu_tab_Groom.dart';
// import 'package:wedding_reservation_app/services/api_service.dart';
// import '../../utils/colors.dart';
// import '../../utils/constants.dart';
// import 'create_reservation_screen.dart';
// import 'home_tab.dart';
// import 'reservations_tab.dart';
// import 'profile_tab.dart';

// class GroomHomeScreen extends StatefulWidget {
//   final int initialTabIndex;
  
//   const GroomHomeScreen({super.key, required this.initialTabIndex});

//   @override
//   _GroomHomeScreenState createState() => _GroomHomeScreenState();
// }

// class _GroomHomeScreenState extends State<GroomHomeScreen> {
//   int _currentIndex = 0;
//   late List<Widget> _tabs;
//   // Add these new properties
//   final GlobalKey<HomeTabState> _homeTabKey = GlobalKey<HomeTabState>();
//   final GlobalKey<ReservationsTabState> _reservationsTabKey = GlobalKey<ReservationsTabState>();
//   final GlobalKey<ProfileTabState> _profileTabKey = GlobalKey<ProfileTabState>();
//   final GlobalKey<FoodMenuTabGState> _foodMenuTabKey = GlobalKey<FoodMenuTabGState>(); // Add this line

// @override
//   void initState() {
//     super.initState();
//     // Initialize _currentIndex with the passed parameter
//     _currentIndex = widget.initialTabIndex;
    
//     _tabs = [
//       HomeTab(
//         key: _homeTabKey,
//         onTabChanged: _changeTab,
//       ),
//       CreateReservationScreen(
//         onReservationCreated: () {
//           // Switch to reservations tab (index 2) when reservation is created
//           _changeTab(2);
//         },
//       ),
//       ReservationsTab(key: _reservationsTabKey),
//       FoodMenuTabG(key: _foodMenuTabKey), // Add this line
//       ProfileTab(key: _profileTabKey),
//     ];
//   }

//   // 4. Update the _changeTab method
//   void _changeTab(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
    
//     // Add refresh logic when changing tabs
//     _refreshCurrentTab(index);
//   }

//   void _refreshCurrentTab(int index) {
//     switch (index) {
//       case 0:
//         // Refresh Home tab
//         _homeTabKey.currentState?.refreshData();
//         break;
//       case 1:
//         // CreateReservationScreen doesn't need refresh typically
//         break;
//       case 2:
//         // Refresh Reservations tab
//         _reservationsTabKey.currentState?.refreshData();
//         break;
//       case 3:
//         // Refresh Food Menu tab
//         _foodMenuTabKey.currentState?.refreshData();
//         break;
//       case 4:
//         // Refresh Profile tab
//         _profileTabKey.currentState?.refreshData();
//         break;
//     }
//   }

//   void _navigateToCreateReservation() {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => const CreateReservationScreen(),
//       ),
//     );
//   }

 
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
//     return WillPopScope(
//       onWillPop: () async {
//         // Prevent back button from doing anything
//         // Just return false to disable back button completely
//         // Or return true to allow normal back navigation without sign out
//         return true; // This disables the back button completely
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(_getAppBarTitle()),
//           backgroundColor: AppColors.primary,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           automaticallyImplyLeading: false, // Remove automatic back button
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.notifications),
//               onPressed: () {
//                 _showNotifications();
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.logout),
//               onPressed: _showLogoutDialog,
//               tooltip: 'تسجيل الخروج',
//             ),
//           ], 
//         ),
//         body: IndexedStack(
//           index: _currentIndex,
//           children: _tabs,
//         ),
//           bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             _changeTab(index);
//           },
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: AppColors.primary,
//           unselectedItemColor: AppColors.textSecondary,
//           backgroundColor: Colors.white,
//           elevation: 8,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home),
//               label: 'الرئيسية',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.add_circle_outline),
//               label: 'انشاء حجز',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today),
//               label: 'حجوزاتي',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.restaurant_menu),
//               label: 'قائمة الطعام',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person),
//               label: 'الملف الشخصي',
//             ),
//           ],
//         ),
 
//       ),
//     );
//   }

// String _getAppBarTitle() {
//   switch (_currentIndex) {
//     case 0:
//       return AppConstants.appName;
//     case 1:
//       return 'انشاء حجز جديد';
//     case 2:
//       return 'حجوزاتي';
//     case 3:
//       return 'قائمة الطعام';
//     case 4:
//       return 'الملف الشخصي';
//     default:
//       return AppConstants.appName;
//   }
// }
//   void _showNotifications() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('الإشعارات'),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Icon(Icons.info, color: Colors.blue),
//               title: Text('مرحباً بك في التطبيق'),
//               subtitle: Text('نتمنى لك تجربة ممتعة في حجز قاعة زفافك'),
//             ),
//             ListTile(
//               leading: Icon(Icons.update, color: Colors.green),
//               title: Text('تحديث التطبيق'),
//               subtitle: Text('تم إضافة ميزات جديدة للتطبيق'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('موافق'),
//           ),
//         ],
//       ),
//     );
//   }
// }