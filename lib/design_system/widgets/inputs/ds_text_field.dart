import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/core.dart';

/// Text field variants
enum DSTextFieldVariant {
  /// Outlined text field
  outlined,
  
  /// Filled text field
  filled,
  
  /// Underlined text field
  underlined,
}

/// Text field sizes
enum DSTextFieldSize {
  /// Small text field
  small,
  
  /// Medium text field
  medium,
  
  /// Large text field
  large,
}

/// Design System Text Field
///
/// A customizable text field component that follows the design system guidelines.
class DSTextField extends StatelessWidget {
  /// The controller for the text field
  final TextEditingController? controller;
  
  /// The focus node for the text field
  final FocusNode? focusNode;
  
  /// The decoration for the text field
  final InputDecoration? decoration;
  
  /// The keyboard type for the text field
  final TextInputType? keyboardType;
  
  /// The text input action for the text field
  final TextInputAction? textInputAction;
  
  /// The text style for the text field
  final TextStyle? style;
  
  /// The text align for the text field
  final TextAlign textAlign;
  
  /// The text direction for the text field
  final TextDirection? textDirection;
  
  /// The text field variant
  final DSTextFieldVariant variant;
  
  /// The text field size
  final DSTextFieldSize size;
  
  /// Whether the text field is read-only
  final bool readOnly;
  
  /// Whether the text field is enabled
  final bool enabled;
  
  /// Whether the text field is obscured
  final bool obscureText;
  
  /// Whether the text field is auto-focused
  final bool autofocus;
  
  /// Whether the text field is full width
  final bool isFullWidth;
  
  /// The max lines for the text field
  final int? maxLines;
  
  /// The min lines for the text field
  final int? minLines;
  
  /// The max length for the text field
  final int? maxLength;
  
  /// Whether to show the cursor
  final bool? showCursor;
  
  /// Whether to auto-correct
  final bool autocorrect;
  
  /// Whether to enable suggestions
  final bool enableSuggestions;
  
  /// Whether to enable interactive selection
  final bool enableInteractiveSelection;
  
  /// The input formatters for the text field
  final List<TextInputFormatter>? inputFormatters;
  
  /// The on changed callback for the text field
  final ValueChanged<String>? onChanged;
  
  /// The on submitted callback for the text field
  final ValueChanged<String>? onSubmitted;
  
  /// The on editing complete callback for the text field
  final VoidCallback? onEditingComplete;
  
  /// The on tap callback for the text field
  final GestureTapCallback? onTap;
  
  /// The validator for the text field
  final FormFieldValidator<String>? validator;
  
  /// The label text for the text field
  final String? labelText;
  
  /// The hint text for the text field
  final String? hintText;
  
  /// The helper text for the text field
  final String? helperText;
  
  /// The error text for the text field
  final String? errorText;
  
  /// The counter text for the text field
  final String? counterText;
  
  /// The prefix icon for the text field
  final IconData? prefixIcon;
  
  /// The suffix icon for the text field
  final IconData? suffixIcon;
  
  /// The prefix text for the text field
  final String? prefixText;
  
  /// The suffix text for the text field
  final String? suffixText;
  
  /// The prefix widget for the text field
  final Widget? prefix;
  
  /// The suffix widget for the text field
  final Widget? suffix;
  
  /// The border radius for the text field
  final double? borderRadius;
  
  /// The border color for the text field
  final Color? borderColor;
  
  /// The focused border color for the text field
  final Color? focusedBorderColor;
  
  /// The error border color for the text field
  final Color? errorBorderColor;
  
  /// The fill color for the text field
  final Color? fillColor;
  
  /// The cursor color for the text field
  final Color? cursorColor;
  
  /// The cursor width for the text field
  final double? cursorWidth;
  
  /// The cursor height for the text field
  final double? cursorHeight;
  
  /// The cursor radius for the text field
  final Radius? cursorRadius;
  
  /// The on tap outside callback for the text field
  final Function(PointerDownEvent)? onTapOutside;
  
  /// Create a design system text field
  const DSTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.variant = DSTextFieldVariant.outlined,
    this.size = DSTextFieldSize.medium,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
    this.autofocus = false,
    this.isFullWidth = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCursor,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enableInteractiveSelection = true,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTap,
    this.validator,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.counterText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.prefix,
    this.suffix,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.fillColor,
    this.cursorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.onTapOutside,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Create the text field
    final Widget textField = TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration ?? _getInputDecoration(context),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: style ?? _getTextStyle(context),
      textAlign: textAlign,
      textDirection: textDirection,
      readOnly: readOnly,
      enabled: enabled,
      obscureText: obscureText,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCursor: showCursor,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      enableInteractiveSelection: enableInteractiveSelection,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      onTap: onTap,
      validator: validator,
      cursorColor: cursorColor ?? Theme.of(context).primaryColor,
      cursorWidth: cursorWidth ?? 2.0,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius ?? const Radius.circular(2.0),
      onTapOutside: onTapOutside,
    );
    
    // Wrap the text field with a SizedBox if not full width
    if (!isFullWidth) {
      return SizedBox(
        width: _getWidth(),
        child: textField,
      );
    }
    
    return textField;
  }
  
  /// Get the input decoration based on the variant and size
  InputDecoration _getInputDecoration(BuildContext context) {
    // Get the content padding based on the size
    final EdgeInsets contentPadding = _getContentPadding();
    
    // Get the border radius
    final double radius = borderRadius ?? _getBorderRadius();
    
    // Get the border colors
    final Color border = borderColor ?? _getBorderColor(context);
    final Color focusedBorder = focusedBorderColor ?? _getFocusedBorderColor(context);
    final Color errorBorder = errorBorderColor ?? _getErrorBorderColor(context);
    
    // Get the fill color
    final Color fill = fillColor ?? _getFillColor(context);
    
    // Create the input decoration based on the variant
    switch (variant) {
      case DSTextFieldVariant.outlined:
        return InputDecoration(
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          counterText: counterText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          prefixText: prefixText,
          suffixText: suffixText,
          prefix: prefix,
          suffix: suffix,
          filled: true,
          fillColor: fill,
          contentPadding: contentPadding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: border,
              width: DSBorders.borderWidthSm,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: border,
              width: DSBorders.borderWidthSm,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: focusedBorder,
              width: DSBorders.borderWidthSm,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: errorBorder,
              width: DSBorders.borderWidthSm,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: errorBorder,
              width: DSBorders.borderWidthSm,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: border.withOpacity(0.5),
              width: DSBorders.borderWidthSm,
            ),
          ),
        );
      case DSTextFieldVariant.filled:
        return InputDecoration(
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          counterText: counterText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          prefixText: prefixText,
          suffixText: suffixText,
          prefix: prefix,
          suffix: suffix,
          filled: true,
          fillColor: fill,
          contentPadding: contentPadding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: focusedBorder,
              width: DSBorders.borderWidthSm,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: errorBorder,
              width: DSBorders.borderWidthSm,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: errorBorder,
              width: DSBorders.borderWidthSm,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
        );
      case DSTextFieldVariant.underlined:
        return InputDecoration(
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          counterText: counterText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          prefixText: prefixText,
          suffixText: suffixText,
          prefix: prefix,
          suffix: suffix,
          filled: false,
          contentPadding: contentPadding,
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: border,
              width: DSBorders.borderWidthSm,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: border,
              width: DSBorders.borderWidthSm,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: focusedBorder,
              width: DSBorders.borderWidthSm,
            ),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: errorBorder,
              width: DSBorders.borderWidthSm,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: errorBorder,
              width: DSBorders.borderWidthSm,
            ),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: border.withOpacity(0.5),
              width: DSBorders.borderWidthSm,
            ),
          ),
        );
    }
  }
  
  /// Get the content padding based on the size
  EdgeInsets _getContentPadding() {
    switch (size) {
      case DSTextFieldSize.small:
        return const EdgeInsets.symmetric(
          horizontal: DSSpacing.sm,
          vertical: DSSpacing.xxs,
        );
      case DSTextFieldSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        );
      case DSTextFieldSize.large:
        return const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.sm,
        );
    }
  }
  
  /// Get the border radius based on the size
  double _getBorderRadius() {
    switch (size) {
      case DSTextFieldSize.small:
        return DSBorders.radiusXs;
      case DSTextFieldSize.medium:
        return DSBorders.radiusSm;
      case DSTextFieldSize.large:
        return DSBorders.radiusMd;
    }
  }
  
  /// Get the border color
  Color _getBorderColor(BuildContext context) {
    return DSColors.grey400;
  }
  
  /// Get the focused border color
  Color _getFocusedBorderColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }
  
  /// Get the error border color
  Color _getErrorBorderColor(BuildContext context) {
    return DSColors.error;
  }
  
  /// Get the fill color
  Color _getFillColor(BuildContext context) {
    if (!enabled) {
      return DSColors.grey100;
    }
    
    switch (variant) {
      case DSTextFieldVariant.outlined:
        return Colors.transparent;
      case DSTextFieldVariant.filled:
        return DSColors.grey100;
      case DSTextFieldVariant.underlined:
        return Colors.transparent;
    }
  }
  
  /// Get the text style based on the size
  TextStyle _getTextStyle(BuildContext context) {
    switch (size) {
      case DSTextFieldSize.small:
        return DSTypography.bodySmallStyle;
      case DSTextFieldSize.medium:
        return DSTypography.bodyMediumStyle;
      case DSTextFieldSize.large:
        return DSTypography.bodyLargeStyle;
    }
  }
  
  /// Get the width based on the size
  double _getWidth() {
    switch (size) {
      case DSTextFieldSize.small:
        return 160;
      case DSTextFieldSize.medium:
        return 240;
      case DSTextFieldSize.large:
        return 320;
    }
  }
}
