// // lib/screens/home/super_admin_home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:wedding_reservation_app/screens/super%20admin/clans_tab.dart';
// import 'package:wedding_reservation_app/screens/super%20admin/haia_tab.dart';
// import 'package:wedding_reservation_app/screens/super%20admin/madaih_tab.dart';
// import '../../utils/colors.dart';
// import '../../utils/constants.dart';
// import '../super admin/counties_tab.dart'; // Import the new CountiesTab

// class SuperAdminHomeScreen extends StatefulWidget {
//   @override
//   _SuperAdminHomeScreenState createState() => _SuperAdminHomeScreenState();
// }

// class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppConstants.appName),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications),
//             onPressed: () {
//               // TODO: Navigate to notifications
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.person),
//             onPressed: () {
//               // TODO: Navigate to profile
//             },
//           ),
//         ],
//       ),
//       body: IndexedStack(
//         index: _currentIndex,
//         children: [
//           _buildHomeTab(),
//           CountiesTab(), // Use the new CountiesTab widget
//           ClansTab(),
//           MadaihTab(),
//           HaiaTab(),
//           _buildProfileTab(),
//         ],
        
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: AppColors.primary,
//         unselectedItemColor: AppColors.textSecondary,
//         backgroundColor: Colors.white,
//         elevation: 8,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'الرئيسية',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.location_city), // Changed icon to better represent counties
//             label: 'القصور', // Updated label from القصور to القصور
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.groups),
//             label: 'العشائر',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.business),
//             label: 'لجنات المدايح',
//           ),

//           BottomNavigationBarItem(
//             icon: Icon(Icons.groups),
//             label: 'الهيئات',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'الملف الشخصي',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHomeTab() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Welcome Card
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.primary,
//                   AppColors.primary.withOpacity(0.8),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'مرحباً بك',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'تحكم في جميع القصور والعشائر من هنا', // Updated text
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           SizedBox(height: 24),
          
//           // Quick Actions
//           Text(
//             'الإجراءات السريعة',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
          
//           SizedBox(height: 16),
          
//           GridView.count(
//             crossAxisCount: 2,
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             mainAxisSpacing: 16,
//             crossAxisSpacing: 16,
//             childAspectRatio: 1.2,
//             children: [
//               _buildActionCard(
//                 icon: Icons.location_city, // Updated icon
//                 title: 'القصور', // Updated title
//                 subtitle: 'إدارة القصور', // Updated subtitle
//                 color: AppColors.primary,
//                 onTap: () {
//                   setState(() {
//                     _currentIndex = 1;
//                   });
//                 },
//               ),
//               _buildActionCard(
//                 icon: Icons.groups, // Updated icon for clans
//                 title: 'العشائر',
//                 subtitle: 'إدارة العشائر',
//                 color: AppColors.secondary,
//                 onTap: () {
//                   setState(() {
//                     _currentIndex = 2;
//                   });
//                 },
//               ),
//               _buildActionCard(
//                 icon: Icons.business,
//                 title: 'لجنات المدايح',
//                 subtitle: 'إدارة لجنات المدايح',
//                 color: Colors.purple,
//                 onTap: () {
//                   setState(() {
//                     _currentIndex = 3;
//                   });
//                 },
//               ),
//               _buildActionCard(
//                 icon: Icons.groups_2, // Different icon for Haia
//                 title: 'الهيئات',
//                 subtitle: 'إدارة الهيئات',
//                 color: Colors.orange,
//                 onTap: () {
//                   setState(() {
//                     _currentIndex = 4;
//                   });
//                 },
//               ),
//             ],
//           ),
          
          
          
//         ],
//       ),
//     );
//   }

//   Widget _buildActionCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: AppColors.border),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               spreadRadius: 1,
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(25),
//               ),
//               child: Icon(
//                 icon,
//                 color: color,
//                 size: 28,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textPrimary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: AppColors.textSecondary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsCard({
//     required IconData icon,
//     required String title,
//     required String count,
//     required Color color,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 color: color,
//                 size: 24,
//               ),
//               SizedBox(width: 8),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Text(
//             count,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildClansTab() {
//   //   return Center(
//   //     child: Column(
//   //       mainAxisAlignment: MainAxisAlignment.center,
//   //       children: [
//   //         Icon(
//   //           Icons.business,
//   //           size: 64,
//   //           color: AppColors.textSecondary,
//   //         ),
//   //         SizedBox(height: 16),
//   //         Text(
//   //           'قريباً...',
//   //           style: TextStyle(
//   //             fontSize: 24,
//   //             fontWeight: FontWeight.bold,
//   //             color: AppColors.textPrimary,
//   //           ),
//   //         ),
//   //         Text(
//   //           'صفحة القاعات قيد التطوير',
//   //           style: TextStyle(
//   //             fontSize: 16,
//   //             color: AppColors.textSecondary,
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _buildProfileTab() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.person,
//             size: 64,
//             color: AppColors.textSecondary,
//           ),
//           SizedBox(height: 16),
//           Text(
//             'قريباً...',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           Text(
//             'صفحة الملف الشخصي قيد التطوير',
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }