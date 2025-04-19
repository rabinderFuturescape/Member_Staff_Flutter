# Design System

This is a comprehensive design system for the Member Staff Flutter application. It provides a centralized way to manage design elements such as themes, colors, typography, spacing, and reusable UI components.

## Table of Contents

- [Overview](#overview)
- [Structure](#structure)
- [Usage](#usage)
- [Components](#components)
- [Customization](#customization)
- [Design Console](#design-console)

## Overview

The design system is designed to:

- Provide a consistent look and feel across the application
- Make it easy to update design elements in one place
- Provide reusable UI components that follow the design guidelines
- Support both light and dark themes
- Support accessibility features like font scaling and high contrast mode
- Provide a design console for previewing and customizing the design system

## Structure

The design system is organized into the following directories:

- `core/`: Core design system components (colors, typography, spacing, borders, shadows, animations)
- `themes/`: Theme definitions (light theme, dark theme)
- `widgets/`: Reusable UI components (buttons, inputs, cards, etc.)
- `providers/`: State management for the design system
- `assets/`: Asset management (fonts, images)
- `utils/`: Utility functions and extensions
- `console/`: Design console screens for previewing and customizing the design system

## Usage

To use the design system in your application, wrap your app with the `DesignSystemApp` widget:

```dart
void main() {
  runApp(
    DesignSystemApp(
      child: MyApp(),
    ),
  );
}
```

Then, you can use the design system components in your application:

```dart
import 'package:member_staff_app/design_system/design_system.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Widget'),
      ),
      body: Center(
        child: DSButton(
          text: 'Click Me',
          onPressed: () {
            // Do something
          },
        ),
      ),
    );
  }
}
```

## Components

The design system provides the following components:

### Core Components

- **Colors**: A comprehensive color palette for the application
- **Typography**: Text styles for different types of text
- **Spacing**: Consistent spacing values for margins, paddings, and gaps
- **Borders**: Border styles and border radius values
- **Shadows**: Shadow styles for different elevation levels
- **Animations**: Animation durations, curves, and transitions

### Widgets

- **Buttons**: Primary, secondary, tertiary, danger, success, warning, and info buttons
- **Inputs**: Text fields, text areas, and other input components
- **Cards**: Elevated, outlined, and filled cards

## Customization

The design system can be customized through the `ThemeProvider` and `DesignSystemProvider`:

```dart
// Get the theme provider
final themeProvider = ThemeProvider.of(context);

// Set the theme mode
themeProvider.setLightMode();
themeProvider.setDarkMode();
themeProvider.setSystemMode();

// Toggle between light and dark theme
themeProvider.toggleTheme();

// Get the design system provider
final designSystemProvider = DesignSystemProvider.of(context);

// Customize the font size scale
designSystemProvider.setFontSizeScale(1.2);

// Enable or disable animations
designSystemProvider.setAnimationsEnabled(true);

// Enable or disable reduced motion
designSystemProvider.setReducedMotion(false);

// Enable or disable high contrast mode
designSystemProvider.setHighContrast(false);
```

## Design Console

The design system includes a design console for previewing and customizing the design system. To launch the design console, call the `launchDesignConsole` function:

```dart
import 'package:member_staff_app/main.dart';

void main() {
  launchDesignConsole();
}
```

The design console provides the following features:

- **Theme Preview**: Preview the theme colors, typography, and other design system elements
- **Component Gallery**: Preview the design system components
- **Settings**: Customize the design system settings (font size scale, animations, etc.)
- **Theme Toggle**: Toggle between light and dark theme
