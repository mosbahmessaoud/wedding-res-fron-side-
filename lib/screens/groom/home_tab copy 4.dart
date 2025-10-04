// // lib/screens/home/tabs/home_tab.dart
// import 'package:flutter/material.dart';
// import '../../../services/api_service.dart';
// import '../../../utils/colors.dart';
// import 'dart:math' as math;

// class HomeTab extends StatefulWidget {
//   final Function(int)? onTabChanged;
  
//   const HomeTab({
//     super.key,
//     this.onTabChanged,
//   });

//   @override
//   HomeTabState createState() => HomeTabState();
// }

// class HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
//   bool _isLoading = true;
//   Map<String, dynamic>? _userProfile;
//   Map<String, dynamic>? _pendingReservation;
//   Map<String, int> _reservationStats = {};
//   List<Map<String, dynamic>> _recentReservations = [];
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   Map<String, dynamic>? _validatedReservation;

//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _loadDashboardData();
//   }

//     void refreshData() {
//     // Add your data refresh logic here
//     // For example:
//     _initAnimations();
//     _loadDashboardData();
//     setState(() {
//       // Trigger rebuild to show updated data
//     });
//   }

//   void _initAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
    
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
    
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutBack,
//     ));
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

// Future<void> _loadDashboardData() async {
//   setState(() => _isLoading = true);
  
//   try {
//     // Load user profile
//     _userProfile = await ApiService.getProfile();
    
//     // Load pending reservation
//     try {
//       _pendingReservation = await ApiService.getMyPendingReservation();
//     } catch (e) {
//       _pendingReservation = null;
//     }

//     // Load reservation statistics
//     try {
//       final allReservations = await ApiService.getMyAllReservations();
      
//       Map<String, dynamic>? validatedReservation;
//       try {
//         validatedReservation = await ApiService.getMyValidatedReservation();
//       } catch (e) {
//         validatedReservation = null;
//       }
      
//       final cancelledReservations = await ApiService.getMyCancelledReservations();
      
//       _reservationStats = {
//         'total': allReservations.length,
//         'validated': validatedReservation != null ? 1 : 0,
//         'cancelled': cancelledReservations.length,
//         'pending': _pendingReservation != null ? 1 : 0,
//       };

//       // Get recent reservations (last 3)
//       if (allReservations.isNotEmpty) {
//         _recentReservations = allReservations.take(3).map((reservation) => Map<String, dynamic>.from(reservation)).toList();
//       }
      
//     } catch (e) {
//       _reservationStats = {'total': 0, 'validated': 0, 'cancelled': 0, 'pending': 0};
//     }
    
//   } catch (e) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في تحميل البيانات: ${e.toString()}'),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//     }
//   } finally {
//     if (mounted) {
//       setState(() => _isLoading = false);
//       _animationController.forward();
//     }
//   }
// }
// // Spotify-Inspired Home Tab - Light Mode

// @override
// Widget build(BuildContext context) {
//   if (_isLoading) {
//     return _buildLoadingState();
//   }

//   return Container(
//     // decoration: BoxDecoration(
//     //   gradient: LinearGradient(
//     //     begin: Alignment.bottomCenter,
//     //     end: Alignment.topCenter,
//     //     colors: [
//     //       const Color(0xFF1DB954).withOpacity(0.15),
//     //       const Color(0xFFF6F6F6),
//     //     ],
//     //   ),
//     // ),
//     color: const Color(0xFFF6F6F6), // Spotify light background
//     child: RefreshIndicator(
//       onRefresh: _loadDashboardData,
//       color: const Color(0xFF1DB954), // Spotify green
//       backgroundColor: Colors.white,
//       child: ListView(
//         padding: EdgeInsets.zero,
//         physics: const BouncingScrollPhysics(),
//         children: [
//           _buildSpotifyHeader(),
//           _buildSpotifyStatusCard(),
//           const SizedBox(height: 24),
//           _buildSpotifyStatsSection(),
//           const SizedBox(height: 32),
//           _buildSpotifyQuickActions(),
//           if (_recentReservations.isNotEmpty) ...[
//             const SizedBox(height: 32),
//             _buildSpotifyRecentReservations(),
//           ],
//           const SizedBox(height: 100),
//         ],
//       ),
//     ),
//   );
// }

// Widget _buildLoadingState() {
//   return Container(
//     color: const Color(0xFFF6F6F6),
//     child: Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 60,
//             height: 60,
//             child: CircularProgressIndicator(
//               strokeWidth: 3,
//               valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1DB954)),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'جاري التحميل...',
//             style: TextStyle(
//               fontSize: 16,
//               color: Color(0xFF6A6A6A),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget _buildSpotifyHeader() {
//   final userName = _userProfile != null 
//       ? '${_userProfile!['first_name'] ?? ''} ${_userProfile!['last_name'] ?? ''}'.trim()
//       : 'العريس الكريم';

//   final timeOfDay = DateTime.now().hour;
//   String greeting = timeOfDay < 12 ? ' السلام عليكم صباح الخير' : timeOfDay < 18 ? 'السلام عليكم مرحبا بك' : 'السلام عليكم مساء الخير';

//   return Container(
//     padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [
//           const Color(0xFF1DB954).withOpacity(0.15),
//           const Color(0xFFF6F6F6),
//         ],
//       ),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           greeting,
//           style: const TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.w800,
//             color: Color.fromARGB(255, 0, 144, 19),
//             height: 1.2,
//             letterSpacing: -0.5,

//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           userName,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF6A6A6A),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildSpotifyStatusCard() {
//   if (_reservationStats['validated'] != null && _reservationStats['validated']! > 0) {
//     return FutureBuilder<Map<String, dynamic>?>(
//       future: _getValidatedReservation(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             height: 160,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Center(
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1DB954)),
//               ),
//             ),
//           );
//         }
        
//         if (snapshot.hasData && snapshot.data != null) {
//           final res = snapshot.data!;
//           final date = res['date1'] ?? 'غير محدد';
//           final date2 = res['date2'];
//           final hall = res['hall_name'] ?? 'غير محدد';
          
//           return GestureDetector(
//             onTap: () => widget.onTabChanged!(2),
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     const Color(0xFF1DB954),
//                     const Color(0xFF1ED760),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF1DB954).withOpacity(0.3),
//                     blurRadius: 15,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
//                       ),
//                       const SizedBox(width: 12),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'حجز مؤكد',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w900,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Text(
//                               'تهانينا! حجزك جاهز',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             const Icon(Icons.event_rounded, size: 16, color: Colors.white),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 date2 != null && date2.isNotEmpty ? '$date و $date2' : date,
//                                 style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             const Icon(Icons.location_on_rounded, size: 16, color: Colors.white),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 hall,
//                                 style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//         return _buildSpotifyReadyCard();
//       },
//     );
//   }
  
//   if (_pendingReservation != null) return _buildSpotifyPendingCard();
//   return _buildSpotifyReadyCard();
// }

// Widget _buildSpotifyPendingCard() {
//   final date = _pendingReservation!['date1'] ?? 'غير محدد';
//   final date2 = _pendingReservation!['date2'];
//   final hall = _pendingReservation!['hall_name'] ?? 'غير محدد';
  
//   return GestureDetector(
//     onTap: () => widget.onTabChanged!(2),
//     child: Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.orange.shade500,
//             Colors.orange.shade600,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.orange.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Icon(Icons.pending_rounded, color: Colors.white, size: 24),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'حجز معلق',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w900,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       'في انتظار الموافقة',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.event_rounded, size: 16, color: Colors.white),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         date2 != null && date2.isNotEmpty ? '$date و $date2' : date,
//                         style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     const Icon(Icons.location_on_rounded, size: 16, color: Colors.white),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         hall,
//                         style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget _buildSpotifyReadyCard() {
//   return GestureDetector(
//     onTap: () => widget.onTabChanged!(1),
//     child: Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             const Color.fromARGB(153, 29, 185, 84),
//             const Color.fromARGB(142, 12, 86, 38),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF1DB954).withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 28),
//           ),
//           const SizedBox(width: 16),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'ابدأ الحجز',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   'احجز موعد العرس الآن',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
//         ],
//       ),
//     ),
//   );
// }

// Widget _buildSpotifyStatsSection() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'إحصائيات الحجوزات',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.w900,
//             color: Color(0xFF121212),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(child: _buildSpotifyStatCard('${_reservationStats['total'] ?? 0}', 'الإجمالي', Icons.calendar_today_rounded, const Color(0xFF1DB954))),
//             const SizedBox(width: 12),
//             Expanded(child: _buildSpotifyStatCard('${_reservationStats['validated'] ?? 0}', 'المؤكد', Icons.check_circle_rounded, const Color(0xFF1DB954))),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(child: _buildSpotifyStatCard('${_reservationStats['pending'] ?? 0}', 'المعلق', Icons.pending_rounded, Colors.orange)),
//             const SizedBox(width: 12),
//             Expanded(child: _buildSpotifyStatCard('${_reservationStats['cancelled'] ?? 0}', 'الملغي', Icons.cancel_rounded, Colors.red)),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildSpotifyStatCard(String value, String title, IconData icon, Color color) {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(8),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 10,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, color: color, size: 24),
//         const SizedBox(height: 12),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.w900,
//             color: Color(0xFF121212),
//           ),
//         ),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 13,
//             color: Color(0xFF6A6A6A),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildSpotifyQuickActions() {
//   final actions = [
//     {'icon': Icons.add_circle_rounded, 'title': 'حجز جديد', 'subtitle': 'احجز موعد زفافك', 'onTap': () => widget.onTabChanged!(1)},
//     {'icon': Icons.calendar_month_rounded, 'title': 'حجوزاتي', 'subtitle': 'عرض وإدارة الحجوزات', 'onTap': () => widget.onTabChanged!(2)},
//     {'icon': Icons.person_rounded, 'title': 'الملف الشخصي', 'subtitle': 'إعدادات وتفضيلات', 'onTap': () => widget.onTabChanged!(3)},
//   ];

//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'الإجراءات السريعة',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.w900,
//             color: Color(0xFF121212),
//           ),
//         ),
//         const SizedBox(height: 16),
//         ...actions.map((action) => Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: GestureDetector(
//             onTap: action['onTap'] as VoidCallback,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1DB954).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Icon(action['icon'] as IconData, color: const Color(0xFF1DB954), size: 24),
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           action['title'] as String,
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF121212),
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           action['subtitle'] as String,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Color(0xFF6A6A6A),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Icon(Icons.chevron_right_rounded, color: Color(0xFF6A6A6A), size: 24),
//                 ],
//               ),
//             ),
//           ),
//         )),
//       ],
//     ),
//   );
// }

// Widget _buildSpotifyRecentReservations() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'الحجوزات الأخيرة',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.w900,
//             color: Color(0xFF121212),
//           ),
//         ),
//         const SizedBox(height: 16),
//         ...(_recentReservations.map((res) => Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: _buildSpotifyReservationCard(res),
//         ))),
//       ],
//     ),
//   );
// }

// Widget _buildSpotifyReservationCard(Map<String, dynamic> reservation) {
//   final status = reservation['status'] ?? 'pending';
//   final date = reservation['wedding_date'] ?? 'غير محدد';
//   final hall = reservation['hall_name'] ?? 'غير محدد';
  
//   Color color = Colors.orange;
//   IconData icon = Icons.pending_rounded;
//   String text = 'معلق';
  
//   if (status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'validated') {
//     color = const Color(0xFF1DB954);
//     icon = Icons.check_circle_rounded;
//     text = 'مؤكد';
//   } else if (status.toLowerCase() == 'cancelled') {
//     color = Colors.red.shade400;
//     icon = Icons.cancel_rounded;
//     text = 'ملغي';
//   }

//   return Container(
//     padding: const EdgeInsets.all(16),
    
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(8),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 10,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 hall,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF121212),
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 date,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Color(0xFF6A6A6A),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             text,
//             style: TextStyle(
//               color: color,
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildNormalStatusCard() => _buildSpotifyReadyCard();

 



// // Add this helper method to get validated reservation
// Future<Map<String, dynamic>?> _getValidatedReservation() async {
//   try {
//     if (_validatedReservation != null) {
//       return _validatedReservation;
//     }
    
//     _validatedReservation = await ApiService.getMyValidatedReservation();
//     return _validatedReservation;
//   } catch (e) {
//     return null;
//   }
// }



// }