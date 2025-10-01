// lib/screens/auth/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wedding_reservation_app/screens/super%20admin/admin_otp_screen.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';


class OTPVerificationScreenE extends StatefulWidget {
  final String? phoneNumber;
  final bool isClanadmin;
    
  const OTPVerificationScreenE({
    super.key,
    this.phoneNumber, 
    required this.isClanadmin,
  });

  @override
  _OTPVerificationScreenEState createState() => _OTPVerificationScreenEState();
}

class _OTPVerificationScreenEState extends State<OTPVerificationScreenE>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  bool _isLoading = false;
  bool _isResending = false;
  bool _isPhoneVerified = false;
  String _errorMessage = '';
  String _successMessage = '';
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    if (widget.phoneNumber != null) {
      _phoneController.text = widget.phoneNumber!;
      _isPhoneVerified = true;
      _startCountdown();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    
    _animationController.forward();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _shakeError() {
    _shakeController.forward(from: 0);
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

Widget _buildAdminAccessButton(bool isTablet, bool isDesktop) {
  return Container(
    margin: EdgeInsets.only(top: 20),
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminOTPScreen(),
          ),
        );
      },
      icon: Icon(
        Icons.admin_panel_settings,
        size: 20,
        color: Colors.orange,
      ),
      label: Text(
        ' المشرف - البحث عن رمز التحقق',
        style: TextStyle(
          fontSize: isDesktop ? 16 : 14,
          fontWeight: FontWeight.w600,
          color: Colors.orange,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        side: BorderSide(color: Colors.orange, width: 2),
        backgroundColor: Colors.orange.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      await ApiService.resendOTP(_phoneController.text.trim());
      setState(() {
        _isPhoneVerified = true;
        _successMessage = 'تم إرسال رمز التحقق بنجاح';
      });
      _startCountdown();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      _shakeError();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;
    
    final otpCode = _otpController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      await ApiService.verifyPhone(_phoneController.text.trim(), otpCode);
      setState(() {
        _successMessage = 'تم التحقق من الهاتف بنجاح';
      });
      

      if(widget.isClanadmin == true){
        // Navigate to clan admin home screen by route
        Navigator.pushNamed(context, '/clan_admin_home');

      }else{
              // Navigate back or to next screen after successful verification
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context, true);
      }

      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      _shakeError();
      
      // Clear OTP field on error
      _otpController.clear();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    if (_countdown > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      await ApiService.resendOTP(_phoneController.text.trim());
      setState(() {
        _successMessage = 'تم إعادة إرسال رمز التحقق';
      });
      _startCountdown();
      
      // Clear previous OTP
      _otpController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      _shakeError();
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }



  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }


@override
Widget build(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final isTablet = screenSize.width > 600;
  final isDesktop = screenSize.width > 1200;
  final padding = isDesktop ? 32.0 : isTablet ? 24.0 : 16.0;

  return Scaffold(
    backgroundColor: Colors.grey[50],
    appBar: _buildAppBar(isTablet, isDesktop),
    body: FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 500 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isDesktop ? 60 : isTablet ? 40 : 20),
                  _buildHeader(isTablet, isDesktop),
                  SizedBox(height: 40),
                  _buildMainCard(isTablet, isDesktop),
                  SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty || _successMessage.isNotEmpty)
                    _buildMessageCard(isTablet, isDesktop),
                  // Add the admin access button here
                  _buildAdminAccessButton(isTablet, isDesktop),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  PreferredSizeWidget _buildAppBar(bool isTablet, bool isDesktop) {
    return AppBar(
      title: Text(
        'التحقق من رقم الهاتف',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: isDesktop ? 22 : isTablet ? 20 : 18,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primary.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet, bool isDesktop) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.verified_user,
            color: Colors.white,
            size: isDesktop ? 48 : isTablet ? 40 : 32,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'التحقق من رقم الهاتف',
          style: TextStyle(
            fontSize: isDesktop ? 32 : isTablet ? 28 : 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          _isPhoneVerified 
            ? 'أدخل رمز التحقق المرسل إلى هاتفك'
            : 'أدخل رقم هاتفك لإرسال رمز التحقق',
          style: TextStyle(
            fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMainCard(bool isTablet, bool isDesktop) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value * 10 * 
            ((_shakeAnimation.value - 0.5).sign),
            0,
          ),
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 32 : isTablet ? 28 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: Offset(0, 8),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (!_isPhoneVerified) ...[
                    _buildPhoneInputSection(isTablet, isDesktop),
                  ] else ...[
                    _buildOTPSection(isTablet, isDesktop),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneInputSection(bool isTablet, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم الهاتف',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: '0*********',
            hintTextDirection: TextDirection.ltr,
            prefixIcon: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.phone,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال رقم الهاتف';
            }
            if (value.trim().length < 10) {
              return 'رقم الهاتف قصير جداً';
            }
            return null;
          },
        ),
        SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _sendOTP,
            icon: _isLoading 
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(Icons.send),
            label: Text(
              _isLoading ? 'جاري الإرسال...' : 'إرسال رمز التحقق',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPSection(bool isTablet, bool isDesktop) {
    return Column(
      children: [
        Text(
          'تم إرسال رمز التحقق إلى',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _phoneController.text,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textDirection: TextDirection.ltr,
          ),
        ),
        SizedBox(height: 32),
        
        // OTP Input Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'رمز التحقق',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: '123456',
                hintTextDirection: TextDirection.ltr,
                counterText: '',
                prefixIcon: Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.security,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
              ),
              validator: _validateOtp,
            ),
            SizedBox(height: 20),
          ],
        ),
        
        SizedBox(height: 12),
        
        // Verify Button
        SizedBox(
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
                    color: Colors.white,
                  ),
                )
              : Icon(Icons.verified),
            label: Text(
              _isLoading ? 'جاري التحقق...' : 'تحقق من الرمز',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        
        SizedBox(height: 24),
        
        // Resend Section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'لم تستلم الرمز؟ ',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (_countdown > 0) ...[
              Text(
                'إعادة الإرسال خلال $_countdown ثانية',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: _isResending ? null : _resendOTP,
                child: Text(
                  _isResending ? 'جاري الإرسال...' : 'إعادة الإرسال',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: _isResending ? AppColors.textSecondary : AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
        
        SizedBox(height: 16),
        
        // Change Phone Number
        GestureDetector(
          onTap: () {
            setState(() {
              _isPhoneVerified = false;
              _otpController.clear();
              _timer?.cancel();
              _countdown = 0;
            });
          },
          child: Text(
            'تغيير رقم الهاتف',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard(bool isTablet, bool isDesktop) {
    final isError = _errorMessage.isNotEmpty;
    final message = isError ? _errorMessage : _successMessage;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 20 : isTablet ? 16 : 14),
      decoration: BoxDecoration(
        color: isError 
          ? Colors.red.withOpacity(0.1) 
          : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError 
            ? Colors.red.withOpacity(0.3)
            : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
            size: isDesktop ? 24 : 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: isError ? Colors.red[700] : Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}