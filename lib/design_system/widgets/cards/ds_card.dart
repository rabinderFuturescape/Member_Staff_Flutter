import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Card variants
enum DSCardVariant {
  /// Elevated card
  elevated,
  
  /// Outlined card
  outlined,
  
  /// Filled card
  filled,
}

/// Design System Card
///
/// A customizable card component that follows the design system guidelines.
class DSCard extends StatelessWidget {
  /// The child widget
  final Widget child;
  
  /// The card variant
  final DSCardVariant variant;
  
  /// The card elevation
  final double? elevation;
  
  /// The card border radius
  final double? borderRadius;
  
  /// The card padding
  final EdgeInsets? padding;
  
  /// The card margin
  final EdgeInsets? margin;
  
  /// The card background color
  final Color? backgroundColor;
  
  /// The card border color
  final Color? borderColor;
  
  /// The card border width
  final double? borderWidth;
  
  /// The card shadow color
  final Color? shadowColor;
  
  /// The card shape
  final ShapeBorder? shape;
  
  /// The card clip behavior
  final Clip? clipBehavior;
  
  /// The on tap callback
  final VoidCallback? onTap;
  
  /// Create a design system card
  const DSCard({
    Key? key,
    required this.child,
    this.variant = DSCardVariant.elevated,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.shadowColor,
    this.shape,
    this.clipBehavior,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Get the card shape
    final ShapeBorder cardShape = shape ?? _getShape(context);
    
    // Get the card elevation
    final double cardElevation = elevation ?? _getElevation();
    
    // Get the card color
    final Color cardColor = backgroundColor ?? _getBackgroundColor(context);
    
    // Get the card shadow color
    final Color cardShadowColor = shadowColor ?? _getShadowColor(context);
    
    // Get the card padding
    final EdgeInsets cardPadding = padding ?? _getPadding();
    
    // Get the card margin
    final EdgeInsets cardMargin = margin ?? _getMargin();
    
    // Create the card
    final Widget card = Card(
      elevation: cardElevation,
      shape: cardShape,
      color: cardColor,
      shadowColor: cardShadowColor,
      margin: cardMargin,
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      child: Padding(
        padding: cardPadding,
        child: child,
      ),
    );
    
    // Wrap the card with an InkWell if onTap is provided
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? DSBorders.radiusMd),
        child: card,
      );
    }
    
    return card;
  }
  
  /// Get the card shape based on the variant
  ShapeBorder _getShape(BuildContext context) {
    // Get the border radius
    final double radius = borderRadius ?? DSBorders.radiusMd;
    
    // Get the border color
    final Color border = borderColor ?? _getBorderColor(context);
    
    // Get the border width
    final double width = borderWidth ?? _getBorderWidth();
    
    // Create the shape based on the variant
    switch (variant) {
      case DSCardVariant.elevated:
      case DSCardVariant.filled:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        );
      case DSCardVariant.outlined:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(
            color: border,
            width: width,
          ),
        );
    }
  }
  
  /// Get the card elevation based on the variant
  double _getElevation() {
    switch (variant) {
      case DSCardVariant.elevated:
        return 2;
      case DSCardVariant.outlined:
      case DSCardVariant.filled:
        return 0;
    }
  }
  
  /// Get the card background color based on the variant
  Color _getBackgroundColor(BuildContext context) {
    switch (variant) {
      case DSCardVariant.elevated:
      case DSCardVariant.outlined:
        return Theme.of(context).cardColor;
      case DSCardVariant.filled:
        return DSColors.grey100;
    }
  }
  
  /// Get the card border color based on the variant
  Color _getBorderColor(BuildContext context) {
    switch (variant) {
      case DSCardVariant.elevated:
      case DSCardVariant.filled:
        return Colors.transparent;
      case DSCardVariant.outlined:
        return DSColors.grey300;
    }
  }
  
  /// Get the card border width based on the variant
  double _getBorderWidth() {
    switch (variant) {
      case DSCardVariant.elevated:
      case DSCardVariant.filled:
        return 0;
      case DSCardVariant.outlined:
        return DSBorders.borderWidthSm;
    }
  }
  
  /// Get the card shadow color
  Color _getShadowColor(BuildContext context) {
    return Colors.black.withOpacity(0.1);
  }
  
  /// Get the card padding
  EdgeInsets _getPadding() {
    return const EdgeInsets.all(DSSpacing.md);
  }
  
  /// Get the card margin
  EdgeInsets _getMargin() {
    return const EdgeInsets.all(DSSpacing.xs);
  }
}
