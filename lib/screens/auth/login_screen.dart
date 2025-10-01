// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/screens/auth/forgot_password_screen.dart';
import 'package:wedding_reservation_app/screens/auth/tempCodeRunnerFile.dart';
import 'package:wedding_reservation_app/screens/clan%20admin/home_screen.dart';
import 'package:wedding_reservation_app/screens/groom/groom_home_screen.dart';
import 'package:wedding_reservation_app/screens/super%20admin/home_screen.dart';
import '../../utils/colors.dart' hide AppColors;
import '../../services/api_service.dart';
import '../../widgets/common/custom_text_field.dart' hide LoadingButton;
import '../../widgets/common/loading_button.dart';
import '../groom/home_tab.dart';
import 'signup_screen.dart';

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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
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

      final role = await ApiService.getRole();
    
      // Navigate to home screen based on user role
      if (role == 'groom') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GroomHomeScreen(initialTabIndex: 0,),
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
      } else  {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('دور المستخدم غير معروف'),
            backgroundColor: AppColors.error,
          ),
        );
      }


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تسجيل الدخول: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل الدخول'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              
              // Welcome Text
              Text(
                'مرحباً بعودتك',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 28,
                  color: AppColors.primary,
                ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                'سجل دخولك للمتابعة',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              
              SizedBox(height: 40),

              // Phone Number
              CustomTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                prefixIcon: Icons.phone,
                hint: '0xxxxxxxx',
              ),
              
              SizedBox(height: 20),

              // Password
              CustomTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
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
              
              SizedBox(height: 40),
              // Forgot Password Link
              Align(
                alignment: Alignment.centerLeft,
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
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),
              // Login Button
              LoadingButton(
                onPressed: _login,
                isLoading: _isLoading,
                text: 'تسجيل الدخول',
              ),
              
              SizedBox(height: 30),

              // Signup Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ليس لديك حساب؟ ',
                    style: TextStyle(color: AppColors.textSecondary),
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
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}