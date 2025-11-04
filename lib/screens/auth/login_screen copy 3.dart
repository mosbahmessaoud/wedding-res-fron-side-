// // lib/screens/auth/login_screen.dart
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:wedding_reservation_app/screens/auth/forgot_password_screen.dart';
// import 'package:wedding_reservation_app/screens/auth/sing_up_screen.dart';
// import 'package:wedding_reservation_app/screens/auth/welcome_screen.dart';
// import 'package:wedding_reservation_app/screens/clan%20admin/home_screen.dart';
// import 'package:wedding_reservation_app/screens/groom/groom_home_screen.dart';
// import 'package:wedding_reservation_app/screens/super%20admin/home_screen.dart';
// import '../../utils/colors.dart';
// import '../../services/api_service.dart';
// import '../../widgets/common/custom_text_field.dart' hide LoadingButton, AppColors;
// import '../../widgets/common/loading_button.dart';
// import '../../widgets/theme_toggle_button.dart';
// import '../../providers/theme_provider.dart';
// import '../groom/home_tab.dart';
// import 'signup_screen copy .dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
  
//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _slideAnimation;

//   // Cache precached image
//   late ImageProvider _backgroundImageProvider;
//   bool _imageLoaded = false;

//   @override
//   bool get wantKeepAlive => true;

//   // @override
//   // void initState() {
//   //   super.initState();
    
//   //   // Initialize animations
//   //   _animationController = AnimationController(
//   //     duration: const Duration(milliseconds: 600), // Reduced from 800ms
//   //     vsync: this,
//   //   );

//   //   _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//   //     CurvedAnimation(
//   //       parent: _animationController,
//   //       curve: Curves.easeOut,
//   //     ),
//   //   );

//   //   _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate( // Reduced from 30.0
//   //     CurvedAnimation(
//   //       parent: _animationController,
//   //       curve: Curves.easeOut,
//   //     ),
//   //   );

//   //   // Preload images
//   //   _preloadImages();
    
//   //   _animationController.forward();
//   // }

//   // @override
//   // void didChangeDependencies() {
//   //   super.didChangeDependencies();
//   //   // Only clear on first load, not on every navigation
//   //   if (_phoneController.text.isEmpty) {
//   //     _phoneController.clear();
//   //     _passwordController.clear();
//   //     _formKey.currentState?.reset();
//   //   }
//   // }

// @override
// void initState() {
//   super.initState();
  
//   // Initialize animations
//   _animationController = AnimationController(
//     duration: const Duration(milliseconds: 600),
//     vsync: this,
//   );

//   _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//     CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut,
//     ),
//   );

//   _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
//     CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut,
//     ),
//   );
  
//   // Initialize the image provider here
//   _backgroundImageProvider = const AssetImage('assets/images/IMG_2838.JPG');
  
//   _animationController.forward();
// }

// @override
// void didChangeDependencies() {
//   super.didChangeDependencies();
  
//   // Preload images only once
//   if (!_imageLoaded) {
//     _preloadImages();
//   }
// }

// // Updated preload method
// void _preloadImages() {
//   precacheImage(_backgroundImageProvider, context).then((_) {
//     if (mounted) {
//       setState(() {
//         _imageLoaded = true;
//       });
//     }
//   }).catchError((error) {
//     print('Error loading image: $error');
//     // Set to true anyway to prevent infinite retry
//     if (mounted) {
//       setState(() {
//         _imageLoaded = true;
//       });
//     }
//   });
// }

//   String? _validatePhone(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'رقم الهاتف مطلوب';
//     }
//     return null;
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'كلمة المرور مطلوبة';
//     }
//     return null;
//   }

//   // Optimized internet check with timeout
//   // Future<bool> _checkInternetConnection() async {
//   //   try {
//   //     final result = await InternetAddress.lookup('google.com')
//   //         .timeout(const Duration(seconds: 2)); // Reduced timeout
//   //     return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//   //   } catch (_) {
//   //     return false;
//   //   }
//   // }
//   // Method to check internet connectivity
// Future<bool> _checkInternetConnection() async {
//   try {
//     final connectivityResult = await Connectivity().checkConnectivity();
//     return !connectivityResult.contains(ConnectivityResult.none);
//   } catch (_) {
//     return false;
//   }
// }
  
//   // Optimized dialog - extracted as widget
//   void _showNoInternetDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => _NoInternetDialog(),
//     );
//   }

//   // Future<void> _login() async {
//   //   if (!_formKey.currentState!.validate()) {
//   //     return;
//   //   }

//   //   // Show loading immediately for better UX
//   //   if (!mounted) return;
//   //   setState(() {
//   //     _isLoading = true;
//   //   });

//   //   // Check internet in parallel with preparing data
//   //   final phoneText = _phoneController.text.trim();
//   //   final passwordText = _passwordController.text;
    
//   //   final hasInternet = await _checkInternetConnection();
    
//   //   if (!hasInternet) {
//   //     if (!mounted) return;
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //     _showNoInternetDialog();
//   //     return;
//   //   }

//   //   try {
//   //     final response = await ApiService.login(phoneText, passwordText);

//   //     if (!mounted) return;

//   //     // Decode JWT to get role
//   //     final token = response['access_token'];
//   //     final parts = token.split('.');
//   //     if (parts.length != 3) {
//   //       throw Exception('توكن غير صالح');
//   //     }
      
//   //     final payload = json.decode(
//   //       utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
//   //     );
      
//   //     final role = payload['role'];
    
//   //     if (!mounted) return;
      
//   //     // Use pushReplacement with custom transition for smoother navigation
//   //     Widget destination;
//   //     if (role == 'groom') {
//   //       destination = GroomHomeScreen(initialTabIndex: 0);
//   //     } else if (role == 'super_admin') {
//   //       destination = SuperAdminHomeScreen();
//   //     } else if (role == 'clan_admin') {
//   //       destination = ClanAdminHomeScreen();
//   //     } else {
//   //       if (!mounted) return;
//   //       _showErrorDialog('دور المستخدم غير معروف');
//   //       return;
//   //     }

//   //     // Navigate with fade transition
//   //     Navigator.of(context).pushReplacement(
//   //       PageRouteBuilder(
//   //         pageBuilder: (context, animation, secondaryAnimation) => destination,
//   //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//   //           return FadeTransition(opacity: animation, child: child);
//   //         },
//   //         transitionDuration: const Duration(milliseconds: 200),
//   //       ),
//   //     );
      
//   //   } catch (e) {
//   //     if (!mounted) return;
//   //     _showErrorDialog('$e');
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() {
//   //         _isLoading = false;
//   //       });
//   //     }
//   //   }
//   // }

//   Future<void> _login() async {
//   if (!_formKey.currentState!.validate()) {
//     return;
//   }

//   if (!mounted) return;
//   setState(() {
//     _isLoading = true;
//   });

//   final phoneText = _phoneController.text.trim();
//   final passwordText = _passwordController.text;

//   // Check internet connection with smooth handling
//   final hasInternet = await _checkInternetConnection();
  
//   if (!hasInternet) {
//     if (!mounted) return;
//     setState(() {
//       _isLoading = false;
//     });
//     _showNoInternetDialog();
//     return;
//   }

//   try {
//     final response = await ApiService.login(phoneText, passwordText)
//         .timeout(const Duration(seconds: 10)); // Add timeout to API call

//     if (!mounted) return;

//     // Decode JWT to get role
//     final token = response['access_token'];
//     final parts = token.split('.');
//     if (parts.length != 3) {
//       throw Exception('توكن غير صالح');
//     }
    
//     final payload = json.decode(
//       utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
//     );
    
//     final role = payload['role'];
  
//     if (!mounted) return;
    
//     Widget destination;
//     if (role == 'groom') {
//       destination = GroomHomeScreen(initialTabIndex: 0);
//     } else if (role == 'super_admin') {
//       destination = SuperAdminHomeScreen();
//     } else if (role == 'clan_admin') {
//       destination = ClanAdminHomeScreen();
//     } else {
//       if (!mounted) return;
//       _showErrorDialog('دور المستخدم غير معروف');
//       return;
//     }

//     Navigator.of(context).pushReplacement(
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) => destination,
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           return FadeTransition(opacity: animation, child: child);
//         },
//         transitionDuration: const Duration(milliseconds: 200),
//       ),
//     );
    
//   } on SocketException catch (_) {
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//     _showNoInternetDialog();
//   } on TimeoutException catch (_) {
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//     _showErrorDialog('انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.');
//   } catch (e) {
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//     _showErrorDialog('$e');
//   } finally {
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }


//   // Extracted error dialog for reusability
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => _ErrorDialog(message: message),
//     );
//   }
// @override
// Widget build(BuildContext context) {
//   super.build(context);
  
//   final isDark = Theme.of(context).brightness == Brightness.dark;
//   final screenWidth = MediaQuery.of(context).size.width;
//   final screenHeight = MediaQuery.of(context).size.height;
//   final isLargeScreen = screenWidth >= 750;
  
//   return Scaffold(
//     body: SizedBox.expand(
//       child: Container(
//         decoration: BoxDecoration(
//           image: (!isLargeScreen && _imageLoaded) 
//             ? DecorationImage(
//                 image: _backgroundImageProvider,
//                 fit: BoxFit.cover,
//                 colorFilter: ColorFilter.mode(
//                   isDark 
//                     ? const Color.fromARGB(120, 0, 0, 0) 
//                     : const Color.fromARGB(55, 255, 255, 255),
//                   BlendMode.overlay,
//                 ),
//               ) 
//             : null,
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: isDark
//                 ? (isLargeScreen
//                       ? [
//                           Colors.black.withOpacity(0.7),
//                           Colors.green.shade900.withOpacity(0.1),
//                           Colors.black.withOpacity(0.8),
//                         ] 
//                       : [
//                           Colors.black.withOpacity(0.7),
//                           Colors.green.shade900.withOpacity(0.1),
//                           Colors.black.withOpacity(0.8),
//                         ])
//                 : (isLargeScreen 
//                     ? [
//                         Colors.white.withOpacity(0),
//                         Colors.green.shade900.withOpacity(0.1),
//                         Colors.white.withOpacity(0.4),
//                       ]
//                     : [
//                         Colors.white.withOpacity(0.8),
//                         Colors.green.shade900.withOpacity(0.1),
//                         Colors.white,
//                       ]),
//               stops: const [0.0, 0.5, 1.0],
//             ),
//           ),
//             child: SafeArea(
//               child: Stack(
//                 children: [
//                   // Scrollable content
//                   SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(), // Smoother scrolling
//                     padding: const EdgeInsets.symmetric(horizontal: 32.0),
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(
//                         minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
//                       ),
//                       child: _LoginForm(
//                         formKey: _formKey,
//                         phoneController: _phoneController,
//                         passwordController: _passwordController,
//                         obscurePassword: _obscurePassword,
//                         isLoading: _isLoading,
//                         fadeAnimation: _fadeAnimation,
//                         slideAnimation: _slideAnimation,
//                         onObscurePasswordToggle: () {
//                           setState(() {
//                             _obscurePassword = !_obscurePassword;
//                           });
//                         },
//                         onLogin: _login,
//                         validatePhone: _validatePhone,
//                         validatePassword: _validatePassword,
//                         isDark: isDark,
//                         isLargeScreen: isLargeScreen,
//                         screenHeight: screenHeight,
//                       ),
//                     ),
//                   ),
                  
//                   // Back button
//                   Positioned(
//                     top: 8,
//                     right: 16,
//                     child: _BackButton(isDark: isDark),
//                   ),
                  
//                   // Theme Toggle Button
//                   Positioned(
//                     top: 8,
//                     left: 16,
//                     child: ThemeToggleButton(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }

// // Extracted widgets to prevent rebuilds
// class _LoginForm extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController phoneController;
//   final TextEditingController passwordController;
//   final bool obscurePassword;
//   final bool isLoading;
//   final Animation<double> fadeAnimation;
//   final Animation<double> slideAnimation;
//   final VoidCallback onObscurePasswordToggle;
//   final VoidCallback onLogin;
//   final String? Function(String?) validatePhone;
//   final String? Function(String?) validatePassword;
//   final bool isDark;
//   final bool isLargeScreen;
//   final double screenHeight;

//   const _LoginForm({
//     required this.formKey,
//     required this.phoneController,
//     required this.passwordController,
//     required this.obscurePassword,
//     required this.isLoading,
//     required this.fadeAnimation,
//     required this.slideAnimation,
//     required this.onObscurePasswordToggle,
//     required this.onLogin,
//     required this.validatePhone,
//     required this.validatePassword,
//     required this.isDark,
//     required this.isLargeScreen,
//     required this.screenHeight,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: fadeAnimation,
//       builder: (context, child) {
//         return Form(
//           key: formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 60),
              
//               // App Icon
//               _AnimatedWidget(
//                 slideAnimation: slideAnimation,
//                 fadeAnimation: fadeAnimation,
//                 child: _AppIcon(),
//               ),
              
//               const SizedBox(height: 48),
              
//               // Main Heading
//               _AnimatedWidget(
//                 slideAnimation: slideAnimation,
//                 fadeAnimation: fadeAnimation,
//                 child: _WelcomeText(isDark: isDark),
//               ),
              
//               const SizedBox(height: 16),
              
//               // Subtitle
//               _AnimatedWidget(
//                 slideAnimation: slideAnimation,
//                 fadeAnimation: fadeAnimation,
//                 opacity: 0.8,
//                 child: Text(
//                   'سجل دخولك للمتابعة',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: isDark ? const Color.fromARGB(255, 217, 255, 218) : const Color.fromARGB(255, 0, 93, 5),
//                     height: 1.5,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ),
              
//               if (isLargeScreen) SizedBox(height: screenHeight * 0.15) else SizedBox(height: screenHeight * 0.05),

//               // Phone Number
//               _AnimatedWidget(
//                 slideAnimation: slideAnimation,
//                 fadeAnimation: fadeAnimation,
//                 slideMultiplier: 0.5,
//                 child: CustomTextField(
//                   controller: phoneController,
//                   label: 'رقم هاتف العريس',
//                   labelColor: isDark ? Colors.white : Colors.black,
//                   boxcolor: isDark ? const Color.fromARGB(255, 157, 42, 42) : Colors.black,
//                   keyboardType: TextInputType.phone,
//                   validator: validatePhone,
//                   prefixIcon: Icons.phone,
//                   hint: '0xxxxxxxx',
//                 ),
//               ),
              
//               const SizedBox(height: 20),

//               // Password
//               _AnimatedWidget(
//                 slideAnimation: slideAnimation,
//                 fadeAnimation: fadeAnimation,
//                 slideMultiplier: 0.5,
//                 child: CustomTextField(
//                   controller: passwordController,
//                   label: 'كلمة المرور',
//                   labelColor: isDark ? Colors.white : Colors.black,
//                   obscureText: obscurePassword,
//                   validator: validatePassword,
//                   prefixIcon: Icons.lock,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       obscurePassword ? Icons.visibility : Icons.visibility_off,
//                     ),
//                     onPressed: onObscurePasswordToggle,
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 16),

//               // Forgot Password Link
//               _AnimatedWidget(
//                 slideAnimation: slideAnimation,
//                 fadeAnimation: fadeAnimation,
//                 slideMultiplier: 0.3,
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
//                       );
//                     },
//                     child: Text(
//                       'نسيت كلمة المرور؟',
//                       style: TextStyle(
//                         color: isDark ? Colors.green.shade300 : Colors.green.shade700,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // Login Button
//               _AnimatedWidget(
//                 slideAnimation: slideAnimation,
//                 fadeAnimation: fadeAnimation,
//                 slideMultiplier: 0.5,
//                 child: SizedBox(
//                   height: 48,
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: isLoading ? null : onLogin,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green.shade700,
//                       foregroundColor: Colors.white,
//                       elevation: 4,
//                       shadowColor: Colors.green.shade300,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                       disabledBackgroundColor: Colors.green.shade700.withOpacity(0.6),
//                       padding: EdgeInsets.symmetric(vertical: 2)
//                     ),
//                     child: isLoading
//                       ? SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         )
//                       : const Text(
//                           'تسجيل الدخول',
//                           style: TextStyle(
//                             fontSize: 16,  
//                             fontWeight: FontWeight.w600,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 24),

//               // Signup Link
//               _AnimatedWidget(
//                 slideAnimation: slideAnimation,
//                 fadeAnimation: fadeAnimation,
//                 slideMultiplier: 0.3,
//                 opacity: 0.8,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'ليس لديك حساب؟ ',
//                       style: TextStyle(
//                         color: isDark 
//                         ? isLargeScreen 
//                           ? Colors.white70  
//                           : Colors.white70 
//                         : isLargeScreen 
//                           ? Colors.green.shade900
//                           : Colors.black87,
//                         fontWeight: isLargeScreen ?FontWeight.w800 : FontWeight.w600,
//                         fontSize: isLargeScreen ? 18 : 14,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => MultiStepSignupScreen()),
//                         );
//                       },
//                       child: Text(
//                         'إنشاء حساب جديد',
//                         style: TextStyle(
//                           color: isDark ? Colors.green.shade300 : Colors.green.shade700,
//                           fontWeight: FontWeight.w800,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 40),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // Reusable animated widget wrapper
// class _AnimatedWidget extends StatelessWidget {
//   final Animation<double> slideAnimation;
//   final Animation<double> fadeAnimation;
//   final Widget child;
//   final double slideMultiplier;
//   final double opacity;

//   const _AnimatedWidget({
//     required this.slideAnimation,
//     required this.fadeAnimation,
//     required this.child,
//     this.slideMultiplier = 1.0,
//     this.opacity = 1.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Transform.translate(
//       offset: Offset(0, slideAnimation.value * slideMultiplier),
//       child: Opacity(
//         opacity: fadeAnimation.value * opacity,
//         child: child,
//       ),
//     );
//   }
// }

// class _AppIcon extends StatelessWidget {
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
//             color: Colors.green.shade300.withOpacity(0.4),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: const Icon(
//         Icons.login,
//         color: Colors.white,
//         size: 32,
//       ),
//     );
//   }
// }

// class _WelcomeText extends StatelessWidget {
//   final bool isDark;

//   const _WelcomeText({required this.isDark});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'مرحباً',
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.w300,
//             color: isDark ? Colors.white70 : Colors.black87,
//             height: 1.2,
//           ),
//         ),
//         Text(
//           'بعودتك',
//           style: TextStyle(
//             fontSize: 34,
//             fontWeight: FontWeight.bold,
//             color: isDark ? Colors.green.shade300 : Colors.green.shade800,
//             height: 1.1,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _BackButton extends StatelessWidget {
//   final bool isDark;

//   const _BackButton({required this.isDark});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: IconButton(
//         onPressed: () {
//           Navigator.pushReplacement(
//             context,
//             PageRouteBuilder(
//               pageBuilder: (context, animation, secondaryAnimation) => WelcomeScreen(),
//               transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                 return FadeTransition(opacity: animation, child: child);
//               },
//               transitionDuration: const Duration(milliseconds: 200),
//             ),
//           );
//         },
//         icon: Icon(
//           Icons.arrow_back,
//           color: isDark ? Colors.green.shade300 : Colors.green.shade700,
//           size: 24,
//         ),
//       ),
//     );
//   }
// }

// class _NoInternetDialog extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 360;
    
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: screenWidth > 600 ? 400 : screenWidth * 0.85,
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.wifi_off,
//                     color: AppColors.error,
//                     size: isSmallScreen ? 24 : 28,
//                   ),
//                   SizedBox(width: isSmallScreen ? 8 : 12),
//                   Expanded(
//                     child: Text(
//                       'لا يوجد اتصال بالإنترنت',
//                       style: TextStyle(
//                         fontSize: isSmallScreen ? 16 : 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: isSmallScreen ? 12 : 16),
              
//               Text(
//                 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
//                 style: TextStyle(
//                   fontSize: isSmallScreen ? 14 : 16,
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: isSmallScreen ? 16 : 20),
              
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isDark ? Colors.green.shade700 : Colors.green.shade600,
//                     foregroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(
//                       vertical: isSmallScreen ? 10 : 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     'حسناً',
//                     style: TextStyle(
//                       fontSize: isSmallScreen ? 14 : 16,
//                       fontWeight: FontWeight.w600,
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

// class _ErrorDialog extends StatelessWidget {
//   final String message;

//   const _ErrorDialog({required this.message});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final iconSize = screenWidth < 360 ? 24.0 : 28.0;
//     final titleFontSize = screenWidth < 360 ? 16.0 : 18.0;
//     final contentFontSize = screenWidth < 360 ? 14.0 : 16.0;
//     final horizontalPadding = screenWidth < 360 ? 16.0 : 24.0;
    
//     return AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       contentPadding: EdgeInsets.zero,
//       insetPadding: EdgeInsets.symmetric(
//         horizontal: screenWidth * 0.08,
//         vertical: screenHeight * 0.05,
//       ),
//       title: Padding(
//         padding: EdgeInsets.fromLTRB(
//           horizontalPadding,
//           20,
//           horizontalPadding,
//           8,
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.error_outline,
//               color: AppColors.error,
//               size: iconSize,
//             ),
//             SizedBox(width: screenWidth < 360 ? 8 : 12),
//             Expanded(
//               child: Text(
//                 'خطأ في تسجيل الدخول',
//                 style: TextStyle(fontSize: titleFontSize),
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 2,
//               ),
//             ),
//           ],
//         ),
//       ),
//       content: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxHeight: screenHeight * 0.5,
//           minWidth: screenWidth * 0.7,
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.fromLTRB(
//               horizontalPadding,
//               8,
//               horizontalPadding,
//               16,
//             ),
//             child: Text(
//               message,
//               style: TextStyle(fontSize: contentFontSize),
//             ),
//           ),
//         ),
//       ),
//       actions: [
//         Padding(
//           padding: EdgeInsets.fromLTRB(
//             horizontalPadding,
//             0,
//             horizontalPadding,
//             16,
//           ),
//           child: SizedBox(
//             width: double.infinity,
//             child: TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               style: TextButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text(
//                 'حسناً',
//                 style: TextStyle(fontSize: contentFontSize),
//               ),
//             ),
//           ),
//         ),
//       ],
//       actionsPadding: EdgeInsets.zero,
//     );
//   }
// }