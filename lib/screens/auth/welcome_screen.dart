// lib/screens/auth/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/screens/auth/event_type_selection_screen.dart';
import 'package:wedding_reservation_app/screens/auth/sing_up_screen.dart';
import 'package:wedding_reservation_app/widgets/theme_toggle_button.dart';
import '../../utils/colors.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600; // Tablets and desktops
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: !isLargeScreen ? DecorationImage(
            image: AssetImage('assets/images/IMG_2838.JPG'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              isDark 
                ? Color.fromARGB(120, 0, 0, 0) 
                : Color.fromARGB(121, 228, 255, 242),
              BlendMode.overlay,
            ),
          ) : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                ? [
                    Colors.black.withOpacity(0.7),
                    Colors.green.shade900.withOpacity(0.6),
                    Colors.black.withOpacity(0.8),
                  ]
                : [
                    Colors.white,
                    Colors.white.withOpacity(0.85),
                    Colors.white,
                  ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Back button on top right
                Positioned(
                  top: 8,
                  right: 16,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.5),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: IconButton(
                      onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => EventTypeSelectionScreen()),
                            );                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Theme Toggle Button on top left
                Positioned(
                  top: 8,
                  left: 16,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value * 0.5),
                    child: ThemeToggleButton(),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 70),
                          
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
                                  Icons.celebration_outlined,
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
                                    'مرحباً بك في',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w300,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    'تطبيق الأعراس',
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
                                'يسرّنا أن نرحب بكم في تطبيق الأعراس،\nونضع بين أيديكم وسيلة ميسرة لتنظيم و حجز العرس الخاص بكم',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? const Color.fromARGB(255, 217, 255, 218) : const Color.fromARGB(255, 0, 93, 5),
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Action Buttons
                          Transform.translate(
                            offset: Offset(0, _slideAnimation.value * 0.5),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Primary CTA
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const MultiStepSignupScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shadowColor: Colors.green.shade300,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 2)
                                      ),
                                      child: const Text(
                                        'إنشاء حساب جديد',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Secondary CTA
                                  SizedBox(
                                    height: 48,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const LoginScreen(),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: isDark ? Colors.green.shade300 : Colors.green.shade700,
                                        side: BorderSide(
                                          color: isDark ? Colors.green.shade400 : Colors.green.shade300,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      child: const Text(
                                        'تسجيل الدخول',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Footer text
                          Transform.translate(
                            offset: Offset(0, _slideAnimation.value * 0.3),
                            child: Opacity(
                              opacity: _fadeAnimation.value * 0.6,
                              child: Center(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.green.shade400 : Colors.green.shade400,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}