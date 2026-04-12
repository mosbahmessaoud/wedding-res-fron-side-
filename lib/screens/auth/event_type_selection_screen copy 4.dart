// lib/screens/event_type_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_reservation_app/widgets/theme_toggle_button.dart';

import '../auth/welcome_screen.dart';
import 'religious_event_screen.dart';

class EventTypeSelectionScreen extends StatefulWidget {
  const EventTypeSelectionScreen({super.key});

  @override
  State<EventTypeSelectionScreen> createState() =>
      _EventTypeSelectionScreenState();
}

class _EventTypeSelectionScreenState extends State<EventTypeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  static const String _reviewDoneKey = 'has_submitted_review';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      } else {
        await _checkAndShowReview();
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
      await _checkAndShowReview();
    }
  }

  Future<void> _checkAndShowReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasReviewed = prefs.getBool(_reviewDoneKey) ?? false;
      if (!hasReviewed && mounted) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) _showReviewDialog();
      }
    } catch (e) {
      debugPrint('Review check failed: $e');
    }
  }

  Future<void> _requestInAppReview() async {
    try {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        await inAppReview.openStoreListing();
      }
    } catch (e) {
      debugPrint('In-app review failed: $e');
    }
  }

  Future<void> _markReviewDone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reviewDoneKey, true);
    } catch (e) {
      debugPrint('Could not save review state: $e');
    }
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => _ReviewDialog(
        onRate: () async {
          Navigator.of(ctx).pop();
          await _markReviewDone();
          await _requestInAppReview();
        },
        onLater: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _navigate(String type) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            type == 'religious'
                ? const ReligiousEventScreen()
                : const WelcomeScreen(),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
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

// ─── Review Dialog ─────────────────────────────────────────────────────────────

class _ReviewDialog extends StatefulWidget {
  final VoidCallback onRate;
  final VoidCallback onLater;

  const _ReviewDialog({required this.onRate, required this.onLater});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _selectedStars = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF0D2B10),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.green.shade500, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  // ── Title ─────────────────────────────────────────────
                  const Text(
                    'كيف تجد تجربتك؟',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // ── Subtitle ──────────────────────────────────────────
                  const Text(
                    'تقييمك يساعدنا على التحسين المستمر\nويدعم تطوير التطبيق',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xAAFFFFFF),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // ── Stars ─────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      final isSelected = starIndex <= _selectedStars;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedStars = starIndex),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            isSelected
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: isSelected ? 42 : 36,
                            color: isSelected
                                ? Colors.amber.shade400
                                : const Color(0x55FFFFFF),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 28),

                  // ── Rate button ───────────────────────────────────────
                  GestureDetector(
                    onTap: _selectedStars > 0 ? widget.onRate : null,
                    child: Opacity(
                      opacity: _selectedStars > 0 ? 1.0 : 0.38,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _selectedStars > 0
                              ? [
                                  BoxShadow(
                                    color: Colors.green.shade400
                                        .withOpacity(0.45),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rate_review_outlined,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'قيّم الآن',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Later button ──────────────────────────────────────
                  GestureDetector(
                    onTap: widget.onLater,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      child: Text(
                        'ربما لاحقاً',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0x88FFFFFF),
                        ),
                      ),
                    ),
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

// ─── Gradient Background ───────────────────────────────────────────────────────

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
      child: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),

                            _AppIcon(isDark: isDark),

                            const SizedBox(height: 48),

                            Text(
                              'اختر نوع',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black87,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              'المناسبة',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.green.shade300
                                    : Colors.green.shade800,
                                height: 1.1,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'يرجى تحديد نوع المناسبة المراد حجز تاريخها',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? const Color.fromARGB(255, 217, 255, 218)
                                    : Colors.green.shade700,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const SizedBox(height: 48),

                            _EventCard(
                              icon: Icons.favorite_border,
                              title: 'حفل أيْرِيضْ',
                              subtitle: 'إحياء حفل زفاف',
                              isDark: isDark,
                              onTap: () => onNavigate('wedding'),
                            ),

                            const SizedBox(height: 16),

                            _EventCard(
                              icon: Icons.favorite_outlined,
                              title: 'حفل اللَّه أَكْبَر',
                              subtitle: 'إحياء حفل اللَّه أَكْبَر',
                              isDark: isDark,
                              onTap: () => onNavigate('religious'),
                            ),

                            const Spacer(),
                            const SizedBox(height: 40),

                            Center(
                              child: Text(
                                'صَلُّوا عَلَى النَّبِيِّ ﷺ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.green.shade400
                                      : Colors.green.shade800,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Positioned(
            top: 48,
            left: 16,
            child: ThemeToggleButton(),
          ),
        ],
      ),
    );
  }
}

// ─── App Icon ──────────────────────────────────────────────────────────────────

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
          colors: [Colors.green.shade600, Colors.green.shade800],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade300.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.celebration_outlined,
          color: Colors.white, size: 32),
    );
  }
}

// ─── Event Card ────────────────────────────────────────────────────────────────

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
                ? Colors.green.shade300.withOpacity(0.15)
                : Colors.green.shade300.withOpacity(0.08),
            blurRadius: isDark ? 6 : 12,
            offset: const Offset(0, 3),
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
                          color: isDark
                              ? Colors.green.shade300
                              : Colors.green.shade800,
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
                  color: isDark
                      ? Colors.green.shade300
                      : Colors.green.shade700,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Event Icon ────────────────────────────────────────────────────────────────

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
          colors: [Colors.green.shade600, Colors.green.shade800],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade300.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 28, color: Colors.white),
    );
  }
}