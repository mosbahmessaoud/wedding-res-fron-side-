// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wedding_reservation_app/screens/auth/event_type_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _lightAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _lightAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation only once (no repeat)
    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 7000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
              const EventTypeSelectionScreen(),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: _SplashContent(
        fadeAnimation: _fadeAnimation,
        scaleAnimation: _scaleAnimation,
        lightAnimation: _lightAnimation,
        isDark: isDark,
      ),
    );
  }
}

// Separate widget to prevent unnecessary rebuilds
class _SplashContent extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double> lightAnimation;
  final bool isDark;

  const _SplashContent({
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.lightAnimation,
    required this.isDark,
  });

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
        child: Stack(
          children: [
            // Theme Toggle Button
            // const Positioned(
            //   top: 8,
            //   left: 16,
            //   child: ThemeToggleButton(),
            // ),
            
            // Scrollable Main Content
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                      MediaQuery.of(context).padding.top - 
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Center(
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: _SplashLogo(
                          lightAnimation: lightAnimation,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Separate widget for logo content with light animation using ShaderMask
class _SplashLogo extends StatelessWidget {
  final Animation<double> lightAnimation;
  final bool isDark;
  
  const _SplashLogo({
    required this.lightAnimation,
    required this.isDark,
  });

  // Helper method to create shader gradient with customizable parameters
  Shader _createLightShader(
    Rect bounds, 
    double animValue, 
    bool isDark, {
    double spreadWidth = 0.3,
    double brightnessIntensity = 1.0,
  }) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: isDark
          ? [
              Colors.green.shade300,
              Colors.green.shade300,
              Colors.green.shade100,
              Colors.white,
              Colors.green.shade100,
              Colors.green.shade300,
              Colors.green.shade300,
            ]
          : [
              Colors.green.shade800,
              Colors.green.shade800,
              Colors.green.shade400,
              Colors.green.shade200,
              Colors.green.shade400,
              Colors.green.shade800,
              Colors.green.shade800,
            ],
      stops: [
        0.0,
        (animValue - spreadWidth).clamp(0.0, 1.0),
        (animValue - spreadWidth / 2).clamp(0.0, 1.0),
        animValue.clamp(0.0, 1.0),
        (animValue + spreadWidth / 2).clamp(0.0, 1.0),
        (animValue + spreadWidth).clamp(0.0, 1.0),
        1.0,
      ],
    ).createShader(bounds);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lightAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Brand Name - Arabic with Light Sweep Effect
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => _createLightShader(
                  bounds,
                  lightAnimation.value,
                  isDark,
                  spreadWidth: 0.35,
                  brightnessIntensity: 1.2,
                ),
                child: Text(
                  'أسُولِي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Brand Name - English with Light Sweep Effect (slightly delayed)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => _createLightShader(
                  bounds,
                  (lightAnimation.value + 0.15).clamp(-2.0, 2.0),
                  isDark,
                  spreadWidth: 0.28,
                  brightnessIntensity: 1.1,
                ),
                child: Text(
                  'ASULI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Subtitle with Light Sweep Effect (offset animation for cascade effect)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => _createLightShader(
                  bounds,
                  (lightAnimation.value - 0.2).clamp(-2.0, 2.0),
                  isDark,
                  spreadWidth: 0.32,
                  brightnessIntensity: 1.0,
                ),
                child: Text(
                  'نظام متكامل لحجز مواعيد الأعراس',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Loading Indicator with subtle glow effect
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    // BoxShadow(
                    //   color: (isDark ? Colors.green.shade300 : Colors.green.shade700)
                    //       .withOpacity(0.3),
                    //   blurRadius: 20,
                    //   spreadRadius: 2,
                    // ),
                  ],
                ),
                child: SpinKitFadingCircle(
                  color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                  size: 45.0,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Loading text with light sweep (faster animation)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => _createLightShader(
                  bounds,
                  (lightAnimation.value + 0.3).clamp(-2.0, 2.0),
                  isDark,
                  spreadWidth: 0.25,
                  brightnessIntensity: 0.95,
                ),
                child: Text(
                  'جاري التحميل...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}