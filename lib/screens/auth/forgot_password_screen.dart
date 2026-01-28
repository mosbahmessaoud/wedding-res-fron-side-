// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/common/custom_text_field.dart' hide LoadingButton;
import '../../widgets/common/loading_button.dart';
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _otpSent = false;
  bool _otpVerified = false;
  int _currentStep = 1; // 1: Phone, 2: OTP, 3: New Password

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    // Add phone number format validation if needed
    if (value.length < 10) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز التحقق مطلوب';
    }
    if (value.length != 6) {
      return 'رمز التحقق يجب أن يكون 6 أرقام';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور الجديدة مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (value != _newPasswordController.text) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call your API service to send OTP
      await ApiService.resendOTP(_phoneController.text.trim());
      
      // For demo purposes, simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      setState(() {
        _otpSent = true;
        _currentStep = 2;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال رمز التحقق إلى رقم هاتفك'),
          backgroundColor: AppColors.success,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في إرسال رمز التحقق: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call your API service to verify OTP
      await ApiService.verifyPhone(
        _phoneController.text.trim(),
        _otpController.text,
      );
      
      // For demo purposes, simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      setState(() {
        _otpVerified = true;
        _currentStep = 3;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم التحقق من الرمز بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('رمز التحقق غير صحيح'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call your API service to reset password
      await ApiService.resetPassword(
        _phoneController.text.trim(),
        _otpController.text,
        _newPasswordController.text
      );
      
      // For demo purposes, simulate API call
      await Future.delayed(Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تغيير كلمة المرور بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate back to login screen
      Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تغيير كلمة المرور: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resendOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call your API service to resend OTP
      await ApiService.resendOTP(_phoneController.text.trim());
      
      // For demo purposes, simulate API call
      await Future.delayed(Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إعادة إرسال رمز التحقق'),
          backgroundColor: AppColors.success,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في إعادة إرسال رمز التحقق'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(1, _currentStep >= 1),
        _buildStepLine(_currentStep >= 2),
        _buildStepCircle(2, _currentStep >= 2),
        _buildStepLine(_currentStep >= 3),
        _buildStepCircle(3, _currentStep >= 3),
      ],
    );
  }

  Widget _buildStepCircle(int stepNumber, bool isActive) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primary : AppColors.surface,
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          stepNumber.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primary : AppColors.border,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('استعادة كلمة المرور'),
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
              SizedBox(height: 20),
              
              // Step Indicator
              _buildStepIndicator(),
              
              SizedBox(height: 40),
              
              // Title based on current step
              Text(
                _currentStep == 1 
                  ? 'استعادة كلمة المرور'
                  : _currentStep == 2
                    ? 'رمز التحقق'
                    : 'كلمة المرور الجديدة',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 28,
                  color: AppColors.primary,
                ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                _currentStep == 1 
                  ? 'أدخل رقم هاتفك لإرسال رمز التحقق'
                  : _currentStep == 2
                    ? 'أدخل رمز التحقق المرسل إلى هاتفك'
                    : 'أدخل كلمة المرور الجديدة',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              
              SizedBox(height: 40),

              // Step 1: Phone Number
              if (_currentStep == 1) ...[
                CustomTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  prefixIcon: Icons.phone,
                  hint: '0xxxxxxxx',
                ),
                
                SizedBox(height: 40),

                LoadingButton(
                  onPressed: _sendOtp,
                  isLoading: _isLoading,
                  text: 'إرسال رمز التحقق',
                ),
              ],

              // Step 2: OTP Verification
              if (_currentStep == 2) ...[
                CustomTextField(
                  controller: _otpController,
                  label: 'رمز التحقق',
                  keyboardType: TextInputType.number,
                  validator: _validateOtp,
                  prefixIcon: Icons.security,
                  hint: 'أدخل الرمز هنا',
                  maxLength: 6,
                  
                ), 
                
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لم تستلم الرمز؟ ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : _resendOtp,
                      child: Text(
                        'إعادة إرسال',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 40),

                LoadingButton(
                  onPressed: _verifyOtp,
                  isLoading: _isLoading,
                  text: 'تحقق من الرمز',
                ),
              ],

              // Step 3: New Password
              if (_currentStep == 3) ...[
                CustomTextField(
                  controller: _newPasswordController,
                  label: 'كلمة المرور الجديدة',
                  obscureText: _obscureNewPassword,
                  validator: _validateNewPassword,
                  prefixIcon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                
                SizedBox(height: 20),

                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'تأكيد كلمة المرور',
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                
                SizedBox(height: 40),

                LoadingButton(
                  onPressed: _resetPassword,
                  isLoading: _isLoading,
                  text: 'تغيير كلمة المرور',
                ),
              ],
              
              SizedBox(height: 30),

              // Back to Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'تذكرت كلمة المرور؟ ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'تسجيل الدخول',
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
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}