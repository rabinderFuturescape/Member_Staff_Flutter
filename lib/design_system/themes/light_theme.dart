import 'package:flutter/material.dart';
import '../core/core.dart';

/// Light Theme
///
/// This class defines the light theme for the application.
class LightTheme {
  // Private constructor to prevent instantiation
  LightTheme._();

  /// Get the light theme data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: DSColors.background,
      primaryColor: DSColors.primary,
      primaryColorLight: DSColors.primaryLight,
      primaryColorDark: DSColors.primaryDark,
      canvasColor: DSColors.surface,
      cardColor: DSColors.surface,
      dividerColor: DSColors.grey300,
      highlightColor: DSColors.primaryLight.withOpacity(0.1),
      splashColor: DSColors.primaryLight.withOpacity(0.1),
      unselectedWidgetColor: DSColors.grey500,
      disabledColor: DSColors.grey400,
      secondaryHeaderColor: DSColors.primaryBackground,
      dialogBackgroundColor: DSColors.surface,
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
  static const ColorScheme _colorScheme = ColorScheme.light(
    primary: DSColors.primary,
    onPrimary: DSColors.white,
    primaryContainer: DSColors.primaryBackground,
    onPrimaryContainer: DSColors.primaryDark,
    secondary: DSColors.secondary,
    onSecondary: DSColors.white,
    secondaryContainer: DSColors.secondaryBackground,
    onSecondaryContainer: DSColors.secondaryDark,
    tertiary: DSColors.accent,
    onTertiary: DSColors.white,
    tertiaryContainer: DSColors.accentBackground,
    onTertiaryContainer: DSColors.accentDark,
    error: DSColors.error,
    onError: DSColors.white,
    errorContainer: DSColors.errorBackground,
    onErrorContainer: DSColors.errorDark,
    background: DSColors.background,
    onBackground: DSColors.grey900,
    surface: DSColors.surface,
    onSurface: DSColors.grey900,
    surfaceVariant: DSColors.grey100,
    onSurfaceVariant: DSColors.grey700,
    outline: DSColors.grey300,
    outlineVariant: DSColors.grey200,
    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: DSColors.grey900,
    onInverseSurface: DSColors.white,
    inversePrimary: DSColors.primaryLight,
  );

  // Text Theme
  static final TextTheme _textTheme = TextTheme(
    displayLarge: DSTypography.displayLargeStyle,
    displayMedium: DSTypography.displayMediumStyle,
    displaySmall: DSTypography.displaySmallStyle,
    headlineLarge: DSTypography.headlineLargeStyle,
    headlineMedium: DSTypography.headlineMediumStyle,
    headlineSmall: DSTypography.headlineSmallStyle,
    titleLarge: DSTypography.titleLargeStyle,
    titleMedium: DSTypography.titleMediumStyle,
    titleSmall: DSTypography.titleSmallStyle,
    bodyLarge: DSTypography.bodyLargeStyle,
    bodyMedium: DSTypography.bodyMediumStyle,
    bodySmall: DSTypography.bodySmallStyle,
    labelLarge: DSTypography.labelLargeStyle,
    labelMedium: DSTypography.labelMediumStyle,
    labelSmall: DSTypography.labelSmallStyle,
  );

  // App Bar Theme
  static final AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: DSColors.primary,
    foregroundColor: DSColors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: DSTypography.titleLargeStyle.copyWith(
      color: DSColors.white,
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
    unselectedLabelColor: DSColors.grey600,
    indicatorColor: DSColors.primary,
    labelStyle: DSTypography.labelLargeStyle.copyWith(
      fontWeight: DSTypography.medium,
    ),
    unselectedLabelStyle: DSTypography.labelLargeStyle,
    indicatorSize: TabBarIndicatorSize.tab,
  );

  // Bottom Navigation Bar Theme
  static final BottomNavigationBarThemeData _bottomNavigationBarTheme = BottomNavigationBarThemeData(
    backgroundColor: DSColors.surface,
    selectedItemColor: DSColors.primary,
    unselectedItemColor: DSColors.grey600,
    selectedLabelStyle: DSTypography.labelSmallStyle.copyWith(
      fontWeight: DSTypography.medium,
    ),
    unselectedLabelStyle: DSTypography.labelSmallStyle,
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
      disabledForegroundColor: DSColors.grey400,
      disabledBackgroundColor: DSColors.grey200,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSBorders.radiusSm),
      ),
      padding: DSSpacing.insetHorizontalMd.add(DSSpacing.insetVerticalSm),
      textStyle: DSTypography.labelLargeStyle.copyWith(
        fontWeight: DSTypography.medium,
      ),
    ),
  );

  // Outlined Button Theme
  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: DSColors.primary,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: DSColors.grey400,
      side: const BorderSide(
        color: DSColors.primary,
        width: DSBorders.borderWidthSm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSBorders.radiusSm),
      ),
      padding: DSSpacing.insetHorizontalMd.add(DSSpacing.insetVerticalSm),
      textStyle: DSTypography.labelLargeStyle.copyWith(
        fontWeight: DSTypography.medium,
      ),
    ),
  );

  // Text Button Theme
  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: DSColors.primary,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: DSColors.grey400,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSBorders.radiusSm),
      ),
      padding: DSSpacing.insetHorizontalMd.add(DSSpacing.insetVerticalSm),
      textStyle: DSTypography.labelLargeStyle.copyWith(
        fontWeight: DSTypography.medium,
      ),
    ),
  );

  // Input Decoration Theme
  static final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: DSColors.surface,
    contentPadding: DSSpacing.insetMd,
    border: DSBorders.inputBorderNormal,
    enabledBorder: DSBorders.inputBorderNormal,
    focusedBorder: DSBorders.inputBorderFocused,
    errorBorder: DSBorders.inputBorderError,
    focusedErrorBorder: DSBorders.inputBorderError,
    disabledBorder: DSBorders.inputBorderDisabled,
    labelStyle: DSTypography.bodyMediumStyle.copyWith(
      color: DSColors.grey700,
    ),
    floatingLabelStyle: DSTypography.bodyMediumStyle.copyWith(
      color: DSColors.primary,
      fontWeight: DSTypography.medium,
    ),
    hintStyle: DSTypography.bodyMediumStyle.copyWith(
      color: DSColors.grey500,
    ),
    errorStyle: DSTypography.bodySmallStyle.copyWith(
      color: DSColors.error,
    ),
    helperStyle: DSTypography.bodySmallStyle.copyWith(
      color: DSColors.grey600,
    ),
    prefixStyle: DSTypography.bodyMediumStyle,
    suffixStyle: DSTypography.bodyMediumStyle,
    counterStyle: DSTypography.bodySmallStyle.copyWith(
      color: DSColors.grey600,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    isDense: false,
  );

  // Card Theme
  static final CardTheme _cardTheme = CardTheme(
    color: DSColors.surface,
    shadowColor: Colors.black.withOpacity(0.1),
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
    iconColor: DSColors.grey700,
    textColor: DSColors.grey900,
    titleTextStyle: TextStyle(
      fontSize: DSTypography.bodyLarge,
      fontWeight: DSTypography.regular,
      color: DSColors.grey900,
    ),
    subtitleTextStyle: TextStyle(
      fontSize: DSTypography.bodyMedium,
      fontWeight: DSTypography.regular,
      color: DSColors.grey700,
    ),
    leadingAndTrailingTextStyle: TextStyle(
      fontSize: DSTypography.bodyMedium,
      fontWeight: DSTypography.regular,
      color: DSColors.grey700,
    ),
  );

  // Divider Theme
  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: DSColors.grey300,
    thickness: 1,
    space: DSSpacing.md,
    indent: 0,
    endIndent: 0,
  );

  // Checkbox Theme
  static final CheckboxThemeData _checkboxTheme = CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return DSColors.grey300;
      }
      if (states.contains(MaterialState.selected)) {
        return DSColors.primary;
      }
      return DSColors.grey400;
    }),
    checkColor: MaterialStateProperty.all(DSColors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusXxs),
    ),
    side: const BorderSide(
      color: DSColors.grey400,
      width: DSBorders.borderWidthSm,
    ),
  );

  // Radio Theme
  static final RadioThemeData _radioTheme = RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return DSColors.grey300;
      }
      if (states.contains(MaterialState.selected)) {
        return DSColors.primary;
      }
      return DSColors.grey400;
    }),
  );

  // Switch Theme
  static final SwitchThemeData _switchTheme = SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return DSColors.grey300;
      }
      if (states.contains(MaterialState.selected)) {
        return DSColors.primary;
      }
      return DSColors.white;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return DSColors.grey200;
      }
      if (states.contains(MaterialState.selected)) {
        return DSColors.primary.withOpacity(0.5);
      }
      return DSColors.grey400;
    }),
    trackOutlineColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return DSColors.grey300;
      }
      return Colors.transparent;
    }),
  );

  // Slider Theme
  static final SliderThemeData _sliderTheme = SliderThemeData(
    activeTrackColor: DSColors.primary,
    inactiveTrackColor: DSColors.grey300,
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
    inactiveTickMarkColor: DSColors.grey400,
    valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
    valueIndicatorColor: DSColors.primary,
    valueIndicatorTextStyle: DSTypography.labelMediumStyle.copyWith(
      color: DSColors.white,
    ),
    showValueIndicator: ShowValueIndicator.onlyForDiscrete,
  );

  // Progress Indicator Theme
  static const ProgressIndicatorThemeData _progressIndicatorTheme = ProgressIndicatorThemeData(
    color: DSColors.primary,
    linearTrackColor: DSColors.grey200,
    linearMinHeight: 4,
    circularTrackColor: DSColors.grey200,
    refreshBackgroundColor: DSColors.grey100,
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
    backgroundColor: DSColors.grey900,
    contentTextStyle: DSTypography.bodyMediumStyle.copyWith(
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
    backgroundColor: DSColors.surface,
    modalBackgroundColor: DSColors.surface,
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
    backgroundColor: DSColors.surface,
    elevation: 24,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusMd),
    ),
    titleTextStyle: DSTypography.titleLargeStyle,
    contentTextStyle: DSTypography.bodyMediumStyle,
    actionsPadding: DSSpacing.insetHorizontalMd.add(DSSpacing.insetVerticalSm),
  );

  // Tooltip Theme
  static final TooltipThemeData _tooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      color: DSColors.grey900.withOpacity(0.9),
      borderRadius: BorderRadius.circular(DSBorders.radiusXs),
    ),
    textStyle: DSTypography.bodySmallStyle.copyWith(
      color: DSColors.white,
    ),
    padding: DSSpacing.insetXs,
    margin: const EdgeInsets.all(DSSpacing.xxs),
    preferBelow: true,
    verticalOffset: 0,
  );

  // Popup Menu Theme
  static final PopupMenuThemeData _popupMenuTheme = PopupMenuThemeData(
    color: DSColors.surface,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DSBorders.radiusSm),
    ),
    textStyle: DSTypography.bodyMediumStyle,
    enableFeedback: true,
  );

  // Drawer Theme
  static final DrawerThemeData _drawerTheme = DrawerThemeData(
    backgroundColor: DSColors.surface,
    elevation: 16,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(
        right: Radius.circular(DSBorders.radiusMd),
      ),
    ),
    width: 304,
  );
}
