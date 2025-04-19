import 'package:flutter/material.dart';

/// Responsive utilities
///
/// This class provides utilities for responsive design.
class DSResponsive {
  // Private constructor to prevent instantiation
  DSResponsive._();
  
  /// Extra small screen width breakpoint (< 600)
  static const double extraSmallScreenWidth = 600;
  
  /// Small screen width breakpoint (>= 600 && < 960)
  static const double smallScreenWidth = 960;
  
  /// Medium screen width breakpoint (>= 960 && < 1280)
  static const double mediumScreenWidth = 1280;
  
  /// Large screen width breakpoint (>= 1280 && < 1920)
  static const double largeScreenWidth = 1920;
  
  /// Extra large screen width breakpoint (>= 1920)
  static const double extraLargeScreenWidth = 1920;
  
  /// Check if the screen is extra small
  static bool isExtraSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < extraSmallScreenWidth;
  }
  
  /// Check if the screen is small
  static bool isSmallScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= extraSmallScreenWidth && width < smallScreenWidth;
  }
  
  /// Check if the screen is medium
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallScreenWidth && width < mediumScreenWidth;
  }
  
  /// Check if the screen is large
  static bool isLargeScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mediumScreenWidth && width < largeScreenWidth;
  }
  
  /// Check if the screen is extra large
  static bool isExtraLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= extraLargeScreenWidth;
  }
  
  /// Get the screen size category
  static String getScreenSizeCategory(BuildContext context) {
    if (isExtraSmallScreen(context)) {
      return 'xs';
    } else if (isSmallScreen(context)) {
      return 'sm';
    } else if (isMediumScreen(context)) {
      return 'md';
    } else if (isLargeScreen(context)) {
      return 'lg';
    } else {
      return 'xl';
    }
  }
  
  /// Get a value based on the screen size
  static T getValueForScreenSize<T>({
    required BuildContext context,
    required T defaultValue,
    T? xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
  }) {
    if (isExtraSmallScreen(context) && xs != null) {
      return xs;
    } else if (isSmallScreen(context) && sm != null) {
      return sm;
    } else if (isMediumScreen(context) && md != null) {
      return md;
    } else if (isLargeScreen(context) && lg != null) {
      return lg;
    } else if (isExtraLargeScreen(context) && xl != null) {
      return xl;
    }
    
    return defaultValue;
  }
  
  /// Get a responsive value based on the screen width
  static double getResponsiveValue({
    required BuildContext context,
    required double defaultValue,
    double? multiplier,
    double? max,
    double? min,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final actualMultiplier = multiplier ?? 0.01;
    
    final calculatedValue = defaultValue * (1 + (screenWidth / 100) * actualMultiplier);
    
    if (max != null && calculatedValue > max) {
      return max;
    }
    
    if (min != null && calculatedValue < min) {
      return min;
    }
    
    return calculatedValue;
  }
  
  /// Get a responsive font size
  static double getResponsiveFontSize({
    required BuildContext context,
    required double fontSize,
    double? minFontSize,
    double? maxFontSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Base the font size on the screen width with a reasonable scaling factor
    final calculatedFontSize = fontSize * (1 + (screenWidth - extraSmallScreenWidth) / 3000);
    
    // Apply min and max constraints if provided
    if (maxFontSize != null && calculatedFontSize > maxFontSize) {
      return maxFontSize;
    }
    
    if (minFontSize != null && calculatedFontSize < minFontSize) {
      return minFontSize;
    }
    
    return calculatedFontSize;
  }
  
  /// Get a responsive padding
  static EdgeInsets getResponsivePadding({
    required BuildContext context,
    required EdgeInsets defaultPadding,
    EdgeInsets? xs,
    EdgeInsets? sm,
    EdgeInsets? md,
    EdgeInsets? lg,
    EdgeInsets? xl,
  }) {
    return getValueForScreenSize(
      context: context,
      defaultValue: defaultPadding,
      xs: xs,
      sm: sm,
      md: md,
      lg: lg,
      xl: xl,
    );
  }
  
  /// Get a responsive margin
  static EdgeInsets getResponsiveMargin({
    required BuildContext context,
    required EdgeInsets defaultMargin,
    EdgeInsets? xs,
    EdgeInsets? sm,
    EdgeInsets? md,
    EdgeInsets? lg,
    EdgeInsets? xl,
  }) {
    return getValueForScreenSize(
      context: context,
      defaultValue: defaultMargin,
      xs: xs,
      sm: sm,
      md: md,
      lg: lg,
      xl: xl,
    );
  }
  
  /// Get a responsive width
  static double getResponsiveWidth({
    required BuildContext context,
    required double percentageOfScreenWidth,
    double? max,
    double? min,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final calculatedWidth = screenWidth * percentageOfScreenWidth / 100;
    
    if (max != null && calculatedWidth > max) {
      return max;
    }
    
    if (min != null && calculatedWidth < min) {
      return min;
    }
    
    return calculatedWidth;
  }
  
  /// Get a responsive height
  static double getResponsiveHeight({
    required BuildContext context,
    required double percentageOfScreenHeight,
    double? max,
    double? min,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final calculatedHeight = screenHeight * percentageOfScreenHeight / 100;
    
    if (max != null && calculatedHeight > max) {
      return max;
    }
    
    if (min != null && calculatedHeight < min) {
      return min;
    }
    
    return calculatedHeight;
  }
}
