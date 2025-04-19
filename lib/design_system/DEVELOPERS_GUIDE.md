# Design System Developer's Guide

This guide provides detailed instructions for developers on how to effectively use the design system in the Member Staff Flutter application.

## Table of Contents

- [Getting Started](#getting-started)
- [Core Components](#core-components)
- [Using UI Components](#using-ui-components)
- [Theming](#theming)
- [Responsive Design](#responsive-design)
- [Accessibility](#accessibility)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Getting Started

### Setup

The design system is already integrated into the application. To use it in your code, simply import the design system package:

```dart
import 'package:member_staff_app/design_system/design_system.dart';
```

This will give you access to all design system components, including colors, typography, spacing, and UI components.

### Design Console

The design system includes a design console that allows you to preview and experiment with all components. To launch the design console:

```dart
import 'package:member_staff_app/main.dart';

void main() {
  launchDesignConsole();
}
```

Use the design console to:
- Preview theme colors and typography
- See all available UI components
- Test different component variants and states
- Adjust design system settings like font scaling

## Core Components

### Colors

Use the predefined color palette to maintain consistency:

```dart
// Primary colors
Container(color: DSColors.primary);
Container(color: DSColors.primaryLight);
Container(color: DSColors.primaryDark);

// Semantic colors
Text('Error', style: TextStyle(color: DSColors.error));
Text('Success', style: TextStyle(color: DSColors.success));

// Status colors
Container(color: DSColors.getStatusColor('pending'));
```

### Typography

Use the predefined text styles:

```dart
Text('Heading', style: DSTypography.headlineLargeStyle);
Text('Body text', style: DSTypography.bodyMediumStyle);
Text('Button label', style: DSTypography.labelLargeStyle);
```

For dark themes, use the dark variants:

```dart
Text('Dark mode heading', style: DSTypography.headlineLargeStyleDark);
```

### Spacing

Use the predefined spacing values for consistent layout:

```dart
// Padding
Padding(padding: DSSpacing.insetMd, child: myWidget);

// Margins
Container(margin: DSSpacing.insetSm, child: myWidget);

// Gaps between elements
Column(
  children: [
    firstWidget,
    DSSpacing.gapVerticalMd,
    secondWidget,
  ],
);

Row(
  children: [
    firstWidget,
    DSSpacing.gapHorizontalSm,
    secondWidget,
  ],
);
```

### Borders

Use the predefined border styles:

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: DSBorders.borderRadiusMd,
    border: DSBorders.borderSm,
  ),
);
```

### Shadows

Use the predefined shadow styles:

```dart
Container(
  decoration: BoxDecoration(
    boxShadow: DSShadows.md,
  ),
);
```

### Animations

Use the predefined animation durations and curves:

```dart
AnimatedContainer(
  duration: DSAnimations.durationMd,
  curve: DSAnimations.curveStandard,
  // other properties
);
```

For page transitions:

```dart
Navigator.of(context).push(
  DSAnimations.fadeTransition(
    page: MyNextScreen(),
  ),
);
```

## Using UI Components

### Buttons

```dart
// Primary button
DSButton(
  text: 'Primary Button',
  onPressed: () {
    // Handle tap
  },
);

// Secondary button
DSButton(
  text: 'Secondary Button',
  variant: DSButtonVariant.secondary,
  onPressed: () {
    // Handle tap
  },
);

// Button with icon
DSButton(
  text: 'Button with Icon',
  icon: Icons.add,
  onPressed: () {
    // Handle tap
  },
);

// Button sizes
DSButton(
  text: 'Small Button',
  size: DSButtonSize.small,
  onPressed: () {},
);

// Loading state
DSButton(
  text: 'Loading',
  isLoading: true,
  onPressed: () {},
);

// Disabled state
DSButton(
  text: 'Disabled',
  isDisabled: true,
  onPressed: null,
);
```

### Text Fields

```dart
// Basic text field
DSTextField(
  labelText: 'Username',
  hintText: 'Enter your username',
  onChanged: (value) {
    // Handle text change
  },
);

// Text field variants
DSTextField(
  labelText: 'Filled Input',
  variant: DSTextFieldVariant.filled,
);

DSTextField(
  labelText: 'Underlined Input',
  variant: DSTextFieldVariant.underlined,
);

// Text field with icon
DSTextField(
  labelText: 'Search',
  prefixIcon: Icons.search,
);

// Text field with error
DSTextField(
  labelText: 'Email',
  errorText: 'Please enter a valid email',
);

// Password field
DSTextField(
  labelText: 'Password',
  obscureText: true,
  suffixIcon: Icons.visibility,
);

// Multiline text field
DSTextField(
  labelText: 'Description',
  maxLines: 5,
);
```

### Cards

```dart
// Elevated card
DSCard(
  child: Padding(
    padding: DSSpacing.insetMd,
    child: Text('Elevated Card'),
  ),
);

// Outlined card
DSCard(
  variant: DSCardVariant.outlined,
  child: Padding(
    padding: DSSpacing.insetMd,
    child: Text('Outlined Card'),
  ),
);

// Filled card
DSCard(
  variant: DSCardVariant.filled,
  child: Padding(
    padding: DSSpacing.insetMd,
    child: Text('Filled Card'),
  ),
);

// Card with tap action
DSCard(
  onTap: () {
    // Handle tap
  },
  child: Padding(
    padding: DSSpacing.insetMd,
    child: Text('Tap me'),
  ),
);
```

## Theming

### Accessing Theme

Access the current theme using the `Theme.of(context)` method:

```dart
final theme = Theme.of(context);
final primaryColor = theme.primaryColor;
final isLightTheme = theme.brightness == Brightness.light;
```

Or use the extension methods:

```dart
final isLightMode = context.isLightMode;
final isLandscape = context.isLandscape;
```

### Changing Theme

To change the theme programmatically:

```dart
final themeProvider = ThemeProvider.of(context);

// Set light theme
themeProvider.setLightMode();

// Set dark theme
themeProvider.setDarkMode();

// Set system theme (follows device settings)
themeProvider.setSystemMode();

// Toggle between light and dark
themeProvider.toggleTheme();
```

### Theme-Aware Colors

To use colors that adapt to the current theme:

```dart
final color = context.getColorByBrightness(
  DSColors.grey100,  // Light theme color
  DSColors.grey800,  // Dark theme color
);
```

Or use the AppTheme utility:

```dart
final color = AppTheme.getColorByBrightness(
  DSColors.grey100,  // Light theme color
  DSColors.grey800,  // Dark theme color
  Theme.of(context).brightness,
);
```

## Responsive Design

### Screen Size Detection

Detect the current screen size:

```dart
if (context.isSmallScreen) {
  // Use compact layout
} else if (context.isMediumScreen) {
  // Use medium layout
} else {
  // Use expanded layout
}
```

### Responsive Values

Get values based on screen size:

```dart
final padding = context.getResponsivePadding(
  defaultPadding: DSSpacing.insetMd,
  xs: DSSpacing.insetSm,
  lg: DSSpacing.insetLg,
);

final fontSize = context.getResponsiveFontSize(
  fontSize: 16.0,
  minFontSize: 14.0,
  maxFontSize: 20.0,
);

final width = context.getResponsiveWidth(
  percentageOfScreenWidth: 80,
  max: 500,
);
```

## Accessibility

### Font Scaling

The design system automatically handles font scaling based on the user's device settings. You can also adjust it programmatically:

```dart
final designSystemProvider = DesignSystemProvider.of(context);

// Increase font size
designSystemProvider.increaseFontSize();

// Decrease font size
designSystemProvider.decreaseFontSize();

// Set specific font size scale
designSystemProvider.setFontSizeScale(1.2);
```

### Reduced Motion

For users who prefer reduced motion:

```dart
final designSystemProvider = DesignSystemProvider.of(context);

// Check if reduced motion is enabled
if (designSystemProvider.reducedMotion) {
  // Use simpler animations or none at all
}

// Enable reduced motion
designSystemProvider.setReducedMotion(true);
```

### High Contrast

For users who need higher contrast:

```dart
final designSystemProvider = DesignSystemProvider.of(context);

// Check if high contrast is enabled
if (designSystemProvider.highContrast) {
  // Use high contrast colors
}

// Enable high contrast
designSystemProvider.setHighContrast(true);
```

## Best Practices

### Do's

1. **Always use design system components** instead of creating custom ones
2. **Use the predefined colors, spacing, and typography** for consistency
3. **Make your UI responsive** using the responsive utilities
4. **Consider accessibility** by supporting font scaling and reduced motion
5. **Test your UI in both light and dark themes**
6. **Use the design console** to preview and test your components

### Don'ts

1. **Don't hardcode colors, spacing, or font sizes** - use the design system values
2. **Don't create custom components** that duplicate functionality of existing ones
3. **Don't ignore accessibility** - ensure your UI works with different font sizes
4. **Don't assume a specific screen size** - make your UI responsive
5. **Don't ignore dark theme** - ensure your UI looks good in both themes

## Troubleshooting

### Common Issues

#### Components don't match the design system

Make sure you're importing the design system correctly:

```dart
import 'package:member_staff_app/design_system/design_system.dart';
```

#### Theme changes don't apply

Make sure your widget is a child of the `DesignSystemApp` widget. If you're using a custom `MaterialApp`, wrap it with `DesignSystemApp`:

```dart
DesignSystemApp(
  child: MaterialApp(
    // Your app configuration
  ),
);
```

#### Responsive utilities not working

Make sure you're using the context from a widget that's a descendant of `MaterialApp` and has access to `MediaQuery`.

#### Custom fonts not loading

Make sure the fonts are correctly defined in `pubspec.yaml` and that the font files are in the correct location.

### Getting Help

If you encounter issues not covered in this guide:

1. Check the design system tests for examples of correct usage
2. Use the design console to experiment with components
3. Review the design system source code for implementation details
4. Ask for help from the team
