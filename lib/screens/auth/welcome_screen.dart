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
      duration: const Duration(milliseconds: 500), // Reduced from 800ms
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate( // Reduced from 30.0
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

  // Navigate with instant transition
  void _navigateToSignup() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MultiStepSignupScreen(),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateBack() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const EventTypeSelectionScreen(),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: !isLargeScreen ? DecorationImage(
            image: const AssetImage('assets/images/IMG_2838.JPG'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              isDark 
                ? const Color.fromARGB(120, 0, 0, 0) 
                : const Color.fromARGB(121, 228, 255, 242),
              BlendMode.overlay,
            ),
          ) : null,  
        ),
        child: _GradientOverlay(isDark: isDark),
      ),
    );
  }
}

// Separate widget to prevent gradient rebuilds
class _GradientOverlay extends StatelessWidget {
  final bool isDark;

  const _GradientOverlay({required this.isDark});
@override
Widget build(BuildContext context) {
  return Container(
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
      child: SingleChildScrollView(  // Add this
        physics: const ClampingScrollPhysics(),  // Add this
        child: ConstrainedBox(  // Add this
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
          ),
          child: IntrinsicHeight(  // Add this
            child: _WelcomeContent(isDark: isDark),
          ),
        ),
      ),
    ),
  );
}
}

class _WelcomeContent extends StatelessWidget {
  final bool isDark;

  const _WelcomeContent({required this.isDark});

  void _navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MultiStepSignupScreen(),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const EventTypeSelectionScreen(),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Back button
      Positioned(
        top: 8,
        right: 16,
        child: IconButton(
          onPressed: () => _navigateBack(context),
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
      
      // Theme Toggle
      const Positioned(
        top: 8,
        left: 16,
        child: ThemeToggleButton(),
      ),
      
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 70),
            
            // App Icon - Simplified shadow
            _AppIcon(isDark: isDark),
            
            const SizedBox(height: 48),
            
            // Headings
            Text(
              'مرحباً بك في',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تطبيق الأعراس',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.green.shade300 : Colors.green.shade800,
                height: 1.1,
              ),
            ),
            
            const SizedBox(height: 18),
            
            // Subtitle
            Text(
              'يسرنا أن نرحب بكم في تطبيق الأعراس \nوسيلتكم الميسرة لتنطيم و حجز عرسكم',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? const Color.fromARGB(255, 217, 255, 218) : const Color.fromARGB(255, 0, 93, 5),
                height: 1.9,
                fontWeight: FontWeight.w400,
              ),
            ),
            
            const Spacer(),
            
            // Buttons
            _ActionButtons(
              isDark: isDark,
              onSignup: () => _navigateToSignup(context),
              onLogin: () => _navigateToLogin(context),
            ),
            
            const SizedBox(height: 32),
            
            // Footer
            Center(
              child: Text(
                ' برعاية عشيرة آت الشيخ الحاج مسعود © 2025',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.green.shade300 : Colors.green.shade800,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    ],
  );
}
}

// Separate widget for app icon to cache decoration
class _AppIcon extends StatelessWidget {
  final bool isDark;

  const _AppIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: Colors.green.shade300.withOpacity(0.3), // Reduced opacity
            blurRadius: 8, // Reduced blur
            offset: const Offset(0, 4), // Reduced offset
          ),
        ],
      ),
      child: const Icon(
        Icons.celebration_outlined,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}

// Separate widget for buttons
class _ActionButtons extends StatelessWidget {
  final bool isDark;
  final VoidCallback onSignup;
  final VoidCallback onLogin;

  const _ActionButtons({
    required this.isDark,
    required this.onSignup,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              elevation: 2, // Reduced from 4
              shadowColor: Colors.green.shade300.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 2),
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
        
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: onLogin,
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
    );
  }
}