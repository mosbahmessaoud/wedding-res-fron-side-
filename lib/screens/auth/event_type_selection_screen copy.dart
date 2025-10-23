// // lib/screens/event_type_selection_screen.dart
// import 'package:flutter/material.dart';
// import '../auth/welcome_screen.dart';
// import 'religious_event_screen.dart';
// import '../../widgets/theme_toggle_button.dart';

// class EventTypeSelectionScreen extends StatefulWidget {
//   const EventTypeSelectionScreen({super.key});

//   @override
//   State<EventTypeSelectionScreen> createState() => _EventTypeSelectionScreenState();
// }

// class _EventTypeSelectionScreenState extends State<EventTypeSelectionScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeOut,
//       ),
//     );

//     _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeOut,
//       ),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }



//   void _navigate(String type) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => type == 'religious' ? ReligiousEventScreen() : WelcomeScreen(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(''),
//             fit: BoxFit.cover,
//             colorFilter: ColorFilter.mode(
//               isDark 
//                 ? Color.fromARGB(120, 0, 0, 0) 
//                 : Color.fromARGB(55, 255, 255, 255),
//               BlendMode.overlay,
//             ),
//           ),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: isDark
//                 ? [
//                     Colors.black.withOpacity(0.7),
//                     Colors.green.shade900.withOpacity(0.6),
//                     Colors.black.withOpacity(0.8),
//                   ]
//                 : [
//                     const Color.fromARGB(84, 255, 255, 255).withOpacity(0.95),
//                     const Color.fromARGB(20, 248, 248, 248).withOpacity(0.4),
//                     const Color.fromARGB(93, 255, 255, 255).withOpacity(0.95),
//                   ],
//               stops: const [0.0, 0.5, 1.0],
//             ),
//           ),
//           child: SafeArea(
//             child: Stack(
//               children: [
//                 // Theme Toggle Button on top right
//                 Positioned(
//                   top: 8,
//                   left: 16,
//                   child: ThemeToggleButton(),
//                 ),
                
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32.0),
//                   child: AnimatedBuilder(
//                     animation: _animationController,
//                     builder: (context, child) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 60),
                          
//                           // App Icon
//                           Transform.translate(
//                             offset: Offset(0, _slideAnimation.value),
//                             child: Opacity(
//                               opacity: _fadeAnimation.value,
//                               child: Container(
//                                 width: 64,
//                                 height: 64,
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                     colors: [
//                                       Colors.green.shade600,
//                                       Colors.green.shade800,
//                                     ],
//                                   ),
//                                   borderRadius: BorderRadius.circular(16),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.green.shade300.withOpacity(isDark ? 0.4 : 0.4),
//                                       blurRadius: 12,
//                                       offset: const Offset(0, 6),
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Icon(
//                                   Icons.celebration_outlined,
//                                   color: Colors.white,
//                                   size: 32,
//                                 ),
//                               ),
//                             ),
//                           ),
                          
//                           const SizedBox(height: 48),
                          
//                           // Main Heading
//                           Transform.translate(
//                             offset: Offset(0, _slideAnimation.value),
//                             child: Opacity(
//                               opacity: _fadeAnimation.value,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'اختر نوع',
//                                     style: TextStyle(
//                                       fontSize: 28,
//                                       fontWeight: FontWeight.w300,
//                                       color: isDark ? Colors.white70 : Colors.black87,
//                                       height: 1.2,
//                                     ),
//                                   ),
//                                   Text(
//                                     'المناسبة',
//                                     style: TextStyle(
//                                       fontSize: 34,
//                                       fontWeight: FontWeight.bold,
//                                       color: isDark ? Colors.green.shade300 : Colors.green.shade800,
//                                       height: 1.1,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
                          
//                           const SizedBox(height: 16),
                          
//                           // Subtitle
//                           Transform.translate(
//                             offset: Offset(0, _slideAnimation.value),
//                             child: Opacity(
//                               opacity: _fadeAnimation.value * 0.8,
//                               child: Text(
//                                 'يرجى تحديد نوع المناسبة المراد حجز تاريخها',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: isDark ? const Color.fromARGB(255, 217, 255, 218) : Colors.green.shade700,
//                                   height: 1.5,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                             ),
//                           ),
                          
//                           const SizedBox(height: 48),
                          
//                           // Event Cards
//                           Transform.translate(
//                             offset: Offset(0, _slideAnimation.value * 0.5),
//                             child: Opacity(
//                               opacity: _fadeAnimation.value,
//                               child: _EventCard(
//                                 icon: Icons.favorite_border,
//                                 title: 'حفل زفاف',
//                                 subtitle: 'إحياء حفل زفاف',
//                                 isDark: isDark,
//                                 onTap: () => _navigate('wedding'),
//                               ),
//                             ),
//                           ),
                          
//                           const SizedBox(height: 16),
                          
//                           Transform.translate(
//                             offset: Offset(0, _slideAnimation.value * 0.5),
//                             child: Opacity(
//                               opacity: _fadeAnimation.value,
//                               child: _EventCard(
//                                 // icon: Icons.bedtime_outlined,
//                                 // icon: Icons.auto_awesome_outlined,
//                                 icon: Icons.favorite_outlined,
//                                 title: 'حفل الله أكبر',
//                                 subtitle: 'إحياء حفل الله أكبر',
//                                 isDark: isDark,
//                                 onTap: () => _navigate('religious'),
//                               ),
//                             ),
//                           ),
                          
//                           const Spacer(),
                           
//                           // Footer text
//                           Transform.translate(
//                             offset: Offset(0, _slideAnimation.value * 0.3),
//                             child: Opacity(
//                               opacity: _fadeAnimation.value * 0.6,
//                               child: Center(
//                                 child: Text(
//                                   'صَلُّوا عَلَى النَّبِيِّ ﷺ',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: isDark ? Colors.green.shade400 : Colors.green.shade800,
//                                     height: 1.4,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ),
//                           ),
                          
//                           const SizedBox(height: 40),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _EventCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final bool isDark;
//   final VoidCallback onTap;

//   const _EventCard({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.isDark,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark 
//           ? Colors.black.withOpacity(0.3)
//           : Colors.white.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isDark 
//             ? Colors.green.shade400.withOpacity(0.3)
//             : const Color.fromARGB(255, 17, 80, 21).withOpacity(0.3),
//           width: 1.5,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: isDark 
//               ? Colors.green.shade300.withOpacity(0.2)
//               : Colors.green.shade300.withOpacity(0.1),
//             blurRadius: isDark ? 8 : 18,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Colors.green.shade600,
//                         Colors.green.shade800,
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.green.shade300.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     icon,
//                     size: 28,
//                     color: Colors.white,
//                   ),
//                 ),
                
//                 const SizedBox(width: 16),
                
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: isDark ? Colors.green.shade300 : Colors.green.shade800,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         subtitle,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: isDark ? Colors.white70 : Colors.black87,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   size: 16,
//                   color: isDark ? Colors.green.shade300 : Colors.green.shade700,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }