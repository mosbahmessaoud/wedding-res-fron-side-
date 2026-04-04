// lib/screens/super_admin/admin_otp_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_service.dart';
import '../../utils/colors.dart';

class AdminOTPScreen extends StatefulWidget {
  const AdminOTPScreen({super.key});

  @override
  AdminOTPScreenState createState() => AdminOTPScreenState();
}

class AdminOTPScreenState extends State<AdminOTPScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  String _otpCode = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }
  void refreshData() {
    // Add your refresh logic here
    // For example: _loadHalls();
    setState(() {
      // Trigger rebuild
    });
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

  void _shakeError() {
    _shakeController.forward(from: 0);
  }

  Future<void> _getOtpCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
      _otpCode = '';
    });

    try {
      final otpCode = await ApiService.getOtpCodeClanAdmin(_phoneController.text.trim());
      setState(() {
        _otpCode = otpCode;
        _successMessage = 'تم الحصول على رمز التحقق بنجاح';
      });
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

  void _copyToClipboard() {
    if (_otpCode.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _otpCode));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم نسخ رمز التحقق إلى الحافظة'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearResults() {
    setState(() {
      _otpCode = '';
      _successMessage = '';
      _errorMessage = '';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    _phoneController.dispose();
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
                    if (_otpCode.isNotEmpty)
                      _buildOtpResultCard(isTablet, isDesktop),
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
        title: Text('إعدادات العشيرة',
                style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18 ,
        ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/clan_admin_home');
            },
          ),
      
      automaticallyImplyLeading: false, // This removes the back button


      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      actions: [
        if (_otpCode.isNotEmpty)
          IconButton(
            onPressed: _clearResults,
            icon: Icon(Icons.clear_all),
            tooltip: 'مسح النتائج',
          ),
      ],
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
              colors: [Colors.orange, Colors.orange.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
            size: isDesktop ? 48 : isTablet ? 40 : 32,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'البحث عن رمز التحقق',
          style: TextStyle(
            fontSize: isDesktop ? 32 : isTablet ? 28 : 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'أدخل رقم هاتف المستخدم للحصول على رمز التحقق الخاص به',
          style: TextStyle(
            fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[700],
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'للمشرفين فقط',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رقم هاتف المستخدم',
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
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.phone_android,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      suffixIcon: _phoneController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _phoneController.clear();
                              _clearResults();
                            },
                            icon: Icon(Icons.clear, color: Colors.grey),
                          )
                        : null,
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
                        borderSide: BorderSide(color: Colors.orange, width: 2),
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
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _getOtpCode,
                      icon: _isLoading 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.search),
                      label: Text(
                        _isLoading ? 'جاري البحث...' : 'البحث عن رمز التحقق',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
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

  Widget _buildMessageCard(bool isTablet, bool isDesktop) {
    final isError = _errorMessage.isNotEmpty;
    final message = isError ? _errorMessage : _successMessage;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 20 : isTablet ? 16 : 14),
      margin: EdgeInsets.only(bottom: 16),
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

  Widget _buildOtpResultCard(bool isTablet, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'رمز التحقق للمستخدم',
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _otpCode,
                    style: TextStyle(
                      fontSize: isDesktop ? 32 : isTablet ? 28 : 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.green[700],
                      letterSpacing: 4,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 12),
                IconButton(
                  onPressed: _copyToClipboard,
                  icon: Icon(Icons.copy),
                  color: Colors.green[700],
                  tooltip: 'نسخ الرمز',
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'رقم الهاتف: ${_phoneController.text}',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.green[600],
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'اضغط على أيقونة النسخ لنسخ الرمز',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}