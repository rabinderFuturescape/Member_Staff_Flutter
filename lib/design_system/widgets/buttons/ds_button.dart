import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Button variants
enum DSButtonVariant {
  /// Primary button
  primary,
  
  /// Secondary button
  secondary,
  
  /// Tertiary button
  tertiary,
  
  /// Danger button
  danger,
  
  /// Success button
  success,
  
  /// Warning button
  warning,
  
  /// Info button
  info,
}

/// Button sizes
enum DSButtonSize {
  /// Small button
  small,
  
  /// Medium button
  medium,
  
  /// Large button
  large,
}

/// Design System Button
///
/// A customizable button component that follows the design system guidelines.
class DSButton extends StatelessWidget {
  /// The text to display on the button
  final String text;
  
  /// The icon to display on the button
  final IconData? icon;
  
  /// The callback to call when the button is pressed
  final VoidCallback? onPressed;
  
  /// The button variant
  final DSButtonVariant variant;
  
  /// The button size
  final DSButtonSize size;
  
  /// Whether to show a loading indicator
  final bool isLoading;
  
  /// Whether the button is disabled
  final bool isDisabled;
  
  /// Whether the button is full width
  final bool isFullWidth;
  
  /// Whether the icon is on the right side
  final bool isIconRight;
  
  /// The button elevation
  final double? elevation;
  
  /// The button border radius
  final double? borderRadius;
  
  /// The button padding
  final EdgeInsets? padding;
  
  /// The button text style
  final TextStyle? textStyle;
  
  /// The button background color
  final Color? backgroundColor;
  
  /// The button foreground color
  final Color? foregroundColor;
  
  /// The button border color
  final Color? borderColor;
  
  /// The button border width
  final double? borderWidth;
  
  /// The button shape
  final OutlinedBorder? shape;
  
  /// The button shadow color
  final Color? shadowColor;
  
  /// The button minimum size
  final Size? minimumSize;
  
  /// The button maximum size
  final Size? maximumSize;
  
  /// The button side
  final BorderSide? side;
  
  /// The button visual density
  final VisualDensity? visualDensity;
  
  /// The button tap target size
  final MaterialTapTargetSize? tapTargetSize;
  
  /// The button animation duration
  final Duration? animationDuration;
  
  /// The button enable feedback
  final bool? enableFeedback;
  
  /// The button alignment
  final AlignmentGeometry? alignment;
  
  /// The button splash factory
  final InteractiveInkFeatureFactory? splashFactory;
  
  /// The button clip behavior
  final Clip? clipBehavior;
  
  /// The button focus node
  final FocusNode? focusNode;
  
  /// The button autofocus
  final bool autofocus;
  
  /// The button tooltip
  final String? tooltip;
  
  /// Create a design system button
  const DSButton({
    Key? key,
    required this.text,
    this.icon,
    this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.size = DSButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.isIconRight = false,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.shape,
    this.shadowColor,
    this.minimumSize,
    this.maximumSize,
    this.side,
    this.visualDensity,
    this.tapTargetSize,
    this.animationDuration,
    this.enableFeedback,
    this.alignment,
    this.splashFactory,
    this.clipBehavior,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Determine if the button is disabled
    final bool disabled = isDisabled || isLoading || onPressed == null;
    
    // Get the button style based on the variant and size
    final ButtonStyle buttonStyle = _getButtonStyle(context, disabled);
    
    // Create the button content
    final Widget buttonContent = _buildButtonContent(context, disabled);
    
    // Create the button
    Widget button = ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: buttonStyle,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior ?? Clip.none,
      child: buttonContent,
    );
    
    // Wrap the button with a tooltip if provided
    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    // Wrap the button with a SizedBox if full width
    if (isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }
  
  /// Build the button content
  Widget _buildButtonContent(BuildContext context, bool disabled) {
    // Get the text style based on the size
    final TextStyle style = textStyle ?? _getTextStyle(context);
    
    // Create the text widget
    final Widget textWidget = Text(
      text,
      style: style,
      overflow: TextOverflow.ellipsis,
    );
    
    // If loading, show a loading indicator
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: _getLoadingIndicatorSize(),
            height: _getLoadingIndicatorSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingIndicatorColor(context, disabled),
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          textWidget,
        ],
      );
    }
    
    // If no icon, just return the text
    if (icon == null) {
      return textWidget;
    }
    
    // Create the icon widget
    final Widget iconWidget = Icon(
      icon,
      size: _getIconSize(),
      color: _getIconColor(context, disabled),
    );
    
    // Return the icon and text in the correct order
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: isIconRight
          ? [
              textWidget,
              const SizedBox(width: DSSpacing.xs),
              iconWidget,
            ]
          : [
              iconWidget,
              const SizedBox(width: DSSpacing.xs),
              textWidget,
            ],
    );
  }
  
  /// Get the button style based on the variant and size
  ButtonStyle _getButtonStyle(BuildContext context, bool disabled) {
    // Get the colors based on the variant
    final Color bgColor = backgroundColor ?? _getBackgroundColor(context, disabled);
    final Color fgColor = foregroundColor ?? _getForegroundColor(context, disabled);
    final Color bdColor = borderColor ?? _getBorderColor(context, disabled);
    
    // Get the padding based on the size
    final EdgeInsets buttonPadding = padding ?? _getPadding();
    
    // Get the border radius
    final double radius = borderRadius ?? _getBorderRadius();
    
    // Get the border width
    final double width = borderWidth ?? _getBorderWidth();
    
    // Get the elevation
    final double buttonElevation = elevation ?? _getElevation(disabled);
    
    // Create the button style
    return ElevatedButton.styleFrom(
      foregroundColor: fgColor,
      backgroundColor: bgColor,
      disabledForegroundColor: fgColor.withOpacity(0.5),
      disabledBackgroundColor: bgColor.withOpacity(0.5),
      elevation: buttonElevation,
      shadowColor: shadowColor,
      padding: buttonPadding,
      minimumSize: minimumSize ?? _getMinimumSize(),
      maximumSize: maximumSize,
      side: side ?? BorderSide(
        color: bdColor,
        width: width,
      ),
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
    );
  }
  
  /// Get the background color based on the variant
  Color _getBackgroundColor(BuildContext context, bool disabled) {
    if (disabled) {
      return _getDisabledBackgroundColor(context);
    }
    
    switch (variant) {
      case DSButtonVariant.primary:
        return DSColors.primary;
      case DSButtonVariant.secondary:
        return DSColors.secondary;
      case DSButtonVariant.tertiary:
        return Colors.transparent;
      case DSButtonVariant.danger:
        return DSColors.error;
      case DSButtonVariant.success:
        return DSColors.success;
      case DSButtonVariant.warning:
        return DSColors.warning;
      case DSButtonVariant.info:
        return DSColors.info;
    }
  }
  
  /// Get the foreground color based on the variant
  Color _getForegroundColor(BuildContext context, bool disabled) {
    if (disabled) {
      return _getDisabledForegroundColor(context);
    }
    
    switch (variant) {
      case DSButtonVariant.primary:
      case DSButtonVariant.secondary:
      case DSButtonVariant.danger:
      case DSButtonVariant.success:
      case DSButtonVariant.warning:
      case DSButtonVariant.info:
        return DSColors.white;
      case DSButtonVariant.tertiary:
        return DSColors.primary;
    }
  }
  
  /// Get the border color based on the variant
  Color _getBorderColor(BuildContext context, bool disabled) {
    if (disabled) {
      return _getDisabledBorderColor(context);
    }
    
    switch (variant) {
      case DSButtonVariant.primary:
        return DSColors.primary;
      case DSButtonVariant.secondary:
        return DSColors.secondary;
      case DSButtonVariant.tertiary:
        return Colors.transparent;
      case DSButtonVariant.danger:
        return DSColors.error;
      case DSButtonVariant.success:
        return DSColors.success;
      case DSButtonVariant.warning:
        return DSColors.warning;
      case DSButtonVariant.info:
        return DSColors.info;
    }
  }
  
  /// Get the disabled background color
  Color _getDisabledBackgroundColor(BuildContext context) {
    switch (variant) {
      case DSButtonVariant.primary:
      case DSButtonVariant.secondary:
      case DSButtonVariant.danger:
      case DSButtonVariant.success:
      case DSButtonVariant.warning:
      case DSButtonVariant.info:
        return DSColors.grey300;
      case DSButtonVariant.tertiary:
        return Colors.transparent;
    }
  }
  
  /// Get the disabled foreground color
  Color _getDisabledForegroundColor(BuildContext context) {
    switch (variant) {
      case DSButtonVariant.primary:
      case DSButtonVariant.secondary:
      case DSButtonVariant.danger:
      case DSButtonVariant.success:
      case DSButtonVariant.warning:
      case DSButtonVariant.info:
        return DSColors.grey600;
      case DSButtonVariant.tertiary:
        return DSColors.grey600;
    }
  }
  
  /// Get the disabled border color
  Color _getDisabledBorderColor(BuildContext context) {
    switch (variant) {
      case DSButtonVariant.primary:
      case DSButtonVariant.secondary:
      case DSButtonVariant.danger:
      case DSButtonVariant.success:
      case DSButtonVariant.warning:
      case DSButtonVariant.info:
        return DSColors.grey300;
      case DSButtonVariant.tertiary:
        return Colors.transparent;
    }
  }
  
  /// Get the padding based on the size
  EdgeInsets _getPadding() {
    switch (size) {
      case DSButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: DSSpacing.sm,
          vertical: DSSpacing.xxs,
        );
      case DSButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        );
      case DSButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.sm,
        );
    }
  }
  
  /// Get the border radius based on the size
  double _getBorderRadius() {
    switch (size) {
      case DSButtonSize.small:
        return DSBorders.radiusXs;
      case DSButtonSize.medium:
        return DSBorders.radiusSm;
      case DSButtonSize.large:
        return DSBorders.radiusMd;
    }
  }
  
  /// Get the border width based on the variant
  double _getBorderWidth() {
    switch (variant) {
      case DSButtonVariant.primary:
      case DSButtonVariant.secondary:
      case DSButtonVariant.danger:
      case DSButtonVariant.success:
      case DSButtonVariant.warning:
      case DSButtonVariant.info:
        return DSBorders.borderWidthSm;
      case DSButtonVariant.tertiary:
        return 0;
    }
  }
  
  /// Get the elevation based on the variant and disabled state
  double _getElevation(bool disabled) {
    if (disabled) {
      return 0;
    }
    
    switch (variant) {
      case DSButtonVariant.primary:
      case DSButtonVariant.secondary:
      case DSButtonVariant.danger:
      case DSButtonVariant.success:
      case DSButtonVariant.warning:
      case DSButtonVariant.info:
        return 2;
      case DSButtonVariant.tertiary:
        return 0;
    }
  }
  
  /// Get the text style based on the size
  TextStyle _getTextStyle(BuildContext context) {
    switch (size) {
      case DSButtonSize.small:
        return DSTypography.labelSmallStyle.copyWith(
          fontWeight: DSTypography.medium,
        );
      case DSButtonSize.medium:
        return DSTypography.labelMediumStyle.copyWith(
          fontWeight: DSTypography.medium,
        );
      case DSButtonSize.large:
        return DSTypography.labelLargeStyle.copyWith(
          fontWeight: DSTypography.medium,
        );
    }
  }
  
  /// Get the icon size based on the button size
  double _getIconSize() {
    switch (size) {
      case DSButtonSize.small:
        return 16;
      case DSButtonSize.medium:
        return 20;
      case DSButtonSize.large:
        return 24;
    }
  }
  
  /// Get the icon color based on the variant and disabled state
  Color _getIconColor(BuildContext context, bool disabled) {
    return _getForegroundColor(context, disabled);
  }
  
  /// Get the loading indicator size based on the button size
  double _getLoadingIndicatorSize() {
    switch (size) {
      case DSButtonSize.small:
        return 12;
      case DSButtonSize.medium:
        return 16;
      case DSButtonSize.large:
        return 20;
    }
  }
  
  /// Get the loading indicator color based on the variant and disabled state
  Color _getLoadingIndicatorColor(BuildContext context, bool disabled) {
    return _getForegroundColor(context, disabled);
  }
  
  /// Get the minimum size based on the button size
  Size _getMinimumSize() {
    switch (size) {
      case DSButtonSize.small:
        return const Size(64, 32);
      case DSButtonSize.medium:
        return const Size(88, 40);
      case DSButtonSize.large:
        return const Size(120, 48);
    }
  }
}
