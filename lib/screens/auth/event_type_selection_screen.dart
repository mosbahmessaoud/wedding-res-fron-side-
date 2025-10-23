// lib/screens/event_type_selection_screen.dart
import 'package:flutter/material.dart';
import '../auth/welcome_screen.dart';
import 'religious_event_screen.dart';
import '../../widgets/theme_toggle_button.dart';

class EventTypeSelectionScreen extends StatefulWidget {
  const EventTypeSelectionScreen({super.key});

  @override
  State<EventTypeSelectionScreen> createState() => _EventTypeSelectionScreenState();
}

class _EventTypeSelectionScreenState extends State<EventTypeSelectionScreen>
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

  void _navigate(String type) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          type == 'religious' ? const ReligiousEventScreen() : const WelcomeScreen(),
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
    
    return Scaffold(
      body: _GradientBackground(isDark: isDark, onNavigate: _navigate),
    );
  }
}

// Separate widget to prevent gradient rebuilds
class _GradientBackground extends StatelessWidget {
  final bool isDark;
  final Function(String) onNavigate;

  const _GradientBackground({
    required this.isDark,
    required this.onNavigate,
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
                const Color.fromARGB(84, 255, 255, 255).withOpacity(0.95),
                const Color.fromARGB(20, 248, 248, 248).withOpacity(0.4),
                const Color.fromARGB(93, 255, 255, 255).withOpacity(0.95),
              ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
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
                  const SizedBox(height: 60),
                  
                  // App Icon - Simplified
                  _AppIcon(isDark: isDark),
                  
                  const SizedBox(height: 48),
                  
                  // Headings
                  Text(
                    'اختر نوع',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'المناسبة',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.green.shade300 : Colors.green.shade800,
                      height: 1.1,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    'يرجى تحديد نوع المناسبة المراد حجز تاريخها',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? const Color.fromARGB(255, 217, 255, 218) : Colors.green.shade700,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Event Cards
                  _EventCard(
                    icon: Icons.favorite_border,
                    title: 'حفل زفاف',
                    subtitle: 'إحياء حفل زفاف',
                    isDark: isDark,
                    onTap: () => onNavigate('wedding'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _EventCard(
                    icon: Icons.favorite_outlined,
                    title: 'حفل الله أكبر',
                    subtitle: 'إحياء حفل الله أكبر',
                    isDark: isDark,
                    onTap: () => onNavigate('religious'),
                  ),
                  
                  const Spacer(),
                  
                  // Footer
                  Center(
                    child: Text(
                      'صَلُّوا عَلَى النَّبِيِّ ﷺ',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.green.shade400 : Colors.green.shade800,
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
        ),
      ),
    );
  }
}

// Optimized App Icon widget
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

class _EventCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _EventCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
            ? Colors.green.shade400.withOpacity(0.3)
            : const Color.fromARGB(255, 17, 80, 21).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.green.shade300.withOpacity(0.15) // Reduced opacity
              : Colors.green.shade300.withOpacity(0.08), // Reduced opacity
            blurRadius: isDark ? 6 : 12, // Reduced blur
            offset: const Offset(0, 3), // Reduced offset
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _EventIcon(icon: icon, isDark: isDark),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.green.shade300 : Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Separate widget for event icon to cache decoration
class _EventIcon extends StatelessWidget {
  final IconData icon;
  final bool isDark;

  const _EventIcon({required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade600,
            Colors.green.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade300.withOpacity(0.2), // Reduced opacity
            blurRadius: 6, // Reduced blur
            offset: const Offset(0, 3), // Reduced offset
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 28,
        color: Colors.white,
      ),
    );
  }
}