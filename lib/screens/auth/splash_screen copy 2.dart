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
//       duration: Duration(milliseconds: 2000),
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

//     Future.delayed(Duration(milliseconds: 8000), () {
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
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       body: AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, child) {
//           return Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   AppColors.primary,
//                   AppColors.primary.withOpacity(0.8),
//                   AppColors.secondary.withOpacity(0.6),
//                 ],
//               ),
//             ),
//             child: Center(
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: ScaleTransition(
//                   scale: _scaleAnimation,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Wedding Icon
//                       Container(
//                         width: 120,
//                         height: 120,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(60),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.3),
//                             width: 2,
//                           ),
//                         ),
//                         child: Icon(
//                           Icons.favorite,
//                           size: 60,
//                           color: Colors.white,
//                         ),
//                       ),
                      
//                       SizedBox(height: 30),
                      
//                       // App Title
//                       Text(
//                         AppConstants.appName,
//                         style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                           color: Colors.white,
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
                      
//                       SizedBox(height: 10),
                      
//                       // Subtitle
//                       Text(
//                         'نظام متكامل لحجز مواعيد الأعراس',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.9),
//                           fontSize: 16,
//                           fontWeight: FontWeight.w400,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
                      
//                       SizedBox(height: 50),
                      
//                       // Loading Indicator
//                       SpinKitFadingCircle(
//                         color: Colors.white,
//                         size: 50.0,
//                       ),
                      
//                       SizedBox(height: 20),
                      
//                       Text(
//                         'جاري التحميل...',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.8),
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }