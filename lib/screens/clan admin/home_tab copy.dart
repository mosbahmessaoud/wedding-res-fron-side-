// // lib/screens/clan admin/home_tab.dart
// import 'package:flutter/material.dart';
// import 'package:wedding_reservation_app/utils/constants.dart';
// import '../../utils/colors.dart';
// import '../../services/api_service.dart';

// class HomeTab extends StatefulWidget {
//   final Function(int)? onNavigateToTab;
  
//   const HomeTab({super.key, this.onNavigateToTab});
  
//   @override
//   HomeTabState createState() => HomeTabState();
// }

// class HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late AnimationController _refreshAnimationController;
//   late Animation<double> _refreshAnimation;

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
// void _navigateToTab(int tabIndex) {
//   if (widget.onNavigateToTab != null) {
//     widget.onNavigateToTab!(tabIndex);
//   }
// }

// void _showLogoutDialog() {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('تسجيل الخروج'),
//       content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('إلغاء'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             ApiService.clearToken();
//             Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//           },
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//           child: const Text('تسجيل الخروج'),
//         ),
//       ],
//     ),
//   );
// }

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

//   // Public method to refresh data from parent
//   void refreshData() {
//     _loadDashboardData();
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

//  @override
// Widget build(BuildContext context) {
//   final screenSize = MediaQuery.of(context).size;
//   final isTablet = screenSize.width > 768;
//   final isMobile = screenSize.width <= 480;

//   return Scaffold(
//     appBar: _buildSliverAppBar(isMobile),
//     body: RefreshIndicator(
//       onRefresh: _loadDashboardData,
//       color: AppColors.primary,
//       backgroundColor: Colors.white,
//       displacement: 20,
//       child: CustomScrollView(
//         physics: AlwaysScrollableScrollPhysics(),
//         slivers: [
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
//                     _buildQuickActions(context),
//                     SizedBox(height: isMobile ? 24 : 32),
//                     _buildRecentActivity(isMobile, isTablet),
//                     SizedBox(height: 80),


//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
// PreferredSizeWidget _buildSliverAppBar(bool isMobile) {
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
//               const Color.fromARGB(255, 130, 161, 112).withOpacity(0.9),
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
//   //  void _showLogoutDialog() {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) => AlertDialog(
//   //       title: const Text('تسجيل الخروج'),
//   //       content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(context),
//   //           child: const Text('إلغاء'),
//   //         ),
//   //         ElevatedButton(
//   //           onPressed: () {
//   //             ApiService.clearToken();
//   //             Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//   //           },
//   //           style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//   //           child: const Text('تسجيل الخروج'),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

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
//             const Color.fromARGB(255, 176, 126, 39).withOpacity(0.8),
//             const Color.fromARGB(255, 183, 143, 58).withOpacity(0.9),
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

//  Widget _buildStatsCards(bool isMobile, bool isTablet) {
//   final stats = [
//     {
//       'title': 'القاعات',
//       'value': _dashboardData['halls_count'].toString(),
//       'icon': Icons.castle_outlined,
//       'color': Colors.blue,
//       'trend': '+2.5%'
//     },
//     {
//       'title': 'الحجوزات',
//       'value': _dashboardData['reservations_count'].toString(),
//       'icon': Icons.book_outlined,
//       'color': Colors.green,
//       'trend': '+12.3%'
//     },
//     {
//       'title': 'العرسان',
//       'value': _dashboardData['grooms_count'].toString(),
//       'icon': Icons.group_outlined,
//       'color': Colors.orange,
//       'trend': '+8.1%'
//     },
//     if (!isMobile) {
//       'title': 'القوائم',
//       'value': _dashboardData['menus_count'].toString(),
//       'icon': Icons.restaurant_menu,
//       'color': Colors.purple,
//       'trend': '+5.7%'
//     },
//   ];

//   return LayoutBuilder(
//     builder: (context, constraints) {
//       final crossAxisCount = isMobile ? 2 : (isTablet ? 4 : 3);
//       final childAspectRatio = isMobile ? 1.1 : (isTablet ? 1.3 : 1.2);
      
//       return GridView.builder(
//         shrinkWrap: true,
//         physics: NeverScrollableScrollPhysics(),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: crossAxisCount,
//           mainAxisSpacing: isMobile ? 10 : 16,
//           crossAxisSpacing: isMobile ? 10 : 16,
//           childAspectRatio: childAspectRatio,
//         ),
//         itemCount: stats.length,
//         itemBuilder: (context, index) {
//           final stat = stats[index] as Map<String, dynamic>;
//           return _buildStatCard(
//             stat['title'],
//             stat['value'],
//             stat['icon'],
//             stat['color'],
//             stat['trend'],
//             isMobile,
//           );
//         },
//       );
//     },
//   );
// }
// Widget _buildStatCard(String title, String value, IconData icon, Color color, 
//                      String trend, bool isMobile) {
//   return Container(
//     padding: EdgeInsets.all(isMobile ? 12 : 16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.04),
//           spreadRadius: 0,
//           blurRadius: 12,
//           offset: Offset(0, 4),
//         ),
//       ],
//       border: Border.all(color: Colors.grey.withOpacity(0.1)),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               padding: EdgeInsets.all(isMobile ? 6 : 8),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
//               ),
//               child: Icon(icon, color: color, size: isMobile ? 16 : 20),
//             ),
//             if (!isMobile)
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   trend,
//                   style: TextStyle(
//                     fontSize: 9,
//                     color: Colors.green.shade700,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: isMobile ? 18 : 24,
//                 fontWeight: FontWeight.w800,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             SizedBox(height: 2),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: isMobile ? 10 : 12,
//                 color: AppColors.textSecondary,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
// Widget _buildQuickActions(BuildContext context) {
//   final screenWidth = MediaQuery.of(context).size.width;
//   final isCompact = screenWidth < 600;
//   final crossAxisCount = screenWidth < 600 ? 2 : screenWidth < 900 ? 3 : screenWidth < 1200 ? 4 : 5;
  
//   final actions = [
//     (Icons.castle_outlined, 'القاعات', '${_dashboardData['halls_count']} قاعة', Color(0xFF1877F2), 1),
//     (Icons.group_outlined, 'العرسان', '${_dashboardData['grooms_count']} مسجل', Color(0xFF42B72A), 2),
//     (Icons.book_outlined, 'الحجوزات', '${_dashboardData['pending_reservations']} معلق', Color(0xFFE4405F), 3),
//     (Icons.restaurant_outlined, 'قوائم الطعام', '${_dashboardData['menus_count']} قائمة', Color(0xFFFF6F00), 4),
//     (Icons.lock_outline, 'رموز التحقق', 'بحث عن رموز', Color(0xFF9C27B0), 6),
//   ];

//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Padding(
//         padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 0),
//         child: Text(
//           'الإجراءات السريعة',
//           style: TextStyle(
//             fontSize: isCompact ? 20 : 24,
//             fontWeight: FontWeight.w700,
//             color: Color(0xFF050505),
//             letterSpacing: -0.5,
//           ),
//         ),
//       ),
//       SizedBox(height: isCompact ? 12 : 16),
//       LayoutBuilder(
//         builder: (context, constraints) {
//           return GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: crossAxisCount,
//               mainAxisSpacing: 12,
//               crossAxisSpacing: 12,
//               childAspectRatio: 1.0,
//             ),
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: actions.length,
//             padding: EdgeInsets.zero,
//             itemBuilder: (_, i) {
//               final a = actions[i];
//               return Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: () => widget.onNavigateToTab?.call(a.$5),
//                   borderRadius: BorderRadius.circular(12),
//                   splashColor: a.$4.withOpacity(0.1),
//                   highlightColor: a.$4.withOpacity(0.05),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Color(0xFFE4E6EB), width: 1),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.04),
//                           blurRadius: 8,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(isCompact ? 12 : 14),
//                           decoration: BoxDecoration(
//                             color: a.$4.withOpacity(0.1),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             a.$1,
//                             color: a.$4,
//                             size: isCompact ? 28 : 32,
//                           ),
//                         ),
//                         SizedBox(height: 12),
//                         Text(
//                           a.$2,
//                           style: TextStyle(
//                             color: Color(0xFF050505),
//                             fontSize: isCompact ? 14 : 15,
//                             fontWeight: FontWeight.w600,
//                             letterSpacing: -0.2,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: 4),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 8),
//                           child: Text(
//                             a.$3,
//                             style: TextStyle(
//                               color: Color(0xFF65676B),
//                               fontSize: isCompact ? 12 : 13,
//                               fontWeight: FontWeight.w400,
//                             ),
//                             textAlign: TextAlign.center,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     ],
//   );
// }


// Widget _buildModernActionCard({
//   required IconData icon,
//   required String title,
//   required String subtitle,
//   required List<Color> gradient,
//   required VoidCallback onTap,
//   required bool isMobile,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: gradient,
//         ),
//         borderRadius: BorderRadius.circular(isMobile ? 14 : 18),
//         boxShadow: [
//           BoxShadow(
//             color: gradient[0].withOpacity(0.3),
//             spreadRadius: 0,
//             blurRadius: 15,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Container(
//         padding: EdgeInsets.all(isMobile ? 12 : 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               padding: EdgeInsets.all(isMobile ? 8 : 10),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
//               ),
//               child: Icon(
//                 icon,
//                 color: Colors.white,
//                 size: isMobile ? 20 : 24,
//               ),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: isMobile ? 14 : 16,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 3),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: isMobile ? 10 : 11,
//                     color: Colors.white.withOpacity(0.85),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

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
// }