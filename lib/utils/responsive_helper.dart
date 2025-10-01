import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints for different screen sizes
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double largeDesktopBreakpoint = 1440;

  // Screen type enumeration
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.largeMobile;
    } else if (width < desktopBreakpoint) {
      return ScreenType.tablet;
    } else if (width < largeDesktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  // Check if screen is mobile (including large mobile)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  // Check if screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  // Check if screen is desktop or larger
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  // Check if screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }

  // Get responsive value based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? largeMobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.largeMobile:
        return largeMobile ?? mobile;
      case ScreenType.tablet:
        return tablet ?? largeMobile ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? largeMobile ?? mobile;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? largeMobile ?? mobile;
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? largeMobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return getResponsiveValue<double>(
      context,
      mobile: mobile,
      largeMobile: largeMobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  // Get responsive padding
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? largeMobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? largeDesktop,
  }) {
    return getResponsiveValue<EdgeInsets>(
      context,
      mobile: mobile,
      largeMobile: largeMobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  // Get responsive margin
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? largeMobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? largeDesktop,
  }) {
    return getResponsiveValue<EdgeInsets>(
      context,
      mobile: mobile,
      largeMobile: largeMobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  // Get responsive width
  static double getResponsiveWidth(
    BuildContext context, {
    required double mobile,
    double? largeMobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return getResponsiveValue<double>(
      context,
      mobile: mobile,
      largeMobile: largeMobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  // Get responsive height
  static double getResponsiveHeight(
    BuildContext context, {
    required double mobile,
    double? largeMobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return getResponsiveValue<double>(
      context,
      mobile: mobile,
      largeMobile: largeMobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  // Get screen width percentage
  static double screenWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  // Get screen height percentage
  static double screenHeightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  // Get responsive columns for grid layouts
  static int getResponsiveColumns(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return 1;
      case ScreenType.largeMobile:
        return 2;
      case ScreenType.tablet:
        return 3;
      case ScreenType.desktop:
        return 4;
      case ScreenType.largeDesktop:
        return 5;
    }
  }

  // Get responsive cross axis count for grid views
  static int getResponsiveCrossAxisCount(
    BuildContext context, {
    int? mobile,
    int? largeMobile,
    int? tablet,
    int? desktop,
    int? largeDesktop,
  }) {
    return getResponsiveValue<int>(
      context,
      mobile: mobile ?? 1,
      largeMobile: largeMobile ?? 2,
      tablet: tablet ?? 3,
      desktop: desktop ?? 4,
      largeDesktop: largeDesktop ?? 5,
    );
  }

  // Get device pixel ratio
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  // Get text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  // Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // Get responsive border radius
  static BorderRadius getResponsiveBorderRadius(
    BuildContext context, {
    required double mobile,
    double? largeMobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    final radius = getResponsiveValue<double>(
      context,
      mobile: mobile,
      largeMobile: largeMobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
    return BorderRadius.circular(radius);
  }

  // Get responsive icon size
  static double getResponsiveIconSize(
    BuildContext context, {
    required double mobile,
    double? largeMobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return getResponsiveValue<double>(
      context,
      mobile: mobile,
      largeMobile: largeMobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}

// Screen type enumeration
enum ScreenType {
  mobile,          // < 480px
  largeMobile,     // 480px - 767px
  tablet,          // 768px - 1023px
  desktop,         // 1024px - 1439px
  largeDesktop,    // >= 1440px
}

// Extension for easier access to responsive helper methods
extension ResponsiveExtension on BuildContext {
  ScreenType get screenType => ResponsiveHelper.getScreenType(this);
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isLargeDesktop => ResponsiveHelper.isLargeDesktop(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);
  bool get isPortrait => ResponsiveHelper.isPortrait(this);
  
  double screenWidthPercentage(double percentage) => 
      ResponsiveHelper.screenWidthPercentage(this, percentage);
  
  double screenHeightPercentage(double percentage) => 
      ResponsiveHelper.screenHeightPercentage(this, percentage);
}

// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;
  
  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveHelper.getScreenType(context));
  }
}

// Responsive layout widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? largeMobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  
  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.largeMobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveHelper.getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.largeMobile:
        return largeMobile ?? mobile;
      case ScreenType.tablet:
        return tablet ?? largeMobile ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? largeMobile ?? mobile;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? largeMobile ?? mobile;
    }
  }
}