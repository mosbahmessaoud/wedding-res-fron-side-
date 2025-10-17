// lib/screens/auth/login_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/screens/auth/forgot_password_screen.dart';
import 'package:wedding_reservation_app/screens/auth/sing_up_screen.dart';
import 'package:wedding_reservation_app/screens/auth/welcome_screen.dart';
import 'package:wedding_reservation_app/screens/clan%20admin/home_screen.dart';
import 'package:wedding_reservation_app/screens/groom/groom_home_screen.dart';
import 'package:wedding_reservation_app/screens/super%20admin/home_screen.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';
import '../../widgets/common/custom_text_field.dart' hide LoadingButton, AppColors;
import '../../widgets/common/loading_button.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../providers/theme_provider.dart';
import '../groom/home_tab.dart';
import 'signup_screen copy .dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Clear form fields when navigating to this screen
    _phoneController.clear();
    _passwordController.clear();
    // Reset form validation state
    _formKey.currentState?.reset();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    return null;
  }

  // Method to check internet connectivity
  Future<bool> _checkInternetConnection() async {
    try {
      // Try multiple hosts for better reliability
      final hosts = ['google.com', '1.1.1.1', '8.8.8.8' ,'0.0.0.0'];
      
      for (var host in hosts) {
        try {
          final result = await InternetAddress.lookup(host)
              .timeout(const Duration(seconds: 10));
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            return true;
          }
        } catch (_) {
          continue;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
  // Show no internet dialog
  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 600 ? 400 : screenWidth * 0.85,
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title with icon
                  Row(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        color: AppColors.error,
                        size: isSmallScreen ? 24 : 28,
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        child: Text(
                          'لا يوجد اتصال بالإنترنت',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  
                  // Content
                  Text(
                    'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.green.shade700 : Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'حسناً',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check internet connection first
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      _showNoInternetDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.login(
        _phoneController.text.trim(),
        _passwordController.text,
      );

      // Decode JWT to get role instead of making another API call
      final token = response['access_token'];
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('توكن غير صالح');
      }
      
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      
      final role = payload['role'];
    
      // Navigate based on role
      if (role == 'groom') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GroomHomeScreen(initialTabIndex: 0),
          ),
        );
      } else if (role == 'super_admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuperAdminHomeScreen(),
          ),
        );
      } else if (role == 'clan_admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ClanAdminHomeScreen(),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 28),
                  const SizedBox(width: 12),
                  const Text('خطأ'),
                ],
              ),
              content: const Text('دور المستخدم غير معروف'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('حسناً'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
  context: context,
  builder: (BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen size
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        
        // Responsive sizing
        final iconSize = screenWidth < 360 ? 24.0 : 28.0;
        final titleFontSize = screenWidth < 360 ? 16.0 : 18.0;
        final contentFontSize = screenWidth < 360 ? 14.0 : 16.0;
        final horizontalPadding = screenWidth < 360 ? 16.0 : 24.0;
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08, // 8% margin from edges
            vertical: screenHeight * 0.05,  // 5% margin from top/bottom
          ),
          title: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              20,
              horizontalPadding,
              8,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: iconSize,
                ),
                SizedBox(width: screenWidth < 360 ? 8 : 12),
                Expanded(
                  child: Text(
                    'خطأ في تسجيل الدخول',
                    style: TextStyle(fontSize: titleFontSize),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.5, // Max 50% of screen height
              minWidth: screenWidth * 0.7,   // Min 70% of screen width
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  16,
                ),
                child: Text(
                  '$e',
                  style: TextStyle(fontSize: contentFontSize),
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'حسناً',
                    style: TextStyle(fontSize: contentFontSize),
                  ),
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.zero,
        );
      },
    );
  },
);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/IMG_2838.JPG'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                isDark 
                  ? Color.fromARGB(120, 0, 0, 0) 
                  : Color.fromARGB(55, 255, 255, 255),
                BlendMode.overlay,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                  ? [
                      Colors.black.withOpacity(0.7),
                      Colors.green.shade900.withOpacity(0.4),
                      Colors.black.withOpacity(0.8),
                    ]
                  : [
                    Colors.white.withOpacity(0.85),
                    Colors.white.withOpacity(0.65),
                    Colors.white,
                    ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Scrollable content
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 60),
                              
                              // App Icon
                              Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.green.shade600,
                                          Colors.green.shade800,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.shade300.withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.login,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 48),
                              
                              // Main Heading
                              Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'مرحباً',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w300,
                                          color: isDark ? Colors.white70 : Colors.black87,
                                          height: 1.2,
                                        ),
                                      ),
                                      Text(
                                        'بعودتك',
                                        style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.green.shade300 : Colors.green.shade800,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Subtitle
                              Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: Opacity(
                                  opacity: _fadeAnimation.value * 0.8,
                                  child: Text(
                                    'سجل دخولك للمتابعة',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: isDark ? const Color.fromARGB(255, 217, 255, 218) : const Color.fromARGB(255, 0, 122, 6),
                                      height: 1.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 40),

                              // Phone Number
                              Transform.translate(
                                offset: Offset(0, _slideAnimation.value * 0.5),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.shade300.withOpacity(0.2),
                                          blurRadius: 25,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                                    ),
                                    child: CustomTextField(
                                      controller: _phoneController,
                                      label: 'رقم هاتف العريس',
                                      labelColor: isDark ? Colors.white : Colors.black,
                                      boxcolor: isDark ? const Color.fromARGB(255, 157, 42, 42) : Colors.black,
                                      keyboardType: TextInputType.phone,
                                      validator: _validatePhone,
                                      prefixIcon: Icons.phone,
                                      hint: '0xxxxxxxx',
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),

                              // Password
                              Transform.translate(
                                offset: Offset(0, _slideAnimation.value * 0.5),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.shade300.withOpacity(0.2),
                                          blurRadius: 25,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                                    ),
                                    child: CustomTextField(
                                      controller: _passwordController,
                                      label: 'كلمة المرور',
                                      labelColor: isDark ? Colors.white : Colors.black,
                                      obscureText: _obscurePassword,
                                      validator: _validatePassword,
                                      prefixIcon: Icons.lock,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),

                              // Forgot Password Link
                              Transform.translate(
                                offset: Offset(0, _slideAnimation.value * 0.3),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                                        );
                                      },
                                      child: Text(
                                        'نسيت كلمة المرور؟',
                                        style: TextStyle(
                                          color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Login Button
                              Transform.translate(
                                offset: Offset(0, _slideAnimation.value * 0.5),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: SizedBox(
                                    height: 48,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shadowColor: Colors.green.shade300,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        disabledBackgroundColor: Colors.green.shade700.withOpacity(0.6),
                                        padding: EdgeInsets.symmetric(vertical: 2)
                                      ),
                                      child: _isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'تسجيل الدخول',
                                            style: TextStyle(
                                              fontSize: 16,  
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),

                              // Signup Link
                              Transform.translate(
                                offset: Offset(0, _slideAnimation.value * 0.3),
                                child: Opacity(
                                  opacity: _fadeAnimation.value * 0.8,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'ليس لديك حساب؟ ',
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => MultiStepSignupScreen()),
                                          );
                                        },
                                        child: Text(
                                          'إنشاء حساب جديد',
                                          style: TextStyle(
                                            color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Back button on top left
                  Positioned(
                    top: 8,
                    right: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => WelcomeScreen()),
                          );
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  
                  // Theme Toggle Button on top right
                  Positioned(
                    top: 8,
                    left: 16,
                    child: ThemeToggleButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}