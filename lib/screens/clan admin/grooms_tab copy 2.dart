// // lib/screens/home/tabs/grooms_tab.dart
// import 'package:flutter/material.dart';
// import '../../../services/api_service.dart';
// import '../../../utils/colors.dart';

// class GroomsTab extends StatefulWidget {
//   const GroomsTab({super.key});

//   @override
//   _GroomsTabState createState() => _GroomsTabState();
// }

// class _GroomsTabState extends State<GroomsTab> with TickerProviderStateMixin {
//   List<dynamic> grooms = [];
//   List<dynamic> filteredGrooms = [];
//   bool isLoading = true;
//   String errorMessage = '';
//   String searchQuery = '';
  
//   late TabController _tabController;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
  
//   // Filter states
//   String selectedStatusFilter = 'الكل';
//   final List<String> statusFilters = ['الكل', 'نشط', 'معلق', 'محظور'];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 1200),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Interval(0.0, 0.8, curve: Curves.easeOutCubic),
//       ),
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
//       ),
//     );
//     _loadGrooms();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadGrooms() async {
//     if (!mounted) return;
    
//     try {
//       setState(() {
//         isLoading = true;
//         errorMessage = '';
//       });

//       final response = await ApiService.listGrooms();
      
//       if (!mounted) return;
      
//       setState(() {
//         grooms = response;
//         _applyFilters();
//         isLoading = false;
//       });
      
//       _animationController.forward();
//     } catch (e) {
//       if (!mounted) return;
      
//       setState(() {
//         errorMessage = e.toString().replaceAll('Exception: ', '');
//         isLoading = false;
//       });
//     }
//   }

//   void _applyFilters() {
//     filteredGrooms = grooms.where((groom) {
//       // Search filter
//       if (searchQuery.isNotEmpty) {
//         final firstName = groom['first_name']?.toString().toLowerCase() ?? '';
//         final lastName = groom['last_name']?.toString().toLowerCase() ?? '';
//         final phone = groom['phone_number']?.toString().toLowerCase() ?? '';
//         final guardianName = groom['guardian_name']?.toString().toLowerCase() ?? '';
//         final fatherName = groom['father_name']?.toString().toLowerCase() ?? '';
//         final query = searchQuery.toLowerCase();
        
//         if (!firstName.contains(query) && 
//             !lastName.contains(query) && 
//             !phone.contains(query) && 
//             !guardianName.contains(query) &&
//             !fatherName.contains(query)) {
//           return false;
//         }
//       }

//       // Status filter
//       if (selectedStatusFilter != 'الكل') {
//         final status = groom['status']?.toString() ?? '';
//         switch (selectedStatusFilter) {
//           case 'نشط':
//             return status == 'active';
//           case 'معلق':
//             return status == 'pending';
//           case 'محظور':
//             return status == 'banned';
//         }
//       }

//       return true;
//     }).toList();
//   }

//   void _showSnackBar(String message, Color color) {
//     if (!mounted) return;
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 color == Colors.green ? Icons.check_circle : Icons.error,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         margin: EdgeInsets.all(16),
//         duration: Duration(seconds: 4),
//         elevation: 8,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isTablet = screenSize.width > 768;
//     final isMobile = screenSize.width <= 480;

//     return Scaffold(
//       backgroundColor: Color(0xFFF6F8FC),
//       body: Column(
//         children: [
//           _buildModernHeader(isMobile, isTablet),
//           _buildModernTabBar(isMobile),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildModernCardsView(isMobile, isTablet),
//                 _buildModernListView(isMobile, isTablet),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernHeader(bool isMobile, bool isTablet) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF667EEA),
//             Color(0xFF764BA2),
//             Color(0xFF8B5CF6),
//           ],
//           stops: [0.0, 0.5, 1.0],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(32),
//           bottomRight: Radius.circular(32),
//         ),
//       ),
//       child: Container(
//         padding: EdgeInsets.fromLTRB(
//           isMobile ? 20 : 28, 
//           MediaQuery.of(context).padding.top + 20, 
//           isMobile ? 20 : 28, 
//           28
//         ),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(32),
//             bottomRight: Radius.circular(32),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Icon(
//                               Icons.people_alt_rounded,
//                               color: Colors.white,
//                               size: isMobile ? 20 : 24,
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Text(
//                             'إدارة العرسان',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: isMobile ? 26 : (isTablet ? 34 : 30),
//                               fontWeight: FontWeight.w900,
//                               height: 1.1,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'متابعة وإدارة شاملة لحسابات العرسان المسجلين',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.95),
//                           fontSize: isMobile ? 15 : 17,
//                           fontWeight: FontWeight.w500,
//                           height: 1.4,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isMobile ? 16 : 20, 
//                     vertical: isMobile ? 10 : 12
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.25),
//                     borderRadius: BorderRadius.circular(24),
//                     border: Border.all(color: Colors.white.withOpacity(0.4)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.group_rounded,
//                         color: Colors.white,
//                         size: isMobile ? 18 : 20,
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         '${filteredGrooms.length}',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w800,
//                           fontSize: isMobile ? 16 : 18,
//                         ),
//                       ),
//                       SizedBox(width: 6),
//                       Text(
//                         'عريس',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.95),
//                           fontWeight: FontWeight.w600,
//                           fontSize: isMobile ? 13 : 15,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
            
//             SizedBox(height: isMobile ? 24 : 28),
            
//             // Modern Search bar
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 20,
//                     offset: Offset(0, 8),
//                   ),
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 4,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 onChanged: (value) {
//                   setState(() {
//                     searchQuery = value;
//                     _applyFilters();
//                   });
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'ابحث عن العرسان (الاسم، الهاتف، ولي الأمر)...',
//                   hintStyle: TextStyle(
//                     color: AppColors.textSecondary.withOpacity(0.7),
//                     fontSize: isMobile ? 15 : 17,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   prefixIcon: Container(
//                     padding: EdgeInsets.all(16),
//                     child: Icon(
//                       Icons.search_rounded, 
//                       color: Color(0xFF667EEA),
//                       size: isMobile ? 22 : 26,
//                     ),
//                   ),
//                   suffixIcon: searchQuery.isNotEmpty
//                       ? Container(
//                           margin: EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: IconButton(
//                             icon: Icon(
//                               Icons.clear_rounded, 
//                               color: AppColors.textSecondary,
//                               size: isMobile ? 20 : 22,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 searchQuery = '';
//                                 _applyFilters();
//                               });
//                             },
//                           ),
//                         )
//                       : null,
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.all(isMobile ? 18 : 22),
//                 ),
//               ),
//             ),
            
//             SizedBox(height: isMobile ? 20 : 24),
            
//             // Modern Filter chips
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: statusFilters.asMap().entries.map((entry) {
//                   final index = entry.key;
//                   final filter = entry.value;
//                   final isSelected = selectedStatusFilter == filter;
                  
//                   return Container(
//                     margin: EdgeInsets.only(right: 12),
//                     child: AnimatedContainer(
//                       duration: Duration(milliseconds: 300),
//                       curve: Curves.easeInOutCubic,
//                       child: Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           onTap: () {
//                             setState(() {
//                               selectedStatusFilter = filter;
//                               _applyFilters();
//                             });
//                           },
//                           borderRadius: BorderRadius.circular(20),
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: isMobile ? 18 : 22,
//                               vertical: isMobile ? 10 : 12,
//                             ),
//                             decoration: BoxDecoration(
//                               gradient: isSelected 
//                                 ? LinearGradient(
//                                     colors: [
//                                       Colors.white.withOpacity(0.35),
//                                       Colors.white.withOpacity(0.25),
//                                     ],
//                                   )
//                                 : null,
//                               color: isSelected 
//                                 ? null 
//                                 : Colors.white.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                 color: isSelected 
//                                   ? Colors.white.withOpacity(0.6) 
//                                   : Colors.white.withOpacity(0.3),
//                                 width: isSelected ? 2 : 1,
//                               ),
//                               boxShadow: isSelected ? [
//                                 BoxShadow(
//                                   color: Colors.white.withOpacity(0.2),
//                                   blurRadius: 8,
//                                   offset: Offset(0, 4),
//                                 ),
//                               ] : null,
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 if (isSelected) ...[
//                                   Icon(
//                                     Icons.check_circle_rounded,
//                                     size: isMobile ? 16 : 18,
//                                     color: Colors.white,
//                                   ),
//                                   SizedBox(width: 6),
//                                 ],
//                                 Text(
//                                   filter,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
//                                     fontSize: isMobile ? 13 : 15,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildModernTabBar(bool isMobile) {
//     return Container(
//       margin: EdgeInsets.fromLTRB(20, 16, 20, 0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 15,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: TabBar(
//         controller: _tabController,
//         labelColor: Color(0xFF667EEA),
//         unselectedLabelColor: AppColors.textSecondary,
//         indicator: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF667EEA).withOpacity(0.1),
//               Color(0xFF764BA2).withOpacity(0.1),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         indicatorSize: TabBarIndicatorSize.tab,
//         indicatorPadding: EdgeInsets.all(4),
//         splashBorderRadius: BorderRadius.circular(16),
//         labelStyle: TextStyle(
//           fontWeight: FontWeight.w700,
//           fontSize: isMobile ? 15 : 17,
//         ),
//         unselectedLabelStyle: TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: isMobile ? 15 : 17,
//         ),
//         tabs: [
//           Tab(
//             height: 56,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.grid_view_rounded, size: isMobile ? 20 : 22),
//                 SizedBox(width: 8),
//                 Text('بطاقات'),
//               ],
//             ),
//           ),
//           Tab(
//             height: 56,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.list_alt_rounded, size: isMobile ? 20 : 22),
//                 SizedBox(width: 8),
//                 Text('قائمة'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernCardsView(bool isMobile, bool isTablet) {
//     return Container(
//       color: Color(0xFFF6F8FC),
//       child: RefreshIndicator(
//         onRefresh: _loadGrooms,
//         color: Color(0xFF667EEA),
//         backgroundColor: Colors.white,
//         displacement: 20,
//         strokeWidth: 3,
//         child: CustomScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           slivers: [
//             SliverToBoxAdapter(
//               child: SizedBox(height: 24),
//             ),
//             if (isLoading)
//               SliverFillRemaining(
//                 child: _buildModernLoadingWidget(isMobile),
//               )
//             else if (errorMessage.isNotEmpty)
//               SliverFillRemaining(
//                 child: _buildModernErrorWidget(isMobile),
//               )
//             else if (filteredGrooms.isEmpty)
//               SliverFillRemaining(
//                 child: _buildModernEmptyWidget(isMobile),
//               )
//             else
//               SliverPadding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isMobile ? 20 : (isTablet ? 32 : 24),
//                 ),
//                 sliver: SliverGrid(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       return SlideTransition(
//                         position: _slideAnimation,
//                         child: FadeTransition(
//                           opacity: _fadeAnimation,
//                           child: _buildModernGroomCard(filteredGrooms[index], isMobile, isTablet),
//                         ),
//                       );
//                     },
//                     childCount: filteredGrooms.length,
//                   ),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: _getCrossAxisCount(screenSize: MediaQuery.of(context).size),
//                     crossAxisSpacing: isMobile ? 16 : 20,
//                     mainAxisSpacing: isMobile ? 16 : 20,
//                     childAspectRatio: isMobile ? 0.88 : 0.85,
//                   ),
//                 ),
//               ),
//             SliverToBoxAdapter(
//               child: SizedBox(height: 24),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildModernListView(bool isMobile, bool isTablet) {
//     return Container(
//       color: Color(0xFFF6F8FC),
//       child: RefreshIndicator(
//         onRefresh: _loadGrooms,
//         color: Color(0xFF667EEA),
//         backgroundColor: Colors.white,
//         displacement: 20,
//         strokeWidth: 3,
//         child: CustomScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           slivers: [
//             SliverToBoxAdapter(
//               child: SizedBox(height: 24),
//             ),
//             if (isLoading)
//               SliverFillRemaining(
//                 child: _buildModernLoadingWidget(isMobile),
//               )
//             else if (errorMessage.isNotEmpty)
//               SliverFillRemaining(
//                 child: _buildModernErrorWidget(isMobile),
//               )
//             else if (filteredGrooms.isEmpty)
//               SliverFillRemaining(
//                 child: _buildModernEmptyWidget(isMobile),
//               )
//             else
//               SliverPadding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isMobile ? 20 : (isTablet ? 32 : 24),
//                 ),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       final widget = _buildModernGroomListItem(filteredGrooms[index], isMobile);
//                       return SlideTransition(
//                         position: _slideAnimation,
//                         child: FadeTransition(
//                           opacity: _fadeAnimation,
//                           child: widget,
//                         ),
//                       );
//                     },
//                     childCount: filteredGrooms.length,
//                   ),
//                 ),
//               ),
//             SliverToBoxAdapter(
//               child: SizedBox(height: 24),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   int _getCrossAxisCount({required Size screenSize}) {
//     if (screenSize.width > 1200) return 4;
//     if (screenSize.width > 768) return 3;
//     if (screenSize.width > 480) return 2;
//     return 2;
//   }

//   Widget _buildModernGroomCard(dynamic groom, bool isMobile, bool isTablet) {
//     final status = groom['status']?.toString() ?? 'unknown';
//     final statusColor = _getStatusColor(status);
//     final statusText = _getStatusText(status);

//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white,
//             Colors.white.withOpacity(0.95),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 20,
//             offset: Offset(0, 8),
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.withOpacity(0.08)),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
//           onTap: () => _showGroomDetails(groom, isMobile),
//           splashColor: Color(0xFF667EEA).withOpacity(0.1),
//           highlightColor: Color(0xFF667EEA).withOpacity(0.05),
//           child: Padding(
//             padding: EdgeInsets.all(isMobile ? 18 : 22),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Status badge and actions
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             statusColor.withOpacity(0.15),
//                             statusColor.withOpacity(0.1),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: statusColor.withOpacity(0.3),
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         statusText,
//                         style: TextStyle(
//                           color: statusColor,
//                           fontSize: isMobile ? 11 : 13,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                     _buildModernActionButton(groom, isMobile),
//                   ],
//                 ),
                
//                 SizedBox(height: isMobile ? 16 : 20),
                
//                 // Modern Avatar
//                 Container(
//                   width: isMobile ? 68 : 78,
//                   height: isMobile ? 68 : 78,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Color(0xFF667EEA).withOpacity(0.15),
//                         Color(0xFF764BA2).withOpacity(0.1),
//                       ],
//                     ),
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: Color(0xFF667EEA).withOpacity(0.3),
//                       width: 2.5,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Color(0xFF667EEA).withOpacity(0.2),
//                         blurRadius: 12,
//                         offset: Offset(0, 6),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.person_rounded,
//                     size: isMobile ? 32 : 38,
//                     color: Color(0xFF667EEA),
//                   ),
//                 ),
                
//                 SizedBox(height: isMobile ? 16 : 20),
                
//                 // Name
//                 Text(
//                   '${groom['first_name'] ?? ''} ${groom['last_name'] ?? ''}',
//                   style: TextStyle(
//                     fontSize: isMobile ? 15 : 17,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFF1A202C),
//                     height: 1.2,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
                
//                 SizedBox(height: 12),
                
//                 // Phone
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.grey.shade50,
//                         Colors.grey.shade50,
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.withOpacity(0.1)),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.phone_rounded,
//                         size: isMobile ? 16 : 18,
//                         color: Color(0xFF667EEA),
//                       ),
//                       SizedBox(width: 6),
//                       Text(
//                         groom['phone_number']?.toString() ?? '',
//                         style: TextStyle(
//                           fontSize: isMobile ? 13 : 15,
//                           color: AppColors.textSecondary,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 if (groom['guardian_name'] != null) ...[
//                   SizedBox(height: 10),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.family_restroom_rounded,
//                         size: isMobile ? 16 : 18,
//                         color: AppColors.textSecondary,
//                       ),
//                       SizedBox(width: 6),
//                       Flexible(
//                         child: Text(
//                           groom['guardian_name'],
//                           style: TextStyle(
//                             fontSize: isMobile ? 12 : 14,
//                             color: AppColors.textSecondary,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           textAlign: TextAlign.center,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//  Widget _buildModernActionButton(dynamic groom, bool isMobile) {
//   return PopupMenuButton<String>(
//     onSelected: (value) => _handleGroomAction(value, groom),
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//     offset: Offset(-12, 12),
//     elevation: 8,
//     color: Colors.white,
//     surfaceTintColor: Colors.white,
//     shadowColor: Colors.black.withOpacity(0.1),
//     itemBuilder: (context) => [
//       PopupMenuItem(
//         value: 'view',
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.blue.withOpacity(0.15),
//                       Colors.blue.withOpacity(0.1),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: Colors.blue.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Icon(Icons.visibility_rounded, color: Colors.blue.shade600, size: 18),
//               ),
//               SizedBox(width: 16),
//               Text(
//                 'عرض التفاصيل',
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.blue.shade700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
      
//       // Divider
//       PopupMenuItem(
//         enabled: false,
//         height: 1,
//         child: Divider(
//           color: Colors.grey.withOpacity(0.2),
//           thickness: 1,
//           height: 1,
//         ),
//       ),
      
//       PopupMenuItem(
//         value: 'delete',
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.red.withOpacity(0.15),
//                       Colors.red.withOpacity(0.1),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: Colors.red.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Icon(Icons.delete_rounded, color: Colors.red.shade600, size: 18),
//               ),
//               SizedBox(width: 16),
//               Text(
//                 'حذف',
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.red.shade700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//     child: Container(
//       padding: EdgeInsets.all(isMobile ? 10 : 12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.grey.shade100,
//             Colors.grey.shade50,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey.withOpacity(0.25)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Icon(
//         Icons.more_vert_rounded,
//         color: Color(0xFF667EEA),
//         size: isMobile ? 18 : 20,
//       ),
//     ),
//   );
// }
// Widget _buildModernLoadingWidget(bool isMobile) {
//   return Container(
//     padding: EdgeInsets.all(48),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Modern Loading Container
//         Container(
//           width: isMobile ? 80 : 100,
//           height: isMobile ? 80 : 100,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color(0xFF667EEA).withOpacity(0.15),
//                 Color(0xFF764BA2).withOpacity(0.1),
//                 Color(0xFF8B5CF6).withOpacity(0.05),
//               ],
//             ),
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: Color(0xFF667EEA).withOpacity(0.3),
//               width: 2,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Color(0xFF667EEA).withOpacity(0.2),
//                 blurRadius: 20,
//                 offset: Offset(0, 8),
//               ),
//               BoxShadow(
//                 color: Color(0xFF764BA2).withOpacity(0.1),
//                 blurRadius: 40,
//                 offset: Offset(0, 16),
//               ),
//             ],
//           ),
//           child: Center(
//             child: SizedBox(
//               width: isMobile ? 40 : 50,
//               height: isMobile ? 40 : 50,
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   Color(0xFF667EEA),
//                 ),
//                 strokeWidth: 4,
//                 strokeCap: StrokeCap.round,
//               ),
//             ),
//           ),
//         ),
        
//         SizedBox(height: 32),
        
//         // Modern Title
//         Text(
//           'جاري تحميل العرسان...',
//           style: TextStyle(
//             color: Color(0xFF1A202C),
//             fontSize: isMobile ? 18 : 20,
//             fontWeight: FontWeight.w800,
//             height: 1.3,
//           ),
//         ),
        
//         SizedBox(height: 12),
        
//         // Modern Subtitle
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color(0xFF667EEA).withOpacity(0.08),
//                 Color(0xFF764BA2).withOpacity(0.05),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: Color(0xFF667EEA).withOpacity(0.15),
//             ),
//           ),
//           child: Text(
//             'يرجى الانتظار قليلاً',
//             style: TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: isMobile ? 14 : 16,
//               fontWeight: FontWeight.w600,
//               height: 1.4,
//             ),
//           ),
//         ),
        
//         SizedBox(height: 24),
        
//         // Modern Progress Dots
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(3, (index) {
//             return Container(
//               margin: EdgeInsets.symmetric(horizontal: 4),
//               child: TweenAnimationBuilder<double>(
//                 duration: Duration(milliseconds: 800 + (index * 200)),
//                 tween: Tween(begin: 0.3, end: 1.0),
//                 builder: (context, value, child) {
//                   return AnimatedContainer(
//                     duration: Duration(milliseconds: 400),
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Color(0xFF667EEA).withOpacity(value),
//                           Color(0xFF764BA2).withOpacity(value * 0.8),
//                         ],
//                       ),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Color(0xFF667EEA).withOpacity(value * 0.3),
//                           blurRadius: 4,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//                 onEnd: () {
//                   // Repeat animation
//                   Future.delayed(Duration(milliseconds: 200), () {
//                     if (mounted) {
//                       setState(() {});
//                     }
//                   });
//                 },
//               ),
//             );
//           }),
//         ),
//       ],
//     ),
//   );
// }
// }