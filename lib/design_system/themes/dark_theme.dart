import 'package:flutter/material.dart';
import '../core/core.dart';

/// Dark Theme
///
/// This class defines the dark theme for the application.
class DarkTheme {
  // Private constructor to prevent instantiation
  DarkTheme._();

  /// Get the dark theme data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: DSColors.darkBackground,
      primaryColor: DSColors.primary,
      primaryColorLight: DSColors.primaryLight,
      primaryColorDark: DSColors.primaryDark,
      canvasColor: DSColors.darkSurface,
      cardColor: DSColors.darkSurface,
      dividerColor: DSColors.grey700,
      highlightColor: DSColors.primaryLight.withOpacity(0.1),
      splashColor: DSColors.primaryLight.withOpacity(0.1),
      unselectedWidgetColor: DSColors.grey500,
      disabledColor: DSColors.grey600,
      secondaryHeaderColor: DSColors.grey800,
      dialogBackgroundColor: DSColors.darkSurface,
      indicatorColor: DSColors.primary,
      hintColor: DSColors.grey500,
      
      // Text Theme
      textTheme: _textTheme,
      primaryTextTheme: _textTheme,
      
      // App Bar Theme
      appBarTheme: _appBarTheme,
      
      // Tab Bar Theme
      tabBarTheme: _tabBarTheme,
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      
      // Elevated Button Theme
      elevatedButtonTheme: _elevatedButtonTheme,
      
      // Outlined Button Theme
      outlinedButtonTheme: _outlinedButtonTheme,
      
      // Text Button Theme
      textButtonTheme: _textButtonTheme,
      
      // Input Decoration Theme
      inputDecorationTheme: _inputDecorationTheme,
      
      // Card Theme
      cardTheme: _cardTheme,
      
      // List Tile Theme
      listTileTheme: _listTileTheme,
      
      // Divider Theme
      dividerTheme: _dividerTheme,
      
      // Checkbox Theme
      checkboxTheme: _checkboxTheme,
      
      // Radio Theme
      radioTheme: _radioTheme,
      
      // Switch Theme
      switchTheme: _switchTheme,
      
      // Slider Theme
      sliderTheme: _sliderTheme,
      
      // Progress Indicator Theme
      progressIndicatorTheme: _progressIndicatorTheme,
      
      // Floating Action Button Theme
      floatingActionButtonTheme: _floatingActionButtonTheme,
      
      // Snack Bar Theme
      snackBarTheme: _snackBarTheme,
      
      // Bottom Sheet Theme
      bottomSheetTheme: _bottomSheetTheme,
      
      // Dialog Theme
      dialogTheme: _dialogTheme,
      
      // Tooltip Theme
      tooltipTheme: _tooltipTheme,
      
      // Popup Menu Theme
      popupMenuTheme: _popupMenuTheme,
      
      // Drawer Theme
      drawerTheme: _drawerTheme,
    );
  }

  // Color Scheme
  static const ColorScheme _colorScheme = ColorScheme.dark(
    primary: DSColors.primary,
    onPrimary: DSColors.white,
    primaryContainer: DSColors.primaryDark,
    onPrimaryContainer: DSColors.white,
    secondary: DSColors.secondary,
    onSecondary: DSColors.white,
    secondaryContainer: DSColors.secondaryDark,
    onSecondaryContainer: DSColors.white,
    tertiary: DSColors.accent,
    onTertiary: DSColors.white,
    tertiaryContainer: DSColors.accentDark,
    onTertiaryContainer: DSColors.white,
    error: DSColors.darkError,
    onError: DSColors.white,
    errorContainer: DSColors.errorDark,
    onErrorContainer: DSColors.white,
    background: DSColors.darkBackground,
    onBackground: DSColors.white,
    surface: DSColors.darkSurface,
    onSurface: DSColors.white,
    surfaceVariant: DSColors.grey800,
    onSurfaceVariant: DSColors.grey300,
    outline: DSColors.grey700,
    outlineVariant: DSColors.grey800,
    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: DSColors.grey100,
    onInverseSurface: DSColors.grey900,
    inversePrimary: DSColors.primaryDark,
  );

  // Text Theme
  static final TextTheme _textTheme = TextTheme(
    displayLarge: DSTypography.displayLargeStyleDark,
    displayMedium: DSTypography.displayMediumStyleDark,
    displaySmall: DSTypography.displaySmallStyleDark,
    headlineLarge: DSTypography.headlineLargeStyleDark,
    headlineMedium: DSTypography.headlineMediumStyleDark,
    headlineSmall: DSTypography.headlineSmallStyleDark,
    titleLarge: DSTypography.titleLargeStyleDark,
    titleMedium: DSTypography.titleMediumStyleDark,
    titleSmall: DSTypography.titleSmallStyleDark,
    bodyLarge: DSTypography.bodyLargeStyleDark,
    bodyMedium: DSTypography.bodyMediumStyleDark,
    bodySmall: DSTypography.bodySmallStyleDark,
    labelLarge: DSTypography.labelLargeStyleDark,
    labelMedium: DSTypography.labelMediumStyleDark,
    labelSmall: DSTypography.labelSmallStyleDark,
  );

  // App Bar Theme
  static final AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: DSColors.darkSurface,
    foregroundColor: DSColors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: DSTypography.titleLargeStyleDark.copyWith(
      fontWeight: DSTypography.medium,
    ),
    iconTheme: const IconThemeData(
      color: DSColors.white,
    ),
    actionsIconTheme: const IconThemeData(
      color: DSColors.white,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(DSBorders.radiusSm),
      ),
    ),
  );

  // Tab Bar Theme
  static final TabBarTheme _tabBarTheme = TabBarTheme(
    labelColor: DSColors.primary,
    unselectedLabelColor: DSColors.grey400,
    indicatorColor: DSColors.primary,
    labelStyle: DSTypography.labelLargeStyleDark.copyWith(
      fontWeight: DSTypography.medium,
    ),
    unselectedLabelStyle: DSTypography.labelLargeStyleDark,
    indicatorSize: TabBarIndicatorSize.tab,
  );

  // Bottom Navigation Bar Theme
  static final BottomNavigationBarThemeData _bottomNavigationBarTheme = BottomNavigationBarThemeData(
    backgroundColor: DSColors.darkSurface,
    selectedItemColor: DSColors.primary,
    unselectedItemColor: DSColors.grey400,
    selectedLabelStyle: DSTypography.labelSmallStyleDark.copyWith(
      fontWeight: DSTypography.medium,
    ),
    unselectedLabelStyle: DSTypography.labelSmallStyleDark,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  // Elevated Button Theme
  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: DSColors.white,
      backgroundColor: DSColors.primary,
      disabledForegroundColor: DSColors.grey600,
      disabledBackgroundColor: DSColors.grey800,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSBorders.radiusSm),
      ),
      padding: DSSpacing.insetHorizontalMd.add(DSSpacing.insetVerticalSm),
      textStyle: DSTypography.labelLargeStyleDark.copyWith(
        fontWeight: DSTypography.medium,
      ),
    ),
  );

  // Outlined Button Theme
  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: DSColors.primary,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: DSColors.grey600,
      side: const BorderSide(
        color: DSColors.primary,
        width: DSBorders.borderWidthSm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSBorders.radiusSm),
      ),
      padding: DSSpacing.insetHorizontalMd.add(DSSpacing.insetVerticalSm),
      textStyle: DSTypography.labelLargeStyleDark.copyWith(
        fontWeight: DSTypography.medium,
      ),
    ),
  );

  // Text Button Theme
  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: DSColors.primary,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: DSColors.grey600,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSBorders.radiusSm),
      ),
      padding: DSSpacing.insetHorizontalMd.add(DSSpacing.insetVerticalSm),
      textStyle: DSTypography.labelLargeStyleDark.copyWith(
        fontWeight: DSTypography.medium,
      ),
    ),
  );

  // Input Decoration Theme
  static final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: DSColors.grey800,
    contentPadding: DSSpacing.insetMd,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusSm),
      borderSide: const BorderSide(
        color: DSColors.grey700,
        width: DSBorders.borderWidthSm,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusSm),
      borderSide: const BorderSide(
        color: DSColors.grey700,
        width: DSBorders.borderWidthSm,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusSm),
      borderSide: const BorderSide(
        color: DSColors.primary,
        width: DSBorders.borderWidthSm,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusSm),
      borderSide: const BorderSide(
        color: DSColors.darkError,
        width: DSBorders.borderWidthSm,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusSm),
      borderSide: const BorderSide(
        color: DSColors.darkError,
        width: DSBorders.borderWidthSm,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusSm),
      borderSide: BorderSide(
        color: DSColors.grey700.withOpacity(0.5),
        width: DSBorders.borderWidthSm,
      ),
    ),
    labelStyle: DSTypography.bodyMediumStyleDark.copyWith(
      color: DSColors.grey300,
    ),
    floatingLabelStyle: DSTypography.bodyMediumStyleDark.copyWith(
      color: DSColors.primary,
      fontWeight: DSTypography.medium,
    ),
    hintStyle: DSTypography.bodyMediumStyleDark.copyWith(
      color: DSColors.grey500,
    ),
    errorStyle: DSTypography.bodySmallStyleDark.copyWith(
      color: DSColors.darkError,
    ),
    helperStyle: DSTypography.bodySmallStyleDark.copyWith(
      color: DSColors.grey400,
    ),
    prefixStyle: DSTypography.bodyMediumStyleDark,
    suffixStyle: DSTypography.bodyMediumStyleDark,
    counterStyle: DSTypography.bodySmallStyleDark.copyWith(
      color: DSColors.grey400,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    isDense: false,
  );

  // Card Theme
  static final CardTheme _cardTheme = CardTheme(
    color: DSColors.darkSurface,
    shadowColor: Colors.black.withOpacity(0.3),
    elevation: 2,
    margin: DSSpacing.insetXs,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusMd),
    ),
    clipBehavior: Clip.antiAlias,
  );

  // List Tile Theme
  static const ListTileThemeData _listTileTheme = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(
      horizontal: DSSpacing.md,
      vertical: DSSpacing.xs,
    ),
    minLeadingWidth: 24,
    minVerticalPadding: DSSpacing.xs,
    dense: false,
    enableFeedback: true,
    iconColor: DSColors.grey300,
    textColor: DSColors.white,
    titleTextStyle: TextStyle(
      fontSize: DSTypography.bodyLarge,
      fontWeight: DSTypography.regular,
      color: DSColors.white,
    ),
    subtitleTextStyle: TextStyle(
      fontSize: DSTypography.bodyMedium,
      fontWeight: DSTypography.regular,
      color: DSColors.grey300,
    ),
    leadingAndTrailingTextStyle: TextStyle(
      fontSize: DSTypography.bodyMedium,
      fontWeight: DSTypography.regular,
      color: DSColors.grey300,
    ),
  );

  // Divider Theme
  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: DSColors.grey700,
    thickness: 1,
    space: DSSpacing.md,
    indent: 0,
    endIndent: 0,
  );

  // Checkbox Theme
  static final CheckboxThemeData _checkboxTheme = CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return DSColors.grey700;
      }
      if (states.contains(MaterialState.selected)) {
        return DSColors.primary;
      }
      return DSColors.grey600;
    }),
    checkColor: MaterialStateProperty.all(DSColors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusXxs),
    ),
    side: const BorderSide(
      color: DSColors.grey600,
      width: DSBorders.borderWidthSm,
    ),
  );

  // Radio Theme
  static final RadioThemeData _radioTheme = RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return DSColors.grey700;
      }
      if (states.contains(MaterialState.selected)) {
        return DSColors.primary;
      }
      return DSColors.grey600;
    }),
  );

  // Switch Theme
  static final SwitchThemeData _switchTheme = SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return DSColors.grey700;
      }
      if (states.contains(MaterialState.selected)) {
        return DSColors.primary;
      }
      return DSColors.grey300;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return DSColors.grey800;
      }
      if (states.contains(MaterialState.selected)) {
        return DSColors.primary.withOpacity(0.5);
      }
      return DSColors.grey600;
    }),
    trackOutlineColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return DSColors.grey700;
      }
      return Colors.transparent;
    }),
  );

  // Slider Theme
  static final SliderThemeData _sliderTheme = SliderThemeData(
    activeTrackColor: DSColors.primary,
    inactiveTrackColor: DSColors.grey700,
    thumbColor: DSColors.primary,
    overlayColor: DSColors.primary.withOpacity(0.2),
    trackHeight: 4,
    thumbShape: const RoundSliderThumbShape(
      enabledThumbRadius: 10,
    ),
    overlayShape: const RoundSliderOverlayShape(
      overlayRadius: 20,
    ),
    tickMarkShape: const RoundSliderTickMarkShape(
      tickMarkRadius: 2,
    ),
    activeTickMarkColor: DSColors.white,
    inactiveTickMarkColor: DSColors.grey600,
    valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
    valueIndicatorColor: DSColors.primary,
    valueIndicatorTextStyle: DSTypography.labelMediumStyleDark.copyWith(
      color: DSColors.white,
    ),
    showValueIndicator: ShowValueIndicator.onlyForDiscrete,
  );

  // Progress Indicator Theme
  static const ProgressIndicatorThemeData _progressIndicatorTheme = ProgressIndicatorThemeData(
    color: DSColors.primary,
    linearTrackColor: DSColors.grey800,
    linearMinHeight: 4,
    circularTrackColor: DSColors.grey800,
    refreshBackgroundColor: DSColors.grey900,
  );

  // Floating Action Button Theme
  static final FloatingActionButtonThemeData _floatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: DSColors.primary,
    foregroundColor: DSColors.white,
    elevation: 6,
    highlightElevation: 12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusCircular),
    ),
    enableFeedback: true,
  );

  // Snack Bar Theme
  static final SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    backgroundColor: DSColors.grey800,
    contentTextStyle: DSTypography.bodyMediumStyleDark.copyWith(
      color: DSColors.white,
    ),
    actionTextColor: DSColors.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusSm),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 6,
  );

  // Bottom Sheet Theme
  static final BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: DSColors.darkSurface,
    modalBackgroundColor: DSColors.darkSurface,
    elevation: 8,
    modalElevation: 16,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(DSBorders.radiusLg),
      ),
    ),
    clipBehavior: Clip.antiAlias,
  );

  // Dialog Theme
  static final DialogTheme _dialogTheme = DialogTheme(
    backgroundColor: DSColors.darkSurface,
    elevation: 24,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusMd),
    ),
    titleTextStyle: DSTypography.titleLargeStyleDark,
    contentTextStyle: DSTypography.bodyMediumStyleDark,
    actionsPadding: DSSpacing.insetHorizontalMd.add(DSSpacing.insetVerticalSm),
  );

  // Tooltip Theme
  static final TooltipThemeData _tooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      color: DSColors.grey100.withOpacity(0.9),
      borderRadius: BorderRadius.circular(DSBorders.radiusXs),
    ),
    textStyle: DSTypography.bodySmallStyle.copyWith(
      color: DSColors.grey900,
    ),
    padding: DSSpacing.insetXs,
    margin: const EdgeInsets.all(DSSpacing.xxs),
    preferBelow: true,
    verticalOffset: 0,
  );

  // Popup Menu Theme
  static final PopupMenuThemeData _popupMenuTheme = PopupMenuThemeData(
    color: DSColors.darkSurface,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusSm),
    ),
    textStyle: DSTypography.bodyMediumStyleDark,
    enableFeedback: true,
  );

  // Drawer Theme
  static final DrawerThemeData _drawerTheme = DrawerThemeData(
    backgroundColor: DSColors.darkSurface,
    elevation: 16,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(
        right: Radius.circular(DSBorders.radiusMd),
      ),
    ),
    width: 304,
  );
}
