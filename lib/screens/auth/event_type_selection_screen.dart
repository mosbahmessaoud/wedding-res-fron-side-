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
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) => _ReviewDialog(
        onRate: (String feedback) async {
          Navigator.of(ctx).pop();
          await _markReviewDone();
          if (feedback.isNotEmpty) {
            debugPrint('User feedback: $feedback');
          }
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
  final void Function(String feedback) onRate;
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
  final TextEditingController _feedbackController = TextEditingController();

  static const List<String> _starLabels = [
    '',
    'سيئ جداً',
    '',
    '',
    '',
    'ممتاز ',
  ];

  static const List<Color> _starColors = [
    Color(0xFFEF5350),
    Color(0xBBFFFFFF),
    Color(0xBBFFFFFF),
    Color(0xBBFFFFFF),
    Color(0xFF4CAF50),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
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
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    // ── Responsive breakpoints ──────────────────────────────────────────────
    final isXSmall = sw < 320;
    final isSmallW = sw < 360;
    final isSmallH = sh < 600;
    final isTinyH  = sh < 500;

    // Sizing tokens
    final hPad        = isXSmall ? 12.0 : isSmallW ? 16.0 : 24.0;
    final vPadTop     = isTinyH  ? 14.0 : isSmallH ? 18.0 : 26.0;
    final vPadBottom  = isTinyH  ? 12.0 : 18.0;
    final sectionGap  = isTinyH  ? 10.0 : isSmallH ? 14.0 : 20.0;
    final starSize    = isXSmall ? 30.0 : isSmallW ? 36.0 : isSmallH ? 40.0 : 44.0;
    final starHPad    = isXSmall ? 2.0  : isSmallW ? 3.0  : 5.0;
    final titleFs     = isXSmall ? 16.0 : isSmallW ? 18.0 : 21.0;
    final bodyFs      = isXSmall ? 11.0 : isSmallW ? 12.0 : 14.0;
    final btnFs       = isXSmall ? 13.0 : isSmallW ? 14.0 : 16.0;
    final fieldLines  = isTinyH  ? 2     : 3;
    final btnVPad     = isTinyH  ? 10.0  : isSmallH ? 12.0 : 15.0;
    final laterVPad   = isTinyH  ? 6.0   : isSmallH ? 8.0  : 11.0;

    // Dialog horizontal inset: leave at least 20 px on each side
    final dialogHInset = (sw * 0.06).clamp(16.0, 28.0);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: dialogHInset,
          vertical: isTinyH ? 16 : 28,
        ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ConstrainedBox(
            // Never taller than 92 % of screen; never wider than 480 px
            constraints: BoxConstraints(
              maxWidth: 480,
              maxHeight: sh * 0.92,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF102714),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF2E7D32),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 48,
                    spreadRadius: 4,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: const Color(0xFF1B5E20).withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              // Wrap in SingleChildScrollView so the dialog is scrollable on
              // extremely small / landscape phones without overflowing.
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    hPad, vPadTop, hPad, vPadBottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Decorative top pill ──────────────────────────
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      SizedBox(height: sectionGap),

                      // ── Title ────────────────────────────────────────
                      Text(
                        'كيف تجد تجربتك؟',
                        style: TextStyle(
                          fontSize: titleFs,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: sectionGap * 0.45),

                      // ── Subtitle ─────────────────────────────────────
                      Text(
                        'تقييمك يساعدنا على التحسين المستمر\nويدعم التطبيق',
                        style: TextStyle(
                          fontSize: bodyFs,
                          color: const Color(0xBBFFFFFF),
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: sectionGap),

                      // ── Stars ────────────────────────────────────────
                      // Use LayoutBuilder so the 5 stars always fit within
                      // whatever width the dialog actually has on-screen.
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Available width minus dialog horizontal padding
                          final availableW = constraints.maxWidth;
                          // Each star gets 1/5 of available width, capped at
                          // starSize + 2*starHPad so large screens don't look
                          // oversized.
                          final slotW = (availableW / 5)
                              .clamp(0.0, starSize + starHPad * 2 + 4);
                          final fittedStar = (slotW - starHPad * 2)
                              .clamp(24.0, starSize);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final starIndex = index + 1;
                              final isSelected = starIndex <= _selectedStars;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedStars = starIndex),
                                behavior: HitTestBehavior.opaque,
                                child: SizedBox(
                                  width: slotW,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: AnimatedScale(
                                      scale: isSelected ? 1.12 : 1.0,
                                      duration:
                                          const Duration(milliseconds: 180),
                                      curve: Curves.easeOutBack,
                                      child: Icon(
                                        isSelected
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: fittedStar,
                                        color: isSelected
                                            ? const Color.fromARGB(
                                                179, 255, 193, 7)
                                            : const Color(0x44FFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),

                      // ── Star label ───────────────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _selectedStars > 0
                            ? Padding(
                                key: ValueKey(_selectedStars),
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _starLabels[_selectedStars],
                                  style: TextStyle(
                                    fontSize: bodyFs,
                                    fontWeight: FontWeight.w600,
                                    color: _starColors[_selectedStars - 1],
                                  ),
                                ),
                              )
                            : SizedBox(
                                key: const ValueKey(0),
                                height: isTinyH ? 0 : 4,
                              ),
                      ),

                      SizedBox(height: sectionGap * 0.85),

                      // ── Feedback field ───────────────────────────────
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1F0E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedStars > 0
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF1A3A1C),
                            width: 1.2,
                          ),
                        ),
                        child: TextField(
                          controller: _feedbackController,
                          maxLines: fieldLines,
                          maxLength: 200,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: bodyFs,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'اكتب رأيك هنا... (اختياري)',
                            hintStyle: TextStyle(
                              color: const Color(0x55FFFFFF),
                              fontSize: bodyFs,
                            ),
                            counterStyle: const TextStyle(
                              color: Color(0x44FFFFFF),
                              fontSize: 11,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: isTinyH ? 8 : 12,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      SizedBox(height: sectionGap),

                      // ── Rate button ──────────────────────────────────
                      GestureDetector(
                        onTap: _selectedStars > 0
                            ? () => widget
                                .onRate(_feedbackController.text.trim())
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: btnVPad),
                          decoration: BoxDecoration(
                            gradient: _selectedStars > 0
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF43A047),
                                      Color(0xFF1B5E20),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: _selectedStars == 0
                                ? const Color(0xFF1A3A1C)
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _selectedStars > 0
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF43A047)
                                          .withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.send_rounded,
                                color: _selectedStars > 0
                                    ? Colors.white
                                    : const Color(0x44FFFFFF),
                                size: isSmallW ? 16 : 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'إرسال التقييم',
                                style: TextStyle(
                                  fontSize: btnFs,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedStars > 0
                                      ? Colors.white
                                      : const Color(0x44FFFFFF),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isTinyH ? 4 : 8),

                      // ── Later button ─────────────────────────────────
                      GestureDetector(
                        onTap: widget.onLater,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: laterVPad,
                          ),
                          child: Text(
                            'ليس الآن',
                            style: TextStyle(
                              fontSize: bodyFs,
                              fontWeight: FontWeight.w500,
                              color: const Color(0x77FFFFFF),
                              // decoration: TextDecoration.underline,
                              decorationColor: const Color(0x44FFFFFF),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 20.0 : 32.0;

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
                        padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),

                            _AppIcon(isDark: isDark),

                            const SizedBox(height: 48),

                            Text(
                              'اختر نوع',
                              style: TextStyle(
                                fontSize: screenWidth < 360 ? 24 : 28,
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
                                fontSize: screenWidth < 360 ? 30 : 34,
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
                                fontSize: screenWidth < 360 ? 14 : 16,
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