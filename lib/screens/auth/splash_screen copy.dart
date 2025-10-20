// // lib/screens/splash_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:wedding_reservation_app/screens/auth/event_type_selection_screen.dart';
// import '../../utils/colors.dart';
// import '../../utils/constants.dart';
// import '../auth/welcome_screen.dart';
 
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));

//     _scaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.elasticOut,
//     ));

//     _animationController.forward();

//     // Navigate to welcome screen after 3 seconds
//     Future.delayed(Duration(milliseconds: 10000), () {
//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => EventTypeSelectionScreen()),
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final size = MediaQuery.of(context).size;
//     final isLargeScreen = size.width > 600;

//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       body: AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, child) {
//           return Stack(
//             children: [
//               // Background Image
//               if (!isLargeScreen)
//                 Container(
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage('assets/images/FB_IMG_1760946209045.jpg'),
//                       fit: BoxFit.cover,
//                       colorFilter: ColorFilter.mode(
//                         isDark 
//                           ? Color.fromARGB(120, 0, 0, 0) 
//                           : Color.fromARGB(120, 0, 0, 0) ,
//                         BlendMode.overlay,
//                       ),
//                     ),
//                   ),
//                 ),
              
//               // Gradient Overlay
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: isDark
//                       ? [
//                           Colors.black.withOpacity(0.3),
//                           Colors.green.shade900.withOpacity(0.1),
//                           Colors.black.withOpacity(0.3),
//                         ]
//                       : [
//                           Colors.black.withOpacity(0.3),
//                           Colors.green.shade900.withOpacity(0.1),
//                           Colors.black.withOpacity(0.3),
//                         ],
//                     stops: const [0.0, 0.5, 1.0],
//                   ),
//                 ),
//               ),
              
//               // Content
//               Center(
//                 child: FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: ScaleTransition(
//                     scale: _scaleAnimation,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Wedding Icon
//                         Container(
//                           width: 120,
//                           height: 120,
//                           decoration: BoxDecoration(
//                             color: isDark 
//                               ? Colors.white.withOpacity(0.15)
//                               : Colors.white.withOpacity(0.15),
//                             borderRadius: BorderRadius.circular(60),
//                             border: Border.all(
//                               color: isDark 
//                                 ? Colors.white.withOpacity(0.3)
//                                 : Colors.white.withOpacity(0.3),
//                               width: 2,
//                             ),
//                           ),
//                           child: Icon(
//                             Icons.favorite,
//                             size: 60,
//                             color: isDark ? Colors.white : Colors.white,
//                           ),
//                         ),
                        
//                         SizedBox(height: 60),
                        
//                         // App Title
//                         Text(
//                           AppConstants.appName,
//                           style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                             color: isDark ? Colors.white : Colors.white,
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
                        
//                         SizedBox(height: 10),
                        
//                         // Subtitle
//                         Text(
//                           'نظام متكامل لحجز مواعيد الأعراس',
//                           style: TextStyle(
//                             color: isDark 
//                               ? Colors.white
//                               : Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
                        
//                         SizedBox(height: 50),
                        
//                         // // Loading Indicator
//                         SpinKitFadingCircle(
//                           color: isDark ? Colors.white : Colors.white,
//                           size: 50.0,
//                         ),
                        
//                         SizedBox(height: 20),
                        
//                         Text(
//                           'جاري التحميل...',
//                           style: TextStyle(
//                             color: isDark 
//                               ? Colors.white
//                               : Colors.white,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }