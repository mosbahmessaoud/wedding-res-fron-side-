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
//   bool _hideBottomNav = false; // New property to control bottom nav visibility
  
//   // Add these new properties
//   final GlobalKey<HomeTabState> _homeTabKey = GlobalKey<HomeTabState>();
//   final GlobalKey<ReservationsTabState> _reservationsTabKey = GlobalKey<ReservationsTabState>();
//   final GlobalKey<ProfileTabState> _profileTabKey = GlobalKey<ProfileTabState>();
//   final GlobalKey<FoodMenuTabGState> _foodMenuTabKey = GlobalKey<FoodMenuTabGState>();
//   final GlobalKey<CreateReservationScreenState> _creatResTabKey = GlobalKey<CreateReservationScreenState>();

//   @override
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
//         key: _creatResTabKey,
//         onReservationCreated: () {
//           // Switch to reservations tab (index 2) when reservation is created
//           _changeTab(2);
//         },
//       ),
//       ReservationsTab(key: _reservationsTabKey),
//       FoodMenuTabG(key: _foodMenuTabKey),
//       ProfileTab(key: _profileTabKey),
//     ];
//   }

//   // Update the _changeTab method
//   void _changeTab(int index) {
//     setState(() {
//       _currentIndex = index;
//       _hideBottomNav = false; // Show bottom nav when switching between main tabs
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
//         _creatResTabKey.currentState?.refreshData();
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

//   // Method to navigate to external screens and hide bottom nav
//   void _navigateToExternalScreen(Widget screen, String title) {
//     setState(() {
//       _hideBottomNav = true;
//     });
    
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           appBar: AppBar(
//             title: Text(title),
//             backgroundColor: AppColors.primary,
//             foregroundColor: Colors.white,
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () {
//                 Navigator.pop(context);
//                 setState(() {
//                   _hideBottomNav = false; // Show bottom nav when returning
//                 });
//               },
//             ),
//           ),
//           body: screen,
//         ),
//       ),
//     ).then((_) {
//       // Ensure bottom nav is shown when returning from external screen
//       setState(() {
//         _hideBottomNav = false;
//       });
//     });
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
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(_getAppBarTitle()),
//           backgroundColor: AppColors.primary,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           automaticallyImplyLeading: false,
//           leading: Builder(
//             builder: (context) => IconButton(
//               icon: const Icon(Icons.menu),
//               onPressed: () => Scaffold.of(context).openDrawer(),
//             ),
//           ),
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
//         // Add the side navigation drawer
//         drawer: Drawer(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               DrawerHeader(
//                 decoration: BoxDecoration(
//                   color: AppColors.primary,
//                 ),
//                 child: const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Icon(
//                       Icons.account_circle,
//                       size: 60,
//                       color: Colors.white,
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'قائمة التنقل',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Main navigation items (same as bottom nav)
//               ListTile(
//                 leading: const Icon(Icons.home),
//                 title: const Text('الرئيسية'),
//                 selected: _currentIndex == 0,
//                 onTap: () {
//                   Navigator.pop(context);
//                   _changeTab(0);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.add_circle_outline),
//                 title: const Text('انشاء حجز'),
//                 selected: _currentIndex == 1,
//                 onTap: () {
//                   Navigator.pop(context);
//                   _changeTab(1);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.calendar_today),
//                 title: const Text('حجوزاتي'),
//                 selected: _currentIndex == 2,
//                 onTap: () {
//                   Navigator.pop(context);
//                   _changeTab(2);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.restaurant_menu),
//                 title: const Text('قائمة مقادير الوليمة'),
//                 selected: _currentIndex == 3,
//                 onTap: () {
//                   Navigator.pop(context);
//                   _changeTab(3);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.person),
//                 title: const Text('الملف الشخصي'),
//                 selected: _currentIndex == 4,
//                 onTap: () {
//                   Navigator.pop(context);
//                   _changeTab(4);
//                 },
//               ),
//               const Divider(),
//               // Additional external navigation options
//               ListTile(
//                 leading: const Icon(Icons.settings),
//                 title: const Text('الإعدادات'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _navigateToExternalScreen(
//                     const Center(child: Text('شاشة الإعدادات')), 
//                     'الإعدادات'
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.help_outline),
//                 title: const Text('المساعدة والدعم'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _navigateToExternalScreen(
//                     const Center(child: Text('شاشة المساعدة والدعم')), 
//                     'المساعدة والدعم'
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.info_outline),
//                 title: const Text('حول التطبيق'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _navigateToExternalScreen(
//                     const Center(child: Text('شاشة حول التطبيق')), 
//                     'حول التطبيق'
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.star_outline),
//                 title: const Text('تقييم التطبيق'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _navigateToExternalScreen(
//                     const Center(child: Text('شاشة تقييم التطبيق')), 
//                     'تقييم التطبيق'
//                   );
//                 },
//               ),
//               const Divider(),
//               ListTile(
//                 leading: const Icon(Icons.logout, color: Colors.red),
//                 title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showLogoutDialog();
//                 },
//               ),
//             ],
//           ),
//         ),
//         body: IndexedStack(
//           index: _currentIndex,
//           children: _tabs,
//         ),
//         // Conditionally show/hide bottom navigation bar
//         bottomNavigationBar: _hideBottomNav ? null : BottomNavigationBar(
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
//               label: 'الحجوزات',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.restaurant_menu),
//               label: 'الوليمة',
//             ),
//             // BottomNavigationBarItem(
//             //   icon: Icon(Icons.person),
//             //   label: 'الملف الشخصي',
//             // ),
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
//         return 'انشاء حجز جديد';
//       case 2:
//         return 'الحجوزات';
//       case 3:
//         return 'قائمة مقادير الوليمة';
//       case 4:
//         return 'الملف الشخصي';
//       default:
//         return AppConstants.appName;
//     }
//   }

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