import 'package:flutter/material.dart';
import '../core/core.dart';

/// Theme Preview Screen
///
/// A screen that previews the theme colors, typography, and other design system elements.
class ThemePreviewScreen extends StatelessWidget {
  /// Create a theme preview screen
  const ThemePreviewScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Theme Preview'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Colors'),
              Tab(text: 'Typography'),
              Tab(text: 'Elements'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ColorsTab(),
            _TypographyTab(),
            _ElementsTab(),
          ],
        ),
      ),
    );
  }
}

/// Colors Tab
class _ColorsTab extends StatelessWidget {
  /// Create a colors tab
  const _ColorsTab({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Primary Colors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildColorRow('Primary', DSColors.primary),
          _buildColorRow('Primary Light', DSColors.primaryLight),
          _buildColorRow('Primary Dark', DSColors.primaryDark),
          _buildColorRow('Primary Background', DSColors.primaryBackground),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Secondary Colors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildColorRow('Secondary', DSColors.secondary),
          _buildColorRow('Secondary Light', DSColors.secondaryLight),
          _buildColorRow('Secondary Dark', DSColors.secondaryDark),
          _buildColorRow('Secondary Background', DSColors.secondaryBackground),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Accent Colors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildColorRow('Accent', DSColors.accent),
          _buildColorRow('Accent Light', DSColors.accentLight),
          _buildColorRow('Accent Dark', DSColors.accentDark),
          _buildColorRow('Accent Background', DSColors.accentBackground),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Neutral Colors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildColorRow('White', DSColors.white),
          _buildColorRow('Background', DSColors.background),
          _buildColorRow('Surface', DSColors.surface),
          _buildColorRow('Grey 50', DSColors.grey50),
          _buildColorRow('Grey 100', DSColors.grey100),
          _buildColorRow('Grey 200', DSColors.grey200),
          _buildColorRow('Grey 300', DSColors.grey300),
          _buildColorRow('Grey 400', DSColors.grey400),
          _buildColorRow('Grey 500', DSColors.grey500),
          _buildColorRow('Grey 600', DSColors.grey600),
          _buildColorRow('Grey 700', DSColors.grey700),
          _buildColorRow('Grey 800', DSColors.grey800),
          _buildColorRow('Grey 900', DSColors.grey900),
          _buildColorRow('Black', DSColors.black),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Semantic Colors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildColorRow('Error', DSColors.error),
          _buildColorRow('Error Light', DSColors.errorLight),
          _buildColorRow('Error Dark', DSColors.errorDark),
          _buildColorRow('Error Background', DSColors.errorBackground),
          _buildColorRow('Success', DSColors.success),
          _buildColorRow('Success Light', DSColors.successLight),
          _buildColorRow('Success Dark', DSColors.successDark),
          _buildColorRow('Success Background', DSColors.successBackground),
          _buildColorRow('Warning', DSColors.warning),
          _buildColorRow('Warning Light', DSColors.warningLight),
          _buildColorRow('Warning Dark', DSColors.warningDark),
          _buildColorRow('Warning Background', DSColors.warningBackground),
          _buildColorRow('Info', DSColors.info),
          _buildColorRow('Info Light', DSColors.infoLight),
          _buildColorRow('Info Dark', DSColors.infoDark),
          _buildColorRow('Info Background', DSColors.infoBackground),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Status Colors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildColorRow('Pending', DSColors.pending),
          _buildColorRow('Confirmed', DSColors.confirmed),
          _buildColorRow('Cancelled', DSColors.cancelled),
          _buildColorRow('Rescheduled', DSColors.rescheduled),
          _buildColorRow('Present', DSColors.present),
          _buildColorRow('Absent', DSColors.absent),
          _buildColorRow('Mixed', DSColors.mixed),
          _buildColorRow('Paid', DSColors.paid),
          _buildColorRow('Unpaid', DSColors.unpaid),
          _buildColorRow('Partially Paid', DSColors.partiallyPaid),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Dark Theme Colors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildColorRow('Dark Background', DSColors.darkBackground),
          _buildColorRow('Dark Surface', DSColors.darkSurface),
          _buildColorRow('Dark Error', DSColors.darkError),
        ],
      ),
    );
  }
  
  /// Build a color row
  Widget _buildColorRow(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.xxs),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(DSBorders.radiusXs),
              border: Border.all(
                color: Colors.grey.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Typography Tab
class _TypographyTab extends StatelessWidget {
  /// Create a typography tab
  const _TypographyTab({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Display Styles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildTextStyleRow('Display Large', DSTypography.displayLargeStyle),
          _buildTextStyleRow('Display Medium', DSTypography.displayMediumStyle),
          _buildTextStyleRow('Display Small', DSTypography.displaySmallStyle),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Headline Styles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildTextStyleRow('Headline Large', DSTypography.headlineLargeStyle),
          _buildTextStyleRow('Headline Medium', DSTypography.headlineMediumStyle),
          _buildTextStyleRow('Headline Small', DSTypography.headlineSmallStyle),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Title Styles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildTextStyleRow('Title Large', DSTypography.titleLargeStyle),
          _buildTextStyleRow('Title Medium', DSTypography.titleMediumStyle),
          _buildTextStyleRow('Title Small', DSTypography.titleSmallStyle),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Body Styles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildTextStyleRow('Body Large', DSTypography.bodyLargeStyle),
          _buildTextStyleRow('Body Medium', DSTypography.bodyMediumStyle),
          _buildTextStyleRow('Body Small', DSTypography.bodySmallStyle),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Label Styles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildTextStyleRow('Label Large', DSTypography.labelLargeStyle),
          _buildTextStyleRow('Label Medium', DSTypography.labelMediumStyle),
          _buildTextStyleRow('Label Small', DSTypography.labelSmallStyle),
        ],
      ),
    );
  }
  
  /// Build a text style row
  Widget _buildTextStyleRow(String name, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: DSSpacing.xxs),
          Text(
            'The quick brown fox jumps over the lazy dog.',
            style: style,
          ),
          const SizedBox(height: DSSpacing.xxs),
          Text(
            'Size: ${style.fontSize}px, Weight: ${style.fontWeight}, Height: ${style.height}, Letter Spacing: ${style.letterSpacing}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

/// Elements Tab
class _ElementsTab extends StatelessWidget {
  /// Create an elements tab
  const _ElementsTab({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spacing',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildSpacingRow('XXXS (2px)', DSSpacing.xxxs),
          _buildSpacingRow('XXS (4px)', DSSpacing.xxs),
          _buildSpacingRow('XS (8px)', DSSpacing.xs),
          _buildSpacingRow('SM (12px)', DSSpacing.sm),
          _buildSpacingRow('MD (16px)', DSSpacing.md),
          _buildSpacingRow('LG (24px)', DSSpacing.lg),
          _buildSpacingRow('XL (32px)', DSSpacing.xl),
          _buildSpacingRow('XXL (48px)', DSSpacing.xxl),
          _buildSpacingRow('XXXL (64px)', DSSpacing.xxxl),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Border Radius',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildBorderRadiusRow('None (0px)', DSBorders.radiusNone),
          _buildBorderRadiusRow('XXS (2px)', DSBorders.radiusXxs),
          _buildBorderRadiusRow('XS (4px)', DSBorders.radiusXs),
          _buildBorderRadiusRow('SM (8px)', DSBorders.radiusSm),
          _buildBorderRadiusRow('MD (12px)', DSBorders.radiusMd),
          _buildBorderRadiusRow('LG (16px)', DSBorders.radiusLg),
          _buildBorderRadiusRow('XL (24px)', DSBorders.radiusXl),
          _buildBorderRadiusRow('XXL (32px)', DSBorders.radiusXxl),
          _buildBorderRadiusRow('Circular (999px)', DSBorders.radiusCircular),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Shadows',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildShadowRow('None', DSShadows.none),
          _buildShadowRow('XS', DSShadows.xs),
          _buildShadowRow('SM', DSShadows.sm),
          _buildShadowRow('MD', DSShadows.md),
          _buildShadowRow('LG', DSShadows.lg),
          _buildShadowRow('XL', DSShadows.xl),
        ],
      ),
    );
  }
  
  /// Build a spacing row
  Widget _buildSpacingRow(String name, double spacing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.xxs),
      child: Row(
        children: [
          Container(
            width: 200,
            height: spacing,
            color: DSColors.primary,
          ),
          const SizedBox(width: DSSpacing.sm),
          Text(name),
        ],
      ),
    );
  }
  
  /// Build a border radius row
  Widget _buildBorderRadiusRow(String name, double radius) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: DSColors.primary,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Text(name),
        ],
      ),
    );
  }
  
  /// Build a shadow row
  Widget _buildShadowRow(String name, List<BoxShadow> shadows) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DSBorders.radiusSm),
              boxShadow: shadows,
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Text(name),
        ],
      ),
    );
  }
}
