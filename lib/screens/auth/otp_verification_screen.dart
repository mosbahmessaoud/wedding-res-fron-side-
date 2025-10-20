// lib/screens/auth/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wedding_reservation_app/screens/auth/login_screen.dart';
import 'package:wedding_reservation_app/widgets/common/custom_text_field.dart';
import 'dart:async';
import '../../utils/colors.dart' hide AppColors;
import '../../services/api_service.dart';
import '../groom/home_tab.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  // Updated to use single controller
  final TextEditingController _otpController = TextEditingController();
  
  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _shakeAnimation;
  
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  Timer? _timer;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    
    _animationController.forward();
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _otpCode {
    return _otpController.text;
  }

  bool get _hasAnyInput {
    return _otpController.text.isNotEmpty;
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

    Future<void> _DeletUser() async {
    try {
      print("---------  widget.phoneNumber = ${widget.phoneNumber}");
      await ApiService.deleteUser(widget.phoneNumber);
    } catch (e) {
      // Handle error if needed
      print('$e');

    }
    }

  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) {
      _showError('يرجى إدخال الرمز كاملاً');
      _shakeOTPFields();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await ApiService.verifyPhone(widget.phoneNumber, _otpCode);
      
      _showSuccessSnackBar('تم التحقق بنجاح!');

      // Add success animation before navigation
      await Future.delayed(Duration(milliseconds: 500));
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );

    } catch (e) {
      _showError('الرمز غير صحيح، يرجى المحاولة مرة أخرى');
      _shakeOTPFields();
      _clearOTP();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
      _errorMessage = '';
    });

    try {
      await ApiService.resendOTP(widget.phoneNumber);
      
      _showSuccessSnackBar('تم إرسال الرمز مرة أخرى');

      setState(() {
        _resendTimer = 60;
      });
      _startResendTimer();
      _clearOTP();
      
      
    } catch (e) {
      _showError('فشل في إعادة الإرسال، يرجى المحاولة لاحقاً');
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shakeOTPFields() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  Future<void> _clearOTP() async {
    _otpController.clear();
    setState(() {
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'التحقق من الهاتف',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.primary,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            _DeletUser();
            Navigator.pop(context);
          },
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              
              // Phone Icon
              SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 1),
                  end: Offset.zero,
                ).animate(_animationController),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.sms,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(height: 30),
              
              // Title
              Text(
                'التحقق من رقم الهاتف',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 12),
              
              // Description
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    children: [
                      TextSpan(text: 'تم إرسال رمز التحقق المكون من 6 أرقام إلى\n'),
                      TextSpan(
                        text: widget.phoneNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 40),
              
              // OTP Input Card
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _otpController,
                            label: 'رمز التحقق',
                            keyboardType: TextInputType.number,
                            validator: _validateOtp,
                            prefixIcon: Icons.security,
                            hint: 'أدخل الرمز هنا',
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              setState(() {}); // Trigger rebuild for button state
                            },
                          ), 
                          
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 32),
              
              // Verify Button
              _buildVerifyButton(),
              
              SizedBox(height: 24),
              
              // Resend Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  children: [
                    if (_resendTimer > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'إعادة الإرسال خلال $_resendTimer ثانية',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      TextButton.icon(
                        onPressed: _isResending ? null : _resendOTP,
                        icon: _isResending
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              )
                            : Icon(Icons.refresh, color: AppColors.primary),
                        label: Text(
                          _isResending ? 'جاري الإرسال...' : 'إعادة إرسال الرمز',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Change Phone Number
              TextButton.icon(
                onPressed: () {
                  _DeletUser();
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.edit,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                label: Text(
                  'تغيير رقم الهاتف',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _verifyOTP,
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          _isLoading ? 'جاري التحقق...' : 'تأكيد الرمز',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _otpCode.length == 6 
              ? AppColors.primary 
              : AppColors.primary.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _otpCode.length == 6 ? 4 : 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _shakeController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}