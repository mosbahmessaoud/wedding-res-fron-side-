// // lib/screens/splash_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:wedding_reservation_app/screens/auth/event_type_selection_screen.dart';
// import '../../utils/colors.dart';
// import '../../utils/constants.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
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
//       duration: const Duration(milliseconds: 1200), // Reduced from 2000ms
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
//       begin: 0.85, // Reduced from 0.8 for less dramatic effect
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut, // Changed from elasticOut for smoother animation
//     ));

//     _animationController.forward();

//     // Reduced delay from 8000ms to 3000ms
//     Future.delayed(const Duration(milliseconds: 3000), () {
//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           PageRouteBuilder(
//             pageBuilder: (context, animation, secondaryAnimation) => 
//               const EventTypeSelectionScreen(),
//             transitionDuration: const Duration(milliseconds: 300),
//             transitionsBuilder: (context, animation, secondaryAnimation, child) {
//               return FadeTransition(
//                 opacity: animation,
//                 child: child,
//               );
//             },
//           ),
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
//       body: _SplashContent(
//         fadeAnimation: _fadeAnimation,
//         scaleAnimation: _scaleAnimation,
//       ),
//     );
//   }
// }

// // Separate widget to prevent unnecessary rebuilds
// class _SplashContent extends StatelessWidget {
//   final Animation<double> fadeAnimation;
//   final Animation<double> scaleAnimation;

//   const _SplashContent({
//     required this.fadeAnimation,
//     required this.scaleAnimation,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: fadeAnimation,
//       builder: (context, child) {
//         return Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 AppColors.primary,
//                 AppColors.primary.withOpacity(0.8),
//                 AppColors.secondary.withOpacity(0.6),
//               ],
//             ),
//           ),
//           child: Center(
//             child: FadeTransition(
//               opacity: fadeAnimation,
//               child: ScaleTransition(
//                 scale: scaleAnimation,
//                 child: const _SplashLogo(),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // Separate const widget for logo content
// class _SplashLogo extends StatelessWidget {
//   const _SplashLogo();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Wedding Icon with simplified shadow
//         Container(
//           width: 120,
//           height: 120,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.15),
//             borderRadius: BorderRadius.circular(60),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.3),
//               width: 2,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.white.withOpacity(0.1),
//                 blurRadius: 8, // Reduced blur
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: const Icon(
//             Icons.favorite,
//             size: 60,
//             color: Colors.white,
//           ),
//         ),
        
//         const SizedBox(height: 30),
        
//         // App Title
//         Text(
//           AppConstants.appName,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 0.5,
//           ),
//           textAlign: TextAlign.center,
//         ),
        
//         const SizedBox(height: 10),
        
//         // Subtitle
//         Text(
//           'نظام متكامل لحجز مواعيد الأعراس',
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.9),
//             fontSize: 16,
//             fontWeight: FontWeight.w400,
//           ),
//           textAlign: TextAlign.center,
//         ),
        
//         const SizedBox(height: 50),
        
//         // Loading Indicator - Optimized
//         const SpinKitFadingCircle(
//           color: Colors.white,
//           size: 45.0, // Slightly reduced size
//         ),
        
//         const SizedBox(height: 20),
        
//         Text(
//           'جاري التحميل...',
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.8),
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }
// }