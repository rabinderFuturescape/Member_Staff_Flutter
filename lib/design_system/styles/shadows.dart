import 'package:flutter/material.dart';
import 'colors.dart';

/// Design system shadows
class DSShadows {
  /// No shadow
  static const List<BoxShadow> none = [];
  
  /// Extra small shadow
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: DSColors.shadow,
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
  
  /// Small shadow
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: DSColors.shadow,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  /// Medium shadow
  static const List<BoxShadow> md = [
    BoxShadow(
      color: DSColors.shadow,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  /// Large shadow
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: DSColors.shadow,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  
  /// Extra large shadow
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: DSColors.shadow,
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
}
