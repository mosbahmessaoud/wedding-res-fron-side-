// // lib/screens/religious_event_screen.dart
// import 'package:flutter/material.dart';
// import '../../utils/colors.dart';

// class ReligiousEventScreen extends StatefulWidget {
//   const ReligiousEventScreen({super.key});

//   @override
//   _ReligiousEventScreenState createState() => _ReligiousEventScreenState();
// }

// class _ReligiousEventScreenState extends State<ReligiousEventScreen>
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
//       curve: Curves.easeOutBack,
//     ));

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
    
//     // Responsive sizing
//     final iconSize = screenHeight * 0.08; // 8% of screen height
//     final titleFontSize = screenWidth * 0.055; // 5.5% of screen width
//     final messageFontSize = screenWidth * 0.045; // 4.5% of screen width
//     final infoFontSize = screenWidth * 0.035; // 3.5% of screen width
//     final buttonFontSize = screenWidth * 0.045; // 4.5% of screen width
    
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.teal.shade700,
//               Colors.teal.shade600,
//               Colors.teal.shade500,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // App Bar
//               Padding(
//                 padding: EdgeInsets.all(70),
//                 child: Row(
//                   children: [

//                     Expanded(
//                       child: Text(
//                         'إحياء حفل الله أكبر',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: titleFontSize.clamp(18.0, 50.0),
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     SizedBox(width: screenWidth * 0.04), // Balance the back button
//                   ],
//                 ),
//               ),
              
//               // Main Content
//               Expanded(
//                 child: FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: ScaleTransition(
//                     scale: _scaleAnimation,
//                     child: SingleChildScrollView(
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           minHeight: screenHeight * 0.75,
//                         ),
//                         child: Center(
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: screenWidth * 0.08,
//                               vertical: screenHeight * 0.02,
//                             ),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 // Icon Container
                                
//                                 SizedBox(height: screenHeight * 0.03),
                                  
//                                 // Main Message Card
//                                 Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: screenWidth * 0.06,
//                                     vertical: screenHeight * 0.03,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(24),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.15),
//                                         blurRadius: 20,
//                                         offset: Offset(0, 10),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       // Title
//                                       Text(
//                                         'الصفحة قيد التطوير',
//                                         style: TextStyle(
//                                           color: Colors.teal.shade700,
//                                           fontSize: titleFontSize.clamp(18.0, 24.0),
//                                           fontWeight: FontWeight.bold,
//                                           height: 1.4,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
                                      
//                                       SizedBox(height: screenHeight * 0.02),
                                      
//                                       // Divider
//                                       Container(
//                                         width: screenWidth * 0.15,
//                                         height: 3,
//                                         decoration: BoxDecoration(
//                                           color: Colors.teal.shade300,
//                                           borderRadius: BorderRadius.circular(2),
//                                         ),
//                                       ),
                                      
//                                       SizedBox(height: screenHeight * 0.02),
                                      
//                                       // Message
//                                       Text(
//                                         'للحجز يرجى التواصل مع عشيرتك',
//                                         style: TextStyle(
//                                           color: Colors.grey.shade800,
//                                           fontSize: messageFontSize.clamp(14.0, 18.0),
//                                           height: 1.6,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
                                      
//                                       SizedBox(height: screenHeight * 0.025),
                                      
//                                       // Info Icon
//                                       Container(
//                                         padding: EdgeInsets.symmetric(
//                                           horizontal: screenWidth * 0.04,
//                                           vertical: screenHeight * 0.015,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: Colors.teal.shade50,
//                                           borderRadius: BorderRadius.circular(12),
//                                         ),
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Icon(
//                                               Icons.info_outline,
//                                               color: Colors.teal.shade700,
//                                               size: (infoFontSize * 1.2).clamp(16.0, 20.0),
//                                             ),
//                                             SizedBox(width: screenWidth * 0.02),
//                                             Flexible(
//                                               child: Text(
//                                                 'نعمل على تطوير هذه الميزة',
//                                                 style: TextStyle(
//                                                   color: Colors.teal.shade700,
//                                                   fontSize: infoFontSize.clamp(12.0, 14.0),
//                                                   fontWeight: FontWeight.w500,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
                                
//                                 SizedBox(height: screenHeight * 0.03),
                                
//                                 // Back Button
//                                 ElevatedButton(
//                                   onPressed: () => Navigator.of(context).pop(),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.white,
//                                     foregroundColor: Colors.teal.shade700,
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: screenWidth * 0.12,
//                                       vertical: screenHeight * 0.018,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(30),
//                                     ),
//                                     elevation: 8,
//                                     shadowColor: Colors.black.withOpacity(0.3),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(
//                                         Icons.arrow_back,
//                                         size: (buttonFontSize * 1.1).clamp(16.0, 20.0),
//                                       ),
//                                       SizedBox(width: screenWidth * 0.02),
//                                       Text(
//                                         'العودة',
//                                         style: TextStyle(
//                                           fontSize: buttonFontSize.clamp(16.0, 18.0),
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }