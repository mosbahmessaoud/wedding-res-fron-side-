// lib/widgets/common/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function()? onTap;
  final int? maxLines;
  final bool enabled;
  final bool readOnly;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    Key? key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onTap,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.inputFormatters,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _focusAnimation;
  late Animation<double> _shakeAnimation;
  
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorMessage;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Listen to focus changes
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_focusNode.hasFocus) {
        _animationController.forward();
        HapticFeedback.selectionClick();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _shake() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 8, right: 4),
            child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: _isFocused ? 15 : 14,
                fontWeight: FontWeight.w600,
                color: _hasError
                    ? AppColors.error
                    : _isFocused
                        ? AppColors.primary
                        : AppColors.textPrimary,
              ),
              child: Text(widget.label),
            ),
          ),
        ],
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: _isFocused
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.black.withOpacity(0.03),
                      blurRadius: _isFocused ? 12 : 8,
                      offset: Offset(0, _isFocused ? 4 : 2),
                      spreadRadius: _isFocused ? 1 : 0,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  validator: (value) {
                    final result = widget.validator?.call(value);
                    setState(() {
                      _hasError = result != null;
                      _errorMessage = result;
                    });
                    if (_hasError) _shake();
                    return result;
                  },
                  onChanged: widget.onChanged,
                  onTap: widget.onTap,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  inputFormatters: widget.inputFormatters,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.enabled 
                        ? AppColors.textPrimary 
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.6),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: widget.prefixIcon != null
                        ? AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            margin: EdgeInsets.only(right: 12, left: 16),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _isFocused
                                  ? AppColors.primary.withOpacity(0.12)
                                  : AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              widget.prefixIcon,
                              color: _isFocused
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.7),
                              size: 22,
                            ),
                          )
                        : null,
                    suffixIcon: widget.suffixIcon,
                    filled: true,
                    fillColor: widget.enabled 
                        ? Colors.white 
                        : AppColors.surfaceLight,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: widget.maxLines == 1 ? 20 : 16,
                    ),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.error,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.error,
                        width: 2.5,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.border.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    errorStyle: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
}

// lib/widgets/common/custom_dropdown.dart
class CustomDropdown<T> extends StatefulWidget {
  final T? value;
  final String label;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final IconData? prefixIcon;
  final bool enabled;
  final String? Function(T?)? validator;

  const CustomDropdown({
    Key? key,
    this.value,
    required this.label,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.enabled = true,
    this.validator,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 8, right: 4),
            child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: _isFocused ? 15 : 14,
                fontWeight: FontWeight.w600,
                color: _hasError
                    ? AppColors.error
                    : _isFocused
                        ? AppColors.primary
                        : AppColors.textPrimary,
              ),
              child: Text(widget.label),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.black.withOpacity(0.03),
                blurRadius: _isFocused ? 12 : 8,
                offset: Offset(0, _isFocused ? 4 : 2),
                spreadRadius: _isFocused ? 1 : 0,
              ),
            ],
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            items: widget.items,
            onChanged: widget.enabled ? (value) {
              HapticFeedback.selectionClick();
              widget.onChanged(value);
            } : null,
            validator: (value) {
              final result = widget.validator?.call(value);
              setState(() {
                _hasError = result != null;
              });
              return result;
            },
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: 12, left: 16),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isFocused
                            ? AppColors.primary.withOpacity(0.12)
                            : AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.7),
                        size: 22,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: widget.enabled 
                  ? Colors.white 
                  : AppColors.surfaceLight,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.border,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 2.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.border.withOpacity(0.5),
                  width: 1,
                ),
              ),
              errorStyle: TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            dropdownColor: Colors.white,
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            icon: Container(
              margin: EdgeInsets.only(left: 12),
              child: AnimatedRotation(
                turns: _isFocused ? 0.5 : 0.0,
                duration: Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: widget.enabled 
                      ? (_isFocused ? AppColors.primary : AppColors.textSecondary)
                      : AppColors.textSecondary.withOpacity(0.5),
                  size: 24,
                ),
              ),
            ),
            isExpanded: true,
            menuMaxHeight: 300,
            onTap: () {
              setState(() {
                _isFocused = true;
              });
              _animationController.forward();
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// lib/widgets/common/loading_button.dart
class LoadingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final String? loadingText;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool enabled;

  const LoadingButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    required this.text,
    this.loadingText,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.enabled = true,
  }) : super(key: key);

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _loadingAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _pressController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(LoadingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _animationController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.enabled || widget.isLoading || widget.onPressed == null;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: (widget.backgroundColor ?? AppColors.primary)
                            .withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
            ),
            child: ElevatedButton(
              onPressed: isDisabled ? null : () {
                HapticFeedback.mediumImpact();
                widget.onPressed?.call();
              },
              onLongPress: () {
                HapticFeedback.heavyImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled
                    ? AppColors.textSecondary.withOpacity(0.3)
                    : widget.backgroundColor ?? AppColors.primary,
                foregroundColor: widget.textColor ?? Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ).copyWith(
                overlayColor: MaterialStateProperty.all(
                  Colors.white.withOpacity(0.1),
                ),
              ),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: widget.isLoading
                    ? Row(
                        key: ValueKey('loading'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.textColor ?? Colors.white,
                              ),
                            ),
                          ),
                          if (widget.loadingText != null) ...[
                            SizedBox(width: 12),
                            Text(
                              widget.loadingText!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: widget.textColor ?? Colors.white,
                              ),
                            ),
                          ],
                        ],
                      )
                    : Row(
                        key: ValueKey('normal'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 20,
                              color: widget.textColor ?? Colors.white,
                            ),
                            SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: widget.textColor ?? Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pressController.dispose();
    super.dispose();
  }
}

// lib/utils/colors.dart (Enhanced modern color scheme)
class AppColors {
  // Primary colors with modern depth
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);
  static const Color primarySurface = Color(0xFFE8F5E8);
  
  // Secondary colors
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFF80E27E);
  static const Color secondaryDark = Color(0xFF087F23);
  static const Color secondarySurface = Color(0xFFE1F5FE);
  
  // Accent colors
  static const Color accent = Color(0xFFFF9800);
  static const Color accentLight = Color(0xFFFFCC02);
  static const Color accentDark = Color(0xFFE65100);
  static const Color accentSurface = Color(0xFFFFF3E0);
  
  // Background colors with modern hierarchy
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF1F3F4);
  
  // Text colors with better contrast
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  
  // Border colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderFocus = Color(0xFFD1FAE5);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF6EE7B7);
  static const Color successDark = Color(0xFF047857);
  static const Color successSurface = Color(0xFFECFDF5);
  
  static const Color warning = Color(0xFFEAB308);
  static const Color warningLight = Color(0xFFFDE047);
  static const Color warningDark = Color(0xFFA16207);
  static const Color warningSurface = Color(0xFFFEFCE8);
  
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFfca5a5);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFEF2F2);
  
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF93C5FD);
  static const Color infoDark = Color(0xFF1E40AF);
  static const Color infoSurface = Color(0xFFEFF6FF);
  
  // Modern gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFDFDFD), Color(0xFFF8F9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, errorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Modern shadow colors
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowHeavy = Color(0x33000000);
  
  // Glass morphism effects
  static const Color glassBackground = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
}

// lib/widgets/common/modern_card.dart
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final double elevation;
  final BorderRadius? borderRadius;  // Changed to BorderRadius?
  final VoidCallback? onTap;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.elevation = 2,
    this.borderRadius,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: elevation * 4,
            offset: Offset(0, elevation),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation / 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}