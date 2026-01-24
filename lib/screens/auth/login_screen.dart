import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_reservation_app/screens/auth/forgot_password_screen.dart';
import 'package:wedding_reservation_app/screens/auth/sing_up_screen.dart';
import 'package:wedding_reservation_app/screens/auth/welcome_screen.dart';
import 'package:wedding_reservation_app/screens/clan%20admin/home_screen.dart';
import 'package:wedding_reservation_app/screens/groom/groom_home_screen.dart';
import 'package:wedding_reservation_app/screens/super%20admin/home_screen.dart';
import 'package:wedding_reservation_app/services/notification_manager.dart';

import '../../services/api_service.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/theme_toggle_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  static const String _keyLastPhone = 'last_login_phone';

  @override
  void initState() {
    super.initState();
    _loadLastPhone();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Load last logged-in phone number
  Future<void> _loadLastPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPhone = prefs.getString(_keyLastPhone);
      
      if (lastPhone != null && lastPhone.isNotEmpty) {
        _phoneController.text = lastPhone;
      }
    } catch (e) {
      print('Error loading last phone: $e');
    }
  }

  // Save phone number for next login
  Future<void> _saveLastPhone(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastPhone, phone);
    } catch (e) {
      print('Error saving phone: $e');
    }
  }

  // void _showSnack(String msg, bool isError) {
  //   if (!mounted) return;
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
  //           const SizedBox(width: 12),
  //           Expanded(child: Text(msg)),
  //         ],
  //       ),
  //       backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       margin: const EdgeInsets.all(16),
  //     ),
  //   );
  // }


void _showSnack(String msg, bool isError) {
  if (!mounted) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar() // optional: prevents stacking
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10), 
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor:
            isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
}

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Get groom's actual phone
      String actualPhone = _phoneController.text.trim();
      try {
        actualPhone = await ApiService.getGroomPhoneBySearch(actualPhone);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnack('المستخدم غير موجود، لا يوجد حساب مسجل بهذا الرقم.', true);
        return;
      }

      // Login
      final response = await ApiService.login(actualPhone, _passwordController.text);
      
      if (!mounted) return;

      // Save phone number for next login
      await _saveLastPhone(_phoneController.text.trim());

      // Decode JWT to get role
      final token = response['access_token'];
      final parts = token.split('.');
      final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final role = payload['role'];

      // Start notifications in background
      NotificationManager().startMonitoring().catchError((e) => print('Notification error: $e'));

      // Navigate based on role
      Widget destination;
      switch (role) {
        case 'groom':
          destination = GroomHomeScreen(initialTabIndex: 0);
          break;
        case 'super_admin':
          destination = SuperAdminHomeScreen();
          break;
        case 'clan_admin':
          destination = ClanAdminHomeScreen();
          break;
        default:
          throw Exception('دور المستخدم غير معروف');
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 200),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showSnack(errorMessage, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width >= 750;
    
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            image: !isLargeScreen 
              ? DecorationImage(
                  image: const AssetImage('assets/images/IMG_2838.JPG'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    isDark 
                      ? const Color.fromARGB(120, 0, 0, 0) 
                      : const Color.fromARGB(55, 255, 255, 255),
                    BlendMode.overlay,
                  ),
                ) 
              : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                  ? (isLargeScreen
                      ? [
                          Colors.black.withOpacity(0.7),
                          Colors.green.shade500.withOpacity(0.1),
                          Colors.black.withOpacity(0.8),
                        ] 
                      : [
                          Colors.black.withOpacity(0.7),
                          Colors.green.shade900.withOpacity(0.6),
                          Colors.black.withOpacity(1),
                        ])  
                  : (isLargeScreen 
                      ? [
                          Colors.white.withOpacity(0),
                          Colors.green.shade300.withOpacity(0.06),
                          Colors.white.withOpacity(0.4),
                        ]
                      : [
                          Colors.white,
                          Colors.white.withOpacity(0.85),
                          Colors.white,
                        ]),
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          
                          // App Icon
                          Container(
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
                          
                          const SizedBox(height: 48),
                          
                          // Welcome Text
                          Column(
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
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            'سجل دخولك للمتابعة',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? const Color.fromARGB(255, 217, 255, 218) : const Color.fromARGB(255, 0, 93, 5),
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          
                          SizedBox(height: isLargeScreen ? size.height * 0.15 : size.height * 0.05),
                          
                          // Phone Number Field
                          CustomTextField(
                            controller: _phoneController,
                            label: 'رقم الهاتف',
                            labelColor: isDark ? Colors.white : Colors.black,
                            boxcolor: isDark ? const Color.fromARGB(255, 157, 42, 42) : Colors.black,
                            keyboardType: TextInputType.phone,
                            validator: (v) => v!.isEmpty ? 'رقم الهاتف مطلوب' : null,
                            prefixIcon: Icons.phone,
                            hint: '0xxxxxxxx',
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Password Field
                          CustomTextField(
                            controller: _passwordController,
                            label: 'كلمة المرور',
                            labelColor: isDark ? Colors.white : Colors.black,
                            obscureText: _obscurePassword,
                            validator: (v) => v!.isEmpty ? 'كلمة المرور مطلوبة' : null,
                            prefixIcon: Icons.lock,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Forgot Password Link
                          Align(
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
                          
                          const SizedBox(height: 40),
                          
                          // Login Button
                          SizedBox(
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
                                padding: const EdgeInsets.symmetric(vertical: 2),
                              ),
                              child: _isLoading
                                ? const SizedBox(
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
                          
                          const SizedBox(height: 24),
                          
                          // Signup Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ليس لديك حساب؟ ',
                                style: TextStyle(
                                  color: isDark 
                                    ? isLargeScreen ? Colors.white70 : Colors.white70 
                                    : isLargeScreen ? Colors.green.shade900 : Colors.black87,
                                  fontWeight: isLargeScreen ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: isLargeScreen ? 18 : 14,
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
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  
                  // Back Button
                  Positioned(
                    top: 8,
                    right: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => WelcomeScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 200),
                            ),
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
                  
                  // Theme Toggle
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
}