// import 'package:flutter/material.dart';
// import '../../utils/colors.dart';
// import '../../utils/constants.dart';

// class SuperAdminHomeScreen extends StatefulWidget {
//   @override
//   _SuperAdminHomeScreenState createState() => _SuperAdminHomeScreenState();
// }

// class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen>
//     with TickerProviderStateMixin {
//   int _currentIndex = 0;
//   late AnimationController _animationController;
//   late AnimationController _cardAnimationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 1500),
//       vsync: this,
//     );
//     _cardAnimationController = AnimationController(
//       duration: Duration(milliseconds: 800),
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
//       begin: Offset(0, 0.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     ));

//     _animationController.forward();
//     _cardAnimationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _cardAnimationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF8FAFC),
//       body: CustomScrollView(
//         slivers: [
//           _buildSliverAppBar(),
//           SliverToBoxAdapter(
//             child: IndexedStack(
//               index: _currentIndex,
//               children: [
//                 _buildModernHomeTab(),
//                 _buildComingSoonTab('القصور', Icons.castle, Color(0xFF6366F1)),
//                 _buildComingSoonTab('العشائر', Icons.groups, Color(0xFF8B5CF6)),
//                 _buildComingSoonTab('لجنات المدايح', Icons.business, Color(0xFF06B6D4)),
//                 _buildComingSoonTab('الهيئات', Icons.group_work, Color(0xFF10B981)),
//                 _buildComingSoonTab('الملف الشخصي', Icons.person, Color(0xFFF59E0B)),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildModernBottomNav(),
//     );
//   }

//   Widget _buildSliverAppBar() {
//     return SliverAppBar(
//       expandedHeight: 120,
//       floating: false,
//       pinned: true,
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF667EEA),
//               Color(0xFF764BA2),
//             ],
//           ),
//         ),
//         child: FlexibleSpaceBar(
//           title: Text(
//             'لوحة التحكم الرئيسية',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           centerTitle: true,
//         ),
//       ),
//       actions: [
//         Container(
//           margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
//           child: Stack(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.notifications_outlined,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//               Positioned(
//                 right: 4,
//                 top: 4,
//                 child: Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: Color(0xFFEF4444),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
//           child: CircleAvatar(
//             radius: 20,
//             backgroundColor: Colors.white.withOpacity(0.2),
//             child: Icon(
//               Icons.person_outline,
//               color: Colors.white,
//               size: 20,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildModernHomeTab() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildWelcomeCard(),
//               SizedBox(height: 32),
//               _buildQuickStats(),
//               SizedBox(height: 32),
//               _buildQuickActions(),
//               SizedBox(height: 32),
//               _buildRecentActivity(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildWelcomeCard() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF667EEA),
//             Color(0xFF764BA2),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0xFF667EEA).withOpacity(0.3),
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
//             children: [
//               Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Icon(
//                   Icons.admin_panel_settings,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//               ),
//               Spacer(),
//               Text(
//                 '🎉',
//                 style: TextStyle(fontSize: 24),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           Text(
//             'مرحباً بك، المدير العام',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'إدارة شاملة لجميع القصور والعشائر والهيئات من مكان واحد',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.9),
//               fontSize: 16,
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickStats() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'الإحصائيات السريعة',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF1F2937),
//           ),
//         ),
//         SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(child: _buildStatCard('125', 'القصور النشطة', Color(0xFF6366F1), Icons.castle)),
//             SizedBox(width: 16),
//             Expanded(child: _buildStatCard('89', 'العشائر المسجلة', Color(0xFF8B5CF6), Icons.groups)),
//           ],
//         ),
//         SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(child: _buildStatCard('34', 'لجنات المدايح', Color(0xFF06B6D4), Icons.business)),
//             SizedBox(width: 16),
//             Expanded(child: _buildStatCard('67', 'الهيئات المعتمدة', Color(0xFF10B981), Icons.group_work)),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(String number, String label, Color color, IconData icon) {
//     return AnimatedBuilder(
//       animation: _cardAnimationController,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: 0.8 + (_cardAnimationController.value * 0.2),
//           child: Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: color.withOpacity(0.1),
//                   spreadRadius: 0,
//                   blurRadius: 10,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: color.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         icon,
//                         color: color,
//                         size: 20,
//                       ),
//                     ),
//                     Spacer(),
//                     Icon(
//                       Icons.trending_up,
//                       color: Color(0xFF10B981),
//                       size: 16,
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   number,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1F2937),
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF6B7280),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildQuickActions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'الإجراءات السريعة',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF1F2937),
//           ),
//         ),
//         SizedBox(height: 16),
//         GridView.count(
//           crossAxisCount: 2,
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 16,
//           childAspectRatio: 1.0,
//           children: [
//             _buildModernActionCard(
//               icon: Icons.castle,
//               title: 'إدارة القصور',
//               subtitle: 'عرض وإدارة جميع القصور',
//               gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
//               onTap: () => setState(() => _currentIndex = 1),
//             ),
//             _buildModernActionCard(
//               icon: Icons.groups,
//               title: 'إدارة العشائر',
//               subtitle: 'إضافة وتعديل العشائر',
//               gradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
//               onTap: () => setState(() => _currentIndex = 2),
//             ),
//             _buildModernActionCard(
//               icon: Icons.business,
//               title: 'لجنات المدايح',
//               subtitle: 'إدارة لجنات المدايح',
//               gradient: LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)]),
//               onTap: () => setState(() => _currentIndex = 3),
//             ),
//             _buildModernActionCard(
//               icon: Icons.group_work,
//               title: 'الهيئات',
//               subtitle: 'إدارة الهيئات المختلفة',
//               gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
//               onTap: () => setState(() => _currentIndex = 4),
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
//     required LinearGradient gradient,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: gradient,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: gradient.colors.first.withOpacity(0.3),
//               spreadRadius: 0,
//               blurRadius: 15,
//               offset: Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Container(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//               ),
//               Spacer(),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentActivity() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'النشاط الأخير',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF1F2937),
//           ),
//         ),
//         SizedBox(height: 16),
//         Container(
//           padding: EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 spreadRadius: 0,
//                 blurRadius: 10,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               _buildActivityItem(
//                 icon: Icons.add_circle,
//                 title: 'تم إضافة قصر جديد',
//                 subtitle: 'قصر الأمير - منذ 2 ساعة',
//                 color: Color(0xFF10B981),
//               ),
//               Divider(height: 32),
//               _buildActivityItem(
//                 icon: Icons.edit,
//                 title: 'تم تحديث بيانات عشيرة',
//                 subtitle: 'عشيرة الأشراف - منذ 5 ساعات',
//                 color: Color(0xFF8B5CF6),
//               ),
//               Divider(height: 32),
//               _buildActivityItem(
//                 icon: Icons.group_add,
//                 title: 'انضمام هيئة جديدة',
//                 subtitle: 'هيئة الخدمات المجتمعية - منذ يوم',
//                 color: Color(0xFF06B6D4),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActivityItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//   }) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(
//             icon,
//             color: color,
//             size: 20,
//           ),
//         ),
//         SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1F2937),
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Color(0xFF6B7280),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Icon(
//           Icons.arrow_forward_ios,
//           size: 14,
//           color: Color(0xFF9CA3AF),
//         ),
//       ],
//     );
//   }

//   Widget _buildComingSoonTab(String title, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.all(40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
//               ),
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Icon(
//               icon,
//               size: 64,
//               color: color,
//             ),
//           ),
//           SizedBox(height: 24),
//           Text(
//             'قريباً جداً...',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1F2937),
//             ),
//           ),
//           SizedBox(height: 12),
//           Text(
//             'صفحة $title قيد التطوير',
//             style: TextStyle(
//               fontSize: 16,
//               color: Color(0xFF6B7280),
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 32),
//           Container(
//             width: double.infinity,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Color(0xFFE5E7EB),
//               borderRadius: BorderRadius.circular(2),
//             ),
//             child: FractionallySizedBox(
//               widthFactor: 0.7,
//               alignment: Alignment.centerLeft,
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 12),
//           Text(
//             '70% مكتمل',
//             style: TextStyle(
//               fontSize: 14,
//               color: color,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernBottomNav() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             spreadRadius: 0,
//             blurRadius: 10,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         selectedItemColor: Color(0xFF667EEA),
//         unselectedItemColor: Color(0xFF9CA3AF),
//         selectedLabelStyle: TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//         ),
//         unselectedLabelStyle: TextStyle(
//           fontWeight: FontWeight.w500,
//           fontSize: 11,
//         ),
//         items: [
//           BottomNavigationBarItem(
//             icon: _buildNavIcon(Icons.home_rounded, 0),
//             label: 'الرئيسية',
//           ),
//           BottomNavigationBarItem(
//             icon: _buildNavIcon(Icons.castle, 1),
//             label: 'القصور',
//           ),
//           BottomNavigationBarItem(
//             icon: _buildNavIcon(Icons.groups, 2),
//             label: 'العشائر',
//           ),
//           BottomNavigationBarItem(
//             icon: _buildNavIcon(Icons.business, 3),
//             label: 'المدايح',
//           ),
//           BottomNavigationBarItem(
//             icon: _buildNavIcon(Icons.group_work, 4),
//             label: 'الهيئات',
//           ),
//           BottomNavigationBarItem(
//             icon: _buildNavIcon(Icons.person_rounded, 5),
//             label: 'الملف',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavIcon(IconData icon, int index) {
//     bool isSelected = _currentIndex == index;
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 200),
//       padding: EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: isSelected ? Color(0xFF667EEA).withOpacity(0.1) : Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Icon(
//         icon,
//         size: isSelected ? 26 : 24,
//       ),
//     );
//   }
// }