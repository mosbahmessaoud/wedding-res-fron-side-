// // lib/screens/event_type_selection_screen.dart
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:in_app_review/in_app_review.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:wedding_reservation_app/widgets/theme_toggle_button.dart';

// import '../auth/welcome_screen.dart';
// import 'religious_event_screen.dart';
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
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeOut,
//       ),
//     );

//     _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeOut,
//       ),
//     );

//     _animationController.forward();
//       // ✅ Add this — check for update after first frame renders
//   WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

// // ─── Version Check ────────────────────────────────────────────────────────────

// static const String _playStorePackageName = 'com.iTriDev.ASULI';

// // Future<void> _checkForUpdate() async {
// //   try {
// //     final packageInfo = await PackageInfo.fromPlatform();
// //     final currentVersion = packageInfo.version; // e.g. "1.2.0"

// //     final latestVersion = await _getLatestPlayStoreVersion();
// //     if (latestVersion == null) return;

// //     if (_isUpdateAvailable(currentVersion, latestVersion)) {
// //       if (mounted) _showUpdateDialog(latestVersion);
// //     }
// //   } catch (e) {
// //     debugPrint('Version check failed: $e');
// //   }
// // }


// Future<void> _checkForUpdate() async {
//   try {
//     final packageInfo = await PackageInfo.fromPlatform();
//     final currentVersion = packageInfo.version;

//     final latestVersion = await _getLatestPlayStoreVersion();
//     if (latestVersion == null) return;

//     if (_isUpdateAvailable(currentVersion, latestVersion)) {
//       if (mounted) _showUpdateDialog(latestVersion);
//     } else {
//       // No update needed — try to prompt for in-app review
//       await _requestInAppReview();
//     }
//   } catch (e) {
//     debugPrint('Version check failed: $e');
//   }
// }


// Future<void> _requestInAppReview() async {
//   try {
//     final inAppReview = InAppReview.instance;
//     if (await inAppReview.isAvailable()) {
//       await inAppReview.requestReview();
//     }
//   } catch (e) {
//     debugPrint('In-app review failed: $e');
//   }
// }


// // Future<String?> _getLatestPlayStoreVersion() async {
// //   try {
// //     // Scrape the Play Store page for the version number
// //     final url = 'https://play.google.com/store/apps/details?id=$_playStorePackageName&hl=en';
// //     final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

// //     if (response.statusCode == 200) {
// //       // Extract version from the page HTML
// //       final regex = RegExp(r'\[\[\["(\d+\.\d+\.\d+)"');
// //       final match = regex.firstMatch(response.body);
// //       return match?.group(1);
// //     }
// //   } catch (e) {
// //     debugPrint('Play Store fetch failed: $e');
// //   }
// //   return null;
// // }
// Future<String?> _getLatestPlayStoreVersion() async {
//   try {
//     final url = 'https://play.google.com/store/apps/details?id=$_playStorePackageName&hl=en';
//     final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

//     if (response.statusCode == 200) {
//       final regex = RegExp(r'\[\[\["(\d+\.\d+\.\d+)"');
//       final match = regex.firstMatch(response.body);
//       return match?.group(1);
//     }
//   } catch (e) {
//     debugPrint('Play Store fetch failed: $e');
//   }
//   return null;
// }


// // bool _isUpdateAvailable(String current, String latest) {
// //   final currentParts = current.split('.').map(int.parse).toList();
// //   final latestParts = latest.split('.').map(int.parse).toList();

// //   for (int i = 0; i < 3; i++) {
// //     final c = i < currentParts.length ? currentParts[i] : 0;
// //     final l = i < latestParts.length ? latestParts[i] : 0;
// //     if (l > c) return true;
// //     if (l < c) return false;
// //   }
// //   return false;
// // }

// bool _isUpdateAvailable(String current, String latest) {
//   final currentParts = current.split('.').map(int.parse).toList();
//   final latestParts = latest.split('.').map(int.parse).toList();

//   for (int i = 0; i < 3; i++) {
//     final c = i < currentParts.length ? currentParts[i] : 0;
//     final l = i < latestParts.length ? latestParts[i] : 0;
//     if (l > c) return true;
//     if (l < c) return false;
//   }
//   return false;
// }
// void _showUpdateDialog(String latestVersion) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) {
//       final isDark = Theme.of(context).brightness == Brightness.dark;
//       return AlertDialog(
//         backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
//         actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Update icon
//             Container(
//               width: 72,
//               height: 72,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.green.shade500, Colors.green.shade800],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.green.shade300.withOpacity(0.4),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Icon(Icons.system_update_outlined, color: Colors.white, size: 34),
//             ),

//             const SizedBox(height: 20),

//             Text(
//               'تحديث متاح ',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ),

//             const SizedBox(height: 10),

//             Text(
//               'الإصدار $latestVersion متاح الآن.\nيجب التحديث للاستمرار في استخدام التطبيق.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: isDark ? Colors.white60 : Colors.black54,
//                 height: 1.6,
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Divider
//             Divider(
//               color: isDark ? Colors.white12 : Colors.grey.shade200,
//               height: 1,
//             ),

//             const SizedBox(height: 20),

//             // Rating section
//             Text(
//               'قيّم التطبيق ⭐',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 color: isDark ? Colors.white70 : Colors.black87,
//               ),
//             ),

//             const SizedBox(height: 6),

//             Text(
//               'رأيكم يساعدنا على التحسين المستمر',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: isDark ? Colors.white38 : Colors.grey.shade500,
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Star rating row
//             _StarRatingRow(
//               isDark: isDark,
//               onRated: (rating) async {
//                 Navigator.of(context).pop();
//                 await _handleRating(rating);
//               },
//             ),

//             const SizedBox(height: 20),
//           ],
//         ),
//         actions: [
//           Row(
//             children: [
//               Expanded(
//                 child: TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   style: TextButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       side: BorderSide(
//                         color: isDark ? Colors.white12 : Colors.grey.shade300,
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     'لاحقاً',
//                     style: TextStyle(
//                       color: isDark ? Colors.white38 : Colors.grey.shade500,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 flex: 2,
//                 child: ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade700,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   onPressed: () async {
//                     Navigator.of(context).pop();
//                     final uri = Uri.parse(
//                       'https://play.google.com/store/apps/details?id=$_playStorePackageName',
//                     );
//                     if (await canLaunchUrl(uri)) {
//                       launchUrl(uri, mode: LaunchMode.externalApplication);
//                     }
//                   },
//                   // icon: const Icon(Icons.system_update_alt, size: 18),
//                   label: const Text(
//                     'تحديث الآن',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     },
//   );
// }

// Future<void> _handleRating(int rating) async {
//   try {
//     if (rating >= 4) {
//       // High rating — trigger native in-app review
//       final inAppReview = InAppReview.instance;
//       if (await inAppReview.isAvailable()) {
//         await inAppReview.requestReview();
//         return;
//       }
//     }
//     // Low rating or in-app review unavailable — open Play Store
//     final uri = Uri.parse(
//       'https://play.google.com/store/apps/details?id=$_playStorePackageName',
//     );
//     if (await canLaunchUrl(uri)) {
//       launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   } catch (e) {
//     debugPrint('Rating handler failed: $e');
//   }
// }
//   void _navigate(String type) {
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) => 
//           type == 'religious' ? const ReligiousEventScreen() : const WelcomeScreen(),
//         transitionDuration: const Duration(milliseconds: 200),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           return FadeTransition(opacity: animation, child: child);
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Scaffold(
//       body: _GradientBackground(isDark: isDark, onNavigate: _navigate),
//     );
//   }
// }

// // Separate widget to prevent gradient rebuilds
// class _GradientBackground extends StatelessWidget {
//   final bool isDark;
//   final Function(String) onNavigate;

//   const _GradientBackground({
//     required this.isDark,
//     required this.onNavigate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: isDark
//             ? [
//                 Colors.black.withOpacity(0.7),
//                 Colors.green.shade900.withOpacity(0.6),
//                 Colors.black.withOpacity(0.8),
//               ]
//             : [
//                 const Color.fromARGB(84, 255, 255, 255).withOpacity(0.95),
//                 const Color.fromARGB(20, 248, 248, 248).withOpacity(0.4),
//                 const Color.fromARGB(93, 255, 255, 255).withOpacity(0.95),
//               ],
//           stops: const [0.0, 0.5, 1.0],
//         ),
//       ),
//       child: Stack(
//         children: [
//           SafeArea(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 return SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       minHeight: constraints.maxHeight,
//                     ),
//                     child: IntrinsicHeight(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 32.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 60),
                          
//                           // App Icon
//                           _AppIcon(isDark: isDark),
                          
//                           const SizedBox(height: 48),
                          
//                           // Headings
//                           Text(
//                             'اختر نوع',
//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.w300,
//                               color: isDark ? Colors.white70 : Colors.black87,
//                               height: 1.2,
//                             ),
//                           ),
//                           Text(
//                             'المناسبة',
//                             style: TextStyle(
//                               fontSize: 34,
//                               fontWeight: FontWeight.bold,
//                               color: isDark ? Colors.green.shade300 : Colors.green.shade800,
//                               height: 1.1,
//                             ),
//                           ),
                          
//                           const SizedBox(height: 16),
                          
//                           // Subtitle
//                           Text(
//                             'يرجى تحديد نوع المناسبة المراد حجز تاريخها',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: isDark ? const Color.fromARGB(255, 217, 255, 218) : Colors.green.shade700,
//                               height: 1.5,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
                          
//                           const SizedBox(height: 48),
                          
//                           // Event Cards
//                           _EventCard(
//                             icon: Icons.favorite_border,
//                             title: 'حفل أيْرِيضْ',
//                             subtitle: 'إحياء حفل زفاف',
//                             isDark: isDark,
//                             onTap: () => onNavigate('wedding'),
//                           ),
                          
//                           const SizedBox(height: 16),
                          
//                           _EventCard(
//                             icon: Icons.favorite_outlined,
//                             title: 'حفل اللَّه أَكْبَر',
//                             subtitle: 'إحياء حفل اللَّه أَكْبَر',
//                             isDark: isDark,
//                             onTap: () => onNavigate('religious'),
//                           ),
                          
//                           const Spacer(),
//                           const SizedBox(height: 40),

//                           // Footer
//                           Center(
//                             child: Text(
//                               'صَلُّوا عَلَى النَّبِيِّ ﷺ',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: isDark ? Colors.green.shade400 : Colors.green.shade800,
//                                 height: 1.4,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
                          
//                           const SizedBox(height: 40),
//                         ],
//                       ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
          
//           // Theme Toggle - Outside SafeArea for better accessibility
//           const Positioned(
//             top: 48,
//             left: 16,
//             child: ThemeToggleButton(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Optimized App Icon widget
// class _AppIcon extends StatelessWidget {
//   final bool isDark;

//   const _AppIcon({required this.isDark});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 64,
//       height: 64,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.green.shade600,
//             Colors.green.shade800,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.green.shade300.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: const Icon(
//         Icons.celebration_outlined,
//         color: Colors.white,
//         size: 32,
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
//               ? Colors.green.shade300.withOpacity(0.15)
//               : Colors.green.shade300.withOpacity(0.08),
//             blurRadius: isDark ? 6 : 12,
//             offset: const Offset(0, 3),
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
//                 _EventIcon(icon: icon, isDark: isDark),
                
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

// // Separate widget for event icon to cache decoration
// class _EventIcon extends StatelessWidget {
//   final IconData icon;
//   final bool isDark;

//   const _EventIcon({required this.icon, required this.isDark});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 56,
//       height: 56,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.green.shade600,
//             Colors.green.shade800,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.green.shade300.withOpacity(0.2),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Icon(
//         icon,
//         size: 28,
//         color: Colors.white,
//       ),
//     );
//   }
// }


// class _StarRatingRow extends StatefulWidget {
//   final bool isDark;
//   final void Function(int rating) onRated;

//   const _StarRatingRow({required this.isDark, required this.onRated});

//   @override
//   State<_StarRatingRow> createState() => _StarRatingRowState();
// }

// class _StarRatingRowState extends State<_StarRatingRow> {
//   int _hovered = 0;
//   int _selected = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(5, (index) {
//         final starIndex = index + 1;
//         final isActive = starIndex <= (_hovered > 0 ? _hovered : _selected);

//         return GestureDetector(
//           onTap: () {
//             setState(() => _selected = starIndex);
//             Future.delayed(const Duration(milliseconds: 300), () {
//               widget.onRated(starIndex);
//             });
//           },
//           child: MouseRegion(
//             onEnter: (_) => setState(() => _hovered = starIndex),
//             onExit: (_) => setState(() => _hovered = 0),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 150),
//               padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//               child: AnimatedScale(
//                 scale: isActive ? 1.25 : 1.0,
//                 duration: const Duration(milliseconds: 150),
//                 curve: Curves.easeOut,
//                 child: Icon(
//                   isActive ? Icons.star_rounded : Icons.star_outline_rounded,
//                   size: 38,
//                   color: isActive
//                       ? Colors.amber.shade400
//                       : (widget.isDark ? Colors.white24 : Colors.grey.shade300),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }