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
  
//   // Filter states
//   String selectedStatusFilter = 'الكل';
//   final List<String> statusFilters = ['الكل', 'نشط', 'معلق', 'محظور'];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
//             Icon(
//               color == Colors.green ? Icons.check_circle : Icons.error,
//               color: Colors.white,
//               size: 20,
//             ),
//             SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isTablet = screenSize.width > 768;
//     final isMobile = screenSize.width <= 480;

//     return Scaffold(
//       backgroundColor: Color(0xFFF8FAFC),
//       body: Column(
//         children: [
//           _buildHeader(isMobile, isTablet),
//           _buildTabBar(isMobile),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildCardsView(isMobile, isTablet),
//                 _buildListView(isMobile, isTablet),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(bool isMobile, bool isTablet) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         isMobile ? 16 : 24, 
//         MediaQuery.of(context).padding.top + 16, 
//         isMobile ? 16 : 24, 
//         20
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppColors.primary,
//             AppColors.primary.withOpacity(0.8),
//             Colors.deepPurple.withOpacity(0.9),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
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
//                       'إدارة العرسان',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: isMobile ? 24 : (isTablet ? 32 : 28),
//                         fontWeight: FontWeight.w800,
//                         height: 1.2,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       'متابعة وإدارة حسابات العرسان',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: isMobile ? 14 : 16,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isMobile ? 12 : 16, 
//                   vertical: isMobile ? 6 : 8
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.white.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.people,
//                       color: Colors.white,
//                       size: isMobile ? 16 : 18,
//                     ),
//                     SizedBox(width: 6),
//                     Text(
//                       '${filteredGrooms.length}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: isMobile ? 14 : 16,
//                       ),
//                     ),
//                     SizedBox(width: 4),
//                     Text(
//                       'عريس',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.9),
//                         fontWeight: FontWeight.w500,
//                         fontSize: isMobile ? 12 : 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
          
//           SizedBox(height: isMobile ? 16 : 20),
          
//           // Search bar
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 15,
//                   offset: Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: TextField(
//               onChanged: (value) {
//                 setState(() {
//                   searchQuery = value;
//                   _applyFilters();
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'البحث في العرسان (الاسم، الهاتف، ولي الأمر)...',
//                 hintStyle: TextStyle(
//                   color: AppColors.textSecondary,
//                   fontSize: isMobile ? 14 : 16,
//                 ),
//                 prefixIcon: Container(
//                   padding: EdgeInsets.all(12),
//                   child: Icon(
//                     Icons.search, 
//                     color: AppColors.primary,
//                     size: isMobile ? 20 : 24,
//                   ),
//                 ),
//                 suffixIcon: searchQuery.isNotEmpty
//                     ? IconButton(
//                         icon: Icon(
//                           Icons.clear, 
//                           color: AppColors.textSecondary,
//                           size: isMobile ? 20 : 24,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             searchQuery = '';
//                             _applyFilters();
//                           });
//                         },
//                       )
//                     : null,
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.all(isMobile ? 16 : 20),
//               ),
//             ),
//           ),
          
//           SizedBox(height: isMobile ? 12 : 16),
          
//           // Filters
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: statusFilters.map((filter) {
//                 final isSelected = selectedStatusFilter == filter;
//                 return Container(
//                   margin: EdgeInsets.only(right: 8),
//                   child: FilterChip(
//                     label: Text(
//                       filter,
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
//                         fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                         fontSize: isMobile ? 12 : 14,
//                       ),
//                     ),
//                     selected: isSelected,
//                     onSelected: (selected) {
//                       setState(() {
//                         selectedStatusFilter = filter;
//                         _applyFilters();
//                       });
//                     },
//                     backgroundColor: Colors.white.withOpacity(0.15),
//                     selectedColor: Colors.white.withOpacity(0.25),
//                     side: BorderSide(
//                       color: isSelected 
//                         ? Colors.white.withOpacity(0.4) 
//                         : Colors.white.withOpacity(0.2),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isMobile ? 12 : 16,
//                       vertical: isMobile ? 4 : 6,
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabBar(bool isMobile) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TabBar(
//         controller: _tabController,
//         labelColor: AppColors.primary,
//         unselectedLabelColor: AppColors.textSecondary,
//         indicatorColor: AppColors.primary,
//         indicatorWeight: 3,
//         indicatorPadding: EdgeInsets.symmetric(horizontal: 20),
//         labelStyle: TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: isMobile ? 14 : 16,
//         ),
//         unselectedLabelStyle: TextStyle(
//           fontWeight: FontWeight.w500,
//           fontSize: isMobile ? 14 : 16,
//         ),
//         tabs: [
//           Tab(
//             icon: Icon(Icons.grid_view, size: isMobile ? 20 : 24),
//             text: 'بطاقات',
//             height: 60,
//           ),
//           Tab(
//             icon: Icon(Icons.list, size: isMobile ? 20 : 24),
//             text: 'قائمة',
//             height: 60,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCardsView(bool isMobile, bool isTablet) {
//     return Container(
//       color: Color(0xFFF8FAFC),
//       child: RefreshIndicator(
//         onRefresh: _loadGrooms,
//         color: AppColors.primary,
//         backgroundColor: Colors.white,
//         displacement: 20,
//         child: CustomScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           slivers: [
//             SliverToBoxAdapter(
//               child: SizedBox(height: 20),
//             ),
//             if (isLoading)
//               SliverFillRemaining(
//                 child: _buildLoadingWidget(isMobile),
//               )
//             else if (errorMessage.isNotEmpty)
//               SliverFillRemaining(
//                 child: _buildErrorWidget(isMobile),
//               )
//             else if (filteredGrooms.isEmpty)
//               SliverFillRemaining(
//                 child: _buildEmptyWidget(isMobile),
//               )
//             else
//               SliverPadding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isMobile ? 16 : (isTablet ? 32 : 20),
//                 ),
//                 sliver: SliverGrid(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       return FadeTransition(
//                         opacity: _fadeAnimation,
//                         child: _buildGroomCard(filteredGrooms[index], isMobile, isTablet),
//                       );
//                     },
//                     childCount: filteredGrooms.length,
//                   ),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: _getCrossAxisCount(screenSize: MediaQuery.of(context).size),
//                     crossAxisSpacing: isMobile ? 12 : 16,
//                     mainAxisSpacing: isMobile ? 12 : 16,
//                     childAspectRatio: isMobile ? 0.85 : 0.8,
//                   ),
//                 ),
//               ),
//             SliverToBoxAdapter(
//               child: SizedBox(height: 20),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildListView(bool isMobile, bool isTablet) {
//     return Container(
//       color: Color(0xFFF8FAFC),
//       child: RefreshIndicator(
//         onRefresh: _loadGrooms,
//         color: AppColors.primary,
//         backgroundColor: Colors.white,
//         displacement: 20,
//         child: CustomScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           slivers: [
//             SliverToBoxAdapter(
//               child: SizedBox(height: 20),
//             ),
//             if (isLoading)
//               SliverFillRemaining(
//                 child: _buildLoadingWidget(isMobile),
//               )
//             else if (errorMessage.isNotEmpty)
//               SliverFillRemaining(
//                 child: _buildErrorWidget(isMobile),
//               )
//             else if (filteredGrooms.isEmpty)
//               SliverFillRemaining(
//                 child: _buildEmptyWidget(isMobile),
//               )
//             else
//               SliverPadding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isMobile ? 16 : (isTablet ? 32 : 20),
//                 ),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       final widget = _buildGroomListItem(filteredGrooms[index], isMobile);
//                       return _fadeAnimation != null 
//                         ? FadeTransition(
//                             opacity: _fadeAnimation,
//                             child: widget,
//                           )
//                         : widget;
//                     },
//                     childCount: filteredGrooms.length,
//                   ),
//                 ),
//               ),
//             SliverToBoxAdapter(
//               child: SizedBox(height: 20),
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

//   Widget _buildGroomCard(dynamic groom, bool isMobile, bool isTablet) {
//     final status = groom['status']?.toString() ?? 'unknown';
//     final statusColor = _getStatusColor(status);
//     final statusText = _getStatusText(status);

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 15,
//             offset: Offset(0, 5),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.withOpacity(0.1)),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//           onTap: () => _showGroomDetails(groom, isMobile),
//           child: Padding(
//             padding: EdgeInsets.all(isMobile ? 16 : 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Status badge and actions
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         statusText,
//                         style: TextStyle(
//                           color: statusColor,
//                           fontSize: isMobile ? 10 : 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     _buildActionButton(groom, isMobile),
//                   ],
//                 ),
                
//                 SizedBox(height: isMobile ? 12 : 16),
                
//                 // Avatar
//                 Container(
//                   width: isMobile ? 60 : 70,
//                   height: isMobile ? 60 : 70,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         AppColors.primary.withOpacity(0.1),
//                         AppColors.primary.withOpacity(0.05),
//                       ],
//                     ),
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: AppColors.primary.withOpacity(0.2),
//                       width: 2,
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.person,
//                     size: isMobile ? 30 : 35,
//                     color: AppColors.primary,
//                   ),
//                 ),
                
//                 SizedBox(height: isMobile ? 12 : 16),
                
//                 // Name
//                 Text(
//                   '${groom['first_name'] ?? ''} ${groom['last_name'] ?? ''}',
//                   style: TextStyle(
//                     fontSize: isMobile ? 14 : 16,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.textPrimary,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
                
//                 SizedBox(height: 8),
                
//                 // Phone
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.phone,
//                         size: isMobile ? 14 : 16,
//                         color: AppColors.textSecondary,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         groom['phone_number']?.toString() ?? '',
//                         style: TextStyle(
//                           fontSize: isMobile ? 12 : 14,
//                           color: AppColors.textSecondary,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 if (groom['guardian_name'] != null) ...[
//                   SizedBox(height: 8),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.family_restroom,
//                         size: isMobile ? 14 : 16,
//                         color: AppColors.textSecondary,
//                       ),
//                       SizedBox(width: 4),
//                       Flexible(
//                         child: Text(
//                           groom['guardian_name'],
//                           style: TextStyle(
//                             fontSize: isMobile ? 11 : 12,
//                             color: AppColors.textSecondary,
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

//   Widget _buildActionButton(dynamic groom, bool isMobile) {
//     return PopupMenuButton<String>(
//       onSelected: (value) => _handleGroomAction(value, groom),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       offset: Offset(-10, 10),
//       itemBuilder: (context) => [
//         PopupMenuItem(
//           value: 'view',
//           child: Row(
//             children: [
//               Icon(Icons.visibility, color: Colors.blue, size: 18),
//               SizedBox(width: 8),
//               Text('عرض التفاصيل', style: TextStyle(fontSize: 14)),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: 'delete',
//           child: Row(
//             children: [
//               Icon(Icons.delete, color: Colors.red, size: 18),
//               SizedBox(width: 8),
//               Text('حذف', style: TextStyle(color: Colors.red, fontSize: 14)),
//             ],
//           ),
//         ),
//       ],
//       child: Container(
//         padding: EdgeInsets.all(isMobile ? 6 : 8),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(
//           Icons.more_vert,
//           color: AppColors.textSecondary,
//           size: isMobile ? 16 : 18,
//         ),
//       ),
//     );
//   }

//   Widget _buildGroomListItem(dynamic groom, bool isMobile) {
//     final status = groom['status']?.toString() ?? 'unknown';
//     final statusColor = _getStatusColor(status);
//     final statusText = _getStatusText(status);

//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 15,
//             offset: Offset(0, 5),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.withOpacity(0.1)),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//           onTap: () => _showGroomDetails(groom, isMobile),
//           child: Padding(
//             padding: EdgeInsets.all(isMobile ? 16 : 20),
//             child: Row(
//               children: [
//                 // Avatar
//                 Container(
//                   width: isMobile ? 50 : 60,
//                   height: isMobile ? 50 : 60,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         AppColors.primary.withOpacity(0.1),
//                         AppColors.primary.withOpacity(0.05),
//                       ],
//                     ),
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: AppColors.primary.withOpacity(0.2),
//                       width: 2,
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.person,
//                     size: isMobile ? 24 : 30,
//                     color: AppColors.primary,
//                   ),
//                 ),
                
//                 SizedBox(width: isMobile ? 12 : 16),
                
//                 // Info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               '${groom['first_name'] ?? ''} ${groom['last_name'] ?? ''}',
//                               style: TextStyle(
//                                 fontSize: isMobile ? 16 : 18,
//                                 fontWeight: FontWeight.w700,
//                                 color: AppColors.textPrimary,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: statusColor.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               statusText,
//                               style: TextStyle(
//                                 color: statusColor,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
                      
//                       SizedBox(height: 8),
                      
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.phone,
//                             size: 16,
//                             color: AppColors.textSecondary,
//                           ),
//                           SizedBox(width: 6),
//                           Text(
//                             groom['phone_number']?.toString() ?? '',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: AppColors.textSecondary,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
                      
//                       if (groom['guardian_name'] != null) ...[
//                         SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.family_restroom,
//                               size: 16,
//                               color: AppColors.textSecondary,
//                             ),
//                             SizedBox(width: 6),
//                             Expanded(
//                               child: Text(
//                                 'ولي الأمر: ${groom['guardian_name']}',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: AppColors.textSecondary,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
                
//                 SizedBox(width: 8),
                
//                 // Action button
//                 _buildActionButton(groom, isMobile),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleGroomAction(String action, dynamic groom) {
//     switch (action) {
//       case 'view':
//         _showGroomDetails(groom, MediaQuery.of(context).size.width <= 480);
//         break;
//       case 'delete':
//         _deleteGroom(groom);
//         break;
//     }
//   }

//   Future<void> _deleteGroom(dynamic groom) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Icon(Icons.warning, color: Colors.orange, size: 24),
//             SizedBox(width: 12),
//             Text(
//               'تأكيد الحذف',
//               style: TextStyle(
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 18,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'هل أنت متأكد من حذف العريس "${groom['first_name']} ${groom['last_name']}"؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
//           style: TextStyle(
//             color: AppColors.textSecondary,
//             fontSize: 16,
//             height: 1.4,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             style: TextButton.styleFrom(
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: Text(
//               'إلغاء',
//               style: TextStyle(
//                 color: AppColors.textSecondary,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: Text(
//               'حذف',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         // Show loading indicator
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => Center(
//             child: Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(color: AppColors.primary),
//                   SizedBox(height: 16),
//                   Text('جاري الحذف...'),
//                 ],
//               ),
//             ),
//           ),
//         );

//         await ApiService.deleteGroom(groom['phone_number'].toString());
        
//         if (!mounted) return;
        
//         // Close loading dialog
//         Navigator.of(context).pop();
        
//         _showSnackBar('تم حذف العريس بنجاح', Colors.green);
//         await _loadGrooms();
//       } catch (e) {
//         if (!mounted) return;
        
//         // Close loading dialog
//         Navigator.of(context).pop();
        
//         String errorMessage = e.toString().replaceAll('Exception: ', '');
//         // Handle the specific JSON format error
//         if (errorMessage.contains('FormatException')) {
//           errorMessage = 'تم حذف العريس بنجاح من قاعدة البيانات';
//           _showSnackBar(errorMessage, Colors.green);
//           await _loadGrooms();
//         } else {
//           _showSnackBar('فشل في حذف العريس: $errorMessage', Colors.red);
//         }
//       }
//     }
//   }

//   void _showGroomDetails(dynamic groom, bool isMobile) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.85,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(30),
//             topRight: Radius.circular(30),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Handle bar
//             Container(
//               height: 4,
//               width: 40,
//               margin: EdgeInsets.symmetric(vertical: 20),
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     Row(
//                       children: [
//                         Container(
//                           width: isMobile ? 60 : 80,
//                           height: isMobile ? 60 : 80,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 AppColors.primary.withOpacity(0.1),
//                                 AppColors.primary.withOpacity(0.05),
//                               ],
//                             ),
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: AppColors.primary.withOpacity(0.3),
//                               width: 2,
//                             ),
//                           ),
//                           child: Icon(
//                             Icons.person,
//                             size: isMobile ? 30 : 40,
//                             color: AppColors.primary,
//                           ),
//                         ),
//                         SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '${groom['first_name'] ?? ''} ${groom['last_name'] ?? ''}',
//                                 style: TextStyle(
//                                   fontSize: isMobile ? 20 : 24,
//                                   fontWeight: FontWeight.w800,
//                                   color: AppColors.textPrimary,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Container(
//                                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: _getStatusColor(groom['status']?.toString() ?? '').withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Text(
//                                   _getStatusText(groom['status']?.toString() ?? ''),
//                                   style: TextStyle(
//                                     color: _getStatusColor(groom['status']?.toString() ?? ''),
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     SizedBox(height: 30),
                    
//                     // Personal Info
//                     _buildDetailSection(
//                       'المعلومات الشخصية',
//                       Icons.person_outline,
//                       [
//                         _buildDetailItem('الاسم الأول', groom['first_name']),
//                         _buildDetailItem('الاسم الأخير', groom['last_name']),
//                         _buildDetailItem('اسم الأب', groom['father_name']),
//                         _buildDetailItem('اسم الجد', groom['grandfather_name']),
//                         _buildDetailItem('رقم الهاتف', groom['phone_number']),
//                         _buildDetailItem('تاريخ الميلاد', groom['birth_date']),
//                         _buildDetailItem('مكان الميلاد', groom['birth_address']),
//                         _buildDetailItem('العنوان الحالي', groom['home_address']),
//                       ],
//                       isMobile,
//                     ),
                    
//                     SizedBox(height: 30),
                    
//                     // Guardian Info
//                     if (groom['guardian_name'] != null) ...[
//                       _buildDetailSection(
//                         'معلومات ولي الأمر',
//                         Icons.family_restroom,
//                         [
//                           _buildDetailItem('اسم ولي الأمر', groom['guardian_name']),
//                           _buildDetailItem('هاتف ولي الأمر', groom['guardian_phone']),
//                           _buildDetailItem('صلة القرابة', groom['guardian_relation']),
//                         ],
//                         isMobile,
//                       ),
//                       SizedBox(height: 30),
//                     ],
                    
//                     // Account Info
//                     _buildDetailSection(
//                       'معلومات الحساب',
//                       Icons.account_circle_outlined,
//                       [
//                         _buildDetailItem('تاريخ التسجيل', _formatDate(groom['created_at'])),
//                         _buildDetailItem('حالة الحساب', _getStatusText(groom['status']?.toString() ?? '')),
//                         _buildDetailItem('آخر تحديث', _formatDate(groom['updated_at'])),
//                       ],
//                       isMobile,
//                     ),
                    
//                     SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(dynamic dateString) {
//     if (dateString == null) return 'غير محدد';
    
//     try {
//       final date = DateTime.parse(dateString.toString());
//       return '${date.day}/${date.month}/${date.year}';
//     } catch (e) {
//       return dateString.toString();
//     }
//   }

//   Widget _buildDetailSection(String title, IconData icon, List<Widget> children, bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(isMobile ? 8 : 10),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: AppColors.primary, size: isMobile ? 18 : 20),
//             ),
//             SizedBox(width: 12),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: isMobile ? 16 : 18,
//                 fontWeight: FontWeight.w700,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.all(isMobile ? 16 : 20),
//           decoration: BoxDecoration(
//             color: Colors.grey[50],
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.withOpacity(0.1)),
//           ),
//           child: Column(
//             children: children,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailItem(String label, dynamic value) {
//     if (value == null || value.toString().isEmpty) return SizedBox.shrink();
    
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value.toString(),
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingWidget(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: isMobile ? 50 : 60,
//             height: isMobile ? 50 : 60,
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//               strokeWidth: 3,
//             ),
//           ),
//           SizedBox(height: 24),
//           Text(
//             'جاري تحميل العرسان...',
//             style: TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: isMobile ? 14 : 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorWidget(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.red.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.error_outline,
//               size: isMobile ? 48 : 64,
//               color: Colors.red,
//             ),
//           ),
//           SizedBox(height: 24),
//           Text(
//             'حدث خطأ في تحميل البيانات',
//             style: TextStyle(
//               fontSize: isMobile ? 16 : 18,
//               fontWeight: FontWeight.w700,
//               color: AppColors.textPrimary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 12),
//           Text(
//             errorMessage,
//             style: TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: 14,
//               height: 1.4,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: _loadGrooms,
//             icon: Icon(Icons.refresh, size: isMobile ? 18 : 20),
//             label: Text(
//               'إعادة المحاولة',
//               style: TextStyle(fontSize: isMobile ? 14 : 16),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 20 : 30, 
//                 vertical: isMobile ? 12 : 15,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyWidget(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
//               size: isMobile ? 48 : 64,
//               color: AppColors.primary,
//             ),
//           ),
//           SizedBox(height: 24),
//           Text(
//             searchQuery.isNotEmpty 
//               ? 'لا توجد نتائج للبحث'
//               : 'لا توجد عرسان مسجلين',
//             style: TextStyle(
//               fontSize: isMobile ? 16 : 18,
//               fontWeight: FontWeight.w700,
//               color: AppColors.textPrimary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 12),
//           Text(
//             searchQuery.isNotEmpty
//               ? 'جرب البحث بكلمات مختلفة أو تحقق من الفلاتر'
//               : 'سيظهر العرسان المسجلين هنا عند إضافتهم',
//             style: TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: 14,
//               height: 1.4,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           if (searchQuery.isNotEmpty) ...[
//             SizedBox(height: 20),
//             TextButton.icon(
//               onPressed: () {
//                 setState(() {
//                   searchQuery = '';
//                   selectedStatusFilter = 'الكل';
//                   _applyFilters();
//                 });
//               },
//               icon: Icon(Icons.clear_all, size: isMobile ? 18 : 20),
//               label: Text(
//                 'مسح جميع الفلاتر',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primary,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isMobile ? 16 : 20,
//                   vertical: isMobile ? 8 : 12,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'banned':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _getStatusText(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return 'نشط';
//       case 'pending':
//         return 'معلق';
//       case 'banned':
//         return 'محظور';
//       default:
//         return 'غير معروف';
//     }
//   }
// }