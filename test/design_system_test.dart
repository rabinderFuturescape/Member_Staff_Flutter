import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:member_staff_app/design_system/design_system.dart';
import 'package:member_staff_app/design_system_app.dart';

void main() {
  group('Design System Core Components', () {
    test('Colors should have correct values', () {
      expect(DSColors.primary, const Color(0xFF2196F3));
      expect(DSColors.secondary, const Color(0xFF4CAF50));
      expect(DSColors.accent, const Color(0xFFFFC107));
      expect(DSColors.error, const Color(0xFFD32F2F));
    });

    test('Typography should have correct values', () {
      expect(DSTypography.primaryFontFamily, 'Roboto');
      expect(DSTypography.bodyLargeStyle.fontSize, 16.0);
      expect(DSTypography.titleLargeStyle.fontWeight, FontWeight.w500);
    });

    test('Spacing should have correct values', () {
      expect(DSSpacing.unit, 4.0);
      expect(DSSpacing.xs, 8.0);
      expect(DSSpacing.md, 16.0);
      expect(DSSpacing.xl, 32.0);
    });

    test('Borders should have correct values', () {
      expect(DSBorders.radiusSm, 8.0);
      expect(DSBorders.radiusMd, 12.0);
      expect(DSBorders.borderWidthSm, 1.0);
    });

    test('Shadows should have correct values', () {
      expect(DSShadows.none, isEmpty);
      expect(DSShadows.sm.length, 1);
      expect(DSShadows.md.length, 1);
    });

    test('Animations should have correct values', () {
      expect(DSAnimations.durationSm, const Duration(milliseconds: 150));
      expect(DSAnimations.durationMd, const Duration(milliseconds: 300));
      expect(DSAnimations.curveStandard, Curves.easeInOut);
    });
  });

  group('Design System Widgets', () {
    testWidgets('DSButton should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DSButton(
                text: 'Test Button',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('DSTextField should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DSTextField(
                labelText: 'Test Label',
                hintText: 'Test Hint',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('DSCard should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DSCard(
                child: Text('Test Card'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Card'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('Design System Providers', () {
    testWidgets('ThemeProvider should work correctly', (WidgetTester tester) async {
      late ThemeProvider themeProvider;

      await tester.pumpWidget(
        DesignSystemApp(
          child: Builder(
            builder: (context) {
              themeProvider = ThemeProvider.of(context);
              return const Text('Test');
            },
          ),
        ),
      );

      expect(themeProvider.themeMode, ThemeMode.system);
      expect(themeProvider.lightTheme, isNotNull);
      expect(themeProvider.darkTheme, isNotNull);

      themeProvider.setLightMode();
      await tester.pump();
      expect(themeProvider.themeMode, ThemeMode.light);

      themeProvider.setDarkMode();
      await tester.pump();
      expect(themeProvider.themeMode, ThemeMode.dark);

      themeProvider.setSystemMode();
      await tester.pump();
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    testWidgets('DesignSystemProvider should work correctly', (WidgetTester tester) async {
      late DesignSystemProvider designSystemProvider;

      await tester.pumpWidget(
        DesignSystemApp(
          child: Builder(
            builder: (context) {
              designSystemProvider = DesignSystemProvider.of(context);
              return const Text('Test');
            },
          ),
        ),
      );

      expect(designSystemProvider.fontSizeScale, 1.0);
      expect(designSystemProvider.animationsEnabled, true);
      expect(designSystemProvider.reducedMotion, false);
      expect(designSystemProvider.highContrast, false);

      designSystemProvider.setFontSizeScale(1.2);
      await tester.pump();
      expect(designSystemProvider.fontSizeScale, 1.2);

      designSystemProvider.setAnimationsEnabled(false);
      await tester.pump();
      expect(designSystemProvider.animationsEnabled, false);

      designSystemProvider.setReducedMotion(true);
      await tester.pump();
      expect(designSystemProvider.reducedMotion, true);

      designSystemProvider.setHighContrast(true);
      await tester.pump();
      expect(designSystemProvider.highContrast, true);
    });
  });
}
