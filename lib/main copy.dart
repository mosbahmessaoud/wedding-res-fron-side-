// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'screens/auth/splash_screen.dart';
// import 'utils/colors.dart';

// void main() {
//   runApp(WeddingReservationApp());
// }

// class WeddingReservationApp extends StatelessWidget {
//   const WeddingReservationApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'نظام حجز الأعراس',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         primaryColor: AppColors.primary,
//         scaffoldBackgroundColor: AppColors.background,
//         fontFamily: 'Cairo', // Add Arabic font to assets
//         textTheme: TextTheme(
//           displayLarge: TextStyle(
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//             color: AppColors.primary,
//           ),
//           titleLarge: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//           bodyMedium: TextStyle(
//             fontSize: 14,
//             color: AppColors.textSecondary,
//           ),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primary,
//             foregroundColor: Colors.white,
//             padding: EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             textStyle: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppColors.border),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppColors.border),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppColors.primary, width: 2),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppColors.error),
//           ),
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//       ),
//       home: SplashScreen(),
//     );
//   }
// }