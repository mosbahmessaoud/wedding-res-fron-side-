// // lib/screens/auth/welcome_screen.dart
// import 'package:flutter/material.dart';
// import '../../utils/colors.dart';
// import 'signup_screen.dart';
// import 'login_screen.dart';

// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppColors.primary.withOpacity(0.1),
//               AppColors.background,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 SizedBox(height: 60),
                
//                 // Logo and Title
//                 Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     color: AppColors.primary,
//                     borderRadius: BorderRadius.circular(50),
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColors.primary.withOpacity(0.3),
//                         spreadRadius: 5,
//                         blurRadius: 20,
//                         offset: Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.favorite,
//                     size: 50,
//                     color: Colors.white,
//                   ),
//                 ),
                
//                 SizedBox(height: 30),
                
//                 Text(
//                   'أهلاً وسهلاً بك',
//                   style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                     fontSize: 32,
//                     color: AppColors.primary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
                
//                 SizedBox(height: 15),
                
//                 Text(
//                   'في نظام حجز مواعيد الأعراس\nاحجز موعد زفافك بسهولة وأمان',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: AppColors.textSecondary,
//                     height: 1.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
                
//                 Spacer(),
                
//                 // Wedding illustration (you can replace with an image)
//                 Container(
//                   width: double.infinity,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.people, size: 40, color: AppColors.primary),
//                           SizedBox(width: 20),
//                           Icon(Icons.favorite, size: 50, color: AppColors.secondary),
//                           SizedBox(width: 20),
//                           Icon(Icons.celebration, size: 40, color: AppColors.primary),
//                         ],
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         'احجز، نظم، احتفل',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 Spacer(),
                
//                 // Signup Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => MultiStepSignupScreen()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(vertical: 18),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                     child: Text(
//                       'إنشاء حساب جديد',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ),
                
//                 SizedBox(height: 15),
                
//                 // Login Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => LoginScreen()),
//                       );
//                     },
//                     style: OutlinedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(vertical: 18),
//                       side: BorderSide(color: AppColors.primary, width: 2),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                     child: Text(
//                       'تسجيل الدخول',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ),
//                 ),
                
//                 SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

